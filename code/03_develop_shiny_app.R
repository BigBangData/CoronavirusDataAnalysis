# app dir
rm(list=ls())
setwd("../GitHub/CoronavirusDataAnalysis/CoronavirusShinyApp")

# load libraries
library(shiny)
library(ggplot2)
library(xts)
library(dygraphs)

# load dataset
last_month <- readRDS("last_month.rds")

# subset to last_day
last_day <- last_month[last_month$Date == max(last_month$Date), ]

## default inputs

input <- data.frame(
    'continent' = 1
    , 'population_category' = 2
    , 'plot_type' = 'New Cases'
    , 'status' = 'Confirmed'
    , 'top_n' = 8
    , 'ts_type' = 3
)


# set color palette using library(RColorBrewer)
# brewer.pal(n = 8, name = "Set1") # "Accent", "RdBu"
color_palette <- c("#E41A1C", "#377EB8", "#4DAF4A", "#984EA3", "#FF7F00"
    , "#A65628", "#F781BF", "#999999", "#BF5B17", "#666666"
    , "#B2182B", "#D6604D", "#2166AC", "#053061", "#F0027F")

subset_data_for_ts <- function(last_month, last_day, input) {
    # subset to continent
    month_data <- last_month[last_month$Continent %in% input$continent, ]
    day_data <- last_day[last_day$Continent %in% input$continent, ]
    # subset to population category
    month_data <- month_data[month_data$PopulationCategory %in% input$population_category, ]
    day_data <- day_data[day_data$PopulationCategory %in% input$population_category, ]
    # subset to plot type
    month_data <- month_data[month_data$Type == input$plot_type, ]
    day_data <- day_data[day_data$Type == input$plot_type, ]
    # subset to status
    month_data <- month_data[month_data$Status == input$status, ]
    day_data <- day_data[day_data$Status == input$status, ]
    # subset to top N (order desc) - only daily to get countries
    day_data <- day_data[order(day_data$Value, decreasing = TRUE), ]
    # account for case when there are less countries than user chose
    top_n <- min(length(unique(day_data$Country)), input$top_n)
    day_data <- day_data[1:top_n, ]
    # subset monthly data (to last_day's top N countries)
    month_data <- month_data[month_data$Country %in% day_data$Country, ]
    # fix Date data type
    month_data$Date <- as.Date(month_data$Date)
    # return combined dataframes
    month_data$dfm <- "Month"
    day_data$dfm <- "Day"
    return(rbind(day_data, month_data))
}


## default barplot

        # subset to continent
        data <- last_day[last_day$Continent %in% input$continent, ]
        # subset to population category
        data <- data[data$PopulationCategory %in% input$population_category, ]
        # subset to plot type
        data <- data[data$Type == input$plot_type, ]
        # subset to status
        data <- data[data$Status == input$status, ]
        # top N (order desc)
        data <- data[order(data$Value, decreasing = TRUE), ]
        top_n <- min(length(unique(data$Country)), input$top_n)
        data <- data[1:top_n, ]
        # barplot
        par(mar = c(1, 1, 1, 1), oma = c(0, 0, 0, 0))
        # immutable elements
        g <- ggplot(data = data, aes(x = reorder(Country, -Value),  y = Value)) +
             geom_bar(stat = "identity", fill = data$Color) +
             xlab("") + ylab(input$plot_type) + theme_minimal() +
             scale_y_continuous(labels = function(x) format(x, big.mark = ","
                , scientific = FALSE)) +
             theme(plot.title = element_text(size = 14, face = "bold")
                 , axis.text.x = element_text(angle = 90, hjust = 1, size = 10))
        # mutable elements
        if (substr(input$plot_type, 1, 10) == "Cumulative") {
            g + ggtitle(paste0(input$status, " Cases As Of ", data$Date[1]))
        } else {
            g + ggtitle(paste0(input$status, " Cases On ", data$Date[1]))
        }

