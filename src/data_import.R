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
