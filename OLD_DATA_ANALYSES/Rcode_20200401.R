#' ---
#' title: "Coronavirus Data Analysis"
#' author: "Marcelo Sanches"
#' date: "04/01/2020"
#' output: 
#'   html_document:
#'     keep_md: true
#' ---
#' 
## ----setup, include=FALSE------------------------------------------------
knitr::opts_chunk$set(echo = TRUE)

#' 
#' 
## ----include=FALSE-------------------------------------------------------
# setup
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
packages <- c("dygraphs", "tidyverse", "xts", "RColorBrewer","kableExtra")
suppressPackageStartupMessages(install_packages(packages))

#' 
#' 
## ----include=FALSE-------------------------------------------------------

# preprocessing function
preprocess <- function() {

	# create a folder for the data 
	dir_name <- "COVID19_DATA"
	if (!file.exists(dir_name)) {
		dir.create(dir_name)
	}
	
	dir_path <- "COVID19_DATA/"
	
	# download today's file, save as RDS first time, read otherwise
	file_name <- paste0(dir_path, gsub("-", "", Sys.Date()), "_data.rds")
	
	if (!file.exists(file_name)) {

		# create URLs
		http_header <- paste0("https://data.humdata.org/hxlproxy/data/"
		                      ,"download/time_series_covid19_")
		
		url_body <- paste0("_narrow.csv?dest=data_edit&filter01=explode&explode"
		            ,"-header-att01=date&explode-value-att01=value&filter02=ren"
		            ,"ame&rename-oldtag02=%23affected%2Bdate&rename-newtag02=%2"
		            ,"3date&rename-header02=Date&filter03=rename&rename-oldtag0"
		            ,"3=%23affected%2Bvalue&rename-newtag03=%23affected%2Binfec"
		            ,"ted%2Bvalue%2Bnum&rename-header03=Value&filter04=clean&cl"
		            ,"ean-date-tags04=%23date&filter05=sort&sort-tags05=%23date"
		            ,"&sort-reverse05=on&filter06=sort&sort-tags06=%23country%2"
		            ,"Bname%2C%23adm1%2Bname&tagger-match-all=on&tagger-default"
		            ,"-tag=%23affected%2Blabel&tagger-01-header=province%2Fstat"
		            ,"e&tagger-01-tag=%23adm1%2Bname&tagger-02-header=country%2"
		            ,"Fregion&tagger-02-tag=%23country%2Bname&tagger-03-header="
		            ,"lat&tagger-03-tag=%23geo%2Blat&tagger-04-header=long&tagg"
		            ,"er-04-tag=%23geo%2Blon&header-row=1&url=https%3A%2F%2Fraw"
		            ,".githubusercontent.com%2FCSSEGISandData%2FCOVID-19%2Fmast"
		            ,"er%2Fcsse_covid_19_data%2Fcsse_covid_19_time_series%2Ftim"
		            ,"e_series_covid19_")
		
		
		confirmed_URL  <- paste0(http_header, "confirmed_global"
		                         , url_body, "confirmed_global.csv")
		fatal_URL <- paste0(http_header, "deaths_global"
		                    , url_body, "deaths_global.csv")
		recovered_URL  <- paste0(http_header, "recovered_global"
		                         , url_body, "recovered_global.csv")
									
		# download
		download.file(confirmed_URL
		              , destfile=paste0(dir_path, "confirmed.csv"))
		download.file(fatal_URL
		              , destfile=paste0(dir_path, "fatal.csv"))
		download.file(recovered_URL
		              , destfile=paste0(dir_path, "recovered.csv"))
		
		# load csvs
		load_csv <- function(filename) { 
			filename <- read.csv(paste0(dir_path, filename, ".csv"), header=TRUE
			                     , fileEncoding="UTF-8-BOM"
								 , stringsAsFactors=FALSE, na.strings="")[-1, ]
			filename
		}
	
		confirmed  <- load_csv("confirmed")
		fatal <- load_csv("fatal") 
		recovered  <- load_csv("recovered")
		
		# prep data for long format
		
		# add column identifying the dataset	
		add_col <- function(dfm, name) {
			dfm$Status <- rep(name, nrow(dfm))
			dfm
		}
		
		confirmed  <- add_col(confirmed, "Confirmed")
		fatal <- add_col(fatal, "Fatal")
		recovered  <- add_col(recovered, "Recovered")
		
		# join (union actually) into one dataset 
		dfm <- rbind(confirmed, fatal, recovered, make.row.names=FALSE)
		
		# rename columns 
		colnames(dfm) <- c("Province_State", "Country_Region"
				  , "Lat", "Long", "Date", "Value", "Status")
		
		# fix data types 
		dfm$Value <- as.integer(dfm$Value)
		dfm$Lat <- as.numeric(dfm$Lat)
		dfm$Long <- as.numeric(dfm$Long)
		dfm$Date <- as.Date(dfm$Date)
		dfm$Status <- as.factor(dfm$Status)
	
		# save as RDS 
		saveRDS(dfm, file = file_name)
		
	} 

	dfm <- readRDS(file_name) 

}


