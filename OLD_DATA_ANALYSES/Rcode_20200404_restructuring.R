



#' 
#' 
#' 
## ----include=FALSE-------------------------------------------------------
# functions for plotting interactive time series

# arg values:
# dfm = the dataframe
# country = country name
# status_df = to be used as the vector of country names 
#             which is passed instead of a single country
# status = Confirmed, Fatal, Recovered
# scale_ = Linear, Log
# type = Count, Pct 

create_xts_series <- function(dfm, country, status, scale_, type) {
  
	dfm <- dfm[dfm$Country == country & dfm$Status == status, ]
	
	if (type == "Count") {
	  
	  series <- if (scale_ == "Linear") {
	  			xts(dfm$Count, order.by = dfm$Date)
	  		} else {
	  		  xts(log(dfm$Count), order.by = dfm$Date)
	  		}
	
	} else if (type == "Pct") {
	  
	  series <- if (scale_ == "Linear") {
	  			xts(dfm$Pct, order.by = dfm$Date)
	  		} else {
	  		  xts(log(dfm$Pct), order.by = dfm$Date)
	  		}	  
	} else {
	  
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
                                              , type)
                          )
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
    
    ylab_txt <- if (scale_ == "Linear") {
	  				"Number Of "
	  			} else {
	  			  "Log Count - "
	  			}
  } else if (type == "Pct") {
    
    ylab_txt <- if (scale_ == "Linear") {
	  				"Percentage Of "
	  			} else {
	  			  "Log Percentage - "
	  			}   
  } else {
    
    ylab_txt <- if (scale_ == "Linear") {
	  				"Number Of New "
	  			} else {
	  			  "Log Count of New - "
	  			}       
  }
  
  ylab_lab <- paste0(ylab_txt, status, " Cases")
  main_title <- paste0("Top Countries - ", status
					 , " Cases (", scale_, " Scale)")
  
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

#' 
#' 
#' 
#' 
## ----fig.height=5, fig.width=9, echo=FALSE-------------------------------
# INTERACTIVE PLOTS - COUNT 

# By Status (4), Type (3), Scale (2) = 4*3*2 = 24 plots 

plot_types <- data.frame('Status' = c(rep("Confirmed",6)
									  ,rep("Fatal",6)
									  ,rep("Recovered",6)
									  ,rep("Active",6))
						  ,'Scale' = rep(c("Linear","Log"),3)
						  ,'Type' = rep(c("Count","Pct","NewCases"), each=2)
						  , stringsAsFactors = FALSE
						  )

	

# Confirmed plots 
for (i in 1:6) {
			
	show(plot_interactive_df(percap
							, top_confirmed[1:5, ]
							, plot_types$Status[i]
							, plot_types$Scale[i]
							, plot_types$Type[i])
		)
}
# Fatal plots 
for (i in 1:6) {
			
	show(plot_interactive_df(percap
							, top_fatal[1:5, ]
							, plot_types$Status[i]
							, plot_types$Scale[i]
							, plot_types$Type[i])
		)
}
# Recovered plots 
for (i in 1:6) {
			
	show(plot_interactive_df(percap
							, top_recovered[1:5, ]
							, plot_types$Status[i]
							, plot_types$Scale[i]
							, plot_types$Type[i])
		)
}
# Active plots 
for (i in 1:6) {
			
	show(plot_interactive_df(percap
							, top_active[1:5, ]
							, plot_types$Status[i]
							, plot_types$Scale[i]
							, plot_types$Type[i])
		)
}





					
										
										
					
					

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
# Per Capita Analysis 

# data enrichment and wrangling

# read in prepared dataset of countries and populations
country_population <- read.csv("COVID19_DATA/country_population.csv")
		  
# test for new countries in data 
current_countries <- unique(dfm$Country)
current_countries[!current_countries %in% country_population$Country]

# merge datasets
percap <- merge(dfm, country_population, by="Country")

