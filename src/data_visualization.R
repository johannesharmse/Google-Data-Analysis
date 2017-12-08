library(tidyverse)
library(lubridate)
# library(forcats)
# devtools::install_github("dgrtwo/gganimate")
library(gganimate)
library(ggmap)
library(animation)
# library(NLP)
# library(stringr)

browse_summary <- readRDS(file = "../data/R_temp/browse_summary.rds")
location_summary <- readRDS(file = "../data/R_temp/location_summary.rds")

# Function for plotting daily, weekly and annual location data points

plot_map <- function(location, zoom = 10, location_summary, period = 10, plot_period = "daily", alpha = 0.2){
  
  # location_summary <- location_summary
  
  mapData <- get_googlemap(location, zoom = zoom)
  
  borders <- attr(mapData, which = "bb")
  
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
  
  mapData <- get_googlemap(center = center, zoom = zoom)
  
  ggmapdata <- ggmap(mapData)
  
  temp_filt <- location_summary
  
  start = 1
  start_plot = 1
  lat_start = 0
  long_start = 0
  
  # plot_seq <- seq(period, nrow(temp_filt), 1)
  
  temp = data_frame()
  
  
  
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

# remove (if necessary), then generate and write plots to HTML GIF

do.call(try(file.remove), list(list.files("../results/anim_dir", full.names = TRUE)))

# zoom value should be between 3 and 21. (3 = continent, 21 = building)

saveHTML({plot_map(location = "UBC", zoom = 15, alpha = 0.5,
                   location_summary, 
                   period = 10, 
                   plot_period = "weekly")}, 
         img.name = "anim_plot", imgdir = "../results/anim_dir", 
         htmlfile = "../results/anim.html", autobrowse = FALSE, title = "Google Location Data", 
         verbose =FALSE, interval = 0.25, ani.width = 480, ani.height = 480)

graphics.off()

