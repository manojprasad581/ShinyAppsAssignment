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
