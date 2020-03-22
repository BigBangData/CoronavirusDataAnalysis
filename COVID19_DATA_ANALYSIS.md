---
title: "Coronavirus Data Analysis"
author: "Marcelo Sanches"
date: "3/21/2020"
output: 
  html_document:
    keep_md: true
---



## Coronavirus Data Analysis

This is a simple exploration of the time series data which was compiled by the Johns Hopkins University Center for Systems Science and Engineering (JHU CCSE) from various sources (see the website) and can be direcly accessed at [Novel Coronavirus 2019 Cases.](https://data.humdata.org/dataset/novel-coronavirus-2019-ncov-cases)

### Evironment Setup


```r
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

suppressMessages(suppressWarnings(install_packages(packages)))
```

```
##     Hmisc tidyverse   ggplot2 
##      TRUE      TRUE      TRUE
```

### Data Pre-Processing

I pull the data directly from the website into a folder (COVID19) created in the R working directory, perform some pre-processing steps to create one narrow and long dataset with confirmed cases, fatal, and recovered cases, and save it in the compressed RDS format.



```r
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
		fatal_URL <- paste0(http_header, "Deaths.csv", url_body, "Deaths.csv")
		recovered_URL  <- paste0(http_header, "Recovered.csv", url_body, "Recovered.csv")
									
		# downloading 
		download.file(confirmed_URL, destfile="./COVID19/confirmed.csv")
		download.file(fatal_URL, destfile="./COVID19/fatal.csv")
		download.file(recovered_URL, destfile="./COVID19/recovered.csv")
		
		# read in separate files
		read_in_file <- function(filename) { 
		
			filename <- read.csv(paste0("./COVID19/", filename, ".csv"), 
								,header=TRUE,
								,stringsAsFactors=FALSE, 
								,na.strings="")[-1, ]
			filename
		}
	
		confirmed  <- read_in_file("confirmed")
		fatal <- read_in_file("fatal") 
		recovered  <- read_in_file("recovered")
		
		# prep data for long format
		
		# add column identifying the dataset	
		add_col <- function(dfm, name) {
		
			dfm$Status <- rep(name, nrow(dfm))
			dfm
		}
		
		confirmed  <- add_col(confirmed, "confirmed")
		fatal <- add_col(fatal, "fatal")
		recovered  <- add_col(recovered, "recovered")
		
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
		saveRDS(dfm, file = "COVID19/covid_data.rds")
		
	} 

	dfm <- readRDS("./COVID19/covid_data.rds") 

}

# read in RDS file 
dfm <- preprocess()
```


## Exploratory Data Analysis



The time series data is cumulative and exponential, but pulling current totals isn't as simple as subsetting the dataset to today's date. 

For some reason, the data often zeroes out after starting some accumulation, which tells me that the recent zeroes must be NA values that need to be imputed. Here are a couple of examples:



```r
# examples of bad data
example1 <-  dfm[dfm$Country_Region == "US" 
    		       & dfm$Province_State == "California" 
    		       & dfm$Status == "recovered" 
    		       & as.character(dfm$Date) > "2020-03-01", !colnames(dfm) %in% c("Lat","Long")]
    
    
example2 <- dfm[dfm$Country_Region == "US" 
    		      & dfm$Province_State == "Westchester County, NY" 
    		      & dfm$Status == "confirmed" 
    		      & as.character(dfm$Date) > "2020-03-01", !colnames(dfm) %in% c("Lat","Long")]

example1
```

```
##       Province_State Country_Region       Date Value    Status
## 70801     California             US 2020-03-20     0 recovered
## 70802     California             US 2020-03-19     0 recovered
## 70803     California             US 2020-03-18     0 recovered
## 70804     California             US 2020-03-17     6 recovered
## 70805     California             US 2020-03-16     6 recovered
## 70806     California             US 2020-03-15     6 recovered
## 70807     California             US 2020-03-14     6 recovered
## 70808     California             US 2020-03-13     6 recovered
## 70809     California             US 2020-03-12     6 recovered
## 70810     California             US 2020-03-11     2 recovered
## 70811     California             US 2020-03-10     2 recovered
## 70812     California             US 2020-03-09     0 recovered
## 70813     California             US 2020-03-08     0 recovered
## 70814     California             US 2020-03-07     0 recovered
## 70815     California             US 2020-03-06     0 recovered
## 70816     California             US 2020-03-05     0 recovered
## 70817     California             US 2020-03-04     0 recovered
## 70818     California             US 2020-03-03     0 recovered
## 70819     California             US 2020-03-02     0 recovered
```

```r
example2
```

```
##               Province_State Country_Region       Date Value    Status
## 27436 Westchester County, NY             US 2020-03-20     0 confirmed
## 27437 Westchester County, NY             US 2020-03-19     0 confirmed
## 27438 Westchester County, NY             US 2020-03-18     0 confirmed
## 27439 Westchester County, NY             US 2020-03-17     0 confirmed
## 27440 Westchester County, NY             US 2020-03-16     0 confirmed
## 27441 Westchester County, NY             US 2020-03-15     0 confirmed
## 27442 Westchester County, NY             US 2020-03-14     0 confirmed
## 27443 Westchester County, NY             US 2020-03-13     0 confirmed
## 27444 Westchester County, NY             US 2020-03-12     0 confirmed
## 27445 Westchester County, NY             US 2020-03-11     0 confirmed
## 27446 Westchester County, NY             US 2020-03-10     0 confirmed
## 27447 Westchester County, NY             US 2020-03-09    98 confirmed
## 27448 Westchester County, NY             US 2020-03-08    83 confirmed
## 27449 Westchester County, NY             US 2020-03-07    57 confirmed
## 27450 Westchester County, NY             US 2020-03-06    19 confirmed
## 27451 Westchester County, NY             US 2020-03-05    18 confirmed
## 27452 Westchester County, NY             US 2020-03-04    10 confirmed
## 27453 Westchester County, NY             US 2020-03-03     1 confirmed
## 27454 Westchester County, NY             US 2020-03-02     0 confirmed
```


Here's a panoramic view of the cumulative dataset showing how, for several US states, there is no data available after 3/10, and instead of ending with the highest value available, the cumulative series just zeros out again. This is a zoomed out Excel file with conditional formatting, where green is zero and are high numbers, with white being small numbers:



**US States that zero out after 3/10**

![image: US states](./IMG/US_states_zeroing.PNG)

---


By comparison, here is the same visualization for the Chinese province of Hubei, showing the exponential growth of confirmed cases:

**Hubei cumulative series**

![image: Hubei Province](./IMG/Hubei_example.PNG)

---


We can see the typical cumulative time series with exponential growth and flattening in Hubei Province, compared to the anomalous data of Westchester County, NY:


```r
hubei <- dfm[dfm$Country_Region == "China" 
			& dfm$Province_State == "Hubei" 
			& dfm$Status == "confirmed", ]
			
westchester <- dfm[dfm$Country_Region == "US" 
					& dfm$Province_State == "Westchester County, NY" 
					& dfm$Status == "confirmed", ]

mult_factor <- max(hubei$Value)/max(westchester$Value)

# plot
par(mar = c(5,5,2,5))
with(hubei, plot(Date, Value, type="l", col="red3", lwd=1,
		     main="Hubei Province, China vs Westchester County, NY",
             ylab="Confirmed Cases (Hubei)"))
					 
par(new = TRUE)
with(westchester, plot(Date, Value, type="l", lwd=1, axes=FALSE, xlab=NA, ylab=NA))
axis(side = 4)
mtext(side = 4, line = 3, 'Confirmed Cases (Westchester)')
legend("topleft",
       legend=c("Hubei", "Westchester"),
       lty=1, lwd=1, col=c("red3", "black"))
```

![](COVID19_DATA_ANALYSIS_files/figure-html/unnamed-chunk-4-1.png)<!-- -->




