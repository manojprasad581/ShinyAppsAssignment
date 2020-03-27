library(shiny)
library(leaflet)
library(dplyr)
data("quakes")

process_quakes_data <- function() {
    # Based on magnitudes, add a color variable
    quakes <- quakes %>% mutate (
        color = case_when(
            mag >= 4.0 & mag <= 4.9 ~ "blue",
            mag >= 5.0 & mag <= 5.9 ~ "orange",
            mag >= 6.0 & mag <= 6.9 ~ "red",
        )
    )
    
    # Pick only top 15 observations from each color groups
    quakes <- quakes %>%
        group_by(color) %>%
        arrange(desc(mag)) %>%
        do(head(., n = 15))
    
    quakes
}

quakes <- process_quakes_data()
mean_lat <- mean(quakes[["lat"]])
mean_long <- mean(quakes[["long"]])

# Define server logic required to draw a histogram
shinyServer(function(input, output) {
    output$quakesPlot <- renderLeaflet({
        if(length(input$intensity) == 0) {
            # Plot an empty interactive map using Leaflet
            quakes %>% 
            leaflet() %>%
            addTiles() %>%
            setView(lng = mean_long, lat = mean_lat, zoom = 04)
        } else {
            # Filter quakes dataset as per input$intensity
            quakes <- quakes %>% filter(color == input$intensity)
            
            # Plot an interactive map using Leaflet
            quakes %>%
            leaflet() %>%
            addTiles() %>%
            addCircleMarkers(color = quakes$color, popup = paste("Magnitude = ", quakes$mag), radius = ~ mag ^ 2,
                                 stroke = FALSE, fillOpacity = 0.5) %>%
            addLegend(labels = c("Mag = (6.0 ~ 6.9)", "Mag = (5.0 ~ 5.9)", "Mag = (4.0 ~ 4.9)"), colors = c("red", "orange", "blue"))    
        }
    })
})
