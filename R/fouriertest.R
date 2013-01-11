# A program for generating simulated time series with known periodicities.
# Designed to be used for testing and debugging Meteolytica's routines for 
# identifying periodicities of time series and generating forecasts.

# Basic set up: each time step represents one hour,
# create a time series with daily, weekly and annual periodicities.
# Designed to mimic, abstractly, variation in demand for electricity.
library(zoo)


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

test <- fakeLoadTs()
str(test)
xtsible(test)


# Variant of above that returns a zoo object
fakeLoadZoo <- function(mean=5000,fday=24, fweek=7*fday, fyr=365*fday, f=fyr,aday=1000,aweek=1500,ayear=2000,anoise=500,numyears=2, startYr=2005,startDay=1,seed=123,useSetSeed=FALSE){
  t <- as.vector(1:(fyr*numyears)) 
  xday <-  ts(sin(2*pi*t/fday),  start=c(startYr,startDay), frequency=f)  
  xweek <- ts(sin(2*pi*t/fweek), start=c(startYr,startDay), frequency=f)
  xyr <-   ts(sin(2*pi*t/fyr),   start=c(startYr,startDay), frequency=f)
  if(useSetSeed==TRUE) set.seed(seed)
  noise <- anoise*rnorm(t) 
  x <- mean + ayr*xyr + aweek*xweek + aday*xday + noise
  dts <- seq(from=ISOdate(2005,1,1), by='hour', length.out=NROW(t))
  z <- zoo(x, order.by=dts) 
  return(z)
}

z <- fakeLoadZoo()
str(z)
plot(z)
xtsible(z)
try.xts(z)


# Variant of above that returns an xts object
fakeLoadXts <- function(
  mean=5000,
#   seasonal = list(
#     periods = c(24,24*7,24*365),
#     frequency = max(periods)),
#   amplitudes = c(1000,1500,2000,500),
  fday=24, fweek=7*fday, fyr=365*fday, f=fyr,
  aday=1000,aweek=1500,ayear=2000,anoise=500,
  numyears=2, startYr=2005,startDay=1,seed=123,useSetSeed=FALSE){
  
  t <- as.vector(1:(fyr*numyears)) 
  xday <-  ts(sin(2*pi*t/fday),  start=c(startYr,startDay), frequency=f)  
  xweek <- ts(sin(2*pi*t/fweek), start=c(startYr,startDay), frequency=f)
  xyr <-   ts(sin(2*pi*t/fyr),   start=c(startYr,startDay), frequency=f)
  if(useSetSeed==TRUE) set.seed(seed)
  noise <- anoise*rnorm(t) 
  x <- mean + ayr*xyr + aweek*xweek + aday*xday + noise
  dts <- seq(from=ISOdate(2005,1,1), by='hour', length.out=NROW(t))
  out.xts <- xts(x, order.by=dts) 
  xtsAttributes(out.xts) <- list(
    frequency=f,
    seasonal.periods=c(fday,fweek,fyr)
  )
  return(out.xts)
}

test.xts <- fakeLoadXts()
str(test.xts)
plot(test.xts)

periodicity(test.xts)

seasonal(test.xts)
numyears <- 2
# frequencies of the several periods
fday <- 24
fweek <- 7*fday
fyr <- 365*fday
frequency <- c(fday,fweek,fyr)

# amplitudes of the several sine waves
mean <- 5000
aday <- 1000
aweek <- 1500
ayr <- 2000
anoise <- 500
amplitude <- c(aday,aweek,ayr)

# time steps in the time series
t <- as.vector(1:(fyr*numyears)) 

# theta: phase shift
xyr <- ts(sin(2*pi*t/fyr), start=c(2005,1), frequency=fyr)
fyr
plot(xyr)

xweek <- ts(sin(2*pi*t/fweek), start=2005, frequency=8760)
xday <- ts(sin(2*pi*t/fday), start=2005, frequency=fyr)

x <- mean + ayr*xyr + aweek*xweek + aday*xday + anoise*rnorm(t)
plot(x)

aweek <- 1500
ayr <- 2000
anoise <- 500



set.seed(NULL)
> set.seed(123)
> rnorm(1)

> rnorm(1)
> set.seed(123)
> rnorm(1)


testParameter

y <- fakeLoadTs(numyears=1/6)
plot(y)
z <- fakeLoadTs(0,1,1,1,1,1)
plot(fakeLoadTs(useSetSeed=TRUE, seed=456, numyears=1/2, aweek=500))
y <- fakeLoadTs(useSetSeed=TRUE, seed=456, numyears=1, aweek=500)
plot(y)
str(y)
