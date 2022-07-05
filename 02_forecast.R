
setwd("../GitHub/CoronavirusDataAnalysis")
source("./setup_and_load.R")

## Daily Forecast

# example with US latest confirmed
latest <- merged[merged$Country == "US" & merged$Status == "Confirmed", ][1:70, ]
latest <- latest[order(latest$Date), ]

# convert to time series
timeseries <- ts(latest$NewCases_per10K, frequency = 7)

# validation split
train <- window(timeseries, start = c(1, 1), end = c(8, 7))
validate <- window(timeseries, start = c(9, 1))

# seasonal naive method for benchmark
# h = number of periods to forecast = 14 days
naive <- snaive(train, h = length(validate))
MAPE(naive$mean, validate) * 100
# 29.88

# exponential smoothing is too smart for its own good here
ets_model <- ets(train, allow.multiplicative.trend = TRUE)
ets_forecast = forecast(ets_model, h = length(validate))
MAPE(ets_forecast$mean, validate) * 100
# 38.18

# plot forecasts
par(mfrow = c(2, 1))
plot(timeseries, col = "blue", main = "Seasonal Naive Forecast", type = 'l')
lines(naive$mean, col = "red", lwd = 2)

plot(timeseries, col = "blue", main = "Exponential Smoothing Forecast", type = 'l')
lines(ets_forecast$mean, col = "red", lwd = 2)
par(mfrow = c(1, 1))

# seasonal naive is better so using that
naive_future <- snaive(timeseries, h = length(validate))

# forecasting future plot
plot(c(timeseries, rep(0, 14)), col = "blue", main = "Seasonal Naive Forecast", type = 'l')
lines(c(rep(0, 70), naive_future$mean), col = "red", lwd = 2)

## Weekly Forecast

# reshape data to weekly averages and user a linear model






## ----echo=FALSE-------------------------------------------------------------------------------------------------------------------------
# top and bottom rows for final data set
kable(rbind(head(merged[merged$Country == "Brazil", ], 3)
            , head(merged[merged$Country == "US", ], 3))) %>%
      kable_styling(bootstrap_options = c("striped", "hover", "condensed")
                  , full_width = FALSE)


## ----echo=FALSE, fig.height=6, fig.width=6----------------------------------------------------------------------------------------------
# subset to current counts 
current_data <- data.frame(
    merged %>%
    filter(Date == unique(merged$Date)[1])) %>%
    arrange(Status, desc(Count)
)

# subset to world totals 
world_totals <- data.frame(current_data %>% 
                    group_by(Status) %>%
                    summarise('Total'=sum(Count)))

world_totals$Total <- formatC(world_totals$Total, big.mark=",")

kable(world_totals) %>%
      kable_styling(bootstrap_options = c("striped", "hover")
                    , full_width = FALSE)


## ----echo=FALSE-------------------------------------------------------------------------------------------------------------------------
# subset to country totals 
country_totals <- data.frame(
    current_data %>%
        select(Country, Status, Count, Percentage, NewCases) %>%
        group_by(Country, Status)
)
    
# subset to top counts     
get_top_counts <- function(dfm, coln, num) {
      dfm <- dfm[dfm$Status == coln, ][1:num, ]
      row.names(dfm) <- 1:num
      dfm
}                    

# separate by status 
top_confirmed     <- get_top_counts(country_totals, "Confirmed", 10)
top_fatal        <- get_top_counts(country_totals, "Fatal", 10)


