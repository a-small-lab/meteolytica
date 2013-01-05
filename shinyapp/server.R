#  File meteolyticaDemo/server.R
#  Server logic module for Meteolytica web app demo.
#  Created by A.A. Small 24 Dec 2012 based on Shiny's Mpg application.

library(shiny)       # Shiny web app
library(xts)         # Support for eXtensible Time Series structures
library(forecast)    # Automated forecasting analytics
library(fpp)         # Example datasets


beer <- ausbeer


# ProjectID <- c("(Name of user)",
#                "Load",
#                "NYC-temp+load-hourly-feb2005--may2008.csv",
#                "Forecasting electric power load in New York City"
#                )
# 
# UserName <-          ProjectID[1]
# ProjectName <-       ProjectID[2]
# UserDataCSVFile <-   ProjectID[3]
# projectTitle <-      ProjectID[4]

# Retrieve and transform user's outcomes data -----------------------------------

#  Identify files containing the load data.
# PathFromRoot <- c("/Users/arthursmalliii/Documents/Google\ Drive/meteolytica")
# UserDataDirectory <- paste("Data/Outcomes",ProjectName, sep="/")
# outcomesDataCSVFile <- paste(PathFromRoot,UserDataDirectory,UserDataCSVFile,sep="/")
#outcomesDataCSVFile <- UserDataCSVFile

#  Read user's outcomes data from file, creating a data frame
#NYC.temp.load <- read.table(outcomesDataCSVFile, header = TRUE, sep = ",")

# cleanDf() is a utility that cleans data uploaded by user
#funk <- c("cleanDf.R")
# source(funk)    


# BEGIN SHINY SERVER()  ----------------------------------------------------

shinyServer(function(input, output) {
       
# PREDICTAND HISTORY: Collect, organize, and display data and meta-data --------

# > Collect and organize data and meta-data describing predictand history ------
  
  # Identify the time series of historical outcomes data according to user's selection
  predictandHistoryTs <- reactive(function(){
    tSeries <- get(input$dataset)
    return(tSeries)
  })
  
  # Assemble xts object containing data & meta-data for predictand history
  predictandHistoryXts <- reactive(function(){
    data <- get(input$dataset)
    return(as.ts(taylor))
#     frequency <- NULL # Need to code fcn() to establish time series frequency
#     xts(data,
# #      order.by = index(data),
#       frequency = frequency,
#       unique = TRUE,
#       tzone = "GMT")
  })
  
#   # Draft code shell for more advanced version of predictandHistoryTs() that allows
#   # user option to upload own dataset
#   predictandHistoryTs <- reactive(function(){
#     if(input$upload==FALSE){
#       tSeries <- get(input$dataset)
#       return(tSeries)
#     }  else  {
#       if(is.null(input$file)) {
#         return(NULL)
#       } else {
#         # cleanFile <- clean(input$file, ...) # Need to write cleaning utility function 
#         # tSeries <- as.ts(cleanFile, ... )   # (...) = parameters from meta-data
#         # return (tSeries)
#         return(NULL)
#       }
#     }
#   })

# > Generate plots and reports describing predictand history -------------------
  
  # Create plot of historical outcomes data
  output$predictandHistoryTsPlot <- reactivePlot(function(){
    tSeries <- predictandHistoryTs()
    plot(tSeries)
    })

  #  Print out a summary description of the time series
  output$predictandHistoricalTsSummary <- reactivePrint(function() {
    return(summary(predictandHistoryTs()))
    })  
  
  # Make a table showing the first few and last few elements in the series
  output$predictandHistoricalTsHead <- reactivePrint(function(){
    tSeries <- predictandHistoryTs()
    head <- head(as.data.frame(tSeries), n=20)
    return(head)
    })
  
  #  Decompose the time series into trend, seasonal and random components,
  #  and generate a plot of a decomposed time series
  predictandHistoryStl <- reactive(function(){
    # NEEDED HERE: test whether predictand ts is periodic, & only apply stl() if true
    return(stl(predictandHistoryTs(), s.window='periodic'))
       })

  output$predictandHistoryStlPlot <- reactivePlot(function(){  
            return(plot(predictandHistoryStl()))          
       })
  

# FORECASTING MODEL: Generate model and reports  -----------------------------------------

# > Engine for generating forecasting model ------
  
  #  Use forecast() function to create a forecasting model 
  #  based (for now) only on user-supplied data 
  forecastModel <- reactive(function(){
    fcastModel <- forecast(predictandHistoryStl())
    return(fcastModel)
    })

  
# > Reports on forecasting model ------
  
  # Generate a plot of the tail of obs + forecast
  output$forecastPlot <- reactivePlot(function() {
#           endPt <- end(outcomesTs())[1]+end(outcomesTs())[2]/(24*365)
# #          xlim <- c(endPt-input$trainingPeriods, endPt+input$display_periods)
# #          xlim <- c(endPt-, endPt+input$display_periods*24*7)
#           xlim <- c(endPt - 3/52, endPt + 2/52)
# 
#           xlab <- c("Weeks")
#           ylab <- c("MW")
    plot(forecastModel()
      #, 
#                xlab = xlab, ylab = ylab,
# #               xlim=xlim,
#                main=as.character(end(outcomesTs()))
# #               main=projectTitle
      )
    })

  

# MODEL EVALUATION --------------------------------------------------------
  
  # Display some of the forecast residuals in a table
  output$accuracy <- reactiveTable(function() {
    forecastAccuracy <- accuracy(forecastModel())
    return(as.table(forecastAccuracy))       
    })


# MODEL EXPORT and app testing area  -------------------------------------------

  # General-use testing function
  output$testOutput <- reactivePrint(function(){
    expression <- str(input)
    expressionText <- as.character(expression)
    #return(paste(expressionText,expression))
    as.character(predictandHistoryXts())
    as.character(xtsible(taylor))
  })

}) #############################################
######  END ShinyServer()             ########## 

