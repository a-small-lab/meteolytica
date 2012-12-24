# Learning how to use the shiny package in R. First app.
library(shiny)
library(datasets)
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

# We tweak the "am" field to have nicer factor labels. Since this doesn't
# rely on any user inputs we can do this once at startup and then use the
# value throughout the lifetime of the application
mpgData <- mtcars
mpgData$am <- factor(mpgData$am, labels = c("Automatic", "Manual"))

# Define server logic required to plot various variables against mpg
shinyServer(function(input, output) {
  
  # Compute the forumla text in a reactive function since it is 
  # shared by the output$caption and output$mpgPlot functions
  formulaText <- reactive(function() {
    paste("mpg ~", input$variable)
  })
  
  # Return the formula text for printing as a caption
  output$caption <- reactiveText(function() {
    formulaText()
  })
  
  # Generate a plot of the requested variable against mpg and only 
  # include outliers if requested
  output$mpgPlot <- reactivePlot(function() {
       plot(NYC.load.forecast, main="Forecast of NYC load (MW)", xlim=c(170,175))
#      hist(rnorm(100 + 100*input$outliers))
#     boxplot(as.formula(formulaText()), 
#             data = mpgData,
#             outline = input$outliers)
  })

#  output$projectTitle <- ProjectTitle
  # Return the text for the main title of the page
  output$projectTitle  <- reactiveText(function() {
       ProjectTitle
  })
  
})