# create percentage col
percap$Pct <- (percap$Count/(percap$Population_thousands*1000))*100 

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
#' Since the cruise ships Diamond Princess and MS Zaandam are not countries and dominate plots in a perhaps unrealistic comparison, I am removing them from from consideration in the plots below.
#' 
#' 
#' 
## ----include=FALSE-------------------------------------------------------
# discard cruise ships from countries	
cruise_ships <- c("Diamond Princess", "MS Zaandam")
current_data <- current_data[!current_data$Country %in% cruise_ships, ]

# subset to top ten percentages 	
get_top10_pcts <- function(dfm, coln) {
	
	dfm <- dfm[dfm$Status == coln, c(1,6)][1:10,]
	row.names(dfm) <- 1:10
	dfm$Pct <- round(dfm$Pct, 4)
	dfm
}					

# separate by status 
top10_confirmed 	<- get_top10_pcts(current_data, "Confirmed")
top10_fatal	<- get_top10_pcts(current_data, "Fatal")
top10_recovered 	<- get_top10_pcts(current_data, "Recovered")

# plot top countries per status 
gg_plot <- function(dfm, status, color) {

	ggplot(data=dfm, aes(x=reorder(Country, -Pct), y=Pct)) +
		geom_bar(stat="identity", fill=color) + 
		ggtitle(paste0("Top Ten Countries: ", status
		               , " Cases by Percentage of Population")) + 
		xlab("") + ylab(paste0("Percentage of ", status, " Cases")) +
		geom_text(aes(label=Pct), vjust=1.6, color="white", size=3.5) +
    theme_minimal() + 
    theme(axis.text.x = element_text(angle = 45, hjust = 1))
}

#' 
#' 
#' 
## ----echo=FALSE, fig.height=6, fig.width=9-------------------------------
# top confirmed
gg_plot(top10_confirmed, "Confirmed", "#D6604D")

# top fatal 
gg_plot(top10_fatal, "Fatal", "gray25")

# top recovered
gg_plot(top10_recovered, "Recovered", "#74C476")

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
#' 
## ----fig.height=5, fig.width=9, echo=FALSE-------------------------------
# Confirmed Cases 
plot_interactive_df(percap, top10_confirmed[1:6, ]
                    , "Confirmed", "Linear", "Pct")
plot_interactive_df(percap, top10_confirmed[1:6, ]
                    , "Confirmed", "Log", "Pct")

# Fatal Cases 
plot_interactive_df(percap, top10_fatal
                    , "Fatal", "Linear", "Pct")
plot_interactive_df(percap, top10_fatal
                    , "Fatal", "Log", "Pct")

# Recovered Cases
plot_interactive_df(percap, top10_recovered
                    , "Recovered", "Linear", "Pct")
plot_interactive_df(percap, top10_recovered
                    , "Recovered", "Log", "Pct")

#' 
#' 
#' 
#' ---
#' 
#' 
#' 
#' ### Time Series Of New Cases 
#' 
#' 
#' The most interesting plots would show how the disease is progressing. One way is to track how many new cases pop up every day. Since the daily number is a bit erratic, I first calculate the previous week's daily average (mean) and select the top countries with highest mean daily number of new cases per status.
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


# get last weeks data only
lastweek_vec <- percap$Date[1:7]
lastweek <- percap[percap$Date %in% lastweek_vec, ]

# calculate grouped means 
lastweek <- data.frame(lastweek %>%
					   group_by(Country, Status) %>%
					   summarise(MeanNewCases=round(mean(NewCases),2)))
					   
# status dfs reordered by mean new cases 
confirmed <- lastweek[lastweek$Status == "Confirmed", ] %>%
			 arrange(desc(MeanNewCases))
fatal <- lastweek[lastweek$Status == "Fatal", ] %>%
			 arrange(desc(MeanNewCases))
recovered <- lastweek[lastweek$Status == "Recovered", ] %>%
			 arrange(desc(MeanNewCases))


