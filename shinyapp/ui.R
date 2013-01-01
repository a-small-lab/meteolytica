#  File meteolyticaDemo/ui.R
#  User interface module for Meteolytica web app demo.
#  Created by A.A. Small 24 Dec 2012
#  Based on Shiny's Mpg application, plus additions from many sources.

library(shiny)

welcomeMessage <- helpText(
"Meteolytica is a web app designed to generate forecasting models automatically based on historical data supplied by the user.",
     helpText("\n"),
"The tabs above are organized from left to right to reflect the user's workflow. Click on the tabs to see context-specific instructions.",
     helpText("\n"),
"CAUTIONARY NOTES:",
     helpText("\n"),
"The file upload feature is not yet working on glimmer.rstudio.org: you must use one of the prepared data files. For now the only prepared data file is a time series of hourly 
electricity load for New York City from 2005--2008.",
     helpText("\n"),
"Performance is slow. Results will take several seconds to load. Please be patient.",
     helpText("\n"),
"This is a very early and unstable version of the system. If the program crashes, simply reload the browser to restart."
)

doc <- tags$html(

  tags$head(
    tags$title('My first page'),
#    tags$style(tags$body(margin='100px'))
    tags$style("body {
            background-color: #CCC;
        }
               
               #SiteBody 
        {
            width: 960px;
            margin: 0 auto;
            background-color: white;
        }")
  ),
  tags$body(tags$div(id='SiteBody', class='container')

  )
)

cat(as.character(doc))

#<body leftmargin="0px" topmargin="0px" marginwidth="0px" marginheight="0px">,


shinyUI(
bootstrapPage(
h1("Meteolytica Demo"),
tabsetPanel(id="openTab",
            tabPanel("Welcome", value='welcome',          
                     pageWithSidebar(
                       headerPanel("Welcome to Meteolytica"),
                       sidebarPanel(),
                       mainPanel(welcomeMessage)
                       )
                     ),

            tabPanel("[Placeholder]", value='placeholder',
                     pageWithSidebar(                           
                           headerPanel("Meteolytica Demo"),
                           
                           # Sidebar with control to select the number of forecast periods to display
                           sidebarPanel(       
                             
                             conditionalPanel(
                               condition = "input.openTab == 'welcome' ",
                               helpText("Click on the tabs, proceeding from left to right ",
                                        "to see context-specific instructions.")
                             ),
                             
                             #         tabsetPanel(id='dist',
                             #                     tabPanel("Normal", value='norm', textInput("dist1","Xdist1", c("norm"))), 
                             #                     tabPanel("Uniform", value='unif', textInput("dist2","Xdist2", c("unif"))), 
                             #                     tabPanel("Log-normal", value='lnorm', textInput("dist3","Xdist3", c("lnorm"))), 
                             #                     tabPanel("Exponential", value='exp', textInput("dist4","Xdist4", c("exp"))) 
                             #         ), 
                             #         br(), 
                             
                             conditionalPanel(
                               condition = "input.openTab == 'upload' ",
                               fileInput("file", "Upload a time series file", multiple = FALSE, accept = NULL)
                             ),
                             
                             conditionalPanel(
                               condition = "input.openTab == 'view' ",
                               helpText("Your data.")
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
                           
                        mainPanel()
                           
                         )),
                  
            tabPanel("Your Project", value='project',
                    tabsetPanel(id='projectTab',
                                tabPanel("Describe your project", value='describeProject'),
                                tabPanel("Test 3"),
                                tabPanel("Test 4")
                                )
                    ),
                  
            tabPanel("Your Data", value='data',
                    tabsetPanel(id="dataTab",
                                tabPanel("Upload your data", value='uploadData'),
                                tabPanel("View your data", value='viewData', 
                                         verbatimTextOutput("outcomesSummary"),
                                         tableOutput("tableOfUsersData")
                                         )
                                )
                    ),
                
            tabPanel("Forecast Model Generator", value='model',
                     bootstrapPage(
                       tabsetPanel(id='modelTab',
                                   tabPanel("Create forecasting model", value='create', 
                                            plotOutput('decomposedTsPlot')
                                            ),
                                   tabPanel("View plot", value='plot', 
                                            plotOutput("forecastPlot")
                                            )
                                   )
                       )
                     ), 

             tabPanel("Forecast Accuracy", value='performance', 
                        tableOutput("accuracy")
                        )

              )  #  Close top-level tabsetPanel()
      )          #  Close bootstrapPage()
   )             #  Close ShinyUI()


########### DEPRECATED CODE (you may ignore everything below here) #############