#' 
#' 
#' 
#' This is a simple exploration of the time series data which was compiled by the Johns Hopkins University Center for Systems Science and Engineering (JHU CCSE) from various sources (see website for full description). The data can be downloaded manually at [Novel Coronavirus 2019 Cases.](https://data.humdata.org/dataset/novel-coronavirus-2019-ncov-cases)
#' 
#' 
#' ## Contents {#contents-link}
#' 
#' * [Data Pre-Processing](#preprocess-link)
#' * [Data Cleanup](#cleanup-link)
#' * [Exploratory Data Analysis](#eda-link)
#' * [Code Appendix](#codeappendix-link)
#' 
#' ---
#' 
#' ## Data Pre-Processing {#preprocess-link}
#' 
#' The `preprocess` function creates a local folder and pulls three csv files, one for each stage in tracking the coronavirus spread (confirmed, fatal, and recovered cases), performs various pre-processing steps to create one narrow and long dataset, saving it in compressed RDS format. See code in the [Code Appendix.](#codeappendix-link)
#' 
#' 
#' 
## ------------------------------------------------------------------------
# read in RDS file 
dfm <- preprocess()

str(dfm)

#' 
#' 
#' There are `r nrow(dfm)` rows and `r length(dfm)` columns. There's a 'Status' column for the different stages, so the number of rows is 3 times the number of rows for a single status (ex. "confirmed"). Each single-status dataset is as long as the number of days in the time series (for a given day the data is pulled) times the number of countries and sub-national provinces or states. This number varies per country, and also varies per day depending on how the dataset is built. 
#' 
#' 
#' ---
#' 
#' [Back to [Contents](#contents-link)]{style="float:right"}
#' 
#' ## Data Cleanup  {#cleanup-link}
#' 
#' 
#' ### Location Granularity 
#' 
#' The data's location variables have several issues. I will discard `Lat` and `Long` since I'm not doing any mapping. The variables `Country_Region` and `Province_State` are often loosely aggregated. This can be visualized in [Johns Hopkins' dashboard](https://coronavirus.jhu.edu/map.html): the totals for fatalities are grouped by a mixture of countries and subnational geographic areas. The US is conspicuously missing as a country. 
#' 
#' Since subnational data is sparse, I'll focus on country-level data. After some data analysis, I noticed that the anomalies will repond to one simple aggregation and I recreated the dataset at this national level. Canada is a prime example of bad data: notice how it lacks subnational data on recovered cases, but also, I doubt there's a province in Canada called 'Recovered':
#' 
#' 
nrow(dfm)
length(dfm)
## ----echo=FALSE----------------------------------------------------------
# Canada provinces example
kable(data.frame(dfm[dfm$Country_Region == "Canada", ]) %>% 
		   distinct(Country_Region, Province_State, Status)) %>%
      kable_styling(bootstrap_options = c("striped", "hover", "condensed")
                  , full_width = FALSE)

#' 
## ----include=FALSE-------------------------------------------------------
# country-level dataset
country_level_df <- data.frame(dfm %>%
							   select(Country_Region, Status, Date, Value) %>%
							   group_by(Country_Region, Status, Date) %>%
							   summarise('Value'=sum(Value))) %>%
							   arrange(Country_Region, Status, desc(Date))

colnames(country_level_df) <- c("Country", "Status", "Date", "Count")

Ncountries <- length(unique(country_level_df$Country))
Ndays <- length(unique(country_level_df$Date))

# check: is the number of rows equal to the number of countries
# times the number of days times 3 (statuses)?
nrow(country_level_df) == Ncountries * Ndays * 3

#' 
#' The top and bottom rows for the final dataset:
#' 
## ----echo=FALSE----------------------------------------------------------
# top and bottom rows for final dataset
kable(rbind(head(country_level_df)
     ,tail(country_level_df))) %>%
      kable_styling(bootstrap_options = c("striped", "hover", "condensed")
                  , full_width = FALSE)

#' 
#' 
#' 
#' 
#' 
#' ---
#' 
#' [Back to [Contents](#contents-link)]{style="float:right"}
#' 
#' 
#' ## Exploratory Data Analysis {#eda-link}
#' 
#' #### WORLD TOTALS
#' 
#' 
#' 
## ----echo=FALSE----------------------------------------------------------
# subset to current counts 
current_data <- data.frame(country_level_df %>%
					filter(Date == unique(country_level_df$Date)[1])) %>%
					arrange(Status, desc(Count))

# subset to world totals 
world_totals <- data.frame(current_data %>% 
					group_by(Status) %>%
					summarise('Total'=sum(Count)))


kable(world_totals) %>%
      kable_styling(bootstrap_options = c("striped", "hover")
                    , full_width = FALSE)

#' 
#' 
#' #### TOP COUNTRIES PER STATUS
#' 
## ----echo=FALSE----------------------------------------------------------
# subset to country totals 
country_totals <- data.frame(current_data %>%
						select(Country, Status, Count) %>%
						group_by(Country, Status))
	
