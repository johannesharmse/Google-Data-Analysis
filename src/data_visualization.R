# DOCUMENTATION: 
# 
# The purpose of this script is to visualise personal Google location data and Google browser history.
# 
# The script can be cusomised by changing the argument values within the saveHTML function at the end of this script. 
# The saveHTML function mainly relies on the plot_map function.
# 
# The following arguments can be specified for the plot_map function. Type ?saveHTML to view other arguments eligible for change.
#
# location: Character string. Search term for the location that you want visualised. Google API is used to perform the search for the location.
# 
# zoom: Integer (default = 10). The zoom factor for the location map. The zoom value has to be within the range 3-21, 
# where 3 is typically continent view and 21 is typically building view.
# 
# location_summary: Dataframe (default = data frame loaded from data cleaning step). 
# This refers to the location summarised data that will be mapped. It is not recommended to change this.
# 
# browse_summary: Dataframe (default = data frame loaded from data cleaning step).
# This refers to the browser history summarised data that will be used to visualise search terms. 
# It is not recommended to change this.
# 
# plot_period: Character string (default = "weekly"). Choose from c("daily", "weekly", "annually"). 
# This specifies the plotting period for the location points and search term analysis.
# 
# alpha: Numerical between 0 and 1 (default = 0.2). The transparency value for the location points visualised.
# 
# stop_words_dir: Character string (default: "../data/additional/stopwords.csv"). 
# Specifies the csv file location relative to the working directory for stop words not to be used in Google Search term analysis.
# It is not recommended to change this location, but rather add on stop words within this file if desired.
#
# n_words: Integer (default = 10). The number of most popular search terms to report on.
# 
# 
# 
# The saveHTML function generates an HMTL animation by creating a number of plots and then calling each plot image from an HTML file.
# The folder and file locations, animation interval, height and width can be specified in the saveHTML function. 
# Try ?saveHTML for more information on this function.


library(tidyverse)
library(lubridate)
library(gganimate)
library(ggmap)
library(animation)
# library(NLP)
library(stringr)
library(png)
library(grid)
library(cowplot)

# load cleaned datasets

browse_summary <- readRDS(file = "../data/R_temp/browse_summary.rds")
location_summary <- readRDS(file = "../data/R_temp/location_summary.rds")

# Function for plotting daily, weekly and annual location data points

