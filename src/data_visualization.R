library(tidyverse)
library(lubridate)
# library(forcats)
# devtools::install_github("dgrtwo/gganimate")
library(gganimate)
library(ggmap)
library(animation)
# library(NLP)
library(stringr)
library(png)
library(grid)
library(cowplot)


browse_summary <- readRDS(file = "../data/R_temp/browse_summary.rds")
location_summary <- readRDS(file = "../data/R_temp/location_summary.rds")

# Function for plotting daily, weekly and annual location data points

plot_map <- function(location, zoom = 10, location_summary, browse_summary, period = 10, plot_period = "daily", alpha = 0.2, 
                     stop_words_url = "../data/additional/stopwords.csv", n_words = 10){
  
  
  stop_words <- read_csv(stop_words_url)
  
  # filter for Google Search and cleaning
  
  browse_summary <- browse_summary %>% 
    filter(str_detect(title, " - Google Search$")) %>% 
    mutate(title = str_sub(title, 1, str_locate(title, " - Google Search")[ ,1] - 1)) %>% 
    distinct(ymd = str_sub(time, 1, 13), title, .keep_all = TRUE) %>% 
    group_by(time) %>% 
    mutate(words = list(words = unlist(str_split(title, pattern = " "))[!(unlist(str_split(title, pattern = " ")) %in% unlist(stop_words$words))]), 
           ymd = NULL)
  
  top_words <- as_data_frame(table(unlist(browse_summary$words))) %>% 
    top_n(n, n = n_words)
    # top_n(10, beta) %>%
    # ungroup() %>%
    # arrange(topic, -beta)
  
  # location_summary <- location_summary
  
  mapData <- get_googlemap(location, zoom = zoom)
  
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
  
  # zoom <- floor(10/max((max(location_summary$long) - min(location_summary$long)/(borders$ur.lon - borders$ll.lon)), 
  #              (max(location_summary$lat) - min(location_summary$lat))/(borders$ur.lat - borders$ll.lat)))
  
  # center <- c(min(location_summary$long) + (max(location_summary$long) - min(location_summary$long))/2, 
  #            min(location_summary$lat) + (max(location_summary$lat) - min(location_summary$lat))/2)
  
  center <- c(median(location_summary$long), median(location_summary$lat))
  
  # mapData <- get_googlemap(center = center, zoom = zoom)
  # borders <- attr(mapData, which = "bb")
  mapplot <- ggmap(get_googlemap(center = center, zoom = zoom), extent = "device")
  
  lon_breaks <- mapplot$data$lon
  lat_breaks <- mapplot$data$lat
  
  mapplot <- mapplot + 
      theme(axis.line=element_blank(), 
            axis.text.x=element_blank(),
            axis.text.y=element_blank(), 
            axis.ticks=element_blank(),
            axis.title.x=element_blank(),
            axis.title.y=element_blank())
  
  png(filename = "../results/base_map.png")
  print(mapplot)
  dev.off()
  

  base_map <- readPNG(source = "../results/base_map.png")
  ggmapdata <- rasterGrob(base_map, interpolate=TRUE)
  
  ggmapdata <- qplot(x = lon_breaks, 
        y = lat_breaks, 
        xlim = c(min(lon_breaks), max(lon_breaks)), 
        ylim = c(min(lat_breaks), max(lat_breaks)), 
        geom="blank") +
    annotation_custom(ggmapdata, xmin=-Inf, xmax=Inf, ymin=-Inf, ymax=Inf)
  
  temp_filt <- location_summary
  
  start = 1
  start_plot = 1
  lat_start = 0
  long_start = 0
  
  # plot_seq <- seq(period, nrow(temp_filt), 1)
  
  temp = data_frame()
  
  p <- ggmapdata
  
  print(p)
  
  if (plot_period == "daily"){
    for (count in 1:nrow(temp_filt)){
      if(interval(temp_filt$time[start], temp_filt$time[count])/ddays(1) >= 1){
        
        searches <- paste(browse_summary$title)
        
        p <- ggmapdata + 
          geom_point(data = temp_filt[1:count, ], aes(x = long, 
                                                      y = lat), 
                     fill = "light blue", size = 2, 
                     alpha = alpha,
                     colour = "blue") + 
          geom_point(data = temp_filt[count, ], aes(x = long, 
                                                    y = lat), 
                     alpha = 0.5, fill = "red", size = 3, colour = "red")
        
        print(p)
        
        start = count
        
      }
    }
  }else if (plot_period == "weekly"){
    for (count in 2:nrow(temp_filt)){
      if(interval(temp_filt$time[start], temp_filt$time[count])/dweeks(1) >= 1){
        
        word_occurances <- unlist(browse_summary %>% 
                          filter(time >= temp_filt$time[start] & 
                                   time <= temp_filt$time[count]) %>% 
                          select(words))
        
        word_occurances <- unlist(table(word_occurances))
        
        # word_occurances <- data_frame(words = word_occurances)
        
        tops <- data_frame(cats = top_words$Var1)
        
        tops$freq <- sapply(1:nrow(tops), function(x, y, z) 
          if_else(any(names(y) %in% z[x, "cats"]), as.numeric(y[unlist(z[x, "cats"])]), 0), 
          y = word_occurances, z = tops)
        
        # word_occurances <- unlist(word_occurances)
        # word_occurances_freq <- as_data_frame(table(word_occurances[word_occurances %in% top_words]))
        
        p <- ggmapdata + 
          geom_point(data = temp_filt[1:count, ], aes(x = long, 
                                                      y = lat), 
                     fill = "light blue", size = 2, alpha = alpha,
                     colour = "blue") + 
          geom_point(data = temp_filt[count, ], aes(x = long, 
                                                    y = lat), 
                     alpha = 0.5, fill = "red", size = 3, colour = "red")
        
        word_freq <- ggplot(data = tops, aes(x = cats, y = freq, fill = factor(cats))) + 
          geom_col() + 
          theme(axis.ticks.x =element_blank(), axis.text.x=element_blank())
        
        
        # op <- par(mfrow=c(1,2), pty = "s")
          
        # p <- plot_grid(p, word_freq, ncol = 2)  
        
        # p
        # word_freq
        
        # par(op)
        
        # dev.off()
        
        grid.newpage()
        pushViewport(viewport(layout = grid.layout(1, 2), width = 1, height = 0.5))
        print(p, vp = viewport(layout.pos.row = 1, layout.pos.col = 1))
        print(word_freq, vp = viewport(layout.pos.row = 1, layout.pos.col = 2))
        
        start = count
        
      }
    }
  }else if (plot_period == "annually"){
    for (count in 1:nrow(temp_filt)){
      if(interval(temp_filt$time[start], temp_filt$time[count])/dyears(1) >= 1){
        
        p <- ggmapdata + 
          geom_point(data = temp_filt[1:count, ], aes(x = long, 
                                                      y = lat), 
                      fill = "light blue", size = 2, alpha = alpha,
                     colour = "blue") + 
          geom_point(data = temp_filt[count, ], aes(x = long, 
                                                    y = lat), 
                     alpha = 0.5, fill = "red", size = 3, colour = "red")
        
        print(p)
        
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

# zoom value should be between 3 and 21. (3 = continent, 21 = building)

saveHTML({plot_map(location = "Vancouver", zoom = 10, alpha = 0.5,
                   location_summary = location_summary, browse_summary = browse_summary, 
                   period = 10, 
                   plot_period = "weekly")}, 
         img.name = "anim_plot", imgdir = "../results/anim_dir", 
         htmlfile = "../results/anim.html", autobrowse = FALSE, title = "Google Location Data", 
         verbose =FALSE, interval = 0.25, ani.width = 480, ani.height = 480)

graphics.off()

