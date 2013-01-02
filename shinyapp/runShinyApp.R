#  Batch file to run shiny app.
library(shiny)

runApp("shinyapp")


#  Use this command to run the shiny app as a separate R process
#  BUT don't use this until you figure out how to *stop* that process.
#  R -e "shiny::runApp('~/shinyapp')"