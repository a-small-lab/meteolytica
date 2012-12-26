#  File meteolyticaDemo/ui.R
#  User interface module for Meteolytica web app demo.
#  Created by A.A. Small 24 Dec 2012 based on Shiny's Mpg application.

library(shiny)

shinyUI(pageWithSidebar(
  
  # Print project title at top of page
     headerPanel(textOutput("projectTitle")),
  
  # Sidebar with control to select the number of forecast periods to display
  sidebarPanel(
     numericInput("numberOfObsToDisplay", "Number of observations to display in table:", 10),
     
     sliderInput(inputId = "display_periods",
                label = "Number of forecast weeks to display in plot:",
                min = 0.2, max = 2, value = 1, step = 0.2)
    
      ),
  
  # Show the caption and plot of the recent history plus short-range forecast
  mainPanel(
    verbatimTextOutput("outcomesSummary"),

    tableOutput("view"),

    plotOutput("forecastPlot")   
    #    h3(textOutput("caption")),   
  )
))
