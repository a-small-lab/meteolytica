# Function csv2ts:
# A function that converts a CSV file containing user outcomes into
# a time series object. Includes utilities for data checking and cleaning.

csv2ts <- function(csvFile){
     #  Perform transformations on user data:
     NYC.temp.load <- read.table(csvFile, header = TRUE, sep = ",")
     
     #     Convert text dates into R's internal "Date" class
     NYC.temp.load$Date <- as.Date(NYC.temp.load$Date,'%m/%d/%Y')
     
     #  Check for missing values in the load series
     NYC.temp.load[is.na(NYC.temp.load$Load.MW), ]
     
     #  Perform ad-hoc plugs of missing values
     NYC.temp.load$Load.MW[6727] <- (NYC.temp.load$Load.MW[6728]+NYC.temp.load$Load.MW[6728])/2
     NYC.temp.load$Load.MW[6727]
     NYC.temp.load$Load.MW[14992] <- (NYC.temp.load$Load.MW[14993]+NYC.temp.load$Load.MW[14991])/2
     NYC.temp.load$Load.MW[14992]
     
     #  Check for impossibly low values in the load series
     NYC.temp.load[NYC.temp.load$Load.MW < 1000, ]
     
     #  Check for missing values in the temperature series
     NYC.temp.load[is.na(NYC.temp.load$Temp.Faren), ]
     #  None!
     
     #  Convert NYC load series into a time series object
     NYC.load.ts <- ts(NYC.temp.load$Load.MW, 
                       # start     = 2005+1/12,
                       frequency = 7*24)
     NYC.load.ts
     # NYC.temp.load$Date[1]
     # plot(NYC.load.ts)
     # NYC.load.ts[is.na(NYC.load.ts)]
}