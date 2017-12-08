library(rjson)

browse_locs <- c("../data/Chrome/BrowserHistory.json", "../data/Chrome/Sample/BrowserHistory.json")
location_locs <- c("../data/Location History/Location History.json", "../data/Location History/Sample/Location History.json")

locs <- list(browse_locs, location_locs)

dataset_names <- c("browse_hist", "location_hist")

for (loc_dir in 1:length(locs)){
  temp <- try(fromJSON(file = locs[[loc_dir]][1]))
  if("try-error" %in% class(temp)){
    message("Trying next location")
    temp <- try(suppressMessages(fromJSON(file = locs[[loc_dir]][2])))
    if("try-error" %in% class(temp)){
      stop(paste0("Locations do not exist: ",  locs[[loc_dir]]))
    }else{
      message("Location found. Continuing with script")
    }  
  }
  
  if(loc_dir == 1){
    browse_hist <- temp
  }else if(loc_dir == 2){
    location_hist <- temp
  }
  
}