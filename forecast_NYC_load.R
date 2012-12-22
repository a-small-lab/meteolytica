#  File forecast_NYC_load.R.
#  Copyright 2012 by Venti Risk Management.
#  Created by A.A. Small, III, November, 2012
#  
#  A program to estimate the structural relationships between temperature and
#  electric power load for a single region, and to generate preditive
#  distributions of electric power load. To be used as the basis for a planned
#  demo in the form of a Shiny-based web app. 


# Initialize the workspace ------------------------------------------------
library(forecast)

ProjectID = c("arthursmalliii","Power_load","NYC-temp+load-hourly-feb2005--may2008.csv")
UserName =     ProjectID[1]
ProjectName =  ProjectID[2]
UserDateFile = ProjectID[3]
#  Identify files containing the raw data
UserDataDirectory = paste("/Users",UserName,"Dropbox/Research_Projects/Electricity-Load-Forecasting/Data", sep="/")
UserDateFile = paste(UserDataDirectory,UserDateFile,sep="/")


# Retrieve and transform data ------------------------------------------------------
NYC.temp.load <- read.table(UserDateFile, header = TRUE, sep = ",")

#	Convert text dates into R's internal "Date" class
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
#                  start     = 2005+1/12,
                  frequency = 7*24)
NYC.load.ts[1:100]
NYC.temp.load$Date[1]
plot(NYC.load.ts)
NYC.load.ts[is.na(NYC.load.ts)]

#  Create a load forecasting model using only the load time series
system.time(NYC.load.forecast <- forecast(NYC.load.ts))
#  Plot forecast
plot(NYC.load.forecast, main="Forecast of NYC load (MW)", xlim=c(170,175))


############################

#  Create a second load forecasting model using temperature as a regressor
#  First convert both load and temp series into a ts object
load <- ts(NYC.temp.load$Load.MW, frequency = 8760, start = c(2005, 30*24))
plot(load)

temp <- ts(NYC.temp.load$Temp.Faren, frequency = 7*24)


plot(temp)
system.time(load.forecast <- forecast(load))
plot(load.forecast)

load.forecast2 <- forecast(load, xreg = temp)


#  Use stl() to create seasonal decomposition of load time series:
fit <- stl(NYC.load.ts[!is.na(NYC.load.ts)])
plot(fit)



#  Now try to add temperature
temp <- ts(NYC.temp.load$Temp.Faren,
           start     = 2005+1/12,
           frequency = 8760)
temp           
NYC.load.forecast.arima <- Arima(NYC.load.ts[!is.na(NYC.load.ts)], xreg=temp[!is.na(NYC.load.ts)]) 
plot(NYC.load.forecast.arima)

nyc.data.ts <- ts(c(temp,load))
rm(nyc.data.ts)

## NYC.load.forecast.truncated <- window(NYC.load.forecast, start=2008)
## plot(NYC.load.ts.truncated)



### 	Describe the structure of the NYC.temp.load data frame:
###   names(NYC.temp.load)
###   str(NYC.temp.load)

#	Select out only the weekdays
NYC.temp.load.workdays = NYC.temp.load[weekdays(NYC.temp.load$Date) != "Saturday" & weekdays(NYC.temp.load$Date) != "Sunday", ]
### workdays <- weekdays(NYC.temp.load.workdays$Date)
### unique(workdays)
### plot(NYC.temp.load.workdays$Temp.Faren,NYC.temp.load.workdays$Load.MW, xlab="Hourly observed temperature (degrees F)", ylab="Total load for New York City (MW)", main="Scatterplot of temp v. load, weekdays, 1/31/2005 - 5/31/2008")

#	Select out only the hours 4-5pm on weekdays
NYC.temp.load.workdays.17 = NYC.temp.load.workdays[NYC.temp.load.workdays$Hour == 17, ]

#	For convenience, assign shorter names to relevant data series of weather and outcomes variables
temp <- NYC.temp.load.workdays.17$Temp.Faren
load <- NYC.temp.load.workdays.17$Load.MW

