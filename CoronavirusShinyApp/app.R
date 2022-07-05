# load libraries
library(shiny)
library(ggplot2)

# load dataset
current_data <- read.csv("current_data.csv")

# Define UI for application
ui <- fluidPage(
    
    # Application title
    titlePanel("Coronavirus: Latest Country Stats"),
    
    # Sidebar panel
    sidebarLayout(
        position = "right",
        sidebarPanel(
            
            # drop-down for type of plot
            selectInput(inputId = "plot_type", 
                        label = "Plot Type",
                        choices = c( "Total Count", "Count per 10K", "New Cases per 10K"),
                        selected = "Count Per 10K"),
            
            # drop-down for status
            selectInput(inputId = "status", 
                        label = "Status",
                        choices = c("Confirmed", "Fatal"),
                        selected = "Fatal"),
            
            # slider for top N number of countries to display
            sliderInput(inputId = "top_n",
                        label = "Number of Countries:",
                        min = 5,
                        max = 50,
                        value = 15)
        ),
        
        # Show plot
        mainPanel(
           plotOutput("distPlot")
        )
    ),
    
    fluidRow(
        column(12,
            p(
                strong("Warning! "),
                "These bar charts are not intended as a serious data analysis, which would require more data and study.
                This is a personal project to explore the daily JHU datasets.", style = "color:#A93C38"
            ),
            h4(strong("Notes")),
            p(
                tags$ul(
                    tags$li("This is a simple exploration of the raw time series data compiled by the Johns Hopkins University Center for 
                            Systems Science and Engineering (JHU CCSE) from various sources."),
                    tags$li("See the ",
                            tags$a(href="https://github.com/CSSEGISandData/COVID-19", "JHU-CSSE GitHub repository"),
                            " for more information."),
                    tags$li("See ",
                            tags$a(href="https://github.com/BigBangData/CoronavirusDataAnalysis", "this GitHub repository"),
                            " for all files and code related to this app and data project.")
                )
            )
        )
    )
)

# Define server logic
server <- function(input, output) {
    
    output$distPlot <- renderPlot({
        
        # subset to specific type
        data <- current_data[current_data$Type == input$plot_type, ]
        
        # subset to specific status
        data <- data[data$Status == input$status, ]
        
        # top N (order desc)
        data <- data[order(data$Value, decreasing = TRUE), ]
        data <- data[1:input$top_n, ]
        
        # draw the bar chart
        ggplot(
            data = data, aes(x = reorder(Country, -Value),  y = Value)) +
            geom_bar(stat = "identity", fill = data$Color) +
            ggtitle(paste0("Top ", input$top_n, " Countries - ", data$Status[1], " Cases - ", data$Date[1])) +
            xlab("") + ylab(input$plot_type) + theme_minimal() +
            scale_y_continuous(labels=function(x) format(x, big.mark = ",", scientific = FALSE)) +
            theme(plot.title = element_text(size = 14, face = "bold")) +
            theme(axis.text.x = element_text(angle = 90, hjust = 1, size = 10)
        )
    })
}

# Run the application 
shinyApp(ui = ui, server = server)
