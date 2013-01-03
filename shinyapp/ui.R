#  File meteolyticaDemo/ui.R
#  User interface module for Meteolytica web app demo.
#  Created by A.A. Small 24 Dec 2012
#  Based on Shiny's Mpg application, plus additions from many sources.

library(shiny)
library(fpp)

welcomeMessage <- helpText(
"Meteolytica is a web app designed to generate forecasting models automatically based on historical data supplied by the user.",
     helpText("\n"),
"The tabs above are organized from left to right to reflect the user's workflow. Click on the tabs to see context-specific instructions.",
     helpText("\n"),
"CAUTIONARY NOTES:",
#     helpText("\n"),
"The file upload feature is not yet implemented. For the time being, you must use one of the prepared data files. ",
#     helpText("\n"),
"Performance is slow. Results may take several seconds to load. Please be patient.",
#     helpText("\n"),
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
    h1("Welcome to Meteolytica"), 

    tabsetPanel(id="openTab",


# Welcome panel -----------------------------------------------------------

      tabPanel("Welcome", value='welcome',
#        welcomeMessage,
#        wellPanel(welcomeMessage),    
        pageWithSidebar(
          headerPanel(""),
          sidebarPanel(
            selectInput("dataset", "Choose an example dataset:",
              list("UK electricity consumption" = "taylor",
                   "Austrailian beer production" = "beer",
                   "Austrailian pharma usage" = "a10"
              ),
            ),
            
            checkboxInput("upload", "Upload your own dataset", FALSE),
            
            conditionalPanel(
              condition = "input$upload==TRUE",
              h4("[The data upload feature is not yet implemented.]"),
              fileInput("uploadFile", "Upload a time series file", multiple = FALSE, accept = NULL)
            )
          ),
          mainPanel(welcomeMessage)
#          mainPanel(tableOutput("headOfHistoricalTs"))
          )        
      ),


# Data panel -----------------------------------------------------------
    
      tabPanel("Your Data", value='data',
        tabsetPanel(id="dataTab",
          
          tabPanel("Choose an example dataset", value='chooseData'
#            ,
            ),

#           tabPanel("Upload your own dataset", value='uploadData',
#             h4("[This feature is not yet implemented.]"),
#             fileInput("file", "Upload a time series file", multiple = FALSE, accept = NULL)
# #             pageWithSidebar(                           
# #                headerPanel("Upload historical data about the process you wish to forecast"),
# #                sidebarPanel(textOutput("Hello.")),
# #                mainPanel(textOutput("Hello yerself."))
# #            ),
#             ),
                                
          tabPanel("Examine your data", value='viewData', 
            verbatimTextOutput("outcomesSummary"),
            tableOutput("tableOfUsersData")
            ),
                                
          tabPanel("Time series decomposition", value='stl', 
            plotOutput('decomposedTsPlot')
            )
                                
          )
        ),
    
# Model generator panel ---------------------------------------------------------
      
      tabPanel("Forecast Model Generator", value='model',
          bootstrapPage(
            tabsetPanel(id='modelTab',
              tabPanel("Create forecasting model", value='create'),
                
              tabPanel("View plot", value='plot', 
                plotOutput("forecastPlot")
                )
              )
            )
          ), 

# Model accuracy panel ---------------------------------------------------------

      tabPanel("Forecast Accuracy", value='performance', 
        tableOutput("accuracy")
        )

      )  #  Close top-level tabsetPanel()
    )   #   Close bootstrapPage()
  )             #  Close ShinyUI()


########### DEPRECATED CODE (you may ignore everything below here) #############
