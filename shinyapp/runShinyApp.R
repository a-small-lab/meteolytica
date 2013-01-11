#  Batch file to run shiny app.
library(shiny)
library(shinyIncubator)
runApp("shinyapp")

#  Use the command below to run the shiny app as a separate R process
#  BUT don't use this until you figure out how to *stop* that process.
#  R -e "shiny::runApp('~/shinyapp')"

# To use features in the development version of shiny:
install.package("devtools")  # if necessary
devtools::install_github("shiny", "rstudio")
devtools::install_github("shiny-incubator", "rstudio")