gg_plot <- function(dfm, status, color) {

	ggplot(data=dfm, aes(x=reorder(Country, -MeanNewCases), y=MeanNewCases)) +
		geom_bar(stat="identity", fill=color) + 
		ggtitle(paste0("Top Ten Countries: Last Week's Daily Average Of ", status
		               , " New Cases")) + 
		xlab("") + ylab("Mean Number of Daily Cases") +
		geom_text(aes(label=MeanNewCases), vjust=1.6, color="white", size=3.5) +
    theme_minimal() + 
    theme(axis.text.x = element_text(angle = 45, hjust = 1))
}

#' 
## ----fig.height=5, fig.width=9, echo=FALSE-------------------------------
# Bar Plots - New Cases

# top confirmed
gg_plot(confirmed[1:10,], "Confirmed", "#D6604D")

# top fatal 
gg_plot(fatal[1:10,], "Fatal", "gray25")

# top recovered
gg_plot(recovered[1:10,], "Recovered", "#74C476")

# Time Series - New Cases

# Confirmed Cases 
plot_interactive_df(percap, confirmed[1:6,], "Confirmed", "Linear", "NewCases")
plot_interactive_df(percap, confirmed[1:6,], "Confirmed", "Log", "NewCases")
	
# Fatal Cases 	
plot_interactive_df(percap, fatal[1:6,], "Fatal", "Linear", "NewCases")
plot_interactive_df(percap, fatal[1:6,], "Fatal", "Log", "NewCases")
	
# Recovered Cases 	
plot_interactive_df(percap, recovered[1:6,], "Recovered", "Linear", "NewCases")
plot_interactive_df(percap, recovered[1:6,], "Recovered", "Log", "NewCases")

