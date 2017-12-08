library(tidyverse)

browse_hist <- readRDS(file = "../data/R_temp/browse_hist.rds")
location_hist <- readRDS(file = "../data/R_temp/location_hist.rds")


browse_df <- data_frame(time = sapply(1:length(browse_hist[[1]]), function(x) browse_hist[[1]][[x]]$time_usec), 
                        page_transition = sapply(1:length(browse_hist[[1]]), function(x) browse_hist[[1]][[x]]$page_transition), 
                        title = sapply(1:length(browse_hist[[1]]), function(x) browse_hist[[1]][[x]]$title), 
                        url = sapply(1:length(browse_hist[[1]]), function(x) browse_hist[[1]][[x]]$url))

location_df <- data_frame(time = sapply(1:length(location_hist[[1]]), function(x) location_hist[[1]][[x]]$timestampMs), 
                          lat = sapply(1:length(location_hist[[1]]), function(x) location_hist[[1]][[x]]$latitudeE7), 
                          long = sapply(1:length(location_hist[[1]]), function(x) location_hist[[1]][[x]]$longitudeE7), 
                          accuracy = sapply(1:length(location_hist[[1]]), function(x) location_hist[[1]][[x]]$accuracy), 
                          altitude = sapply(1:length(location_hist[[1]]), function(x) location_hist[[1]][[x]]$altitude))