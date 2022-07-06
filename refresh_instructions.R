# for rpubs
# Open RStudio
# Knit CoronavirusDataAnalysis.Rmd
# Republish (update existing)

# for shiny app
# Spin up base R
setwd("../GitHub/CoronavirusDataAnalysis/CoronavirusShinyApp")
source("01_refersh_shiny_app.R")

library(shiny)
runApp() # to test

library(rsconnect)
deployApp() # to update existing