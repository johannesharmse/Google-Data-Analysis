library(tidyverse)
# library(lubridate)
# library(forcats)
# devtools::install_github("dgrtwo/gganimate")
library(gganimate)
library(ggmap)
library(animation)
# library(NLP)
# library(stringr)

browse_summary <- readRDS(file = "../data/R_temp/browse_summary.rds")
location_summary <- readRDS(file = "../data/R_temp/location_summary.rds")

# Load base map from Google



plot_map <- function(location_summary, period = 10, plot_period = "daily"){
  
  # location_summary <- location_summary
  
  mapData <- get_googlemap(center = c(0, 0), zoom = 1, maptype = "hybrid", source = "google", size = c(360, 240), scale = 1)
  
  ggmapdata <- ggmap(mapData)
  
  temp_filt <- location_summary
  
  start = 1
  start_plot = 1
  lat_start = 0
  long_start = 0
  
  plot_seq <- seq(period, nrow(temp_filt), 1)
  
  temp = data_frame()
  
  
  
  if (plot_period == "daily"){
    for (count in 1:nrow(temp_filt)){
      if(interval(temp_filt$time[start], temp_filt$time[count])/ddays(1) >= 1){
        
        searches <- paste(browse_summary$title)
        
        p <- ggmapdata + 
          geom_point(data = temp_filt[1:count, ], aes(x = long, 
                                                      y = lat), 
                     alpha = 0.05, fill = "light blue", size = 2, 
                     colour = "blue") + 
          geom_point(data = temp_filt[count, ], aes(x = long, 
                                                    y = lat), 
                     alpha = 0.5, fill = "red", size = 3, colour = "red")
        
        print(p)
        
        start = count
        
      }
    }
  }else if (plot_period == "weekly"){
    for (count in 1:nrow(temp_filt)){
      if(interval(temp_filt$time[start], temp_filt$time[count])/dweeks(1) >= 1){
        
        p <- ggmapdata + 
          geom_point(data = temp_filt[1:count, ], aes(x = long, 
                                                      y = lat), 
                     alpha = 0.05, fill = "light blue", size = 2, 
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
                     alpha = 0.05, fill = "light blue", size = 2, 
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