#########	MODULE: CHARACTERIZE THE OUTCOMES DATA #########
#	This module creates a general characterization of the data set supplied by the user.
#  Summary statistics are computed for (potential) use in variable identification and preliminary model selection.

#####	DEMO: 
summary(load)
#  Make a box plot:
boxplot(load)
# 	Plot a histogram of the electricity load data:
hist(load, 50)

######### MODULE: CONSULT LOOK-UP TABLE TO IDENTIFY CANDIDATE EXPLANATORY VARIABLES #########
#  "Where the rubber really starts to meet the road."
#  
#  This module identifies a subset of weather and other variables as candidates
#  that are likely to have explanatory power in a model of the user's specified
#  outcomes variable(s).
#  
#  The module performs as follows: A look-up table is used to translate
#  user-supplied meta-data, summary characteristics of the user-supplied data,
#  and user-supplied preference parameters into a list of variables in our
#  database (weather observations, weather forecasts, and non-weather economic
#  variables) that are likely to have explanatory power for this application.

#    INPUT:   Project meta-data, summary values of project data, and (possibly) user preference parameters.
# 	RETURN:
#    - A list of candidate explanatory weather variables.
#    - A list of candidate explanatory auxiliary variables.
#    - Expressions representing the available prior information concerning the probabilities
#    that any given explanatory variable, or combination of variables, is likely to be
#    significant.
#    - Expressions for one or more structured queries that will retrieve the required
#    explanatory data from Meteolytica's internal databases.

#   [George Young's code goes here]

#####	DEMO: 
#  In our simple example, we simply assume that our sole explanatory variable is: concurrent
#  observed temperature. In lieu of mishigoss around the lookup table, we'll symbolize the
#  search for explanatory variables by making a scatterplot of the outcomes data vs.
#  concurrent temperature:

plot(temp,load, xlab="Hourly observed temperature (degrees F)", ylab="Total load for New York City (MW)", main="Scatterplot, temp v. load, 4-5pm, weekdays 1/31/2005 - 5/31/2008")

######### MODULE:   RETRIEVE HISTORICAL DATA FOR CANDIDATE VARIABLES #########

#   Historical time series of candidate variables are retrieved from Meteolytica's internal databases.
#   A data frame populated with these historical values is passed back to the main program.

#  INPUT:   Expressions for one or more structured queries that will retrieve the required explanatory data from 
#           Meteolytica's internal databases.
#  RETURN:  A data frame (or other object) containing these data.


######  Identify the directories containing main archives of weather data and socioeconomic data:
#  Meteolytica will rely on core databases of weather and other data that are not specific
#  to any particular user or application. Some of the most intricate parts of the system
#  will involve the tasks of identifying and extracting the subsets of these databases that
#  are needed for each particular project or application.

#  DEMO: For this demo, the weather data are simply read in along with the power load data.
#  But just in the spirit of the thing, we'll identify a directory as the location of our weather data archive.
#  For this demo, we'll set the weather data directory be the same as the user data directory. 
#  Note that this directory path is stable across applications: it does not depend (formally) on the identify of the individual user or project application. (In just happens, in this demo, to be the same as the user data directory.)
WeatherDataDirectory = "/Users/arthursmalliii/Dropbox/Research_Projects/Electricity-Load-Forecasting/Data"

#  In other applications, we might also have use of a separate database of socioeconomic data.Here, we don't.
#  SocioeconomicDataDirectory = "/Users/arthursmalliii/Dropbox/Research_Projects/Electricity-Load-Forecasting/Data"


# 2. Develop predictive model --------------------------------------------------------

######### MODULE: APPLY PRELIMINARY FILTER TO SCREEN OUT UNPROMISING CANDIDATE EXPLANATORY FACTORS #########
#  This sub-module implements one or more procedures for variable selection.
#  The goal is to weed out irrelevant or redundant candidate explanatory variables, allowing us thereby to narrow our focus to (a.k.a. "down-select for") a subset of the candidates deemed "promising". 
#  When fully articulated, the code will offer multiple alternative procedures, e.g., classical hypothesis testing, sequential down-selection, Bayesian variable selection. 

