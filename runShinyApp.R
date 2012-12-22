#  Batch file to run shiny app.
library(shiny)
runApp("./shinyapp")

# Running in a Separate Process: 
# If you don’t want to block access to the console
# while running your Shiny application you can also run it in a separate
# process. You can do this by opening a terminal or console window and executing
# the following:
# R -e "shiny::runApp('~/shinyapp')" 
# By default runApp starts the application on
# port 8100. If you are using this default then you can connect to the running
# application by navigating your browser to http://localhost:8100.