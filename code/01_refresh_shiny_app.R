# environment setup
rm(list = ls())
options(scipen=999)

# uncomment if sourcing file from dir
# setwd("../GitHub/CoronavirusDataAnalysis/code")

# install and/or load packages
install_packages <- function(package){
    newpackage <- package[!(package %in% installed.packages()[, "Package"])]
      if (length(newpackage)) {
        suppressMessages(install.packages(newpackage, dependencies = TRUE))
      }
      sapply(package, require, character.only = TRUE)
}

suppressPackageStartupMessages(
    install_packages(
        # list of packages
        c("sqldf", "tidyverse")
    )
)

# check if today's RDS file exists
enriched_rds <- paste0(gsub("-", "", Sys.Date()), "_enriched.rds")

# load preprocessed data or preprocess if not available
if (!file.exists(paste0("../data/", enriched_rds))) {
    source("00_setup_and_load.R")
} else {
    merged <- readRDS(paste0("../data/", enriched_rds))
    rm(list=ls()[-which(ls() == "merged")])
}

# App data

# subset to last 90 days, ordered by Status and overall Count DESC
last_90d <- merged[merged$Date >= as.Date(Sys.Date() - 90), ]

# add color based on Status
last_90d$Color <- ifelse(last_90d$Status == "Confirmed", "#D6604D", "#202226")

# reorder columns & reshape
new_order <-  c("Date", "Country", "Continent", "PopulationCategory", "Status", "Color", 
    "Cumulative_Count", "Cumulative_PctPopulation", "NewCases", "NewCases_per10K")
last_90d <- last_90d[, new_order]
new_names <- c("Date", "Country", "Continent", "PopulationCategory", "Status", "Color",
    "Total Count", "Total % of Population", "New Cases", "New Cases per 10K")
colnames(last_90d) <- new_names

last_90d <- as.data.frame(
    last_90d %>% pivot_longer(
        cols = c("Total Count", "Total % of Population", "New Cases", "New Cases per 10K")
            , names_to = "Type"
            , values_to = "Value"
    )
)

# fix data quality problem of negative cases
last_90d[last_90d$Value < 0,]$Value <- 0

# write data to app folder
saveRDS(last_90d, file = "CoronavirusShinyApp/last_90d.rds")