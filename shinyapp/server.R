#  File meteolyticaDemo/server.R
#  Server logic module for Meteolytica web app demo.
#  Created by A.A. Small 24 Dec 2012 based on Shiny's Mpg application.

library(shiny)
library(forecast)

ProjectID <- c("(Name of user)","Load","NYC-temp+load-hourly-feb2005--may2008.csv",
              "Forecasting electric power load in New York City")
UserName <-          ProjectID[1]
ProjectName <-       ProjectID[2]
UserDataCSVFile <-   ProjectID[3]
ProjectTitle <-      ProjectID[4]

# Retrieve and transform user's outcomes data -----------------------------------

#  Identify files containing the load data.
PathFromRoot <- c("/Users/arthursmalliii/Documents/Google\ Drive/meteolytica")
UserDataDirectory <- paste("Data/Outcomes",ProjectName, sep="/")
outcomesDataCSVFile <- paste(PathFromRoot,UserDataDirectory,UserDataCSVFile,sep="/")

#  Read user's outcomes data from file, creating a data frame
NYC.temp.load <- read.table(outcomesDataCSVFile, header = TRUE, sep = ",")

# Clean outcomes series and convert it to a time series object

funk <- paste(PathFromRoot,"R/outcomes.df2ts.R",sep="/")
source(funk)    
NYC.load.ts <- outcomes.df2ts(NYC.temp.load)

# Create a much shorter time series, to make the computations run faster during development.
NYC.load.ts <- window(NYC.load.ts, start=168)

# Create forecasting models -----------------------------------------------

#  Create a load forecasting model using the forecast() package, 
#  based only the load time series
system.time(NYC.load.forecast <- forecast(NYC.load.ts))

#  Plot forecast
# plot(NYC.load.forecast, main="Forecast of NYC load (MW)", xlim=c(170,175))

# ShinyServer Function ----------------------------------------------------

# Define server logic required to plot forecast
shinyServer(function(input, output) {
  
  # Return the text for the main title of the page
  output$projectTitle  <- reactiveText(function() {
       ProjectTitle
  })
  
  # Generate a plot of the forecast
  output$forecastPlot <- reactivePlot(function() {
       xlim <- c(170,172.8+input$display_periods)
       veritcalLabel <- c("MW")
       horizLabel <- c("Weeks")
       plot(NYC.load.forecast, 
            main="Forecast of NYC load (MW)", 
            xlim=xlim)
  })

})


# Deprecated code (you may ignore) ----------------------------------------

#   captionText <- reactive(function() {
#     c("Units of MWh per hour")
#   })
#   
#   # Return the text for the caption
#   output$caption <- reactiveText(function() {
#     captionText()
#   })