#  The code implements first-pass, not-necessarily-the-cleverest-or-most-appropriate estimation procedures and tests for explanatory power, incorporating not-necessarily-the-cleverest-or-most-appropriate modeling assumptions. 
#  More careful model structuring, parameter estimation and diagnostics are deferred to subsequent modules.

##### DEMO:
#  For demo purposes, we suppose that the look-up table has recommended four variables as candidate explanatory factors: temp, temp^2, temp^3,and temp^4.

#  Let Y (= load) denote the vector containing historical values of dependent variables:
Y <- load 

#  Let X = [temp,temp^2,temp^3,temp^4] denote the matrix containing values of candidate explanatory variables:
#     - Create a matrix containing historical data for candidate explanatory variables:
X <- cbind(temp,temp^2,temp^3,temp^4)           

#     - Assign names to the columns of this matrix: (In a fully articulated program, these variable names would be retrieved from the look-up table and passed along. For this simple demo, we simply assign them:)
colnames(X) <- c("temp", "temp^2", "temp^3", "temp^4")   

### dim(X); X[2, ]; str(X)                           # Display some basic info about this matrix

### Sub-module: Option 1: Variable selection via classical hypothesis testing ---------------------------------
#  An oldie but reasonably goodie: Perform an ordinary least squares regression on a linear version of the model, using all candidate variables as explanatory factors and assuming that errors are independent and identically normally distributed. Test variables for significance. Throw out variables that fail to show significance at at-least a specified threshold level (e.g., 10%).

#  DEMO: Perform linear regression of load data onto explanatory factors; store result as "lm.Y.X"
lm.Y.X <- lm(Y~X)
# Present summary information characterizing the model: summary(lm.Y.X)
str(lm.Y.X)
boxplot(lm.Y.X$residuals)
hist(lm.Y.X$residuals, 20)

#  Let b = [b_0,b_1,b_2,b_3,b_4]' denote the 5x1 vector of estimated values for model parameters.
b <- lm.Y.X$coefficients

#  Let z be a 5x1 vector of indicator variables, where z[k] equals either 1 or 0 
#  depending on whether the factor temp^(k-1) is included in the regression equation.
#  Each value of z corresponds to one element in the set of all possible combinations of candidate variables.
#  Hence all of our models can be nested as instances of the general form: Y = zbX + e

#  Variable selection involves choosing one (or more) of these values for z from the 2^5 = 32 potential cases.

### Sub-module: Option 2: Bayesian variable selection ---------------------------------
#  This sub-module implements a Bayesian procedure for variable selection.

#  Let z be a 5x1 vector of indicator variables, where z[k] equals either 1 or 0 
#  depending on whether the factor temp^(k-1) is included in the regression equation.
#  Each value of z corresponds to one element in the set of all possible combinations of candidate variables.
#  Hence all of our models can be nested as instances of the general form: Y = zbX + e
#  Variable selection involves choosing between these potential values for z.
#  We aim to reduce the number of possible z-values down to a manageable number of cases, to which we then apply more detailed analysis in later modules.
#  
#  We consider three cases: z = [1 1 1 0 0], z = [1 1 1 1 0], and z = [1 1 1 1 1].

### [To be continued... ]

#########	MODULE: IDENTIFY FORMS FOR CANDIDATE STATISTICAL MODELS #########
#   Given a list of promising explanatory variables, this module identifies a set of possible forms (formulae + specification of the error process) for the corresponding statistical model. 

#  INPUT:   - An object containing the user-supplied data series
#           - An object containing the retreived data series for promising explanatory factors
#           - [In the Bayesian case:] Expressions representing any available prior information concerning the probabilities 
#              that a given explanatory variable, or combination of variables, is like to be significant 
# 	RETURN:  - A list of candidate forms for the statistical model
#           - [In the Bayesian case:] For each candidate model: expressions representing updated information about distributions over model parameters 

#   [George Young's code goes here]