# subset to top counts 	
get_top_counts <- function(dfm, coln) {
	
	dfm <- dfm[dfm$Status == coln, c(1,3)][1:6,]
	row.names(dfm) <- 1:6
	dfm
}					

# separate by status 
top_confirmed 	<- get_top_counts(country_totals, "Confirmed")
top_fatal	<- get_top_counts(country_totals, "Fatal")
top_recovered 	<- get_top_counts(country_totals, "Recovered")

# plot top countries per status 
gg_plot <- function(dfm, status, color) {

	ggplot(data=dfm, aes(x=reorder(Country, -Count), y=Count)) +
		geom_bar(stat="identity", fill=color) + 
		ggtitle(paste0("Top ", status, " Cases by Country")) + 
		xlab("") + ylab(paste0("Number of ", status, " Cases")) +
		geom_text(aes(label=Count), vjust=1.6, color="white", size=3.5) +
		theme_minimal()

}

#' 
#' 
#' 
## ----fig.height=5, fig.width=9, echo=FALSE-------------------------------
# top confirmed
gg_plot(top_confirmed, "Confirmed", "#D6604D") 

# top fatal 
gg_plot(top_fatal, "Fatal", "gray25")

# top recovered
gg_plot(top_recovered, "Recovered", "#74C476")


#' 
#' 
#' 
#' 
#' ---
#' 
#'   
#'   
#' 
#' ### Time Series Plots per Status and Location
#' 
#' This interactive time series speaks for itself: the US has overtaken Italy and China in number of confirmed cases in the last two days.
#' 
#' 
#' 
## ----include=FALSE-------------------------------------------------------
create_xts_series <- function(dfm, country, status) {
  
	dfm <- dfm[dfm$Country == country & dfm$Status == status, ]
	series <- xts(dfm$Count, order.by = dfm$Date)
	series
}

create_seriesObject <- function(dfm, countries, status) {
  
  seriesObject <- NULL
  for (i in 1:length(countries)) {
    seriesObject <- cbind(seriesObject
                          , create_xts_series(dfm, countries[i]
                          , status))
  }
  
  names(seriesObject) <- countries
  seriesObject
}


plot_interactive_df <- function(dfm, status_df, status) {
  
  seriesObject <- create_seriesObject(dfm, status_df$Country, status)
  
  interactive_df <- dygraph(seriesObject
                            , main=paste0("Top Countries - "
                                          , status, " Cases")
                            , xlab=""
                            , ylab=paste0("Number of "
                                          , status, " Cases")
                            ) %>%
					          dyAxis("x", drawGrid = FALSE) %>%
                    dyOptions(colors=brewer.pal(
                                       length(status_df$Country)
                                       ,"Dark2")
                            , axisLineWidth = 1.5,
							              , axisLineColor = "navy"
							              , gridLineColor = "lightblue") %>%	
                    dyRangeSelector() %>%
                    dyLegend(width = 750)
  interactive_df
}

#' 
#' 
#' 
## ----fig.height=5, fig.width=9, echo=FALSE-------------------------------
# INTERACTIVE PLOTS - COUNT
# Confirmed
plot_interactive_df(country_level_df, top_confirmed, "Confirmed")

# Fatal
plot_interactive_df(country_level_df, top_fatal, "Fatal")

# Recovered
plot_interactive_df(country_level_df, top_recovered, "Recovered")

#' 
#' 
#' 
#' Since China dominates this plot too much, it would be interesting to see how the other countries are doing as far as recoveries:
#' 
## ----fig.height=5, fig.width=9, echo=FALSE-------------------------------
# Recovered - after China
plot_interactive_df(country_level_df, top_recovered[2:6, ], "Recovered")

#' 
#' 
#' ---
#' 
#' #### Per Capita Analysis
#' 
#' 
#' Raw counts only tell part of the story. Since the probability of, say, being diagnosed with COVID-19 is somewhat dependent on the percentage of people in a country that were diagnosed with the disease, the raw count divided by the population of a country would provide a better estimate of how one country compares to another. 
#' 
#' For example, the number of confirmed cases in the US is much higher now than any other country, yet because there are roughly 322 million people in the US, it ranks lower than most smaller countries in percentage of confirmed cases.
#' 
#' 
#' 
## ----include=FALSE-------------------------------------------------------
# read in prepared dataset of countries and populations
country_population <- read.csv("COVID19_DATA/country_population.csv")
		  
# TEST
current_countries <- unique(country_level_df$Country)
current_countries[!current_countries %in% country_population$Country]

#' 
#' 
## ----include=FALSE-------------------------------------------------------
# per capita analysis
percap <- merge(country_level_df, country_population, by="Country")

# percentage
percap$Pct <- (percap$Count / (percap$Population_thousands*1000)) * 100 

# reorder by Country, Status, and Date descending
percap <- data.frame(percap %>% 
                     arrange(Country, Status, desc(Date)))
          

