library(jsonlite)
library(httr)
library(reshape2)
library(dplyr)
library(plyr)
library(tidyr)
library(foreach)
library(data.table)
library(dtplyr)

places_key <- "AIzaSyAeAw1J7pSGnEY-QwsIWabG6xV_DyeCPkc"
geocode_key <- "AIzaSyBcjA4tAtkNCp-zxx04RSIpGFBZcmo7dt4"

suburb <- google_geocode(address = "Hampton 3188",
                     key = geocode_key,
                     simplify = TRUE)

lon <- suburb$results$geometry$location$lng
lat <- suburb$results$geometry$location$lat
radius <- 50000
type <- "cafe"

url <- paste("https://maps.googleapis.com/maps/api/place/radarsearch/json?location=",lat,",",lon,"&radius=",radius,"&type=",type,"&key=",places_key, sep = "")
req <- GET(url)
req_df <- fromJSON(content(req, type = "text", encoding = "UTF-8"))
location_data <- data.frame(cbind(req_df$results$place_id))
# write.table(location_data,file = "radar-data.csv", sep = ",", row.names = FALSE)

places <- as.list(req_df$results$place_id)

simplefunc <- function(place){
  place_url <- paste("https://maps.googleapis.com/maps/api/place/details/json?placeid=",place,"&key=",places_key, sep = "")
  request <- GET(place_url)
  request_json <- fromJSON(content(request, type = "text", encoding = "UTF-8"))
  place_data <- data.frame(request_json$result$id,request_json$result$formatted_address, request_json$result$name, request_json$result$geometry$location$lat, request_json$result$geometry$location$lng)
}

data <- lapply(places, FUN = simplefunc)
dataframe <- ldply(data, data.frame)

write.table(dataframe, file = "radar-data.csv", sep = ",")

place_url <- paste("https://maps.googleapis.com/maps/api/place/details/json?placeid=ChIJs-Q2IlNd1moRWMeetOC96a8&key=",places_key, sep = "") 
request <- GET(place_url)
request_json <- fromJSON(content(request, type = "text", encoding = "UTF-8"))
place_data <- data.frame(request_json$result$id,request_json$result$rating)