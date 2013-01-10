#  File meteolyticaDemo/server.R
#  Server logic module for Meteolytica web app demo.
#  Created by A.A. Small 24 Dec 2012 based on Shiny's Mpg application.

library(shiny)       # Shiny web app
library(shinyIncubator)
library(xts)         # Support for eXtensible Time Series structures
library(forecast)    # Automated forecasting analytics
library(fpp)         # Example datasets

beer <- ausbeer


# Initialize value to assure forecast is computed at program start-up


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

#  cleanDf() is a utility that cleans data uploaded by user
source("cleanDf.R")    


# Package prepared examples as xts objects
taylor.xts <- as.xts(taylor, dateFormat="POSIXct")
xtsAttributes(taylor.xts) <- list(
  title="Electricity consumption in England and Wales", 
  predictandName="Load",
  units="MW", 
  location="United Kingdom"
)

beer.xts <- as.xts(beer, dateFormat="POSIXct")

xtsAttributes(beer.xts) <- list(
  title="Beer consumption in Australia", 
  predictandName="Beer",
  units="AUD, millions", 
  location="Australia"
)

a10.xts <- as.xts(a10, dateFormat="POSIXct")
xtsAttributes(a10.xts) <- list(
  title="Consumption of pharmaceuticals in Australia, category A10", 
  predictandName="Sales",
  units="AUD, millions", 
  location="Australia"
  )

# A function for generating artificial time series with known periodicities.
# Default parameters chosen to make series look kinda like NYC load series.
fakeLoadTs <- function(mean=5000,fday=24, fweek=7*fday, fyr=365*fday, f=fyr,aday=1000,aweek=1500,ayear=2000,anoise=500,numyears=2, startYr=2005,startDay=1,seed=123,useSetSeed=FALSE){
  t <- as.vector(1:(fyr*numyears)) 
  xday <-  ts(sin(2*pi*t/fday),  start=c(startYr,startDay), frequency=f)  
  xweek <- ts(sin(2*pi*t/fweek), start=c(startYr,startDay), frequency=f)
  xyr <-   ts(sin(2*pi*t/fyr),   start=c(startYr,startDay), frequency=f)
  if(useSetSeed==TRUE) set.seed(seed)
  noise <- anoise*rnorm(t) 
  x <- mean + ayr*xyr + aweek*xweek + aday*xday + noise
  return(x)
}


# Create artificial ts and xts objects for use in testing and debugging
test.ts <- fakeLoadTs(useSetSeed=TRUE)
test.xts <- as.xts(test.ts, dateFormat="POSIXct")
xtsAttributes(test.xts) <- list(
  title="Widget sales", 
  predictandName="Widget sales", 
  units="USD, thousands", 
  location="Isla Incognita, PA"
  )

# 
# # An (mostly) empty xts will come in handy to prevent showing error messages
# #   during transitions between reactive Xts() objects
# empty.xts <- xts()
# xtsAttributes(empty.xts) <- list(title="", predictandName="", units="", location="")


# BEGIN SHINY SERVER()  ----------------------------------------------------

shinyServer(function(input, output) {
       
# PREDICTAND HISTORY: Collect, organize, and display data and meta-data --------

# > Collect and organize data and meta-data describing predictand history ------

  # Convert user's uploaded file into an xts (eXtensible Time Series) object
  uploadedXts <- reactive(function(){
    df <- read.csv(input$uploadedFile$name, header=TRUE)
    DateHour <- paste(as.character(df$Date),as.character(df$Hour))
    dateTime <- as.POSIXct(DateHour,format='%m/%d/%Y %H')
    predictandCol <- 4   # (plan to make this depend on user's choice)
    Xts <- as.xts(df[ ,predictandCol], order.by=dateTime, unique=TRUE, tzone="GMT")
    #  # Need hear: fcn() to establish time series frequency
    #  Replace missing values using the spline() procedure
    #    (May add later: NA's generate a warning message)
    Xts <- na.spline(Xts)
    #  Add meta-data attributes
    xtsAttributes(Xts) <- list( predictandName=input$predictandName,
      title=input$title, units=input$units, location=input$location)    
    return(Xts)
  })
  
  preloadedXts <- reactive(function(){
    xts <- as.xts(get(input$dataset))
    return(xts)
  })
    
  # Choose which data series to identify as the predictand, based on user's selections
  predictandXts <- reactive(function(){
    if(input$upload==FALSE){
      preloaded.xts <- get(paste0(input$dataset,".xts"))
      return(preloaded.xts)
    }
    if(is.null(input$file)) return(test.xts)
    # otherwise...
    return(uploadedXts())
  })
  
  # [Output testing function] %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  output$testOutput <- reactivePrint(function(){
    xts <- predictandXts()
    return(as.character(#list(
#      str(beer) 
      xtsible(test.ts),
      str(test.ts),
      str(xts)
#      str(beer.xts)
#      ,str(preloadedXts()),
#      ,str(xts)
    ))#)
  })
  ##%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
# > Generate plots and reports describing predictand history -------------------
  
  # Create plot of historical outcomes data
  output$predictandHistoryTsPlot <- reactivePlot(function(){
    plot(predictandXts())
  })

#   #  Print out a summary description of the time series
#   output$predictandHistorySummary <- reactivePrint(function() {
#     summary <- summary(predictandXts())
#     return(summary)
#   })  
  
  # Make a table showing the first few and last few elements in the series
  output$predictandHistoryTable <- reactiveTable(function(){
  #  window <- predictandXts()[startDate/endDate]
    df <- as.data.frame(predictandXts())
#    predname <- predictandXts()$predictandName
#    units <- predictandXts()$units
#    names(df) <- c(paste0(predname," (",units,")" ))
    return(head(df))
  })
  
  #  Decompose the time series into trend, seasonal and random components,
  #  and generate a plot of a decomposed time series
  predictandHistoryStl <- reactive(function(){
    # NEEDED HERE: test whether predictand ts is periodic, & only apply stl() if true
    return(stl(get(input$dataset), s.window='periodic'))
       })

  output$predictandHistoryStlPlot <- reactivePlot(function(){  
            return(plot(predictandHistoryStl()))          
       })
  

# FORECASTING MODEL: Generate model and reports  -----------------------------------------

# > Engine for generating forecasting model ------
  
  #  Use forecast() function to create a forecasting model 
  #  based (for now) only on user-supplied data 
  forecastModel <- reactive(function(){
    if (input$generateForecastButton == -1)
      return(NULL)
#   else
    return(isolate({
      # reset value of action button to prevent further un-requested recomputation of the expensive forecast code
      input$generateForecastButton <- -1      
      forecast(predictandHistoryStl())
    }))
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


# MODEL EXPORT   -------------------------------------------

  # Nothing to see here...  Move it along, folks...

  
# DEVELOPMENT and debugging  -----------------------------------------------
  
#   # General-use testing function
#   output$testOutput <- reactivePrint(function(){
# #    as.character(predictandHistoryXts())
# #    df <- read.csv(input$uploadedFile$name, header=TRUE)
# #    DateHour <- paste(as.character(df$Date),as.character(df$Hour))
# #    dateTime <- as.POSIXct(DateHour,format='%m/%d/%Y %H')
# #    Xts <- as.xts(df[ ,4], order.by=dateTime)
# #    window <- Xts['2007-01-01/']
# #    df <- as.data.frame(window)
# #    varnames=c("Load (MW)")
# #    names(df) <- varnames  
#     xts <- predictandXts()
#     return(c(
#       str(xts)
# #      str(attributes(xts))
#     ))
#   })

#############################################
})  ######   END ShinyServer()     ########## 
#############################################


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

