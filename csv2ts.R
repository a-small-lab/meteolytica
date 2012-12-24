# Function csv2ts:
# A function that converts a CSV file containing user outcomes into
# a time series object. Includes utilities for data checking and cleaning.

csv2ts <- function(csvFile){
     #  Perform transformations on user data:
     #   - Convert text dates + times into date-times in the POSIXt class
     #   - Replace initial_datetime with new column of forecast lead/lag times
     #   - Add new column labels
     #   - Reshape data frame into table by validTime, leadTime
}