#####	DEMO:	In this example, we have simply assumed that the data are generated by a polynomial model.
#     The set of candidate models includes three possibilities: either...
#  	   - quadratic:  load = b_0 +b_1*temp +b_2*temp^2 + error
#  	   - cubic:      load = b_0 +b_1*temp +b_2*temp^2 + b_3*temp^3 + error
#  	   - or quartic: load = b_0 +b_1*temp +b_2*temp^2 + b_3*temp^3 + b_4*temp^4 + error

### [To be continued... ]

#########	MODULE: ESTIMATE PARAMETER VALUES FOR CANDIDATE STATISTICAL MODELS #########
#  By this point we have: 
#     (i) based on information in our look-up table, identified a set of variables as candidates worthy of consideration as potential explanatory factors;
#     (ii) applied variable section procedure(s) to weed out irrelevant or redundant candidates, allowing us to narrow our focus to (a.k.a. "down-select") a subset of the candidates deemed "promising";
#     (iii) based in part of information in our look-up table, and also possibly on the results of machine learning procedures: identified a set of candidate model forms that incorporate the promising variables as potential explanatory factors. 
#           - A model form includes: a formula that describes the relationship between the dependent variable and a vector of explanatory factors, plus a characterization of the error process.
#     (iv) based in part of information in our look-up table, and also possibly on the results of machine learning procedures: identified, for each candidate model, one or more prefered procedures for estimating model parameters (e.g., OLS, 3-stage GLS, genetic algorithm).

#  In this module, each candidate model in turn, the recommended estimation procedures are applied to the data to compute estimated values for the model explanatory parameters.


#   [George Young's code goes here]

#####	DEMO:
# Apply linear regression analysis using a quadratic model
lm.load <- lm(load ~ temp + I(temp^2))		# Form a linear model: load = b_0 +b_1*temp +b_2*temp^2 + error

# Alternative: Perform linear regression analysis using a cubic model...
lm.load <- lm(load ~ temp + I(temp^2) + I(temp^3))		# Form a linear model: load = b_0 +b_1*temp +b_2*temp^2 + b_3*temp^3+ error
# ... or a quartic model:
lm.load <- lm(load ~ temp + I(temp^2) + I(temp^3) + I(temp^4))

######### MODULE: PERFORM MODEL DIAGNOSTICS #########

#	In this module, each candidate model is subject in turn to a number of tests. These tests serve several purposes:
#	- They generate a characterization of the model's quality and performance, i.e., its ability to serve as a basis for forecasting.
#	- They provide indications of specific problems with the model, e.g. heteoskadstic or autocorrelated errors, that may indicate that 
#		the model is mis-specified.
#	- They may point to directions in which the model may be improved.
#	- The diagnostics can be used to select between candidate models, or to suggest that a weighted average be used.

# Characterize model's performance in overview:

# Plot a histogram of residuals. Ideally, want a bell curve centered at zero:
hist(resid(lm.load), 50)

# 	Plot explanatory variable versus residuals. 
#	Ideally, residuals should be evenly distributed around zero at all values of the explanatory variable: 
#####	DEMO:
plot(temp,resid(lm.load), pch=3, cex=0.5)
#		Demo plot suggests that the quadratic model falls short of the ideal: 
#		the quadratic model shows evidence of conditional biased and heteroskedastic errors.
#		The quartic model appears to be conditionally unbiased (more or less), but still has heteroskedastic errors:
#		residuals are much larger in magnitude for higher temps.
#		Suggests that the model is mis-specified, errors should perhaps be multiplicative, not additive.
#		Or (better), should have two different models, one for heating days (temp < 65), another for cooling days (temp > 65).	

### plot(fitted(lm.load),resid(lm.load), pch=3, cex=0.5)		# Plot fitted points versus residuals

#	"Are errors heteroskedastic?"

#	"Are errors auto-correlated"

