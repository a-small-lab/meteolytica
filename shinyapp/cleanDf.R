#  Function cleanDf
#  Created 27 Dec 2012 by A.A. Small

#  A utility function that cleans user data. Checks for missing or implausible values.
#  Tries to interpolate replacement values. 

cleanDf <- function(outcomes.df){
     
     #  Check for missing values in the outcomes series
     #  outcomes.df[is.na(outcomes.df$Load.MW), ]
     
     #  Perform ad-hoc plugs of missing values
     outcomes.df$Load.MW[6727] <- (outcomes.df$Load.MW[6728]+outcomes.df$Load.MW[6728])/2
     outcomes.df$Load.MW[14992] <- (outcomes.df$Load.MW[14993]+outcomes.df$Load.MW[14991])/2

     #  Check for impossibly low values in the load series
     #  outcomes.df[outcomes.df$Load.MW < 1000, ]      
     
     clean.df <- outcomes.df
     return(clean.df)
}