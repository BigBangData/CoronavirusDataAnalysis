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
        sidebarPanel(
          
            # drop-down for type of plot
            selectInput(inputId = "plot_type", 
                        label = "Plot Type",
                        choices = c("Cumulative Count", "% Of Population", "New Cases"),
                        selected = "Cumulative Count"),

            # drop-down for status
            selectInput(inputId = "status", 
                        label = "Status",
                        choices = c("Confirmed", "Fatal"),
                        selected = "Confirmed"),
            
            # slider for top N number of countries to display
            sliderInput(inputId = "top_n",
                        label = "Number of Countries:",
                        min = 5,
                        max = 25,
                        value = 10)
        ),
        
        # Show plot
        mainPanel(
           plotOutput("distPlot")
        )
    )
)

# Define server logic
server <- function(input, output) {

    output$distPlot <- renderPlot({
        
        # plot type
        data <- current_data[current_data$Type == input$plot_type, ]
        
        # status
        data <- data[data$Status == input$status, ]
        
        # top n
        data <- data[order(data$Type), ][1:input$top_n, ]
        
        # draw the bar chart
        ggplot(
            data = data, aes(x = reorder(Country, -Value),  y = Value)) +
            geom_bar(stat = "identity", fill = data$Color) +
            ggtitle(paste0("Top ", input$top_n, " Countries - ", data$Status[1], " Cases - ", data$Date[1])) +
            xlab("") + ylab(input$plot_type) + theme_minimal() +
            scale_y_continuous(labels=function(x) format(x, big.mark = ",", scientific = FALSE)) +
            theme(plot.title = element_text(size = 14, face = "bold")) +
            theme(axis.text.x = element_text(angle = 45, hjust = 1)
        )
    })
}

# Run the application 
shinyApp(ui = ui, server = server)