#' 
#' 
#' **Top 25 Confirmed Cases by Percentage of Population**
#' 
## ----echo=FALSE----------------------------------------------------------
# subset to current counts 
current_data <- data.frame(percap %>%
					filter(Date == unique(percap$Date)[1])) %>%
					arrange(Status, desc(Pct))

kable(current_data[1:25, ]) %>%
  kable_styling(bootstrap_options = c("striped", "hover", "condensed")
                , full_width = FALSE)

#' 
#' 
#' Since the Diamond Princess is not a country and it dominates the percentages so much in all statuses, I'm removing it from consideration in the plots below.
#' 
#' 
#' 
#' 
## ----include=FALSE-------------------------------------------------------
# subset to top counts 	
get_top_pcts <- function(dfm, coln) {
	
	dfm <- dfm[dfm$Status == coln, c(1,6)][2:12,]
	row.names(dfm) <- 1:11
	dfm$Pct <- round(dfm$Pct, 4)
	dfm
}					

# separate by status 
top_confirmed 	<- get_top_pcts(current_data, "Confirmed")
top_fatal	<- get_top_pcts(current_data, "Fatal")
top_recovered 	<- get_top_pcts(current_data, "Recovered")

# plot top countries per status 
gg_plot <- function(dfm, status, color) {

	ggplot(data=dfm, aes(x=reorder(Country, -Pct), y=Pct)) +
		geom_bar(stat="identity", fill=color) + 
		ggtitle(paste0("Top ", status, " Cases by Pct of Population")) + 
		xlab("") + ylab(paste0("Percentage of ", status, " Cases")) +
		geom_text(aes(label=Pct), vjust=1.6, color="white", size=3.5) +
    theme_minimal()

}

#' 
#' 
#' 
## ----echo=FALSE, fig.height=7, fig.width=9-------------------------------
# top confirmed
gg_plot(top_confirmed, "Confirmed", "#D6604D")

# top fatal 
gg_plot(top_fatal, "Fatal", "gray25")

# top recovered
gg_plot(top_recovered, "Recovered", "#74C476")


#' 
#' ---
#' 
#' 
#' ### Time Series by Percentage - Linear & Log 
#' 
#' 
#' Following are time series plots of percentages in linear and (natural) log scales for the top six countries in each category.
#' 
#' 
## ----include=FALSE-------------------------------------------------------

# Generalizing Functions
create_xts_series <- function(dfm, country, status, scale_) {
  
	dfm <- dfm[dfm$Country == country & dfm$Status == status, ]
	
	series <- if (scale_ == "Linear") {
				xts(dfm$Pct, order.by = dfm$Date)
			} else {
			  xts(log(dfm$Pct), order.by = dfm$Date)
	        }
	series
}


create_seriesObject <- function(dfm, status_df, status, scale_) {
  
  seriesObject <- NULL
  for (i in 1:6) {
    
    seriesObject <- cbind(seriesObject
                          , create_xts_series(dfm
                                              , status_df$Country[i]
                                              , status
                                              , scale_)
                          )
  }
  
  names(seriesObject) <- status_df$Country[1:6]
  seriesObject
}

plot_interactive_df <- function(dfm, status_df, status, scale_) {
  
  seriesObject <- create_seriesObject(dfm
									  , status_df
									  , status
									  , scale_)
  
  ylab_txt <- if (scale_ == "Linear") {
					""
				} else {
				    "Log "
				}
  ylab_lab <- paste0(ylab_txt, "Percentage Of ", status, " Cases")
  main_title <- paste0("Top Countries - ", status
					 , " Cases (", scale_, " Scale)")
				
  interactive_df <- dygraph(seriesObject, main = main_title) %>% 
					dyAxis("x", drawGrid = FALSE) %>%							
					dyAxis("y", label = ylab_lab) %>%
                    dyOptions(colors=brewer.pal(6, "Dark2")
							 , axisLineWidth = 1.5,
							 , axisLineColor = "navy"
							 , gridLineColor = "lightblue") %>%			
                    dyRangeSelector() %>%
                    dyLegend(width = 750)
  interactive_df
}

# avoid NaNs in Log plots
percap$Pct[percap$Pct == 0] <- 1/1e8


#' 
#' 
#' 
## ----fig.height=5, fig.width=9, echo=FALSE-------------------------------
# Confirmed Cases 
plot_interactive_df(percap, top_confirmed, "Confirmed", "Linear")
plot_interactive_df(percap, top_confirmed, "Confirmed", "Log")

# Fatal Cases 
plot_interactive_df(percap, top_fatal, "Fatal", "Linear")
plot_interactive_df(percap, top_fatal, "Fatal", "Log")

# Recovered Cases
plot_interactive_df(percap, top_recovered, "Recovered", "Linear")
plot_interactive_df(percap, top_recovered, "Recovered", "Log")


