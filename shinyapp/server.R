#  File meteolyticaDemo/server.R
#  Server logic module for Meteolytica web app demo.
#  Created by A.A. Small 24 Dec 2012 based on Shiny's Mpg application.

library(shiny)       # Shiny web app
library(shinyIncubator)
library(xts)         # Support for eXtensible Time Series structures
library(forecast)    # Automated forecasting analytics
library(fpp)         # Example datasets


# Package prepared examples as xts objects
dts.taylor <- seq(from=ISOdate(2005,6,5), by='30 min', length.out=NROW(taylor))
taylor.xts <- xts(taylor, order.by=dts.taylor)
xtsAttributes(taylor.xts) <- list(
  frequency=frequency(taylor),
  msts=attr(taylor,'msts'),
  title="Electricity consumption in England and Wales", 
  predictandName="Load",
  units="MW", 
  location="United Kingdom"
)

str(taylor.xts)

beer <- ausbeer
dts.beer <-seq(from=ISOdate(1991,1,1), by='month', length.out=NROW(beer))
beer.xts <- xts(beer, order.by=dts.beer)
xtsAttributes(beer.xts) <- list(
  frequency=frequency(beer),
  title="Beer consumption in Australia", 
  predictandName="Beer",
  units="AUD, millions", 
  location="Australia"
)

str(beer.xts)

dts.a10 <-seq(from=ISOdate(1991,7,1), by='month', length.out=NROW(a10))
a10.xts <- xts(a10, order.by=dts.a10)
xtsAttributes(a10.xts) <- list(
  frequency=frequency(a10),
  title="Consumption of pharmaceuticals in Australia, category A10", 
  predictandName="Sales",
  units="AUD, millions", 
  location="Australia"
  )


# A function for generating artificial xts time series object with known 
# periodicities. Defaults make series look kinda like NYC load series.
# Variant of above that returns an xts object
fakeLoadXts <- function(
    mean=5000,
    fday=24, fweek=7*fday, fyr=365*fday, f=fyr,
    aday=1000,aweek=1500,ayear=2000,anoise=500,
    start=ISOdate(2009,1,1),numyears=2, 
    seed=123,useSetSeed=FALSE){
  
  t <- as.vector(1:(fyr*numyears)) 
  xday <-  (sin(2*pi*t/fday))
  xweek <- (sin(2*pi*t/fweek))
  xyr <-   (sin(2*pi*t/fyr))
  if(useSetSeed==TRUE) set.seed(seed)
  x <- mean + ayr*xyr + aweek*xweek + aday*xday + anoise*rnorm(t)
  dts <- seq(from=start, by='hour', length.out=NROW(t))
  out.xts <- xts(x, order.by=dts) 
  xtsAttributes(out.xts) <- list(
    frequency=f,
    seasonal.periods=c(fday,fweek,fyr)
  )
  return(out.xts)
}


# Create artificial ts and xts objects for use in testing and debugging
test.xts <- fakeLoadXts(useSetSeed=FALSE)
xtsAttributes(test.xts) <- list(
  title="Test series", 
  predictandName="Widget sales", 
  units="USD, thousands", 
  location="Isla Incognita, PA"
  )


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
    df <- read.csv(as.character(input$uploadedFile[1]), header=TRUE)
    DateHour <- paste(as.character(df$Date),as.character(df$Hour))
    dateTime <- as.POSIXct(DateHour,format='%m/%d/%Y %H')
    
    # Identify which column has the predictand.
    predictandCol <- 4   # (plan to make this depend on user's choice)
    Xts <- xts(df[ ,predictandCol], order.by=dateTime, unique=TRUE, tzone="GMT")
    
    #  # Need hear: fcn() to establish time series frequency
    #  frequency = fcn(df[,predictandCol])
    
    #  Replace missing values using the spline() procedure
    #    (May add later: NA's generate a warning message)
    Xts <- na.spline(Xts)
    
    #  Add meta-data attributes
    xtsAttributes(Xts) <- list(predictandName=input$predictandName,
      title=input$title, units=input$units, location=input$location,
      uploadedFile=list(#header=TRUE
        name=as.character(input$uploadedFile[1]))
      )  
    return(Xts)
  })
  
  # [Output testing function] %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  output$testOutput <- reactivePrint(function(){
    Xts <- uploadedXts()
    return(as.character(#list(
      str(Xts)
    ))#)
  })
  ##%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  preloadedXts <- reactive(function(){
    xts <- get(paste0(input$dataset,".xts"))
    return(xts)
  })
    
  # Choose which data series to identify as the predictand, based on user's selections
  predictandXts <- reactive(function(){
    if(input$upload==FALSE) 
      return(get(paste0(input$dataset,".xts")))
    if(is.null(input$uploadedFile)) 
      return(test.xts)
    # otherwise...
    return(uploadedXts())
  })
  
  
# > Generate plots and reports describing predictand history -------------------
  
  # Create plot of historical outcomes data
  output$predictandHistoryTsPlot <- reactivePlot(function(){
    xts <- predictandXts()
    plot(xts)
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

