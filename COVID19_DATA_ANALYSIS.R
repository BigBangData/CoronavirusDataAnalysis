# ------------------------------------- # 
# CORONAVIRUS DATA ANALYSIS EXPLORATION #
# 					#
# Marcelo Sanches			#
# Boulder, Colorado, 03-20-2020		#
# ------------------------------------- # 


# ENVIRONMENT SETUP ===============================================================================

# clear workspace and set options 
rm(list = ls())
options(scipen=999)

# if not installed, install packages
install_packages <- function(package){
    newpackage <- package[!(package %in% installed.packages()[, "Package"])]
    
	if (length(newpackage)) {
        suppressMessages(install.packages(newpackage, dependencies = TRUE))
	}
	sapply(package, require, character.only = TRUE)
}

packages <- c("Hmisc","tidyverse","ggplot2")

suppressMessages(install_packages(packages))


# PRE-PROCESSING ==================================================================================

preprocess <- function() {

	# create 'COVID19' directory, if not exists 
	if (!file.exists("COVID19")) {
		dir.create("COVID19")
	}
	
	
	# download only if file does not exist, save RDS first time, read otherwise
	if (!file.exists("./COVID19/covid_data.rds")) {
	
		# download files

		# creating URLs
		http_header <- "https://data.humdata.org/hxlproxy/data/download/time_series-ncov-"
		
		url_body <- paste0("?dest=data_edit&filter01=explode&explode-header-att01=date&explode-"
				  ,"value-att01=value&filter02=rename&rename-oldtag02=%23affected%2Bdate"
				  ,"&rename-newtag02=%23date&rename-header02=Date&filter03=rename&rename"
				  ,"-oldtag03=%23affected%2Bvalue&rename-newtag03=%23affected%2Binfected"
				  ,"%2Bvalue%2Bnum&rename-header03=Value&filter04=clean&clean-date-tags04"
				  ,"=%23date&filter05=sort&sort-tags05=%23date&sort-reverse05=on&filter06"
				  ,"=sort&sort-tags06=%23country%2Bname%2C%23adm1%2Bname&tagger-match-all"
				  ,"=on&tagger-default-tag=%23affected%2Blabel&tagger-01-header=province%"
				  ,"2Fstate&tagger-01-tag=%23adm1%2Bname&tagger-02-header=country%2Fregion"
				  ,"&tagger-02-tag=%23country%2Bname&tagger-03-header=lat&tagger-03-tag=%"
				  ,"23geo%2Blat&tagger-04-header=long&tagger-04-tag=%23geo%2Blon&header-"
				  ,"row=1&url=https%3A%2F%2Fraw.githubusercontent.com%2FCSSEGISandData%2F"
				  ,"COVID-19%2Fmaster%2Fcsse_covid_19_data%2Fcsse_covid_19_time_series%2F"
				  ,"time_series_19-covid-")
		
		confirmed_URL  <- paste0(http_header, "Confirmed.csv", url_body, "Confirmed.csv")
		fatalities_URL <- paste0(http_header, "Deaths.csv", url_body, "Deaths.csv")
		recovered_URL  <- paste0(http_header, "Recovered.csv", url_body, "Recovered.csv")
									
		# downloading 
		download.file(confirmed_URL, destfile="./COVID19/confirmed.csv")
		download.file(fatalities_URL, destfile="./COVID19/fatalities.csv")
		download.file(recovered_URL, destfile="./COVID19/recovered.csv")
		
		# read in separate files
		read_in_file <- function(filename) { 
		
			filename <- read.csv(paste0("COVID19/", filename, ".csv"), 
								,header=TRUE,
								,stringsAsFactors=FALSE, 
								,na.strings="")[-1, ]
			filename
		}
	
		confirmed  <- read_in_file("confirmed")
		fatalities <- read_in_file("fatalities") 
		recovered  <- read_in_file("recovered")
		
		# prep data for long format
		
		# add column identifying the dataset	
		add_col <- function(dfm, name) {
		
			dfm$Status <- rep(name, nrow(dfm))
			dfm
		}
		
		confirmed  <- add_col(confirmed, "confirmed")
		fatalities <- add_col(fatalities, "fatalities")
		recovered  <- add_col(recovered, "recovered")
		
		# join (union actually) into one dataset 
		dfm <- rbind(confirmed, fatalities, recovered, make.row.names=FALSE)
		
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
		saveRDS(dfm, file = "COVID19/covid_data.rds")
		
	} 

	dfm <- readRDS("./COVID19/covid_data.rds") 

}

# read in RDS file 
dfm <- preprocess()


# EXPLORATORY DATA ANALYSIS =======================================================================

# aggregate by Country-Region and Status
agg <- as.data.frame(dfm %>% 
		     group_by(Country_Region, Status) %>% 
		     summarise('total'=sum(Value)		# 59 days in time series  
		 	      ,'daily_average'=round(sum(Value)/length(unique(dfm$Date)))),4)
							  
							  

# looking at some countries of personal interest
agg[agg$Country_Region %in% c("Brazil","China","France","Germany","India"
			      ,"Iran","Italy","Russia","South Korea","US"), ]
	
	
	
	
	
	
	