plot_map <- function(location, zoom = 10, location_summary, browse_summary, plot_period = "weekly", alpha = 0.2, 
                     stop_words_dir = "../data/additional/stopwords.csv", n_words = 10, search_filter = c("Google Search")){
  
  # make search term lower case for more dynamic string detection and filtering
   
  search_filter_filter = tolower(paste0(" - ", search_filter, "$", collapse = "|"))
  search_filter_sub = tolower(paste0(" - ", search_filter, collapse = "|"))
  
  # stop word document used for eliminating words from analysis
  
  stop_words <- read_csv(stop_words_dir)
  stops <- paste0(stop_words$words, collapse = "\\>|\\<")
  stops <- paste0("\\<", stops, "\\>")
  
  # filter for Google Search and cleaning
  
  browse_summary <- browse_summary %>% 
    mutate(title = tolower(title)) %>% 
    filter(str_detect(title, search_filter_filter)) %>% 
    mutate(title = str_sub(title, 1, 
                           str_locate(title, search_filter_sub)[ ,1] - 1), 
           words = NA) %>% 
    distinct(ymd = str_sub(time, 1, 13), title, .keep_all = TRUE)# %>% 
    # group_by(time) %>% 
  
  # remove stop words (temp loop for bug)
  
  for (row in 1:nrow(browse_summary)){
    
    temp = list(unlist(strsplit(unlist(browse_summary[row, "title"]), split = " "))[!grepl(stops, unlist(strsplit(unlist(browse_summary[row, "title"]), split = " ")), fixed = FALSE)])  
    
    if(length(unlist(temp)) > 0){
      browse_summary[[row, "words"]] = temp
    }
    
  }
    browse_summary$ymd = NULL
  
  
  # identify the top words that the user searches for
  
  top_words <- as_data_frame(table(unlist(browse_summary$words))) %>% 
    top_n(n, n = n_words)
  
  # use Google API to retrieve map of location
  
  mapData <- get_googlemap(location, zoom = zoom)
  
  # refit borders for optimal visualization
  
  borders <- attr(mapData, which = "bb")
  
  if (borders$ll.lon == borders$ur.lon){
    borders$ll.lon == borders$ll.lon - 0.05
    borders$ur.lon == borders$ur.lon + 0.05
  }else{
    borders$ll.lat == borders$ll.lat - 0.05
    borders$ur.lat == borders$ur.lat + 0.05
  }
  
  location_summary <- location_summary %>% 
    filter(long <= borders$ur.lon & 
             long >= borders$ll.lon & 
             lat <= borders$ur.lat & 
             lat >= borders$ll.lat)
  
  center <- c(median(location_summary$long), median(location_summary$lat))
  
  
  # retrieve re-fitted map using Google API
  
  mapplot <- ggmap(get_googlemap(center = center, zoom = zoom), extent = "device")
  
  # set aesthetics for map
  
  lon_breaks <- mapplot$data$lon
  lat_breaks <- mapplot$data$lat
  
  mapplot <- mapplot + 
      theme(axis.line=element_blank(), 
            axis.text.x=element_blank(),
            axis.text.y=element_blank(), 
            axis.ticks=element_blank(),
            axis.title.x=element_blank(),
            axis.title.y=element_blank())
  
  
  # save map as image file that will be re-used to prevent exausting query limit
  
  png(filename = "../results/base_map.png")
  print(mapplot)
  dev.off()
  
  # plot image as backdrop for visualizations
  
  base_map <- readPNG(source = "../results/base_map.png")
  ggmapdata <- rasterGrob(base_map, interpolate=TRUE)
  
  ggmapdata <- qplot(x = lon_breaks, 
        y = lat_breaks, 
        xlim = c(min(lon_breaks), max(lon_breaks)), 
        ylim = c(min(lat_breaks), max(lat_breaks)), 
        geom="blank") +
    annotation_custom(ggmapdata, xmin=-Inf, xmax=Inf, ymin=-Inf, ymax=Inf)
  
  
  # declare variables for looping over time range
  
  temp_filt <- location_summary
  
  start = 1
  start_plot = 1
  lat_start = 0
  long_start = 0
  
  temp = data_frame()
  
  p <- ggmapdata
  
  # declare seperate processes for differnt time period types to speed up time complexity
  # enter process if a cycle of a day, week or year has been identified
  
  if (plot_period == "daily"){
    for (count in 1:nrow(temp_filt)){
      if(interval(temp_filt$time[start], temp_filt$time[count])/ddays(1) >= 1){
        
        # check which search terms have occurred in time period
        word_occurances <- unlist(browse_summary %>% 
                                    filter(time >= temp_filt$time[start] & 
                                             time <= temp_filt$time[count]) %>% 
                                    select(words))
        
        # count occurances of each search word
        word_occurances <- unlist(table(word_occurances))

        # declare new data frame for top search words
        tops <- data_frame(cats = top_words$Var1)
        
        # count how many times top search words occurred within given time range
        tops$freq <- sapply(1:nrow(tops), function(x, y, z) 
          if_else(any(names(y) %in% z[x, "cats"]), as.numeric(y[unlist(z[x, "cats"])]), 0), 
          y = word_occurances, z = tops)
        
        # declare location plot
        p <- ggmapdata + 
          geom_point(data = temp_filt[1:count, ], aes(x = long, 
                                                      y = lat), 
                     fill = "light blue", size = 2, alpha = alpha,
                     colour = "blue") + 
          geom_point(data = temp_filt[count, ], aes(x = long, 
                                                    y = lat), 
                     alpha = 0.5, fill = "red", size = 3, colour = "red") + 
          labs(title = paste0(location, " - Period: ", as.character(substr(temp_filt$time[start], 1, 10)), "-", 
                              as.character(substr(temp_filt$time[count], 1, 10))), 
               x = "Longitude", 
               y = "Latitude")
        
        # declare top word frequency plot
        word_freq <- ggplot(data = tops, aes(x = cats, y = freq, fill = factor(cats))) + 
          geom_col() + 
          theme(axis.ticks.x =element_blank(), axis.text.x=element_blank()) + 
          labs(x = "Search terms", y = "Frequency") + 
          scale_fill_discrete("")
        
        # print two plots on grid to form one image
        grid.newpage()
        pushViewport(viewport(layout = grid.layout(1, 2), width = 1, height = 0.5))
        print(p, vp = viewport(layout.pos.row = 1, layout.pos.col = 1))
        print(word_freq, vp = viewport(layout.pos.row = 1, layout.pos.col = 2))
        
        # skip loop count to end of current period
        start = count
        
      }
    }
  }else if (plot_period == "weekly"){ # same process as daily
    for (count in 2:nrow(temp_filt)){
      if(interval(temp_filt$time[start], temp_filt$time[count])/dweeks(1) >= 1){
        
        word_occurances <- unlist(browse_summary %>% 
                          filter(time >= temp_filt$time[start] & 
                                   time <= temp_filt$time[count]) %>% 
                          select(words))
        
        word_occurances <- unlist(table(word_occurances))
        
        tops <- data_frame(cats = top_words$Var1)
        
        tops$freq <- sapply(1:nrow(tops), function(x, y, z) 
          if_else(any(names(y) %in% z[x, "cats"]), as.numeric(y[unlist(z[x, "cats"])]), 0), 
          y = word_occurances, z = tops)
        
        p <- ggmapdata + 
          geom_point(data = temp_filt[1:count, ], aes(x = long, 
                                                      y = lat), 
                     fill = "light blue", size = 2, alpha = alpha,
                     colour = "blue") + 
          geom_point(data = temp_filt[count, ], aes(x = long, 
                                                    y = lat), 
                     alpha = 0.5, fill = "red", size = 3, colour = "red") + 
          labs(title = paste0(location, " - Period: ", as.character(substr(temp_filt$time[start], 1, 10)), "-", 
                              as.character(substr(temp_filt$time[count], 1, 10))), 
               x = "Longitude", 
               y = "Latitude")
        
        word_freq <- ggplot(data = tops, aes(x = cats, y = freq, fill = factor(cats))) + 
          geom_col() + 
          theme(axis.ticks.x =element_blank(), axis.text.x=element_blank()) + 
          labs(x = "Search terms", y = "Frequency") + 
          scale_fill_discrete("")
        
        grid.newpage()
        pushViewport(viewport(layout = grid.layout(1, 2), width = 1, height = 0.5))
        print(p, vp = viewport(layout.pos.row = 1, layout.pos.col = 1))
        print(word_freq, vp = viewport(layout.pos.row = 1, layout.pos.col = 2))
        
        start = count
        
      }
    }
  }else if (plot_period == "annually"){ # same process as daily
    for (count in 1:nrow(temp_filt)){
      if(interval(temp_filt$time[start], temp_filt$time[count])/dyears(1) >= 1){
        
        word_occurances <- unlist(browse_summary %>% 
                                    filter(time >= temp_filt$time[start] & 
                                             time <= temp_filt$time[count]) %>% 
                                    select(words))
        
        word_occurances <- unlist(table(word_occurances))

        
        tops <- data_frame(cats = top_words$Var1)
        
        tops$freq <- sapply(1:nrow(tops), function(x, y, z) 
          if_else(any(names(y) %in% z[x, "cats"]), as.numeric(y[unlist(z[x, "cats"])]), 0), 
          y = word_occurances, z = tops)
        
        p <- ggmapdata + 
          geom_point(data = temp_filt[1:count, ], aes(x = long, 
                                                      y = lat), 
                     fill = "light blue", size = 2, alpha = alpha,
                     colour = "blue") + 
          geom_point(data = temp_filt[count, ], aes(x = long, 
                                                    y = lat), 
                     alpha = 0.5, fill = "red", size = 3, colour = "red") + 
          labs(title = paste0(location, " - Period: ", as.character(substr(temp_filt$time[start], 1, 10)), "-", 
                              as.character(substr(temp_filt$time[count], 1, 10))), 
               x = "Longitude", 
               y = "Latitude")
        
        word_freq <- ggplot(data = tops, aes(x = cats, y = freq, fill = factor(cats))) + 
          geom_col() + 
          theme(axis.ticks.x =element_blank(), axis.text.x=element_blank()) + 
          labs(x = "Search terms", y = "Frequency") + 
          scale_fill_discrete("")
        
        grid.newpage()
        pushViewport(viewport(layout = grid.layout(1, 2), width = 1, height = 0.5))
        print(p, vp = viewport(layout.pos.row = 1, layout.pos.col = 1))
        print(word_freq, vp = viewport(layout.pos.row = 1, layout.pos.col = 2))
        
        start = count
        
      }
    }
  }
  
}


# turn device off if it is on
if (!is.null(dev.list())){
  dev.off()
}

# remove (if necessary), then generate and write plots to HTML GIF

do.call(try(file.remove), list(list.files("../results/anim_dir", full.names = TRUE)))

# specify user requirements within saveHTML function
# zoom value should be between 3 and 21. (3 = continent, 21 = building)

saveHTML({plot_map(location = "UBC", zoom = 11, alpha = 0.1,
                   location_summary = location_summary, browse_summary = browse_summary, 
                   plot_period = "weekly", search_filter = c("YouTube"))}, 
         img.name = "anim_plot", imgdir = "../results/anim_dir", 
         htmlfile = "../results/anim.html", autobrowse = FALSE, title = "Google Location Data", 
         verbose =FALSE, interval = 1, ani.width = 720, ani.height = 720)

# prevent from plotting
graphics.off()

