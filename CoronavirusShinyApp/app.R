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
    titlePanel("Coronavirus: Latest Country Stats"),

    fluidRow(
        column(12,
                p(strong("Warning: "),
                "This is a personal project and not intended as a serious data analysis.", style = "color:#A93C38"),
                p("Explore the raw data compiled by the Johns Hopkins University Center for Systems Science and Engineering in this ",
                tags$a(href="https://github.com/CSSEGISandData/COVID-19", "JHU CSSE GitHub repository."),
                "See ", tags$a(href="https://github.com/BigBangData/CoronavirusDataAnalysis", "my GitHub repository"),
                " for all files and code related to this app.")
            )
    ),

    sidebarLayout(
        position = "left",
        sidebarPanel(
            style = "max-height: 80%;",
            # drop-down for type of plot
            selectInput(inputId = "plot_type", 
                        label = "Plot Type",
                        choices = c( "Total Count", "Count per 10K", "New Cases per 10K"),
                        selected = "New Cases per 10K"),
            # drop-down for status
            selectInput(inputId = "status", 
                        label = "Status",
                        choices = c("Confirmed", "Fatal"),
                        selected = "Confirmed"),
            # slider for top N number of countries to display
            sliderInput(inputId = "top_n",
                        label = "Number of Countries:",
                        min = 2,
                        max = 15,
                        value = 7),
            tags$hr(style="border-color: black;"),
            # check box for color vs linetype in time series
            selectInput(inputId = "ts_type",
                        label = "Time Series Lines",
                        choices = list("Color" = 1, "Linetype" = 2, "Both" = 3),
                        selected = 1)
        ),

        # Show plots
        mainPanel(
           plotOutput("barplots", width = "85%", height = "300px"),
           plotOutput("timeseries", width = "100%", height = "300px")
        )
    )
)

# define server logic
server <- function(input, output) {

    output$barplots <- renderPlot({
        # subset to specific type
        data <- last_day[last_day$Type == input$plot_type, ]
        # subset to specific status
        data <- data[data$Status == input$status, ]
        # top N (order desc)
        data <- data[order(data$Value, decreasing = TRUE), ]
        data <- data[1:input$top_n, ]
        # barplot
        par(mar = c(1, 1, 1, 1), oma = c(0, 0, 0, 0))
        ggplot(data = data, aes(x = reorder(Country, -Value),  y = Value)) +
        geom_bar(stat = "identity", fill = data$Color) +
        ggtitle(paste0("On ", data$Date[1])) +
        xlab("") + ylab(input$plot_type) + theme_minimal() +
        scale_y_continuous(labels = function(x) format(x, big.mark = ",", scientific = FALSE)) +
        theme(plot.title = element_text(size = 14, face = "bold")
            , axis.text.x = element_text(angle = 90, hjust = 1, size = 10))
    })

    output$timeseries <- renderPlot({
        # subset to specific type both monthly and last day data
        # the latter for getting "top N" countries
        month_data <- last_month[last_month$Type == input$plot_type, ]
        day_data <- last_day[last_day$Type == input$plot_type, ]
        # subset to specific status
        month_data <- month_data[month_data$Status == input$status, ]
        day_data <- day_data[day_data$Status == input$status, ]
        # top N (order desc) only daily to get countries
        day_data <- day_data[order(day_data$Value, decreasing = TRUE), ]
        day_data <- day_data[1:input$top_n, ]
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
        # plot types
        if (input$ts_type == 1) {
            g +
            geom_line(aes(color = Country), size = 1.2) +
            scale_color_manual(values = sample(palette, input$top_n))
        } else if (input$ts_type == 2) {
            g +
            geom_line(aes(linetype = Country), size = .8) +
            scale_linetype_manual(values = sample(c(1:6), replace = TRUE, input$top_n))
        } else {
            g +
            geom_line(aes(linetype = Country, color = Country), size = 1) +
            scale_color_manual(values = sample(palette, input$top_n)) +
            scale_linetype_manual(values = sample(c(1:6), replace = TRUE, input$top_n))
        }
    })

}

# run app 
shinyApp(ui = ui, server = server)