######  DEPRECATED CODE (you may ignore)  ######  

#      # Return the text for the main title of the page
#      output$projectTitle  <- reactiveText(function() {
#           projectTitle
#           })

#   captionText <- reactive(function() {
#     c("Units of MWh per hour")
#   })
#   
#   # Return the text for the caption
#   output$caption <- reactiveText(function() {
#     captionText()
#   })

#           seasonal.ts <- decomposeTs()$seasonal
#           trend.ts <- decomposeTs()$trend
#           forecastSeasonals <- forecast(seasonal.ts)
#           Model <- seasonal.ts*trend.ts
#
#          outcomes.ts <- outcomesTs()
#startOfTrainingWindow <-end(outcomes.ts)-input$trainingPeriods-input$testingPeriods
#endOfTrainingWindow <- startOfTrainingWindow + input$trainingPeriods
#           outcomes.ts <- window(outcomes.ts, 
#                                start=end(outcomes.ts)-24*7*input$trainingPeriods, 
#                                end=end(outcomes.ts))
#          forecastModelOut <- forecast(outcomes.ts)

#      forecastResiduals.ts <- reactive(function(){
#           Residuals <- forecastModel()$residuals
#           return(Residuals)
#      })


# Convert outcomes data into a time series object, with parameters as
# specified by user.
#      outcomesTs <- reactive(function(){
# #          #     Convert text dates into R's internal "Date" class
# #           outcomes.df$Date <- as.Date(outcomes.df$Date,'%m/%d/%Y')
# #           outcomes.df$Date[1]
#           outcomes.ts <- ts(data = outcomesDf()[, 4], 
#                             start = 2005,
#                             frequency = 7)
# #          outcomes.ts <- window(outcomes.ts, start=2000)
#           return(outcomes.ts)    # Return time series object
#      })

#      # Generate a plot of the tail of obs + forecast
#      output$forecastPlot <- reactivePlot(function() {
#           endPt <- end(outcomesTs())[1]+end(outcomesTs())[2]/(24*365)
# #          xlim <- c(endPt-input$trainingPeriods, endPt+input$display_periods)
# #          xlim <- c(endPt-, endPt+input$display_periods*24*7)
#           xlim <- c(endPt - 3/52, endPt + 2/52)
# 
#           xlab <- c("Weeks")
#           ylab <- c("MW")
#           plot(forecastModel(), 
#                xlab = xlab, ylab = ylab,
# #               xlim=xlim,
#                main=as.character(end(outcomesTs()))
# #               main=projectTitle
#                )
#           })

