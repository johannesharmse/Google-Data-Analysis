library(tidyverse)
library(lubridate)
library(forcats)
# library(NLP)
library(stringr)

browse_hist <- readRDS(file = "../data/R_temp/browse_hist.rds")
location_hist <- readRDS(file = "../data/R_temp/location_hist.rds")

# convert JSON to data frames if personal data was used, otherwise use sample objects

if (is.data.frame(browse_hist) == FALSE){
  
  browse_df <- data_frame(time = sapply(1:length(browse_hist[[1]]), function(x) browse_hist[[1]][[x]]$time_usec), 
                          page_transition = sapply(1:length(browse_hist[[1]]), function(x) browse_hist[[1]][[x]]$page_transition), 
                          title = sapply(1:length(browse_hist[[1]]), function(x) browse_hist[[1]][[x]]$title), 
                          url = sapply(1:length(browse_hist[[1]]), function(x) browse_hist[[1]][[x]]$url))
  
  # remove unused objects
  
  rm(browse_hist)
  
  # clean data
  
  browse_summary <- browse_df %>% 
    mutate(time = as_datetime(as.numeric(time)/1000000))
  
  # clear private data and filter for analysis
  
  browse_summary <- browse_summary %>% 
    filter((str_detect(url, regex('google.*?search|youtube.*?watch', ignore_case = TRUE)) & 
              !str_detect(url, regex('mail', ignore_case = TRUE))) | 
             (str_detect(title, regex('^.*?Google\ Play\ Music$', ignore_case = TRUE)) & 
                !str_detect(title, regex('^Home - Google Play Music$|^Google Play Music$', ignore_case = TRUE))))
  
  # remove unwanted objects
  
  rm(browse_df)

}else{
  browse_summary <- browse_hist
  
  # remove unused objects
  
  rm(browse_hist)
  
}
  
if (is.data.frame(location_hist) == FALSE){  
  
  location_df <- data_frame(time = sapply(1:length(location_hist[[1]]), function(x) location_hist[[1]][[x]]$timestampMs), 
                            lat = sapply(1:length(location_hist[[1]]), function(x) location_hist[[1]][[x]]$latitudeE7), 
                            long = sapply(1:length(location_hist[[1]]), function(x) location_hist[[1]][[x]]$longitudeE7), 
                            accuracy = sapply(1:length(location_hist[[1]]), function(x) location_hist[[1]][[x]]$accuracy), 
                            altitude = sapply(1:length(location_hist[[1]]), function(x) location_hist[[1]][[x]]$altitude))
  
  # remove unused objects
  
  rm(location_hist)
  
  # clean data
  
  location_df <- location_df %>% 
    mutate(time = as_datetime(as.numeric(time)/1000), 
           long = long/10^7, 		
           lat = lat/10^7)
  
  location_summary <- location_df %>% 
    arrange(time) %>% 
    mutate(day = ymd(substr(as.character(time), 1, 10))) %>% 
    select(time, lat, long, day)
  
  location_summary <- location_summary %>% 
    distinct(lat, long, .keep_all = TRUE)
  
  
  # remove unwanted objects
  
  rm(location_df)
  
}else{
  location_summary <- location_hist
  
  # remove unused objects
  
  rm(location_hist)
  
}

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

  
if (nrow(browse_summary) == 0 || 
    nrow(location_summary) == 0){
  stop(message("It seems as if there is no overlap between your browser history and location data. Cannot perform analysis"))
}
  

saveRDS(browse_summary, file = "../data/R_temp/browse_summary.rds")
saveRDS(location_summary, file = "../data/R_temp/location_summary.rds")