#' 
#' 
#' 
#' ---
#' 
#' 
#' 
#' ### Proportion of New Cases Compared to Total Confirmed Cases
#' 
#' 
#' The most interesting plots perpahs would show how the disease is progressing. For this, we need to know how many new confirmed cases pop up every day, compared to the total number of confirmed cases. As a side note, confirmed cases also count fatalities and recoveries. Since at the time a case is confirmed it is generally about two weeks old, also note that we are looking into the past, not what is happening right now. Further, the number of confirmed cases is well below the actual number of cases, and varies depending on location and their ability to conduct testing. 
#' 
#' 
## ----include=FALSE-------------------------------------------------------
# Calculate new cases
percap$NewCases <- NULL 

for (i in  seq.int(from=1, to=(nrow(percap)-1), by=Ndays)) {
	
	for (j in i:(i+Ndays-1)) {
		percap$NewCases[j] <- percap$Count[j] - percap$Count[j+1]
	}
	
	if (i > 1) {
		percap$NewCases[i-1] <- 0
	}
}

percap$NewCases[nrow(percap)] <- 0
percap$NewCases <- as.integer(percap$NewCases)

#' 
#' 
#' **Recent New Confirmed Cases in the US**
#' 
## ----echo=FALSE----------------------------------------------------------
kable(percap[percap$Country == "US", ][1:10,]) %>%
  kable_styling(bootstrap_options = c("striped", "hover", "condensed")
                , full_width = FALSE)

