#  File meteolyticaDemo/ui.R
#  User interface module for Meteolytica web app demo.
#  Created by A.A. Small 24 Dec 2012
#  Based on Shiny's Mpg application, plus additions from many sources.

library(shiny)
library(shinyIncubator)
library(xts)
#library(forecast)
#library(fpp)

welcomeMessage <- helpText(
strong("Meteolytica is a web app designed to help you create a forecasting model for events
that you care about."),
  helpText("\n"),
"If you work in business, for example, Meteolytica can help you with forecasting sales for a particular product, product line, or entire organization.  
But the applications are much broader. In public health, energy demand management, transport, and many other fields, people who have an idea of what's coming are able to make better decisions. 
Meteolytica is being designed to work well especially for forecasting processes that are sensitive to changes in weather or climate.",
  helpText("\n"),
  "Using Meteolytica does not require any expertise in statistics or other methods of data analysis.",
  "The system does that work for you, automatically.",
  helpText("\n"),
  "What Meteolytica requires from you is data: historical data that describe how the process you want to forecast has behaved in the past. The tabs above are organized from left to right to reflect the user's workflow. Click on the tabs to see context-specific instructions.",
     helpText("\n"),
"CAUTIONARY NOTES:",
"The file upload feature is not yet implemented. For the time being, you must use one of the prepared data files. ",
"Performance is slow. Results may take several seconds to load. Please be patient.",
"This is a very early and unstable version of the system. If the program crashes, simply reload the browser to restart.",
  helpText("\n"),
  strong("Click on the next tab to get started.")
)

# doc <- tags$html(
# 
#   tags$head(
#     tags$title('My first page'),
# #    tags$style(tags$body(margin='100px'))
#     tags$style("body {
#             background-color: #CCC;
#         }
#                
#                #SiteBody 
#         {
#             width: 960px;
#             margin: 0 auto;
#             background-color: white;
#         }")
#   ),
#   tags$body(tags$div(id='SiteBody', class='container')
# 
#   )
# )
# 
# cat(as.character(doc))

#<body leftmargin="0px" topmargin="0px" marginwidth="0px" marginheight="0px">,


shinyUI(
  bootstrapPage(
    h1("Meteolytica: Predictive Modeling for Everybody"), 

    tabsetPanel(id="openTab",

# WELCOME panel -----------------------------------------------------------

      tabPanel("Welcome", value='welcome',
        wellPanel(welcomeMessage)
      ),

# META-DATA project background panel -------------------------------------------

      tabPanel("Describe your forecasting challenge", value='metadata',
#        wellPanel("[In this panel the user will supply meta-data that describe the data.]"),
        pageWithSidebar(headerPanel(""),
          sidebarPanel(
            selectInput(inputId = "dataset", 
              label = strong("Explore Meteolytica using an example dataset"),
              choices = list(
                "UK electricity consumption" = "taylor",
                #              "Austrailian beer production" = "beer",
                "Austrailian pharma usage" = "a10"),
              selected = "taylor"),  
            
            helpText("\n"),
            
            checkboxInput(inputId = "upload", 
              label = strong("Or: Upload your own dataset"), 
              value = FALSE),
            
            conditionalPanel("input.upload == true",
              fileInput(inputId = "uploadedFile", 
                label = paste("Must be a time series file in plain text CSV format.",  
                              "[Upload feature not yet fully supported.]"), 
                multiple = FALSE, 
                accept = "text/csv"),
              helpText("\n"),
              helpText(strong("Now tell us about your data...")),
              
              tabsetPanel(id="metadataTabset",
                
                tabPanel("Title", value='titleTab'),
                
                tabPanel("Time", value='timeTab'),
                
                tabPanel("Location", value='locationTab'),
                
                tabPanel("Units", value='unitsTab')
                
              )
              
            )
            
          ),

          mainPanel(
            tabsetPanel(id="viewdataTab",    
              
              tabPanel("Plot", value='viewPlot',
                plotOutput(outputId = "predictandHistoryTsPlot")
              ),
              
              tabPanel("Tables", value='viewTables', 
                wellPanel("An overview of your historical data. [THIS PANEL NEEDS WORK!]"),
                verbatimTextOutput("predictandHistorySummary"),
                br(), 
                tableOutput("predictandHistoryTable")
              ),
              
              
              tabPanel("Seasonal decomposition", value='viewStl',
# #                wellPanel("In the plot below, your selected data series (top panel) may be viewed as the sum of three parts: a periodic seasonal component, a long-term trend, and a residual, or random noise component."),
                plotOutput('predictandHistoryStlPlot')
              )
              
            )
            
          )
        )
      ),  # Close tabPanel
        

# FORECAST model generator panel ---------------------------------------------------------
      
      tabPanel("Generate a forecasting model", value='model',
        pageWithSidebar(
          headerPanel(""),
          sidebarPanel(
            actionButton('generateForecastButton', "Generate forecasting model")
          ),
          mainPanel(            
            tabsetPanel(id='modelTab',
            
              tabPanel("View plot", value='plot', 
                plotOutput("forecastPlot")
              ),
            
              tabPanel("Accuracy measures", value='evaluation', 
                tableOutput("accuracy")
              )            
            )
          )
        )
      ), 

# EXPORT panel ---------------------------------------------------------

      tabPanel("Take your model with you", value='export', 
        wellPanel("[This panel will contain utilities for exporting the forecasting model the user has just created.]")
        ),
      
# MORE INFORMATION panel ----------------------------
      tabPanel("Further information", value='moreInfo', 
        wellPanel("[This panel will contain additional information the performance they can expect, and about Meteolytica's overall performance. The goal is to start transitioning the user from a experimenter to a committed user who would be open to considering moving up to a premium version of the service.]")
      )
      
      
      # We anticipate adding another panel describing Meteolytica's performance
      
# Debugging panel ---------------------------------------------------------

    , tabPanel("[CONSTRUCTION ZONE]", value='debugging', 
        wellPanel("[This panel provides a staging area in which the application developers run various tests. It will not appear in the finished version of Meteolytica.]")
        , verbatimTextOutput("testOutput")          
      )
      
      
      )  #  Close top-level tabsetPanel()
  )      #  Close bootstrapPage()
)        #  Close ShinyUI()




########### DEPRECATED CODE (you may ignore everything below here) #############
