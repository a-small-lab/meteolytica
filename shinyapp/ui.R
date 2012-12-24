#  Learning how to use the shiny package in R.
#  First app.

library(shiny)

# Define UI for miles per gallon application
shinyUI(pageWithSidebar(
  
  # Print project title at top of page
  #    Title <- textOutput("projectTitle")
     headerPanel(textOutput("projectTitle")),
  
  # Sidebar with controls to select the variable to plot against mpg
  # and to specify whether outliers should be included
  sidebarPanel(
    selectInput("variable", "Variable:",
                list("Cylinders" = "cyl", 
                     "Transmission" = "am", 
                     "Gears" = "gear")),
    
    checkboxInput("outliers", "Show outliers", FALSE)
  ),
  
  # Show the caption and plot of the requested variable against mpg
  mainPanel(
    h3(textOutput("caption")),
    
    plotOutput("mpgPlot")
  )
))
