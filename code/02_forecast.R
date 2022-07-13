
rm(list=ls())
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
        c("forecast", "kableExtra", "MLmetrics",
         "RColorBrewer", "sqldf", "testthat", "tidyverse")
    )
)

## Daily Forecast
merged <- readRDS("./data/20220713_enriched.rds")

# Example: US Confirmed, last 70 days
latest <- merged[merged$Country == "Brazil" & merged$Status == "Confirmed", ][1:70, ]
latest <- latest[order(latest$Date), ]
latest$NewCases[latest$NewCases == 0] <- 0.000001
latest$NewCases_per10K[latest$NewCases_per10K == 0] <- 0.000001

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