#	"Are errors normally distributed?"
qqnorm(resid(lm.load), pch=1, cex=0.5)			# Make of q-q plot of the residuals
# The closer this is to a straight line, the more approximately normal are the residuals
# 	Now explore some conditional distributions.
# 	Select out only those records for which temperatures lie within a specified band:
tcenter = 87
twidth = 3
temp.conditional <- lm.load$model$temp[lm.load$model$temp >= tcenter-twidth & lm.load$model$temp <= tcenter+twidth]
load.conditional <- lm.load$model$load[lm.load$model$temp >= tcenter-twidth & lm.load$model$temp <= tcenter+twidth]
resid.conditional <- lm.load$residuals[lm.load$model$temp >= tcenter-twidth & lm.load$model$temp <= tcenter+twidth]
unique(resid.conditional)
hist(resid.conditional, 25)
boxplot(resid.conditional, pch=3, cex=0.5)

### hist(lm.load$residuals, 30)
lm.load$fitted.values[1:20]
### names(lm.load)
### str(lm.load)
### hist(lm.load$model$temp, 20)

######### MODULE: SELECT `WINNING' MODEL (OR WEIGHTED MODEL AVERAGE) #########

#  (Applying Akaike's Information Criterion, select a single best model OR a weighted model average)

# 3. Analyze model's performance ----------------------------------------------------


# 4. Generate reports and graphics ----------------------------------------------------


#########	MODULE: REPORT RESULTS OF MODELING #########

#   [George Young's code goes here]

##### DEMO:
summary(lm.load)      					# Display summary statistics about this model

# For quadratic and quartic model, all coefficients are highly significant
# Interestingly, for cubic model, coefficent b_1 on temp is not significant

#########	MODULE: GENERATE GRAPHICS  #########


##### DEMO:
#	Add confidence intervals and prediction intervals to the figure 
#	First, create a new data frame in which temperatures are in sequential order
pred.frame = data.frame(temp=min(temp):max(temp))
#	Next, estimate confidence intervals and prediction intervals around regression line
pp <- predict(lm.load, int="p", newdata = pred.frame)
pc <- predict(lm.load, int="c", newdata = pred.frame)

#	Make a scatterplot, setting y-axis range wide enough to encompass the entire prediction interval, and choosing a less aggressive style and size for the plot points:
plot(temp,load, ylim=range(load,pp,na.rm=TRUE), pch=3, cex=0.5, xlab="Temperature at La Guardia Airport (degrees F)", ylab="New York City aggregrate power consumption (MW)", main="New York City electicity demand versus temperature, 4-5pm on weekdays")
#	To the above graph, add dashed lines representing confidence intervals and prediction intervals:
pred.temp = pred.frame$temp
matlines(pred.temp, pp, lty=c(1,3,3), col="black")
matlines(pred.temp, pc, lty=c(1,2,2), col="grey")


###	abline(lm.load)								# Add the regression line to the scatterplot -- only works for simple, univariate linear model
###	segments(temp,fitted(lm.load),temp,load)	# Show residuals as line segments off regression line



# 5. Create, test and export model as PMML document ----------------------------------------------------


# 5.1   Export model as PMML document -------------------------------------------------

# Load the required R libraries
library(pmml);
library(XML);

lm.load.pmml <- pmml(lm.load)
xmlFile <- file.path(getwd(),"load-lm.xml")
saveXML(lm.load.pmml,xmlFile)

# # Read in audit data and split into a training file and a testing file
# auditDF <- read.csv("http://rattle.togaware.com/audit.csv")
# auditDF <- na.omit(auditDF)              # remove NAs to make things easy
# 
# target <- auditDF$TARGET_Adjusted       # Get number of observations
# N <- length(target); M <- N - 500  
# i.train <- sample(N,M)                  # Get a random sample for training
# audit.train <- auditDF[i.train,]
# audit.test  <- auditDF[-i.train,]
# 
# # Build a logistic regression model
# glm.model <- glm(audit.train$TARGET_Adjusted ~ .,data=audit.train,family="binomial")
# 
# # Describe the model in PMML and save it in an AML file
# glm.pmml <- pmml(glm.model,name="glm model",data=trainDF)
# xmlFile <- file.path(getwd(),"audit-glm.xml")
# saveXML(glm.pmml,xmlFile)
# 

# 5.2   Test PMML-encoded model -------------------------------------------------------


# 5.3  Upload PMML document to production platform ------------------------------------


######### END OF DOCUMENT ########
