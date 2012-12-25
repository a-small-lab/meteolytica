#  Learning how to use the shiny package in R.
#  First app.

library(shiny)

# Define UI for miles per gallon application
shinyUI(pageWithSidebar(
  
  # Print project title at top of page
     headerPanel(textOutput("projectTitle")),
  
  # Sidebar with control to select the number of forecast periods to display
  sidebarPanel(
    sliderInput(inputId = "display_periods",
                label = "Number of forecast weeks to display:",
                min = 0.2, max = 2, value = 1, step = 0.2)
      ),
  
  # Show the caption and plot of the requested variable against mpg
  mainPanel(
    h3(textOutput("caption")),
    
    plotOutput("mpgPlot")
  )
))