## ----message=FALSE, warnings=FALSE, echo=FALSE------------------------------------------------------------------------------------------
# functions for plotting interactive time series
# arg values:
# dfm = the dataframe
# country = country name
# status_df = to be used as the vector of country names 
#             which is passed instead of a single country
# status = Confirmed, Fatal, Recovered, Active
# scale_ = Linear, Log
# type = Count, Percentage, NewCases
create_xts_series <- function(dfm, country, status, scale_, type) {
  
      dfm <- dfm[dfm$Country == country & dfm$Status == status, ]
      
      if (type == "Count") {
        series <- if (scale_ == "Linear") {
                      xts(dfm$Count, order.by = dfm$Date)
                } else {
                    xts(log(dfm$Count), order.by = dfm$Date)
                }
      } else if (type == "Percentage") {
        series <- if (scale_ == "Linear") {
                      xts(dfm$Percentage, order.by = dfm$Date)
                } else {
                    xts(log(dfm$Percentage), order.by = dfm$Date)
                }
      } else { # for new cases
        series <- if (scale_ == "Linear") {
                      xts(dfm$NewCases, order.by = dfm$Date)
                } else {
                    xts(log(dfm$NewCases), order.by = dfm$Date)
                }
      }
      series
}

create_seriesObject <- function(dfm, status_df, status, scale_, type) {
  
    seriesObject <- NULL
    
    for (i in 1:5) {
        seriesObject <- cbind(seriesObject
                              , create_xts_series(dfm
                                                  , status_df$Country[i]
                                                  , status
                                                  , scale_
                                                  , type))
    }
    
    names(seriesObject) <- status_df$Country[1:5]
    seriesObject
}

plot_interactive_df <- function(dfm, status_df, status, scale_, type) {
  
    seriesObject <- create_seriesObject(dfm
                                                        , status_df
                                                        , status
                                                        , scale_
                                                        , type)
    
    if (type == "Count") {
  
        txt_ <- if (scale_ == "Linear") {
                          "Count Of "
                      } else {
                        "Log Count Of "
                      }            
                  
    } else if (type == "Percentage") {
        
        txt_ <- if (scale_ == "Linear") {
                          "Percentage Of "
                      } else {
                        "Log Percentage Of "
                      }         
                  
    } else { # for new cases
      
        txt_ <- if (scale_ == "Linear") {
                          "New "
                      } else {
                        "Log Of New "
                      }      
    }
    
    ylab_lab   <- paste0(txt_, status, " Cases")
    main_title <- paste0("Top Countries - ", txt_, status, " Cases")
    
    interactive_df <- dygraph(seriesObject, main = main_title) %>% 
                      dyAxis("x", drawGrid = FALSE) %>%                            
                      dyAxis("y", label = ylab_lab) %>%
                      dyOptions(colors=brewer.pal(5, "Dark2")
                              , axisLineWidth = 1.5
                              , axisLineColor = "navy"
                              , gridLineColor = "lightblue") %>%            
                      dyRangeSelector() %>%
                      dyLegend(width = 750)
    
    interactive_df
}


## ----message=FALSE, warnings=FALSE, echo=FALSE------------------------------------------------------------------------------------------
## plot time series
plot_types <- data.frame(
    'Num' = 1:12
    , 'Status' = c(rep("Confirmed", 6), rep("Fatal", 6))
    , 'Type' = rep(c("Count", "Percentage", "NewCases"), each=2)
    , 'Scale' = rep(c("Linear", "Log"), 6)
)

# fatal
fatal_plots <- lapply(1:3, function(i) plot_interactive_df(merged
                                                   , top_fatal[1:5, ]
                                                   , top_fatal$Status[i]
                                                   , plot_types$Scale[i]
                                                   , plot_types$Type[i]))
        
htmltools::tagList(fatal_plots)

# confirmed 
confirmed_plots <- lapply(1:3, function(i) plot_interactive_df(merged
                                                       , top_confirmed[1:5, ]
                                                       , top_confirmed$Status[i]
                                                       , plot_types$Scale[i]
                                                       , plot_types$Type[i]))
        
htmltools::tagList(confirmed_plots)


## ----eval=FALSE-------------------------------------------------------------------------------------------------------------------------
## NA


## ---------------------------------------------------------------------------------------------------------------------------------------
# uncomment to run, creates Rcode file with R code, set documentation = 1 to avoid text commentary
library(knitr)
options(knitr.purl.inline = TRUE)
purl("CoronavirusDataAnalysis.Rmd", output = "Rcode.R", documentation = 1)

