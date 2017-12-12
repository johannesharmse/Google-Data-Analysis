# AUTHOR: Johannes Harmse
#
# Date created: 12-2017
#
# DOCUMENTATION
# 
# The purpose of this script is to import personal Google location and browser history data into R.
# If a user wants to visualise his/her data, they must first download their personal Google location (JSON) and browser history (JSON)
# data by followign the instructions at [Download Instructions](https://support.google.com/accounts/answer/3024190?hl=en).
# 
# The script tries to find personal user data within the directory data folder. Personal browser history data needs to be stored in 
# the Chrome subfolder, and the location data needs to be stored in the Location History subfolder. Both data files should be in 
# .json format (downloadable format from Google).
# 
# If a user has not pasted the necessary datasets in the correct locations, the script will search for the standard sample data 
# and use that as data sources.
# 
# No arguments should be specified within this script. 
#
# The script writes the data sources as R objects to a location where the next script will call it from.


library(rjson)
library(stringr)

browse_locs <- c("../data/Chrome/BrowserHistory.json", "../data/Chrome/Sample/sample.rds")
location_locs <- c("../data/Location History/Location History.json", "../data/Location History/Sample/Location History.json")

locs <- list(browse_locs, location_locs)

dataset_names <- c("browse_hist", "location_hist")

for (loc_dir in 1:length(locs)){
  temp <- try(fromJSON(file = locs[[loc_dir]][1]))
  if("try-error" %in% class(temp)){
    message("Personal data not found.")
    message("...")
    message("Trying Sample data location.")
    if (str_detect(locs[[loc_dir]][2], ".json")){
      temp <- try(suppressMessages(fromJSON(file = locs[[loc_dir]][2])))
    }else if(str_detect(locs[[loc_dir]][2], ".rds")){
      temp <- try(suppressMessages(readRDS(file = locs[[loc_dir]][2])))
    }else{
      stop(message("Data not in the correct format. Must be .json or .rds"))
    }
    if("try-error" %in% class(temp)){
      stop(message("Locations do not exist: ",  locs[[loc_dir]], "Please read the README files on where to store data."))
    }else{
      message("Location found. Continuing...")
    }  
  }
  
  if(loc_dir == 1){
    browse_hist <- temp
  }else if(loc_dir == 2){
    location_hist <- temp
  }
  
}

saveRDS(browse_hist, file = "../data/R_temp/browse_hist.rds")
saveRDS(location_hist, file = "../data/R_temp/location_hist.rds")