#' 
#' 
#' 
#' 
#' 
#' 
#' 
#' 
#' ---
#' 
#' [Back to [Contents](#contents-link)]{style="float:right"}
#' 
#' ### Code Appendix {#codeappendix-link}
#' 
## ----eval=FALSE----------------------------------------------------------
## ## ----setup, include=FALSE------------------------------------------------
## knitr::opts_chunk$set(echo = TRUE)
## 
## ## ----include=FALSE-------------------------------------------------------
## # setup
## rm(list = ls())
## options(scipen=999)
## 
## install_packages <- function(package){
## 
##   newpackage <- package[!(package %in% installed.packages()[, "Package"])]
## 
## 	if (length(newpackage)) {
##       suppressMessages(install.packages(newpackage, dependencies = TRUE))
## 	}
## 	sapply(package, require, character.only = TRUE)
## }
## 
## 
## # install packages
## packages <- c("dygraphs", "tidyverse", "xts", "RColorBrewer","kableExtra")
## suppressPackageStartupMessages(install_packages(packages))
## 
## ## ----include=FALSE-------------------------------------------------------
## 
## # preprocessing function
## preprocess <- function() {
## 
## 	# create a folder for the data
## 	dir_name <- "COVID19_DATA"
## 	if (!file.exists(dir_name)) {
## 		dir.create(dir_name)
## 	}
## 	
## 	dir_path <- "COVID19_DATA/"
## 	
## 	# download today's file, save as RDS first time, read otherwise
## 	file_name <- paste0(dir_path, gsub("-", "", Sys.Date()), "_data.rds")
## 	
## 	if (!file.exists(file_name)) {
## 
## 		# create URLs
## 		http_header <- paste0("https://data.humdata.org/hxlproxy/data/"
## 		                      ,"download/time_series_covid19_")
## 		
## 		url_body <- paste0("_narrow.csv?dest=data_edit&filter01=explode&explode"
## 		            ,"-header-att01=date&explode-value-att01=value&filter02=ren"
## 		            ,"ame&rename-oldtag02=%23affected%2Bdate&rename-newtag02=%2"
## 		            ,"3date&rename-header02=Date&filter03=rename&rename-oldtag0"
## 		            ,"3=%23affected%2Bvalue&rename-newtag03=%23affected%2Binfec"
## 		            ,"ted%2Bvalue%2Bnum&rename-header03=Value&filter04=clean&cl"
## 		            ,"ean-date-tags04=%23date&filter05=sort&sort-tags05=%23date"
## 		            ,"&sort-reverse05=on&filter06=sort&sort-tags06=%23country%2"
## 		            ,"Bname%2C%23adm1%2Bname&tagger-match-all=on&tagger-default"
## 		            ,"-tag=%23affected%2Blabel&tagger-01-header=province%2Fstat"
## 		            ,"e&tagger-01-tag=%23adm1%2Bname&tagger-02-header=country%2"
## 		            ,"Fregion&tagger-02-tag=%23country%2Bname&tagger-03-header="
## 		            ,"lat&tagger-03-tag=%23geo%2Blat&tagger-04-header=long&tagg"
## 		            ,"er-04-tag=%23geo%2Blon&header-row=1&url=https%3A%2F%2Fraw"
## 		            ,".githubusercontent.com%2FCSSEGISandData%2FCOVID-19%2Fmast"
## 		            ,"er%2Fcsse_covid_19_data%2Fcsse_covid_19_time_series%2Ftim"
## 		            ,"e_series_covid19_")
## 		
## 		
## 		confirmed_URL  <- paste0(http_header, "confirmed_global"
## 		                         , url_body, "confirmed_global.csv")
## 		fatal_URL <- paste0(http_header, "deaths_global"
## 		                    , url_body, "deaths_global.csv")
## 		recovered_URL  <- paste0(http_header, "recovered_global"
## 		                         , url_body, "recovered_global.csv")
## 									
## 		# download
## 		download.file(confirmed_URL
## 		              , destfile=paste0(dir_path, "confirmed.csv"))
## 		download.file(fatal_URL
## 		              , destfile=paste0(dir_path, "fatal.csv"))
## 		download.file(recovered_URL
## 		              , destfile=paste0(dir_path, "recovered.csv"))
## 		
## 		# load csvs
## 		load_csv <- function(filename) {
## 			filename <- read.csv(paste0(dir_path, filename, ".csv"), header=TRUE
## 			                     , fileEncoding="UTF-8-BOM"
## 								 , stringsAsFactors=FALSE, na.strings="")[-1, ]
## 			filename
## 		}
## 	
## 		confirmed  <- load_csv("confirmed")
## 		fatal <- load_csv("fatal")
## 		recovered  <- load_csv("recovered")
## 		
## 		# prep data for long format
## 		
## 		# add column identifying the dataset	
## 		add_col <- function(dfm, name) {
## 			dfm$Status <- rep(name, nrow(dfm))
## 			dfm
## 		}
## 		
## 		confirmed  <- add_col(confirmed, "Confirmed")
## 		fatal <- add_col(fatal, "Fatal")
## 		recovered  <- add_col(recovered, "Recovered")
## 		
## 		# join (union actually) into one dataset
## 		dfm <- rbind(confirmed, fatal, recovered, make.row.names=FALSE)
## 		
## 		# rename columns
## 		colnames(dfm) <- c("Province_State", "Country_Region"
## 				  , "Lat", "Long", "Date", "Value", "Status")
## 		
## 		# fix data types
## 		dfm$Value <- as.integer(dfm$Value)
## 		dfm$Lat <- as.numeric(dfm$Lat)
## 		dfm$Long <- as.numeric(dfm$Long)
## 		dfm$Date <- as.Date(dfm$Date)
## 		dfm$Status <- as.factor(dfm$Status)
## 	
## 		# save as RDS
## 		saveRDS(dfm, file = file_name)
## 		
## 	}
## 
## 	dfm <- readRDS(file_name)
## 
## }
## 
## 
## ## ------------------------------------------------------------------------
## # read in RDS file
## dfm <- preprocess()
## 
## str(dfm)
## 
## 
## nrow(dfm)
## length(dfm)
## ## ----echo=FALSE----------------------------------------------------------
## # Canada provinces example
## kable(data.frame(dfm[dfm$Country_Region == "Canada", ]) %>%
## 		   distinct(Country_Region, Province_State, Status)) %>%
##       kable_styling(bootstrap_options = c("striped", "hover", "condensed")
##                   , full_width = FALSE)
## 
## ## ----include=FALSE-------------------------------------------------------
## # country-level dataset
## country_level_df <- data.frame(dfm %>%
## 							   select(Country_Region, Status, Date, Value) %>%
## 							   group_by(Country_Region, Status, Date) %>%
## 							   summarise('Value'=sum(Value))) %>%
## 							   arrange(Country_Region, Status, desc(Date))
## 
## colnames(country_level_df) <- c("Country", "Status", "Date", "Count")
## 
## Ncountries <- length(unique(country_level_df$Country))
## Ndays <- length(unique(country_level_df$Date))
## 
## # check: is the number of rows equal to the number of countries
## # times the number of days times 3 (statuses)?
## nrow(country_level_df) == Ncountries * Ndays * 3
## 
## ## ----echo=FALSE----------------------------------------------------------
## # top and bottom rows for final dataset
## kable(rbind(head(country_level_df)
##      ,tail(country_level_df))) %>%
##       kable_styling(bootstrap_options = c("striped", "hover", "condensed")
##                   , full_width = FALSE)
## 
## ## ----echo=FALSE----------------------------------------------------------
## # subset to current counts
## current_data <- data.frame(country_level_df %>%
## 					filter(Date == unique(country_level_df$Date)[1])) %>%
## 					arrange(Status, desc(Count))
## 
## # subset to world totals
## world_totals <- data.frame(current_data %>%
## 					group_by(Status) %>%
## 					summarise('Total'=sum(Count)))
## 
## 
## kable(world_totals) %>%
##       kable_styling(bootstrap_options = c("striped", "hover")
##                     , full_width = FALSE)
## 
## ## ----echo=FALSE----------------------------------------------------------
## # subset to country totals
## country_totals <- data.frame(current_data %>%
## 						select(Country, Status, Count) %>%
## 						group_by(Country, Status))
## 	
## # subset to top counts 	
## get_top_counts <- function(dfm, coln) {
## 	
## 	dfm <- dfm[dfm$Status == coln, c(1,3)][1:6,]
## 	row.names(dfm) <- 1:6
## 	dfm
## }					
## 
## # separate by status
## top_confirmed 	<- get_top_counts(country_totals, "Confirmed")
## top_fatal	<- get_top_counts(country_totals, "Fatal")
## top_recovered 	<- get_top_counts(country_totals, "Recovered")
## 
## # plot top countries per status
## gg_plot <- function(dfm, status, color) {
## 
## 	ggplot(data=dfm, aes(x=reorder(Country, -Count), y=Count)) +
## 		geom_bar(stat="identity", fill=color) +
## 		ggtitle(paste0("Top ", status, " Cases by Country")) +
## 		xlab("") + ylab(paste0("Number of ", status, " Cases")) +
## 		geom_text(aes(label=Count), vjust=1.6, color="white", size=3.5) +
## 		theme_minimal()
## 
## }
## 
## ## ----fig.height=5, fig.width=9, echo=FALSE-------------------------------
## # top confirmed
## gg_plot(top_confirmed, "Confirmed", "#D6604D")
## 
## # top fatal
## gg_plot(top_fatal, "Fatal", "gray25")
## 
## # top recovered
## gg_plot(top_recovered, "Recovered", "#74C476")
## 
## 
## ## ----include=FALSE-------------------------------------------------------
## create_xts_series <- function(dfm, country, status) {
## 
## 	dfm <- dfm[dfm$Country == country & dfm$Status == status, ]
## 	series <- xts(dfm$Count, order.by = dfm$Date)
## 	series
## }
## 
## create_seriesObject <- function(dfm, countries, status) {
## 
##   seriesObject <- NULL
##   for (i in 1:length(countries)) {
##     seriesObject <- cbind(seriesObject
##                           , create_xts_series(dfm, countries[i]
##                           , status))
##   }
## 
##   names(seriesObject) <- countries
##   seriesObject
## }
## 
## 
## plot_interactive_df <- function(dfm, status_df, status) {
## 
##   seriesObject <- create_seriesObject(dfm, status_df$Country, status)
## 
##   interactive_df <- dygraph(seriesObject
##                             , main=paste0("Top Countries - "
##                                           , status, " Cases")
##                             , xlab=""
##                             , ylab=paste0("Number of "
##                                           , status, " Cases")
##                             ) %>%
## 					          dyAxis("x", drawGrid = FALSE) %>%
##                     dyOptions(colors=brewer.pal(
##                                        length(status_df$Country)
##                                        ,"Dark2")
##                             , axisLineWidth = 1.5,
## 							              , axisLineColor = "navy"
## 							              , gridLineColor = "lightblue") %>%	
##                     dyRangeSelector() %>%
##                     dyLegend(width = 750)
##   interactive_df
## }
## 
## ## ----fig.height=5, fig.width=9, echo=FALSE-------------------------------
## # INTERACTIVE PLOTS - COUNT
## # Confirmed
## plot_interactive_df(country_level_df, top_confirmed, "Confirmed")
## 
## # Fatal
## plot_interactive_df(country_level_df, top_fatal, "Fatal")
## 
## # Recovered
## plot_interactive_df(country_level_df, top_recovered, "Recovered")
## 
## ## ----fig.height=5, fig.width=9, echo=FALSE-------------------------------
## # Recovered - after China
## plot_interactive_df(country_level_df, top_recovered[2:6, ], "Recovered")
## 
## ## ----include=FALSE-------------------------------------------------------
## # read in prepared dataset of countries and populations
## country_population <- read.csv("COVID19_DATA/country_population.csv")
## 		
## # TEST
## current_countries <- unique(country_level_df$Country)
## current_countries[!current_countries %in% country_population$Country]
## 
## ## ----include=FALSE-------------------------------------------------------
## # per capita analysis
## percap <- merge(country_level_df, country_population, by="Country")
## 
## # percentage
## percap$Pct <- (percap$Count / (percap$Population_thousands*1000)) * 100
## 
## # reorder by Country, Status, and Date descending
## percap <- data.frame(percap %>%
##                      arrange(Country, Status, desc(Date)))
## 
## 
## ## ----echo=FALSE----------------------------------------------------------
## # subset to current counts
## current_data <- data.frame(percap %>%
## 					filter(Date == unique(percap$Date)[1])) %>%
## 					arrange(Status, desc(Pct))
## 
## kable(current_data[1:25, ]) %>%
##   kable_styling(bootstrap_options = c("striped", "hover", "condensed")
##                 , full_width = FALSE)
## 
## ## ----include=FALSE-------------------------------------------------------
## # subset to top counts 	
## get_top_pcts <- function(dfm, coln) {
## 	
## 	dfm <- dfm[dfm$Status == coln, c(1,6)][2:12,]
## 	row.names(dfm) <- 1:11
## 	dfm$Pct <- round(dfm$Pct, 4)
## 	dfm
## }					
## 
## # separate by status
## top_confirmed 	<- get_top_pcts(current_data, "Confirmed")
## top_fatal	<- get_top_pcts(current_data, "Fatal")
## top_recovered 	<- get_top_pcts(current_data, "Recovered")
## 
## # plot top countries per status
## gg_plot <- function(dfm, status, color) {
## 
## 	ggplot(data=dfm, aes(x=reorder(Country, -Pct), y=Pct)) +
## 		geom_bar(stat="identity", fill=color) +
## 		ggtitle(paste0("Top ", status, " Cases by Pct of Population")) +
## 		xlab("") + ylab(paste0("Percentage of ", status, " Cases")) +
## 		geom_text(aes(label=Pct), vjust=1.6, color="white", size=3.5) +
##     theme_minimal()
## 
## }
## 
## ## ----echo=FALSE, fig.height=7, fig.width=9-------------------------------
## # top confirmed
## gg_plot(top_confirmed, "Confirmed", "#D6604D")
## 
## # top fatal
## gg_plot(top_fatal, "Fatal", "gray25")
## 
## # top recovered
## gg_plot(top_recovered, "Recovered", "#74C476")
## 
## 
## ## ----include=FALSE-------------------------------------------------------
## 
## # Generalizing Functions
## create_xts_series <- function(dfm, country, status, scale_) {
## 
## 	dfm <- dfm[dfm$Country == country & dfm$Status == status, ]
## 	
## 	series <- if (scale_ == "Linear") {
## 				xts(dfm$Pct, order.by = dfm$Date)
## 			} else {
## 			  xts(log(dfm$Pct), order.by = dfm$Date)
## 	        }
## 	series
## }
## 
## 
## create_seriesObject <- function(dfm, status_df, status, scale_) {
## 
##   seriesObject <- NULL
##   for (i in 1:6) {
## 
##     seriesObject <- cbind(seriesObject
##                           , create_xts_series(dfm
##                                               , status_df$Country[i]
##                                               , status
##                                               , scale_)
##                           )
##   }
## 
##   names(seriesObject) <- status_df$Country[1:6]
##   seriesObject
## }
## 
## plot_interactive_df <- function(dfm, status_df, status, scale_) {
## 
##   seriesObject <- create_seriesObject(dfm
## 									  , status_df
## 									  , status
## 									  , scale_)
## 
##   ylab_txt <- if (scale_ == "Linear") {
## 					""
## 				} else {
## 				    "Log "
## 				}
##   ylab_lab <- paste0(ylab_txt, "Percentage Of ", status, " Cases")
##   main_title <- paste0("Top Countries - ", status
## 					 , " Cases (", scale_, " Scale)")
## 				
##   interactive_df <- dygraph(seriesObject, main = main_title) %>%
## 					dyAxis("x", drawGrid = FALSE) %>%							
## 					dyAxis("y", label = ylab_lab) %>%
##                     dyOptions(colors=brewer.pal(6, "Dark2")
## 							 , axisLineWidth = 1.5,
## 							 , axisLineColor = "navy"
## 							 , gridLineColor = "lightblue") %>%			
##                     dyRangeSelector() %>%
##                     dyLegend(width = 750)
##   interactive_df
## }
## 
## # avoid NaNs in Log plots
## percap$Pct[percap$Pct == 0] <- 1/1e8
## 
## 
## ## ----fig.height=5, fig.width=9, echo=FALSE-------------------------------
## # Confirmed Cases
## plot_interactive_df(percap, top_confirmed, "Confirmed", "Linear")
## plot_interactive_df(percap, top_confirmed, "Confirmed", "Log")
## 
## # Fatal Cases
## plot_interactive_df(percap, top_fatal, "Fatal", "Linear")
## plot_interactive_df(percap, top_fatal, "Fatal", "Log")
## 
## # Recovered Cases
## plot_interactive_df(percap, top_recovered, "Recovered", "Linear")
## plot_interactive_df(percap, top_recovered, "Recovered", "Log")
## 
## 
## ## ----include=FALSE-------------------------------------------------------
## # Calculate new cases
## percap$NewCases <- NULL
## 
## for (i in  seq.int(from=1, to=(nrow(percap)-1), by=Ndays)) {
## 	
## 	for (j in i:(i+Ndays-1)) {
## 		percap$NewCases[j] <- percap$Count[j] - percap$Count[j+1]
## 	}
## 	
## 	if (i > 1) {
## 		percap$NewCases[i-1] <- 0
## 	}
## }
## 
## percap$NewCases[nrow(percap)] <- 0
## percap$NewCases <- as.integer(percap$NewCases)
## 
## ## ----echo=FALSE----------------------------------------------------------
## kable(percap[percap$Country == "US", ][1:10,]) %>%
##   kable_styling(bootstrap_options = c("striped", "hover", "condensed")
##                 , full_width = FALSE)

#' 
#' 
#' 
## ------------------------------------------------------------------------
# uncomment to run, creates Rcode file with R code, set documentation = 1 to avoid text commentary
library(knitr)
options(knitr.purl.inline = TRUE)
purl("COVID19_DATA_ANALYSIS.Rmd", output = "Rcode.R", documentation = 2)

#' 
#' 
