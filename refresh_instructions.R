# for rpubs
# Open RStudio
# Knit CoronavirusDataAnalysis.Rmd
# Republish (update existing)

# for shiny app
# Spin up base R
setwd("../GitHub/CoronavirusDataAnalysis")
source("01_refresh_shiny_app.R")

library(shiny)
setwd("CoronavirusShinyApp/")
runApp() # to test

library(rsconnect)
deployApp() # to update existing