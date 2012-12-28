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

# cleanDf() is a utility that cleans data uploaded by user
funk <- c("cleanDf.R")
source(funk)    


# CREATE FORECASTING MODEL -----------------------------------------------


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
          infile.df <- read.csv(infileCSV, header = TRUE)
          clean.df <- cleanDf(infile.df)
          return(clean.df)
     })
     
     # Convert outcomes data into a time series object, with parameters as
     # specified by user.
     outcomesTs <- reactive(function(){
#          #     Convert text dates into R's internal "Date" class
#           outcomes.df$Date <- as.Date(outcomes.df$Date,'%m/%d/%Y')
#           outcomes.df$Date[1]
          outcomes.ts <- ts(outcomesDf()$Load.MW, 
                            # start     = 2005+1/12,
                            frequency = 7*24)
          return(outcomes.ts)    # Return time series object
     })
     
     #  Use forecast() function to create a forecasting model 
     #  based only on user-supplied data 
     forecastModel <- reactive(function(){
          outcomes.ts <- outcomesTs()
          startOfTrainingWindow <- 172-input$trainingPeriods-input$testingPeriods
          endOfTrainingWindow <- startOfTrainingWindow + input$trainingPeriods
          outcomes.ts <- window(outcomes.ts, 
                               start=startOfTrainingWindow, 
                               end=endOfTrainingWindow)
          forecastModelOut <- forecast(outcomes.ts)
          return(forecastModelOut)
     })
     
     forecastResiduals.ts <- reactive(function(){
          Residuals <- forecastModel()$residuals
          return(Residuals)
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
          yLabel <- c("MW")
          xLabel <- c("Weeks")
          plot(forecastModel(), 
               xlab = xLabel, ylab = yLabel,
               main="Forecast of NYC load (MW)", 
               xlim=xlim)
          })
     
     # Display some of the forecast residuals in a table
     output$view <- reactiveTable(function() {
           numberOfRows <- input$numberOfObsToDisplay
           tableData <- tail(as.data.frame(forecastResiduals.ts()), n=numberOfRows)
           t(tableData)
           })

})


# Deprecated code (you may ignore) ----------------------------------------
# library(datasets)
# str(rock)
# str(cars)
# str(pressure)
#   captionText <- reactive(function() {
#     c("Units of MWh per hour")
#   })
#   
#   # Return the text for the caption
#   output$caption <- reactiveText(function() {
#     captionText()
#   })
