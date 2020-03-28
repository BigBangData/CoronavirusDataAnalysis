rm(list = ls())
options(scipen=999)

install_packages <- function(package){
  
  newpackage <- package[!(package %in% installed.packages()[, "Package"])]
      
	if (length(newpackage)) {
      suppressMessages(install.packages(newpackage, dependencies = TRUE))
	}
	sapply(package, require, character.only = TRUE)
}


# install packages  
packages <- c("dygraphs","tidyverse","xts")
suppressPackageStartupMessages(install_packages(packages))





dfm <- readRDS("../GitHub/CoronavirusDataAnalysis/COVID19_DATA/20200326_data.rds")


us <- dfm[dfm$Country_Region == "US",]

# subset to Italy fatalities
ItalyFatal <- dfm[dfm$Country_Region == "Italy" & dfm$Status == "fatal", ]
ItalyConfirmed <- dfm[dfm$Country_Region == "Italy" & dfm$Status == "confirmed", ]
ItalyRecovered <- dfm[dfm$Country_Region == "Italy" & dfm$Status == "recovered", ]


# create time series object
Fatal <- xts(x = ItalyFatal$Value
                ,order.by = ItalyFatal$Date)
				 
Confirmed <- xts(x = ItalyConfirmed$Value
                ,order.by = ItalyConfirmed$Date)
	
Recovered <- xts(x = ItalyRecovered$Value
                ,order.by = ItalyRecovered$Date
				,title="Italy Recovered")
	
		
Italy_interactive <- dygraph(cbind(ItalyConfirmedSeries, ItalyFatalSeries, ItalyRecoveredSeries))
Italy_interactive


						     ,main="Italy"
						     ,xlab=""
						     ,ylab="Number of Fatalities") %>% 
						     dyOptions(colors = rgb(1,0,0,alpha=0.8)) %>%
						     dyOptions(stackedGraph = TRUE) %>% 						  
						     dyRangeSelector()
Italy_interactive






