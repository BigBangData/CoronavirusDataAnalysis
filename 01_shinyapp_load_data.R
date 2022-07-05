# environment setup
rm(list = ls())
options(scipen=999)
setwd("../GitHub/CoronavirusDataAnalysis")

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
enriched_rds <- paste0("data/", gsub("-", "", Sys.Date()), "_enriched.rds")

# load preprocessed data or preprocess if not available
if (!file.exists(enriched_rds)) {
    source("00_setup_and_load.R")
} else {
    merged <- readRDS(enriched_rds)
    rm(list=ls()[-which(ls() == "merged")])
}

# App data

# subset to last day, ordered by Status and overall Count DESC
current_data <- as.data.frame(
    merged %>%
    filter(Date == unique(merged$Date)[1]) %>%
    arrange(Status, desc(Count))
)

# add color based on Status
current_data$Color <- ifelse(current_data$Status == "Confirmed", "#D6604D", "#202226")

# reorder columns & reshape
new_order <-  c("Date", "Country", "Status", "Color", "Count", "Count_per10K", "NewCases_per10K")
current_data <- current_data[, new_order]
new_names <- c("Date", "Country", "Status", "Color", "Total Count", "Count per 10K", "New Cases per 10K")
colnames(current_data) <- new_names

current_data <- as.data.frame(
    current_data %>% pivot_longer(
        cols = c( "Total Count", "Count per 10K", "New Cases per 10K")
            , names_to = "Type"
            , values_to = "Value"
    )
)

# write csv to app folder
write.csv(current_data, "./CoronavirusShinyApp/current_data.csv", row.names = FALSE)
