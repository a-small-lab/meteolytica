#  Function outcomes.df2ts
#  Created 24 Dec 2012 by A.A. Small

#  A function that converts a data frame containing user outcomes into
#  a time series object. Includes utilities for data checking and cleaning.
#  Abstracted from forecast_NYC_load.R.
#  Version of 2012-12-24 includes legacy labels specific to NYC load forecasting.

outcomes.df2ts <- function(outcomes.df){
     #  Perform transformations on data frame user data:
#     outcomes.df <- read.table(outcomes.df, header = TRUE, sep = ",")
     
     #     Convert text dates into R's internal "Date" class
     outcomes.df$Date <- as.Date(outcomes.df$Date,'%m/%d/%Y')
     
     #  Check for missing values in the load series
     outcomes.df[is.na(outcomes.df$Load.MW), ]
     
     #  Perform ad-hoc plugs of missing values
     outcomes.df$Load.MW[6727] <- (outcomes.df$Load.MW[6728]+outcomes.df$Load.MW[6728])/2
     outcomes.df$Load.MW[14992] <- (outcomes.df$Load.MW[14993]+outcomes.df$Load.MW[14991])/2
     
#      #  Check for impossibly low values in the load series
#      outcomes.df[outcomes.df$Load.MW < 1000, ]
#      
#      #  Check for missing values in the temperature series
#      outcomes.df[is.na(outcomes.df$Temp.Faren), ]
#      #  None!
     
     #  Convert outcomes series into a time series object
     outcomes.ts <- ts(outcomes.df$Load.MW, 
                       # start     = 2005+1/12,
                       frequency = 7*24)
     outcomes.ts    # Return time series object
     # outcomes.df$Date[1]
     # plot(NYC.load.ts)
     # NYC.load.ts[is.na(NYC.load.ts)]
}