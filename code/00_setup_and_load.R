## Setup 
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
        c("forecast", "kableExtra", "MLmetrics",
         "RColorBrewer", "sqldf", "testthat", "tidyverse")
    )
)

# create data dir if not exists
if (!file.exists("../data")) dir.create("../data")

## Download or Load data

# check if today's pre-processed data exists
rds_file <- paste0(gsub("-", "", Sys.Date()), "_data.rds")

# if not, download it
if (!file.exists(paste0("../data/", rds_file))) {

    # download datasets
    base_url <- paste0("https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/"
                      , "csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_")
    
    setwd("../data")
    system(paste0("curl -LJO ", base_url, "confirmed_global.csv"))
    system(paste0("curl -LJO ", base_url, "deaths_global.csv"))
    setwd("..")
    
    # load downloaded datasets
    confirmed  <- read.csv("data/time_series_covid19_confirmed_global.csv")
    deaths <- read.csv("data/time_series_covid19_deaths_global.csv")
    
    # reshape datasets
    reshape_data <- function(dfm) {

        # drop cols & rename Country.Province
        dfm <- dfm[ ,!colnames(dfm) %in% c("Province.State", "Lat", "Long")]
        names(dfm)[1] <- "Country"
        
        # wide to long
        dfm <- dfm %>% pivot_longer(
            cols = starts_with("X")
            , names_to = "Date"
            , values_to = "Count"
        )
        
        # cleanup date col
        dfm$Date <- as.Date(sub("X", "", dfm$Date) , format="%m.%d.%y")
        as.data.frame(dfm)
    }
    
    confirmed <- reshape_data(confirmed)
    deaths <- reshape_data(deaths)
    
    # add status column
    confirmed$Status <- "Confirmed"
    deaths$Status <- "Fatal"
    
    # combine
    dfm <- rbind(confirmed, deaths, make.row.names = FALSE)
    
    # change Status to factor
    dfm$Status <- as.factor(dfm$Status)
    
    deduplicate_provinces <- function(dfm) {
        # fix level of aggregation to Country only
        # necessary because raw data contains mixed levels
        # that include some state/province-level data
        dfm <- dfm %>%
            select(Country, Status, Date, Count) %>%
                  group_by(Country, Status, Date) %>%
                  summarise(Count = sum(Count)) %>%
                  arrange(Country, Status, desc(Date)
            )
            as.data.frame(dfm)
    }
    
    dfm <- deduplicate_provinces(dfm)
    
    saveRDS(dfm, file = paste0("./data/", rds_file))

}

# cleanup env and read in RDS file
rm(list=ls()[-which(ls() == "rds_file")])
dfm <- readRDS(paste0("./data/", rds_file))

## Enrich data

# remove seasonal "countries" like Antarctica, the Olympics, ships,
# and small populations such as the Holy See
non_countries <- c(
    'Antarctica'
    , 'Diamond Princess'
    , 'Holy See'
    , 'MS Zaandam'
    , 'Summer Olympics 2020'
    , 'Winter Olympics 2022'
)

dfm <- dfm[!dfm$Country %in% non_countries, ]

# cleanup Taiwan's asterisk
dfm$Country[which(dfm$Country == "Taiwan*")] <- "Taiwan"

# read in static data set of countries and populations
# DATA QUALITY ISSUE: need to maintain population on a yearly basis
country_population <- read.csv("./data/country_population.csv")

# unit test for no new contries in data
current_countries <- unique(dfm$Country)

test_that("empty vector", {
    expect_equal(
        # any current_countries not in the country_population dataset?
        current_countries[!current_countries %in% country_population$Country]
        , character(0)
    )
})

# merge data sets
merged <- merge(dfm, country_population, by = "Country")

# reorder by Country, Status, and Date descending
merged <- data.frame(merged %>% arrange(Country, Status, desc(Date)))

# calculate new cases per 10K and transform counts to counts per 10K
# note: remember that population is in 1K
merged <- sqldf('
    WITH count_lag AS (
        SELECT
            Continent
            , PopulationCategory
            , Country
            , Status
            , Date
            , Count
            , Population
            , LAG(Count, 1) OVER (PARTITION BY Country, Status) AS CountLag
        FROM merged
    )
    , new_cases AS (
        SELECT
            Continent
            , PopulationCategory
            , Country
            , Status
            , Date
            , Count
            , Population * 1e3 AS Population
            , LEAD(CountLag - Count, 1) OVER (PARTITION BY Country, Status) AS NewCases
        FROM count_lag
    )
    , final AS (
        SELECT
            Continent
            , PopulationCategory
            , Country
            , Status
            , Date
            , Count AS Cumulative_Count
            , (Count * 100) / Population AS Cumulative_PctPopulation
            , NewCases
            , (NewCases * 10000) / Population AS NewCases_per10K
        FROM new_cases
    )
    SELECT * FROM final;
')


# replace NA with 0
merged$NewCases[is.na(merged$NewCases)] <- 0
merged$NewCases_per10K[is.na(merged$NewCases_per10K)] <- 0

# save merged
filename <- paste0("./data/", gsub("-", "", Sys.Date()), "_enriched.rds")
saveRDS(merged, file = filename)

# cleanup env except for merged
rm(list=ls()[-which(ls() == "merged")])
