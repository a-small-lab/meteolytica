#  File meteolyticaDemo/ui.R
#  User interface module for Meteolytica web app demo.
#  Created by A.A. Small 24 Dec 2012
#  Based on Shiny's Mpg application, plus additions from many sources.

library(shiny)
library(xts)
#library(forecast)
#library(fpp)

welcomeMessage <- helpText(
strong("Meteolytica is a web app designed to help you create a forecasting model for events
that you care about."),
  helpText("\n"),
"Using Meteolytica does not require any expertise in statistics or other methods of data analysis.",
"The system does that work for you, automatically.",
  helpText("\n"),
"If you work in business, for example, Meteolytica can help you with forecasting sales for a particular product, product line, or entire organization.  
The applications are much broader, however. They include those in public health, energy demand management, transport, and many other fields. Meteolytica is 
being designed to work well especially for forecasting processes that are sensitive to changes in weather or climate.",
  helpText("\n"),
"What Meteolytica requires from you is data: historical data that describe how the process you want to forecast has behaved in the past. The tabs above are organized from left to right to reflect the user's workflow. Click on the tabs to see context-specific instructions.",
     helpText("\n"),
"CAUTIONARY NOTES:",
"The file upload feature is not yet implemented. For the time being, you must use one of the prepared data files. ",
"Performance is slow. Results may take several seconds to load. Please be patient.",
"This is a very early and unstable version of the system. If the program crashes, simply reload the browser to restart."
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
#        welcomeMessage,
        wellPanel(welcomeMessage),    
        pageWithSidebar(
          headerPanel(""),
          sidebarPanel(
            selectInput(inputId = "dataset", 
              label = "Choose an example dataset:",
              choices = list(
                "UK electricity consumption" = "taylor",
  #              "Austrailian beer production" = "beer",
                "Austrailian pharma usage" = "a10"),
              selected = "taylor"),
                        
            checkboxInput(inputId = "upload", 
              label = "Upload your own dataset", 
              value = FALSE),
                        
            conditionalPanel(condition = "input.upload == true",
              fileInput(inputId = "uploadedFile", 
                label = paste("Upload a time series file ",  
                             "[This feature is not yet supported.]"), 
                multiple = FALSE, accept = NULL)
            )
          ),
#          mainPanel(textOutput("testReactive"))                              
          mainPanel(plotOutput(outputId = "predictandHistoryTsPlot", height="300px"))
          )        
      ),

# META-DATA project background panel -------------------------------------------

      tabPanel("Tell us about your data", value='metadata',
        wellPanel("[In this panel the user will supply meta-data that describe the data.]")),
        

# DATA visualization panel -----------------------------------------------------
    
      tabPanel("Visualize your data", value='data',
        tabsetPanel(id="dataTab",
          
          tabPanel("Tables", value='viewData', 
            wellPanel("An overview of your historical data. \n [THIS TAB NEEDS WORK!]"),
            verbatimTextOutput("predictandHistoricalTsSummary"),
            br(), 
            tableOutput("predictandHistoricalTsHead")
            ),
                                
          tabPanel("Seasonal decomposition", value='stl',
            wellPanel("In the plot below, your selected data series (top panel) may be viewed as the sum of three parts: a periodic seasonal component, a long-term trend, and a residual, or random noise component."),
            plotOutput('predictandHistoryStlPlot')
            )                                
          )
        ),
    
# FORECAST model generator panel ---------------------------------------------------------
      
      tabPanel("Generate a forecasting model", value='model',
          bootstrapPage(
            tabsetPanel(id='modelTab',
              #tabPanel("Create forecasting model", value='create'),
                
              tabPanel("View plot", value='plot', 
                plotOutput("forecastPlot")
                )
              )
            )
          ), 

# EVALUATION: Model accuracy panel ---------------------------------------------------------

      tabPanel("Review forecast accuracy", value='evaluation', 
        tableOutput("accuracy")
        ),


# EXPORT panel ---------------------------------------------------------

      tabPanel("Export your model", value='export', 
        wellPanel("[This panel is slated to contain utilities for exporting the forecasting model the user has just created. In the interim, it is used as a staging area in which the application developers run various tests.")
        , verbatimTextOutput("testOutput")
          
        )

      )  #  Close top-level tabsetPanel()
  )      #  Close bootstrapPage()
)        #  Close ShinyUI()


########### DEPRECATED CODE (you may ignore everything below here) #############
