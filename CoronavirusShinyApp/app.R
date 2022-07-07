# load libraries
library(shiny)
library(ggplot2)

# load dataset
last_month <- read.csv("last_month.csv")

# subset to last_day
last_day <- last_month[last_month$Date == max(last_month$Date), ]

# define ui
ui <- fluidPage(

    # app title
    titlePanel(
        title = div(
            img(src="corona_thumb.jpg", height = 40, width = 40), 
            "Coronavirus: Latest Country Statistics", 
            style = "color:#A93C38"
            )
    ),

    fluidRow(
        column(12,
                p(
                    "Explore the raw data compiled by the Johns Hopkins University
                        Center for Systems Science and Engineering in this ",
                    tags$a(href="https://github.com/CSSEGISandData/COVID-19", 
                    "JHU CSSE GitHub repository."),
                    "See ", 
                    tags$a(href="https://github.com/BigBangData/CoronavirusDataAnalysis", 
                    "my GitHub repository"),
                    " for all files and code related to this app."
                )
        )
    ),

    sidebarLayout(
        position = "left",
        sidebarPanel(
            checkboxGroupInput(
                        inputId = "continent",
                        label = "Continent",
                        choices = list("Africa" = 1, "Asia" = 2, "Europe" = 3,
                            "North America" = 4, "Oceania" = 5, "South America" = 6),
                        selected = c(4, 6)),
            checkboxGroupInput(
                        inputId = "population_category",
                        label = "Population Category",
                        choices = list("more than 100M" = 1, "from 10M to 100M" = 2,
                                       "from 1M to 10M" = 3, "less than 1M" = 4),
                        selected = c(1, 2)),
            # drop-down for type of plot
            selectInput(inputId = "plot_type", 
                        label = "Plot Type",
                        choices = c("Cumulative Count", "Cumulative % of Population"
                            , "New Cases", "New Cases per 10,000"),
                        selected = "New Cases per 10,000"),
            # drop-down for status
            selectInput(inputId = "status", 
                        label = "Status",
                        choices = c("Confirmed", "Fatal"),
                        selected = "Confirmed"),
            # slider for top N number of countries to display
            sliderInput(inputId = "top_n",
                        label = "Number of Countries (Top Values)",
                        min = 2,
                        max = 15,
                        value = 8),
            tags$hr(style="border-color: black;"),
            # check box for color vs linetype in time series
            selectInput(inputId = "ts_type",
                        label = "Time Series Line Choices",
                        choices = list("Color" = 1, "Linetype" = 2, "Both" = 3),
                        selected = 3)
        ),

        # Show plots
        mainPanel(
            plotOutput("barplots", width = "85%", height = "350px"),
            plotOutput("timeseries", width = "100%", height = "350px")
        )
    )
)

# define server logic
server <- function(input, output) {

    output$barplots <- renderPlot({
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
    })

    output$timeseries <- renderPlot({

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
        # immutable elements
        g <- ggplot(data = month_data, aes(x = Date, y = Value)) +
             ggtitle("Time Series - Last 30 days") +
             xlab("") + ylab(input$plot_type) + theme_minimal() +
             scale_y_continuous(labels = function(x) format(x, big.mark = ","
                , scientific = FALSE)) +
             theme(plot.title = element_text(size = 14, face = "bold")
                , legend.title = element_text(size = 14)
                , legend.text = element_text(size = 12)
                , axis.text.x = element_text(size = 12))
        # mutable elements
        # color
        if (input$ts_type == 1) {
            g +
            geom_line(aes(color = Country), size = 1.2) +
            scale_color_manual(values = sample(palette, top_n))
        }
        # linetypes
        if (input$ts_type == 2) {
            g +
            geom_line(aes(linetype = Country), size = .7) +
            scale_linetype_manual(values = sample(c(1:6), replace = TRUE, top_n))
        }
        # both
        if (input$ts_type == 3) {
            g +
            geom_line(aes(linetype = Country, color = Country), size = 1) +
            scale_color_manual(values = sample(palette, top_n)) +
            scale_linetype_manual(values = sample(c(1:6), replace = TRUE, top_n))
        }
    })

}

# run app 
shinyApp(ui = ui, server = server)