#' 
#' 
#' 
#' 
#' ```
#' 
#' TO DO:
#' 
#'   Doubling rate - calculate how many days it takes to double a given status count, plot that.
#'   Plot proportion of New to Total Cases, Linear and Log scales.
#'   Plot against Time and with Time as interaction.
#'   Outcome Simulation section.
#'   Add more links throughough document.
#' 
#' ```
#' 
#' 
#' 
#' ---
#' 
#' ### Doubling Rate
#' 
#' 
#' ---
#' 
#' 
#' ### Proportion of New Cases Compared to Total Confirmed Cases
#' 
#' 
#' ---
#' 
#' ## Outcome Simulation {#sim-link}
#' 
#' 
#' 
#' 
#' ---
#' 
#' 
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
## dfm <- data.frame(dfm %>%
## 							   select(Country_Region, Status, Date, Value) %>%
## 							   group_by(Country_Region, Status, Date) %>%
## 							   summarise('Value'=sum(Value))) %>%
## 							   arrange(Country_Region, Status, desc(Date))
## 
## colnames(dfm) <- c("Country", "Status", "Date", "Count")
## 
## Ncountries <- length(unique(dfm$Country))
## Ndays <- length(unique(dfm$Date))
## 
## # check: is the number of rows equal to the number of countries
## # times the number of days times 3 (statuses)?
## nrow(dfm) == Ncountries * Ndays * 3
## 
## ## ----echo=FALSE----------------------------------------------------------
## # top and bottom rows for final dataset
## kable(rbind(head(dfm)
##      ,tail(dfm))) %>%
##       kable_styling(bootstrap_options = c("striped", "hover", "condensed")
##                   , full_width = FALSE)
## 
## ## ----echo=FALSE----------------------------------------------------------
## # subset to current counts
## current_data <- data.frame(dfm %>%
## 					filter(Date == unique(dfm$Date)[1])) %>%
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
## get_top10_counts <- function(dfm, coln) {
## 	
## 	dfm <- dfm[dfm$Status == coln, c(1,3)][1:10,]
## 	row.names(dfm) <- 1:10
## 	dfm
## }					
## 
## # separate by status
## top10_confirmed 	<- get_top10_counts(country_totals, "Confirmed")
## top10_fatal	<- get_top10_counts(country_totals, "Fatal")
## top10_recovered 	<- get_top10_counts(country_totals, "Recovered")
## 
## # plot top countries per status
## gg_plot <- function(dfm, status, color) {
## 
## 	ggplot(data=dfm, aes(x=reorder(Country, -Count), y=Count)) +
## 		geom_bar(stat="identity", fill=color) +
## 		ggtitle(paste0("Top Ten Countries - ", status, " Cases")) +
## 		xlab("") + ylab(paste0("Number of ", status, " Cases")) +
## 		geom_text(aes(label=Count), vjust=1.6, color="white", size=3.5) +
##     theme_minimal() +
##     theme(axis.text.x = element_text(angle = 45, hjust = 1))
## }
## 
## ## ----fig.height=6, fig.width=9, echo=FALSE-------------------------------
## # top confirmed
## gg_plot(top10_confirmed, "Confirmed", "#D6604D")
## 
## # top fatal
## gg_plot(top10_fatal, "Fatal", "gray25")
## 
## # top recovered
## gg_plot(top10_recovered, "Recovered", "#74C476")
## 
## 
## ## ----include=FALSE-------------------------------------------------------
## # subset to top 6 counts 	
## get_top6_counts <- function(dfm, coln) {
## 	
## 	dfm <- dfm[dfm$Status == coln, c(1,3)][1:6,]
## 	row.names(dfm) <- 1:6
## 	dfm
## }		
## 
## top6_confirmed 	<- get_top6_counts(country_totals, "Confirmed")
## top6_fatal	<- get_top6_counts(country_totals, "Fatal")
## top6_recovered 	<- get_top6_counts(country_totals, "Recovered")
## 
## 
## ## ----include=FALSE-------------------------------------------------------
## # functions for plotting interactive time series
## 
## # arg values:
## # dfm = the dataframe
## # country = country name
## # status_df = to be used as the vector of country names
## #             which is passed instead of a single country
## # status = Confirmed, Fatal, Recovered
## # scale_ = Linear, Log
## # type = Count, Pct
## 
## create_xts_series <- function(dfm, country, status, scale_, type) {
## 
## 	dfm <- dfm[dfm$Country == country & dfm$Status == status, ]
## 	
## 	if (type == "Count") {
## 	
## 	  series <- if (scale_ == "Linear") {
## 	  			xts(dfm$Count, order.by = dfm$Date)
## 	  		} else {
## 	  		  xts(log(dfm$Count), order.by = dfm$Date)
## 	  		}
## 	
## 	} else if (type == "Pct") {
## 	
## 	  series <- if (scale_ == "Linear") {
## 	  			xts(dfm$Pct, order.by = dfm$Date)
## 	  		} else {
## 	  		  xts(log(dfm$Pct), order.by = dfm$Date)
## 	  		}	
## 	} else {
## 	
## 	  series <- if (scale_ == "Linear") {
## 	  			xts(dfm$NewCases, order.by = dfm$Date)
## 	  		} else {
## 	  		  xts(log(dfm$NewCases), order.by = dfm$Date)
## 	  		}	  	
## 	}
## 	series
## }
## 
## 
## create_seriesObject <- function(dfm, status_df, status, scale_, type) {
## 
##   seriesObject <- NULL
##   for (i in 1:6) {
## 
##     seriesObject <- cbind(seriesObject
##                           , create_xts_series(dfm
##                                               , status_df$Country[i]
##                                               , status
##                                               , scale_
##                                               , type)
##                           )
##   }
## 
##   names(seriesObject) <- status_df$Country[1:6]
##   seriesObject
## }
## 
## plot_interactive_df <- function(dfm, status_df, status, scale_, type) {
## 
##   seriesObject <- create_seriesObject(dfm
## 									  , status_df
## 									  , status
## 									  , scale_
## 									  , type)
## 
##   if (type == "Count") {
## 
##     ylab_txt <- if (scale_ == "Linear") {
## 	  				"Number Of "
## 	  			} else {
## 	  			  "Log Count - "
## 	  			}
##   } else if (type == "Pct") {
## 
##     ylab_txt <- if (scale_ == "Linear") {
## 	  				"Percentage Of "
## 	  			} else {
## 	  			  "Log Percentage - "
## 	  			}
##   } else {
## 
##     ylab_txt <- if (scale_ == "Linear") {
## 	  				"Number Of New "
## 	  			} else {
## 	  			  "Log Count of New - "
## 	  			}
##   }
## 
##   ylab_lab <- paste0(ylab_txt, status, " Cases")
##   main_title <- paste0("Top Six Countries - ", status
## 					 , " Cases (", scale_, " Scale)")
## 
##   interactive_df <- dygraph(seriesObject, main = main_title) %>%
## 					dyAxis("x", drawGrid = FALSE) %>%							
## 					dyAxis("y", label = ylab_lab) %>%
## 					dyOptions(colors=brewer.pal(6, "Dark2")
## 							, axisLineWidth = 1.5
## 							, axisLineColor = "navy"
## 							, gridLineColor = "lightblue") %>%			
## 					dyRangeSelector() %>%
## 					dyLegend(width = 750)
## 
##   interactive_df
## }
## 
## ## ----fig.height=5, fig.width=9, echo=FALSE-------------------------------
## # INTERACTIVE PLOTS - COUNT
## 
## # Confirmed
## plot_interactive_df(dfm, top10_confirmed[1:6, ]
##                     , "Confirmed", "Linear", "Count")
## plot_interactive_df(dfm, top10_confirmed[1:6, ]
##                     , "Confirmed", "Log", "Count")
## 
## # Fatal
## plot_interactive_df(dfm, top10_fatal[1:6,]
##                     , "Fatal", "Linear", "Count")
## plot_interactive_df(dfm, top10_fatal[1:6,]
##                     , "Fatal", "Log", "Count")
## 
## # Recovered
## plot_interactive_df(dfm, top10_recovered[1:6,]
##                     , "Recovered", "Linear", "Count")
## plot_interactive_df(dfm, top10_recovered[1:6,]
##                     , "Recovered", "Log", "Count")
## 
## ## ----include=FALSE-------------------------------------------------------
## # Per Capita Analysis
## 
## # data enrichment and wranglingt
## 
## # read in prepared dataset of countries and populations
## country_population <- read.csv("COVID19_DATA/country_population.csv")
## 		
## # test for new countries in data
## current_countries <- unique(dfm$Country)
## current_countries[!current_countries %in% country_population$Country]
## 
## # merge datasets
## percap <- merge(dfm, country_population, by="Country")
## 
## # create percentage col
## percap$Pct <- (percap$Count/(percap$Population_thousands*1000))*100
## 
## # reorder by Country, Status, and Date descending
## percap <- data.frame(percap %>%
##                      arrange(Country, Status, desc(Date)))
## 
## # avoid NaNs in Log plots
## percap$Pct[percap$Pct == 0] <- 0.0001
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
## # discard cruise ships from countries	
## cruise_ships <- c("Diamond Princess", "MS Zaandam")
## current_data <- current_data[!current_data$Country %in% cruise_ships, ]
## 
## # subset to top ten percentages 	
## get_top10_pcts <- function(dfm, coln) {
## 	
## 	dfm <- dfm[dfm$Status == coln, c(1,6)][1:10,]
## 	row.names(dfm) <- 1:10
## 	dfm$Pct <- round(dfm$Pct, 4)
## 	dfm
## }					
## 
## # separate by status
## top10_confirmed 	<- get_top10_pcts(current_data, "Confirmed")
## top10_fatal	<- get_top10_pcts(current_data, "Fatal")
## top10_recovered 	<- get_top10_pcts(current_data, "Recovered")
## 
## # plot top countries per status
## gg_plot <- function(dfm, status, color) {
## 
## 	ggplot(data=dfm, aes(x=reorder(Country, -Pct), y=Pct)) +
## 		geom_bar(stat="identity", fill=color) +
## 		ggtitle(paste0("Top Ten Countries: ", status
## 		               , " Cases by Percentage of Population")) +
## 		xlab("") + ylab(paste0("Percentage of ", status, " Cases")) +
## 		geom_text(aes(label=Pct), vjust=1.6, color="white", size=3.5) +
##     theme_minimal() +
##     theme(axis.text.x = element_text(angle = 45, hjust = 1))
## }
## 
## ## ----echo=FALSE, fig.height=6, fig.width=9-------------------------------
## # top confirmed
## gg_plot(top10_confirmed, "Confirmed", "#D6604D")
## 
## # top fatal
## gg_plot(top10_fatal, "Fatal", "gray25")
## 
## # top recovered
## gg_plot(top10_recovered, "Recovered", "#74C476")
## 
## ## ----fig.height=5, fig.width=9, echo=FALSE-------------------------------
## # Confirmed Cases
## plot_interactive_df(percap, top10_confirmed[1:6, ]
##                     , "Confirmed", "Linear", "Pct")
## plot_interactive_df(percap, top10_confirmed[1:6, ]
##                     , "Confirmed", "Log", "Pct")
## 
## # Fatal Cases
## plot_interactive_df(percap, top10_fatal
##                     , "Fatal", "Linear", "Pct")
## plot_interactive_df(percap, top10_fatal
##                     , "Fatal", "Log", "Pct")
## 
## # Recovered Cases
## plot_interactive_df(percap, top10_recovered
##                     , "Recovered", "Linear", "Pct")
## plot_interactive_df(percap, top10_recovered
##                     , "Recovered", "Log", "Pct")
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
## 
## # get last weeks data only
## lastweek_vec <- percap$Date[1:7]
## lastweek <- percap[percap$Date %in% lastweek_vec, ]
## 
## # calculate grouped means
## lastweek <- data.frame(lastweek %>%
## 					   group_by(Country, Status) %>%
## 					   summarise(MeanNewCases=round(mean(NewCases),2)))
## 					
## # status dfs reordered by mean new cases
## confirmed <- lastweek[lastweek$Status == "Confirmed", ] %>%
## 			 arrange(desc(MeanNewCases))
## fatal <- lastweek[lastweek$Status == "Fatal", ] %>%
## 			 arrange(desc(MeanNewCases))
## recovered <- lastweek[lastweek$Status == "Recovered", ] %>%
## 			 arrange(desc(MeanNewCases))
## 
## 
## gg_plot <- function(dfm, status, color) {
## 
## 	ggplot(data=dfm, aes(x=reorder(Country, -MeanNewCases), y=MeanNewCases)) +
## 		geom_bar(stat="identity", fill=color) +
## 		ggtitle(paste0("Top Ten Countries: Last Week's Daily Average Of ", status
## 		               , " New Cases")) +
## 		xlab("") + ylab("Mean Number of Daily Cases") +
## 		geom_text(aes(label=MeanNewCases), vjust=1.6, color="white", size=3.5) +
##     theme_minimal() +
##     theme(axis.text.x = element_text(angle = 45, hjust = 1))
## }
## 
## ## ----fig.height=5, fig.width=9, echo=FALSE-------------------------------
## # Bar Plots - New Cases
## 
## # top confirmed
## gg_plot(confirmed[1:10,], "Confirmed", "#D6604D")
## 
## # top fatal
## gg_plot(fatal[1:10,], "Fatal", "gray25")
## 
## # top recovered
## gg_plot(recovered[1:10,], "Recovered", "#74C476")
## 
## # Time Series - New Cases
## 
## # Confirmed Cases
## plot_interactive_df(percap, confirmed[1:6,], "Confirmed", "Linear", "NewCases")
## plot_interactive_df(percap, confirmed[1:6,], "Confirmed", "Log", "NewCases")
## 	
## # Fatal Cases 	
## plot_interactive_df(percap, fatal[1:6,], "Fatal", "Linear", "NewCases")
## plot_interactive_df(percap, fatal[1:6,], "Fatal", "Log", "NewCases")
## 	
## # Recovered Cases 	
## plot_interactive_df(percap, recovered[1:6,], "Recovered", "Linear", "NewCases")
## plot_interactive_df(percap, recovered[1:6,], "Recovered", "Log", "NewCases")
## 

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
