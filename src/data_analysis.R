library(tidyverse)
library(lubridate)
library(forcats)
# library(countrycode)
# devtools::install_github("dgrtwo/gganimate")
library(gganimate)
library(ggmap)
library(animation)
library(NLP)
library(stringr)

browse_hist <- readRDS(file = "../data/R_temp/browse_hist.rds")
location_hist <- readRDS(file = "../data/R_temp/location_hist.rds")

# convert JSON to data frames if personal data was used, otherwise use sample objects

if (is.data.frame(browse_hist) == FALSE){
  
  browse_df <- data_frame(time = sapply(1:length(browse_hist[[1]]), function(x) browse_hist[[1]][[x]]$time_usec), 
                          page_transition = sapply(1:length(browse_hist[[1]]), function(x) browse_hist[[1]][[x]]$page_transition), 
                          title = sapply(1:length(browse_hist[[1]]), function(x) browse_hist[[1]][[x]]$title), 
                          url = sapply(1:length(browse_hist[[1]]), function(x) browse_hist[[1]][[x]]$url))
  
  location_df <- data_frame(time = sapply(1:length(location_hist[[1]]), function(x) location_hist[[1]][[x]]$timestampMs), 
                            lat = sapply(1:length(location_hist[[1]]), function(x) location_hist[[1]][[x]]$latitudeE7), 
                            long = sapply(1:length(location_hist[[1]]), function(x) location_hist[[1]][[x]]$longitudeE7), 
                            accuracy = sapply(1:length(location_hist[[1]]), function(x) location_hist[[1]][[x]]$accuracy), 
                            altitude = sapply(1:length(location_hist[[1]]), function(x) location_hist[[1]][[x]]$altitude))
  
  # remove unused objects
  
  rm(browse_hist, location_hist)
  
  # clean data
  
  location_df <- location_df %>% 
    mutate(time = as_datetime(as.numeric(time)/1000), 
           long = round(long/10^7, 3), 
           lat = round(lat/10^7, 3))
  
  browse_summary <- browse_df %>% 
    mutate(time = as_datetime(as.numeric(time)/1000000))
  
  location_summary <- location_df %>% 
    arrange(time) %>% 
    mutate(lag_lat = lag(lat), lag_long = lag(long), day = ymd(substr(as.character(time), 1, 10))) %>% 
    select(time, lag_lat, lat, lag_long, long, day)
  
  location_summary <- location_summary %>% 
    distinct(lat, long, .keep_all = TRUE)
  
  # match time ranges for different data sources
  
  browse_time_range = c(min(browse_summary$time), max(browse_summary$time))
  location_time_range = c(min(location_summary$time), max(location_summary$time))
  
  browse_summary <- browse_summary %>% 
    filter(time >= max(c(browse_time_range[1], location_time_range[1])) & 
             time <= min(c(browse_time_range[2], location_time_range[2]))) %>% 
    arrange(time)
  
  location_summary <- location_summary %>% 
    filter(time >= max(c(browse_time_range[1], location_time_range[1])) & 
             time <= min(c(browse_time_range[2], location_time_range[2]))) %>% 
    arrange(time)
  
  # clear private data and filter for analysis
  
  browse_summary <- browse_summary %>% 
    filter((str_detect(url, regex('google.*?search|youtube.*?watch', ignore_case = TRUE)) & 
              !str_detect(url, regex('mail', ignore_case = TRUE))) | 
             (str_detect(title, regex('^.*?Google\ Play\ Music$', ignore_case = TRUE)) & 
                !str_detect(title, regex('^Home - Google Play Music$|^Google Play Music$', ignore_case = TRUE))))
  
  # remove unwanted objects
  
  rm(location_df, browse_df)
  
  if (nrow(browse_summary) == 0 || 
      nrow(location_summary) == 0){
    stop(message("It seems as if there is no overlap between your browser history and location data. Cannot perform analysis"))
  }
  
}else{
  
  browse_summary <- browse_hist
  location_summary <- location_hist
  
  # remove unused objects
  
  rm(browse_hist, location_hist)
  
}

