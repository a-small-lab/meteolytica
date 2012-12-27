#  File meteolyticaDemo/ui.R
#  User interface module for Meteolytica web app demo.
#  Created by A.A. Small 24 Dec 2012
#  Based on Shiny's Mpg application, plus additions from many sources.

library(shiny)

shinyUI(pageWithSidebar(
     
     headerPanel("Meteolytica Demo"),
   
#      # Print project title at top of page
#   headerPanel(textOutput("projectTitle")),
  
  # Sidebar with control to select the number of forecast periods to display
  sidebarPanel(       
       conditionalPanel(
            condition = "input.openTab == 'welcome' ",
            helpText("Click on the tabs, proceeding from left to right ",
                     "to see context-specific instructions.")
            ),
       
       conditionalPanel(
            condition = "input.openTab == 'upload' ",
            fileInput("file", "Upload a time series file", multiple = FALSE, accept = NULL)
            ),
     
       conditionalPanel(
            condition = "input.openTab == 'create' ",
            numericInput(inputId = "trainingPeriods",
                    label = "Number of weeks of data to use for training",
                    3),
            numericInput(inputId = "testingPeriods",
                    label = "Number of weeks of data to use for testing",
                    0)
            ),
       
       conditionalPanel(
            condition = "input.openTab == 'plot' ",
            sliderInput(inputId = "display_periods",
                        label = "Number of forecast weeks to display in plot:",
                        min = 0.2, max = 2, step = 0.2, value = 1)            
            ),
       
       conditionalPanel(
            condition = "input.openTab == 'performance' ",
            numericInput("numberOfObsToDisplay", 
                         "Number of observations to display in table:", 
                         10)            
            )

       ),
  
     # Show a tabset that includes a plot, summary, and table view
     # of the data set and associated forecast
     mainPanel(
          tabsetPanel(id="openTab",
               tabPanel("Welcome", value='welcome',
                        helpText("Meteolytica is a web app designed to generate forecasting ",
                                 "models automatically based on historical data ",
                                 "supplied by the user.",
                                 helpText(""),
                                 "The tabs are organized from left to right to reflect the", 
                                 "user's workflow. Click on the tabs to see context-specific instructions.",
                                 helpText(""),
                                 "CAUTIONARY NOTES: ",
                                 "This is a very early and unstable version of the system. ",
                                 "The file upload feature is not yet working on ",
                                 "glimmer.rstudio.org: you must use one of the prepared data files. Performance may be slow.", 
                                 "If the program crashes, simply reload the browser to restart."
                                 )
                        ),
               tabPanel("Describe your project", value='describe'),      
               tabPanel("Upload your data", value='upload'), 
               tabPanel("View your data", value='view', tableOutput("tableOfUsersData")),
               # Need to figure out how to add multiple display elements to single tab panel
               # tabPanel("Summary of your data", verbatimTextOutput("outcomesSummary")), 
               tabPanel("Create forecasting model", value='create'), 
               tabPanel("View plot", value='plot', plotOutput("forecastPlot")), 
               tabPanel("Evaluate performance", value='performance', tableOutput("view"))
          )
     )
     
))


############ DEPRECATED CODE (you may ignore) ################
# Show the caption and plot of the recent history plus short-range forecast
#   mainPanel(
#     verbatimTextOutput("outcomesSummary"),
# 
#     tableOutput("view"),
# 
#     plotOutput("forecastPlot")   
#     #    h3(textOutput("caption")),   
#   )

