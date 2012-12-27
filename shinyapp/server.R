#  File meteolyticaDemo/server.R
#  Server logic module for Meteolytica web app demo.
#  Created by A.A. Small 24 Dec 2012 based on Shiny's Mpg application.

library(shiny)
library(forecast)

ProjectID <- c("(Name of user)",
               "Load",
               "NYC-temp+load-hourly-feb2005--may2008.csv",
               "Forecasting electric power load in New York City"
               )

UserName <-          ProjectID[1]
ProjectName <-       ProjectID[2]
UserDataCSVFile <-   ProjectID[3]
projectTitle <-      ProjectID[4]

# Retrieve and transform user's outcomes data -----------------------------------

#  Identify files containing the load data.
# PathFromRoot <- c("/Users/arthursmalliii/Documents/Google\ Drive/meteolytica")
# UserDataDirectory <- paste("Data/Outcomes",ProjectName, sep="/")
# outcomesDataCSVFile <- paste(PathFromRoot,UserDataDirectory,UserDataCSVFile,sep="/")
outcomesDataCSVFile <- UserDataCSVFile

#  Read user's outcomes data from file, creating a data frame
NYC.temp.load <- read.table(outcomesDataCSVFile, header = TRUE, sep = ",")

# Clean outcomes series and convert it to a time series object
# funk <- paste(PathFromRoot,"R/outcomes.df2ts.R",sep="/")
funk <- c("outcomes.df2ts.R")
source(funk)    
NYC.load.ts <- outcomes.df2ts(NYC.temp.load)

# Create a much shorter time series, to make the computations run faster during development.
NYC.load.ts <- window(NYC.load.ts, start=168)
NYC.load.df <- as.data.frame(NYC.load.ts)


# CREATE FORECASTING MODEL -----------------------------------------------

#  Create a load forecasting model using the forecast() package, 
#  based only the load time series
system.time(NYC.load.forecast <- forecast(NYC.load.ts))


# DEFINE SHINY SERVER FUNCTION ----------------------------------------------------

# Define server logic required to plot forecast
shinyServer(function(input, output) {
       
     ### DEFINE FUNCTIONS ###

     #  Read user's outcomes data from UI, then convert it from CSV to data frame.
     #  If user doesn't upload a file, default to a prepared CSV file.
     outcomesDf <- reactive (function(){
          if(is.null(input$file)) {
               infileCSV <- outcomesDataCSVFile
          } else {
               infileCSV <- as.character(input$file[1])
          }
          
          infileDf <- read.csv(infileCSV, header = TRUE)
          return(infileDf)
     })
  
     forecastModel <- reactive(function(){
          outcomesTs <- outcomes.df2ts(outcomesDf())
          outcomesTs <- window(outcomesTs, start=168)
          forecastModelOut <- forecast(outcomesTs)
          return(forecastModelOut)
          # return(outcomesTs)
     })
     
     ### DEFINE OUTPUTS ###
     
     # Return the text for the main title of the page
     output$projectTitle  <- reactiveText(function() {
          projectTitle
          })
  
     # Display the first "n" rows of the users data in a table
     output$tableOfUsersData <- reactiveTable(function() {
          numberOfRows <- input$numberOfObsToDisplay
          headOfData <- head(as.data.frame(outcomesDf()), n=numberOfRows)
          return(headOfData)
          })
     
     output$outcomesSummary <- reactivePrint(function() {
          summary(outcomesDf())
          })
  
     # Generate a plot of the tail of obs + forecast
     output$forecastPlot <- reactivePlot(function() {
          xlim <- c(170,172.8+input$display_periods)
          veritcalLabel <- c("MW")
          horizLabel <- c("Weeks")
          plot(forecastModel(), 
            main="Forecast of NYC load (MW)", 
            xlim=xlim)
          })
     
     # Display the first "n" observations in a table
     output$view <- reactiveTable(function() {
           numberOfRows <- input$numberOfObsToDisplay
           tableData <- tail(as.data.frame(NYC.load.ts), n=numberOfRows)
           t(tableData)
           })

})


# Deprecated code (you may ignore) ----------------------------------------
# library(datasets)
# str(rock)
# str(cars)
# str(pressure)
# str(NYC.load.df)
# xtable(NYC.load.df)
#   captionText <- reactive(function() {
#     c("Units of MWh per hour")
#   })
#   
#   # Return the text for the caption
#   output$caption <- reactiveText(function() {
#     captionText()
#   })
