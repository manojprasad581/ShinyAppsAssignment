<style>
body {
    overflow: scroll;
}
</style>

Shiny Assignment Reproducible Pitch
========================================================
author: Manoj Prasad
date: 28 March, 2020
autosize: true

Overview
========================================================
<font size="5">
- <b><u> This is reproducible pitch for Week4 Assignment on Shiny Application. Below are some of the objectives of this project </b></u>
    - Create a Shiny App to host a map of some of the quakes from the dataset
    - Allow a user to select the "Quake Intensity" to filter the map
- <b><u> The links to some of the hosted artifacts are as follows: </b></u>
    - <b><i> ShinyApp code hosted on GitHub </b></i>:
             https://github.com/manojprasad581/ShinyAppsAssignment
    - <b><i> Deployed ShinyApp </b></i>: https://manojprasad.shinyapps.io/ShinyAppAssignment/
</font>

User Interface
========================================================
<font size="5">
 - <b><u> Below are the 3 intensities of quakes that this App lets user select via a "Check
          Box" widget: </b></u>
    - <b><i> High Intesity </b></i>: Magnitude ranging from 6.0 to 6.9
    - <b><i> Medium Intesity </b></i>: Magnitude ranging from 5.0 to 5.9
    - <b><i> Low Intesity </b></i>: Magnitude ranging from 4.0 to 4.9
 - <b><u> Selecting each Check Box yields those relevant quakes to be pinned on the Map </b></u>
    - When no box is checked, an empty map is displayed
    - When multiple boxes are checked, multiple markers get overlayed on the Map
 - <b><u><p style="color:red"> Note: It's takes a few seconds for the map to be rendered.
   Appreciate your patience! </p></b></u>
 - <b><u> Below is the ui.R code from ShinyApp. Please scroll down to view more details! </b></u>


```r
library(shiny)
library(leaflet)

# Define UI for application that draws a histogram
shinyUI(fluidPage(

    # Application title
    titlePanel("Quakes Data"),
    
    checkboxGroupInput("intensity", "Quake Intensities:",
                       c("High" = "red",
                         "Medium" = "orange",
                         "Low" = "blue")),

    mainPanel(
        leafletOutput("quakesPlot")
    ),
))
```
</font>

Rendering the Map - Server
========================================================
<font size="5">
 - <b><u> Below is the server.R code from ShinyApp </b></u>
 - <b><u> The server takes intensity as an argument from the selected checkbox and adds those relevant markers to the map </b></u>

```r
library(shiny)
library(leaflet)
library(dplyr)
data("quakes")

process_quakes_data <- function() {
    # Based on magnitudes, add a color variable
    quakes_proc <- quakes %>% mutate (
        color = case_when(
            mag >= 4.0 & mag <= 4.9 ~ "blue",
            mag >= 5.0 & mag <= 5.9 ~ "orange",
            mag >= 6.0 & mag <= 6.9 ~ "red",
        )
    )
    
    # Pick only top 15 observations from each color groups
    quakes_proc <- quakes_proc %>%
        group_by(color) %>%
        arrange(desc(mag)) %>%
        do(head(., n = 15))
    
    quakes_proc
}

quakes_proc <- process_quakes_data()
mean_lat <- mean(quakes_proc[["lat"]])
mean_long <- mean(quakes_proc[["long"]])

# Define server logic required to draw a histogram
shinyServer(function(input, output) {
    output$quakesPlot <- renderLeaflet({
        if(length(input$intensity) == 0) {
            # Plot an empty interactive map using Leaflet
            quakes_proc %>% 
            leaflet() %>%
            addTiles() %>%
            setView(lng = mean_long, lat = mean_lat, zoom = 04)
        } else {
            # Filter quakes_proc dataset as per input$intensity
            quakes_proc <- quakes_proc %>% filter(color == input$intensity)
            
            # Plot an interactive map using Leaflet
            quakes_proc %>%
            leaflet() %>%
            addTiles() %>%
            addCircleMarkers(color = quakes_proc$color, popup = paste("Magnitude = ", quakes_proc$mag), radius = ~ mag ^ 2,
                                 stroke = FALSE, fillOpacity = 0.5) %>%
            addLegend(labels = c("Mag = (6.0 ~ 6.9)", "Mag = (5.0 ~ 5.9)", "Mag = (4.0 ~ 4.9)"), colors = c("red", "orange", "blue"))    
        }
    })
})
```
</font>

Map when all intensities are selected - Server code in execution
========================================================

<iframe src="leaflet_maps.html" style="position:absolute;height:100%;width:100%"></iframe>
</font>
