# for rpubs
# Open RStudio
# Knit CoronavirusDataAnalysis.Rmd
# Republish (update existing)

# for shiny app
# Spin up base R
setwd("../GitHub/CoronavirusDataAnalysis/code")
source("01_refresh_shiny_app.R") # leaves you a dir up

library(shiny)
setwd("CoronavirusShinyApp/")
runApp() # to test

library(rsconnect)
deployApp() # to update existing