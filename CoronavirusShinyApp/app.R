# load libraries
library(shiny)
library(ggplot2)
library(xts)
library(dygraphs)

# load data
last_90d <- readRDS("last_90d.rds")

# last day subset (for barplots and ordering)
last_day <- last_90d[last_90d$Date == max(last_90d$Date), ]

## UI
tabPanelfooter <- fluidRow(
    # link sources
    column(6,
        p(style = "text=align:left;",
        "Data source: ", tags$a(href="https://github.com/CSSEGISandData/COVID-19", "JHU CSSE GitHub"), " |",
        "Virus image source: ", tags$a(href="https://phil.cdc.gov/Details.aspx?pid=23312", "CDC.gov"))
    ),
    column(5,
        # signature, GitHub link
        p(style = "text-align:right;",
        "By ", tags$a(href="https://bigbangdata.github.io/", "Marcelo Sanches"),
        tags$a(href="https://github.com/BigBangData/CoronavirusDataAnalysis",
        img(src="GitHub-Mark-32px.png", height = 20)), " BigBangData")
    )
)

ui <- fluidPage(
        title = "Coronavirus: Latest Country Statistics",

    headerPanel(
        title = div(
            style = "color:#A93C38",
            img(src="corona_thumb.jpg", height = 40, width = 40),
            "Coronavirus: Latest Country Statistics"
        )
    ),

    sidebarLayout(
        position = "left",

        # side panel with choices
        sidebarPanel(
            width = 2,

            # checkbox for continent
            checkboxGroupInput(
                inputId = "continent",
                label = "Continent",
                choices = list("Africa" = 1, "Asia" = 2, "Europe" = 3,
                    "North America" = 4, "Oceania" = 5, "South America" = 6),
                selected = c(4, 6)
            ),
            # checkbox for population category
            checkboxGroupInput(
                inputId = "population_category",
                label = "Population",
                choices = list("more than 100 M" = 1, "from 10 M to 100 M" = 2,
                    "from 1 M to 10 M" = 3, "less than 1 M" = 4),
                selected = c(1, 2)
            ),
            # drop-down for plot type
            selectInput(
                inputId = "plot_type",
                label = "Metric & Status",
                choices = c("Total Count", "Total % of Population"
                    , "New Cases", "New Cases per 10K"),
                selected = "New Cases per 10K"
            ),
            # drop-down for status
            selectInput(
                inputId = "status",
                label = NULL,
                choices = c("Confirmed", "Fatal"),
                selected = "Confirmed"
            ),
            # slider for top N number of countries to display
            sliderInput(
                inputId = "top_n",
                label = "Number of Countries",
                min = 2,
                max = 15,
                value = 8
            ),
            HTML("<strong><font size=4>Time Series Options</font></strong>"),
            # line differentiation options
            # scale
            checkboxInput(
                inputId = "ts_scale",
                label = "log scale",
                value = FALSE
            ),
            selectInput(
                inputId = "ts_type",
                label = NULL,
                choices = list("Color" = 1, "Linetype" = 2, "Color & Linetype" = 3),
                selected = 3
            ),
            # start date
            dateInput(
                inputId = "date", 
                label = "Start On", 
                value = min(last_90d$Date),
                min = min(last_90d$Date),
                max = max(last_90d$Date) - 1L
            )
        ),

        # main panel with plots
        mainPanel(
            width = 10,

            tabsetPanel(type = "tabs",
                # tab 1
                tabPanel(title = "Bar Graph & Time Series",
                    br(),
                    plotOutput("barplot", width = "85%", height = "350px"),
                    plotOutput("timeseries", width = "95%", height = "350px"),
                    tabPanelfooter
                ),
                # tab 2
                tabPanel(title ="Interactive Dygraph",
                    br(), br(),
                    dygraphOutput("dygraph", width = "95%", height = "640px"),
                    br(), br(),
                    tabPanelfooter
                )
            )
        )
    )
)

## Server

# set color palette using library(RColorBrewer)
# brewer.pal(n = 8, name = "Set1") # "Accent", "RdBu"
color_palette <- c("#E41A1C", "#377EB8", "#4DAF4A", "#984EA3", "#FF7F00"
    , "#A65628", "#F781BF", "#999999", "#BF5B17", "#666666"
    , "#B2182B", "#D6604D", "#2166AC", "#053061", "#F0027F")

subset_data_for_ts <- function(last_90d, last_day, input) {
    # subset dates
    quarter_data <- last_90d[last_90d$Date >= input$date, ]
    # subset to continent
    quarter_data <- quarter_data[quarter_data$Continent %in% input$continent, ]
    day_data <- last_day[last_day$Continent %in% input$continent, ]
    # subset to population category
    quarter_data <- quarter_data[quarter_data$PopulationCategory %in% input$population_category, ]
    day_data <- day_data[day_data$PopulationCategory %in% input$population_category, ]
    # subset to plot type
    quarter_data <- quarter_data[quarter_data$Type == input$plot_type, ]
    day_data <- day_data[day_data$Type == input$plot_type, ]
    # subset to status
    quarter_data <- quarter_data[quarter_data$Status == input$status, ]
    day_data <- day_data[day_data$Status == input$status, ]
    # subset to top N (order desc) - only daily to get countries
    day_data <- day_data[order(day_data$Value, decreasing = TRUE), ]
    # account for case when there are less countries than user chose
    top_n <- min(length(unique(day_data$Country)), input$top_n)
    day_data <- day_data[1:top_n, ]
    # subset monthly data (to last_day's top N countries)
    quarter_data <- quarter_data[quarter_data$Country %in% day_data$Country, ]
    # fix Date data type
    quarter_data$Date <- as.Date(quarter_data$Date)
    # return combined dataframes
    quarter_data$dfm <- "Month"
    day_data$dfm <- "Day"
    return(rbind(day_data, quarter_data))
}

