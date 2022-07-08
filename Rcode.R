## ----include=FALSE------------------------------------------------------
# setup & pre-process latest data
source("./00_setup_and_load.R")

# read in preprocessed data
rds_file <- paste0("./data/", gsub("-", "", Sys.Date()), "_data.rds")
dfm <- readRDS(rds_file)

# calculate number of countries and number of days in the time series
Ncountries <- length(unique(dfm$Country))
Ndays <- length(unique(dfm$Date))

nrow(dfm)
length(dfm)
Sys.Date()
Ndays
Ncountries
## ----echo=FALSE------------------------------------------------------
# top and bottom rows for final data set
kable(rbind(head(merged[merged$Country == "Brazil", ], 3)
            , head(merged[merged$Country == "US", ], 3))) %>%
      kable_styling(bootstrap_options = c("striped", "hover", "condensed")
                  , full_width = FALSE)

## ----echo=FALSE------------------------------------------------------
# subset to last date and calculate world totals
current_data <- data.frame(
    merged %>%
    select(Country, Status, Date, Cumulative_Count) %>%
    filter(Date == max(merged$Date)) %>%
    arrange(Status, desc(Cumulative_Count))
)


world_totals <- data.frame(
    current_data %>%
    group_by(Status) %>%
    summarise('Total'= sum(Cumulative_Count))
)

world_totals$Total <- formatC(world_totals$Total, big.mark=",")

kable(world_totals) %>%
      kable_styling(bootstrap_options = c("striped", "hover"), full_width = FALSE)
