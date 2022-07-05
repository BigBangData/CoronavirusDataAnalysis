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

# load preprocessed data
if (!file.exists(enriched_rds)) {
    print("Issue: source('00_setup_and_load.R')")
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
current_data <- current_data[, c("Date", "Country", "Status", "Color", "Count", "Count_per10K", "NewCases_per10K")]
colnames(current_data) <- c("Date", "Country", "Status", "Color", "Cumulative Count", "Count Per 10K", "New Cases Per 10K")

current_data <- as.data.frame(
    current_data %>% pivot_longer(
        cols = c( "Cumulative Count", "Count Per 10K", "New Cases Per 10K")
            , names_to = "Type"
            , values_to = "Value"
    )
)

write.csv(current_data, "./CoronavirusShinyApp/current_data.csv", row.names = FALSE)





























