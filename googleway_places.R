library(googleway)
library(leaflet)

# https://developers.google.com/places/supported_types
# https://github.com/SymbolixAU/googleway

df <- google_geocode(address = "Hampton 3188",
                     key = geocode_key,
                     simplify = TRUE)

df$results$geometry$location

places_key <- "AIzaSyBY7jbzD3onwbPhDwe6IJLdhZ57ysVRcpY"
geocode_key <- "AIzaSyAI4ruKKXSucmmlgXjkzGFIbbpGc4PkcP4"
location <- c(df$results$geometry$location$lat, df$results$geometry$location$lng)
place_type <- "cafe"
counter <- 1
radius <- 2000
file <- "temp/file.csv"

res <- google_places(location = location,
                          place_type = place_type,
                          radius = radius,
                          key = places_key)
x <- as.data.frame(cbind(res$results$name, res$results$geometry$location, res$results$rating))
write.table(x,file = file, sep = ",", row.names = FALSE)

page <- res$next_page_token

while (is.null(page) != TRUE) {
                res <- google_places(location = location,
                     place_type = place_type,
                     radius = radius,
                     page_token = page,
                     key = places_key)
                     page <- res$next_page_token
                     counter <- counter + 1
                     x <- as.data.frame(cbind(res$results$name, res$results$geometry$location, res$results$rating))
                     write.table(x, file = file, row.names = FALSE, append = TRUE, col.names = FALSE, sep = ",")
            }


  # cbind(res$results$name, res$results$geometry$location, res$results$rating)
#
#
# res <- google_places(search_string = "Densist in Richmond, Australia",
#                      key = key)
#
# cbind(res$results$name, res$results$opening_hours)