server <- function(input, output) {

    output$barplot <- renderPlot({

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

        # base plot
        g <- ggplot(data = data, aes(x = reorder(Country, -Value),  y = Value)) +
                geom_bar(stat = "identity", fill = data$Color) +
                xlab("") + ylab(input$plot_type) + theme_minimal() +
                scale_y_continuous(labels = function(x) {
                    format(x, big.mark = ",", scientific = FALSE)
                }) +
                theme(plot.title = element_text(size = 16, face = "bold")
                    , axis.text.x = element_text(angle = 45, hjust = 1, size = 14)
                    , axis.title.y = element_text(size = 14)
                    , axis.text.y = element_text(size = 12))

        # mutable elements
        if (substr(input$plot_type, 1, 5) == "Total") {
            g + ggtitle(paste0("Top ", top_n, " Countries - As Of ", data$Date[1]))
        } else {
            g + ggtitle(paste0("Top ", top_n, " Countries - On ", data$Date[1]))
        }
    })

    output$timeseries <- renderPlot({

        # subset data
        dfs <- subset_data_for_ts(last_90d, last_day, input)
        quarter_data <- as.data.frame(dfs[dfs$dfm == "Month", ])
        day_data <- as.data.frame(dfs[dfs$dfm == "Day", ])
        # recalc top_n from day_data
        day_top_n <- nrow(day_data)

        # ggplot time series
        # linear v log scales
        if (input$ts_scale == FALSE) {
            g <- ggplot(data = quarter_data, aes(x = Date, y = Value)) +
                ylab(input$plot_type)
        } else {
            g <- ggplot(data = quarter_data, aes(x = Date, y = log(Value))) +
                ylab(paste0("Log of ", input$plot_type))
        }
        # base plot
        g <- g +
            ggtitle(paste0("Top ", day_top_n, " Countries - Last ", 
                length(unique(quarter_data$Date)), " Days")) +
            xlab("") + theme_minimal() +
            scale_y_continuous(labels = function(x) {
                format(x, big.mark = ",", scientific = FALSE)
            }) +
            theme(plot.title = element_text(size = 16, face = "bold")
                , legend.title = element_text(size = 16)
                , legend.text = element_text(size = 14)
                , axis.text.x = element_text(size = 14)
                , axis.title.y = element_text(size = 14)
                , axis.text.y = element_text(size = 12))
        
        # sample colors
        sample_colors <- sample(color_palette, replace = TRUE, day_top_n)
        # sample linetypes (weighted to avoid over-dotting)
        weighted_distro <- c(1, 1, 1, 2, 2, 2, 3, 4, 4, 5, 5)
        sample_linetypes <- sample(weighted_distro, replace = TRUE, day_top_n)
        # mutable elements:
        # color
        if (input$ts_type == 1) {
            g + geom_line(aes(color = Country), size = 1) +
            scale_color_manual(values = sample_colors)
        }
        # linetype
        else if (input$ts_type == 2) {
            g + geom_line(aes(linetype = Country), size = 1) +
            scale_linetype_manual(values = sample_linetypes)
        }
        # color and linetype
        else {
            g + geom_line(aes(linetype = Country, color = Country), size = 1) +
            scale_color_manual(values = sample_colors) +
            scale_linetype_manual(values = sample_linetypes)
        }

    })

    output$dygraph <- renderDygraph({

        # subset data
        dfs <- subset_data_for_ts(last_90d, last_day, input)
        quarter_data <- as.data.frame(dfs[dfs$dfm == "Month", ])
        day_data <- as.data.frame(dfs[dfs$dfm == "Day", ])
        # recalc top_n from day_data
        day_top_n <- nrow(day_data)

        ## interactive dygraph
        # linear v log scales
        if (input$ts_scale == FALSE) {
            # create xts func
            create_xts_series <- function(df_month, country) {
                df_month <- df_month[df_month$Country == country, ]
                series <- xts(df_month$Value, order.by = df_month$Date)
                return(series)
            }
            # y-axis lab
            y_label <- input$plot_type
        } else {
            # create xts func
            create_xts_series <- function(df_month, country) {
                df_month <- df_month[df_month$Country == country, ]
                series <- xts(log(df_month$Value), order.by = df_month$Date)
                return(series)
            }
            # y-axis lab
            y_label <- paste0("Log of ", input$plot_type)
        }
        # create seriesObject
        create_seriesObject <- function(df_month, df_day) {
            seriesObject <- NULL
            for (i in (1:day_top_n)) {
                seriesObject <- cbind(
                    seriesObject,
                    create_xts_series(df_month, df_day$Country[i])
                )
            }
            names(seriesObject) <- df_day$Country
            return(seriesObject)
        }
        seriesObject <- create_seriesObject(quarter_data, day_data)
        # render dygraph
        title <- paste0("Top ", day_top_n, " Countries - Last ",
            length(unique(quarter_data$Date)), " Days")
        dygraph(seriesObject, main = title) %>%
            dyAxis("x", drawGrid = FALSE) %>%
            dyAxis("y", label = y_label) %>%
            dyOptions(
                colors = sample(color_palette, replace = TRUE, day_top_n)
                , axisLineWidth = 1.5
                , axisLineColor = "navy"
                , gridLineColor = "lightblue"
                , labelsKMB = TRUE) %>%
            dyRangeSelector() %>%
            dyLegend(width = 750)
    })

}

# run app 
shinyApp(ui = ui, server = server)
