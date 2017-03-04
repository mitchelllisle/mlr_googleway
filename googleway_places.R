library(httr)
library(plyr)
library(dplyr)
library(tidyr)
library(dtplyr)
library(googleway)
library(jsonlite)
library(progress)

places_key <- "AIzaSyAeAw1J7pSGnEY-QwsIWabG6xV_DyeCPkc"
geocode_key <- "AIzaSyBcjA4tAtkNCp-zxx04RSIpGFBZcmo7dt4"
radius <- 2000
type <- "bank"
address <- "South Yarra, 3141, Vic"

geocode_address <- function(address, key){
    data.frame(google_geocode(address = address, key = geocode_key, simplify = TRUE))
}

google_radar <- function(lat, lng, radius, type, key){
  req <- GET(paste("https://maps.googleapis.com/maps/api/place/radarsearch/json?location=",lat,",",lng,"&radius=",radius,"&type=",type,"&key=",key, sep = ""))
  req_df <- fromJSON(content(req, type = "text", encoding = "UTF-8"))
  data.frame(cbind(req_df$results$place_id, req_df$results$geometry$location$lat, req_df$results$geometry$location$lng))
}

google_place <- function(place){
  place_url <- paste("https://maps.googleapis.com/maps/api/place/details/json?placeid=",place,"&key=",places_key, sep = "")
  request <- GET(place_url)
  request_json <- fromJSON(content(request, type = "text", encoding = "UTF-8"))
  place_data <- data.frame(request_json$result$id,request_json$result$formatted_address, request_json$result$name, request_json$result$geometry$location$lat, request_json$result$geometry$location$lng)
}

req <- geocode_address(address, geocode_key)
req2 <- google_radar(req$results.geometry$location$lat, req$results.geometry$location$lng, radius, type, places_key)
places <- as.list(req2$X1)
data <- lapply(places, FUN = google_place)
dataframe <- ldply(data, data.frame)
write.table(dataframe, file = "output/output.csv")