## default time series

        # subset to continent
        month_data <- last_month[last_month$Continent %in% input$continent, ]
        day_data <- last_day[last_day$Continent %in% input$continent, ]
        # subset to population category
        month_data <- month_data[month_data$PopulationCategory %in% input$population_category, ]
        day_data <- day_data[day_data$PopulationCategory %in% input$population_category, ]
        # subset to plot type
        month_data <- month_data[month_data$Type == input$plot_type, ]
        day_data <- day_data[day_data$Type == input$plot_type, ]
        # subset to status
        month_data <- month_data[month_data$Status == input$status, ]
        day_data <- day_data[day_data$Status == input$status, ]
        # top N (order desc) only daily to get countries
        day_data <- day_data[order(day_data$Value, decreasing = TRUE), ]
        top_n <- min(length(unique(day_data$Country)), input$top_n)
        day_data <- day_data[1:top_n, ]
        # subset monthly data to last_day's top N countries
        month_data <- month_data[month_data$Country %in% day_data$Country, ]
        # fix Date data type
        month_data$Date <- as.Date(month_data$Date)
        # library(RColorBrewer)
        # brewer.pal(n = 8, name = "Set1") # "Accent", "RdBu"
        palette <- c("#E41A1C", "#377EB8", "#4DAF4A", "#984EA3", "#FF7F00"
                , "#A65628", "#F781BF", "#999999", "#BF5B17", "#666666"
                , "#B2182B", "#D6604D", "#2166AC", "#053061", "#F0027F")

        # time series
        par(mar = c(1, 1, 1, 1), oma = c(0, 0, 0, 0))

        g <- ggplot(data = month_data, aes(x = Date, y = Value)) +
             ggtitle("Time Series - Last 30 days") +
             xlab("") + ylab(input$plot_type) + theme_minimal() +
             scale_y_continuous(labels = function(x) format(x, big.mark = ",", scientific = FALSE)) +
             theme(plot.title = element_text(size = 14, face = "bold")
                , legend.title = element_text(size = 14)
                , legend.text = element_text(size = 12)
                , axis.text.x = element_text(size =12))

        if (input$ts_type == 1) {
            g +
            geom_line(aes(color = Country), size = 1.2) +
            scale_color_manual(values = sample(palette, top_n))
        }
        
        if (input$ts_type == 2) {
            g +
            geom_line(aes(linetype = Country), size = .7) +
            scale_linetype_manual(values = sample(c(1:6), replace = TRUE, top_n))
        }
        
        if (input$ts_type == 3) {
            g +
            geom_line(aes(linetype = Country, color = Country), size = 1) +
            scale_color_manual(values = sample(palette, top_n)) +
            scale_linetype_manual(values = sample(c(1:6), replace = TRUE, top_n))
        }


## Interactive Time Series

        # subset to continent
        month_data <- last_month[last_month$Continent %in% input$continent, ]
        day_data <- last_day[last_day$Continent %in% input$continent, ]
        # subset to population category
        month_data <- month_data[month_data$PopulationCategory %in% input$population_category, ]
        day_data <- day_data[day_data$PopulationCategory %in% input$population_category, ]
        # subset to plot type
        month_data <- month_data[month_data$Type == input$plot_type, ]
        day_data <- day_data[day_data$Type == input$plot_type, ]
        # subset to status
        month_data <- month_data[month_data$Status == input$status, ]
        day_data <- day_data[day_data$Status == input$status, ]
        # top N (order desc) only daily to get countries
        day_data <- day_data[order(day_data$Value, decreasing = TRUE), ]
        top_n <- min(length(unique(day_data$Country)), input$top_n)
        day_data <- day_data[1:top_n, ]
        # subset monthly data to last_day's top N countries
        month_data <- month_data[month_data$Country %in% day_data$Country, ]
        # fix Date data type
        month_data$Date <- as.Date(month_data$Date)
        # library(RColorBrewer)
        # brewer.pal(n = 8, name = "Set1") # "Accent", "RdBu"
        palette <- c("#E41A1C", "#377EB8", "#4DAF4A", "#984EA3", "#FF7F00"
                , "#A65628", "#F781BF", "#999999", "#BF5B17", "#666666"
                , "#B2182B", "#D6604D", "#2166AC", "#053061", "#F0027F")

        create_xts_series <- function(df_month, country) {

            df_month <- df_month[df_month$Country == country, ]
            series <- xts(df_month$Value, order.by = df_month$Date)

            return(series)
        }

        create_seriesObject <- function(df_month, df_day) {

            seriesObject <- NULL
            for (i in 1:input$top_n) {
                seriesObject <- cbind(seriesObject,
                                    create_xts_series(df_month, df_day$Country[i])
                                    )
            }
            names(seriesObject) <- df_day$Country

            return(seriesObject)
        }

        plot_interactive_df <- function(df_month, df_day) {

            seriesObject <- create_seriesObject(df_month, df_day)
            title <- paste0("Top ", input$top_n, " Countries - Time Series")

            interactive_df <- dygraph(seriesObject, main = title) %>%
                dyAxis("x", drawGrid = FALSE) %>%
                dyAxis("y", label = input$plot_type) %>%
                dyOptions(
                    colors = sample(palette, input$top_n)
                    , axisLineWidth = 1.5
                    , axisLineColor = "navy"
                    , gridLineColor = "lightblue") %>%
                dyRangeSelector() %>%
                dyLegend(width = 750)

            return(interactive_df)
        }

        plot_interactive_df(month_data, day_data)