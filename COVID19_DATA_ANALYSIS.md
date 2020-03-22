---
title: "Coronavirus Data Analysis"
author: "Marcelo Sanches"
date: "3/21/2020"
output: 
  html_document:
    keep_md: true
---









## Coronavirus Data Analysis

This is a simple exploration of the time series data which was compiled by the Johns Hopkins University Center for Systems Science and Engineering (JHU CCSE) from various sources (see website for full description). The data can be downloaded manually at [Novel Coronavirus 2019 Cases.](https://data.humdata.org/dataset/novel-coronavirus-2019-ncov-cases)

---

### Data Pre-Processing {#preprocess-link}

The `preprocess` function creates a local folder and pulls three csv files, one for each stage in tracking the coronavirus spread (confirmed, fatal, and recovered cases), performs various pre-processing steps to create one narrow and long dataset, saving it in compressed RDS format. See code in the [Code Appendix.](#codeappendix-link)




```r
# read in RDS file 
dfm <- preprocess()

head(dfm)
```

```
##   Province_State Country_Region Lat Long       Date Value    Status
## 1           <NA>    Afghanistan  33   65 2020-03-21    24 confirmed
## 2           <NA>    Afghanistan  33   65 2020-03-20    24 confirmed
## 3           <NA>    Afghanistan  33   65 2020-03-19    22 confirmed
## 4           <NA>    Afghanistan  33   65 2020-03-18    22 confirmed
## 5           <NA>    Afghanistan  33   65 2020-03-17    22 confirmed
## 6           <NA>    Afghanistan  33   65 2020-03-16    21 confirmed
```

---

### Data Cleanup  {#cleanup-link}



The time series data is cumulative, but pulling current totals isn't qutie as simple as subsetting the dataset to the most current date. For some reason, the data shows zeroes after positive values within a time series. I assume these ending zeroes should be treated as `NA` values and need to be imputed. Here is an example from the original dataset:



```r
# example of NA values coded as zeroes
dfm[dfm$Country_Region == "US" & dfm$Province_State == "Westchester County, NY" & dfm$Status == "confirmed"
    & as.character(dfm$Date) > "2020-03-01", !colnames(dfm) %in% c("Country.Region","Lat","Long"), ]
```

```
##               Province_State Country_Region       Date Value    Status
## 28201 Westchester County, NY             US 2020-03-21     0 confirmed
## 28202 Westchester County, NY             US 2020-03-20     0 confirmed
## 28203 Westchester County, NY             US 2020-03-19     0 confirmed
## 28204 Westchester County, NY             US 2020-03-18     0 confirmed
## 28205 Westchester County, NY             US 2020-03-17     0 confirmed
## 28206 Westchester County, NY             US 2020-03-16     0 confirmed
## 28207 Westchester County, NY             US 2020-03-15     0 confirmed
## 28208 Westchester County, NY             US 2020-03-14     0 confirmed
## 28209 Westchester County, NY             US 2020-03-13     0 confirmed
## 28210 Westchester County, NY             US 2020-03-12     0 confirmed
## 28211 Westchester County, NY             US 2020-03-11     0 confirmed
## 28212 Westchester County, NY             US 2020-03-10     0 confirmed
## 28213 Westchester County, NY             US 2020-03-09    98 confirmed
## 28214 Westchester County, NY             US 2020-03-08    83 confirmed
## 28215 Westchester County, NY             US 2020-03-07    57 confirmed
## 28216 Westchester County, NY             US 2020-03-06    19 confirmed
## 28217 Westchester County, NY             US 2020-03-05    18 confirmed
## 28218 Westchester County, NY             US 2020-03-04    10 confirmed
## 28219 Westchester County, NY             US 2020-03-03     1 confirmed
## 28220 Westchester County, NY             US 2020-03-02     0 confirmed
```



In this plot I compare the cumulative curve for confirmed cases in Hubei Province (China) with that of Westchester County, NY, which has this anomaly. The number of confirmed cases in Westchester is much smaller so I adjusted the y axes (note values):

![](COVID19_DATA_ANALYSIS_files/figure-html/unnamed-chunk-5-1.png)<!-- -->


### Impute missing values

The simplest imputation strategy is to replace all the zeroes after positive values given a time series, which I interpret as missing values, with the latest cumulative value. This is the result of the imputation for Westchester County, NY:


```
##               Province_State Country_Region       Date Value    Status
## 28201 Westchester County, NY             US 2020-03-21    98 confirmed
## 28202 Westchester County, NY             US 2020-03-20    98 confirmed
## 28203 Westchester County, NY             US 2020-03-19    98 confirmed
## 28204 Westchester County, NY             US 2020-03-18    98 confirmed
## 28205 Westchester County, NY             US 2020-03-17    98 confirmed
## 28206 Westchester County, NY             US 2020-03-16    98 confirmed
## 28207 Westchester County, NY             US 2020-03-15    98 confirmed
## 28208 Westchester County, NY             US 2020-03-14    98 confirmed
## 28209 Westchester County, NY             US 2020-03-13    98 confirmed
## 28210 Westchester County, NY             US 2020-03-12    98 confirmed
## 28211 Westchester County, NY             US 2020-03-11    98 confirmed
## 28212 Westchester County, NY             US 2020-03-10    98 confirmed
## 28213 Westchester County, NY             US 2020-03-09    98 confirmed
## 28214 Westchester County, NY             US 2020-03-08    83 confirmed
## 28215 Westchester County, NY             US 2020-03-07    57 confirmed
## 28216 Westchester County, NY             US 2020-03-06    19 confirmed
## 28217 Westchester County, NY             US 2020-03-05    18 confirmed
## 28218 Westchester County, NY             US 2020-03-04    10 confirmed
## 28219 Westchester County, NY             US 2020-03-03     1 confirmed
## 28220 Westchester County, NY             US 2020-03-02     0 confirmed
```


![](COVID19_DATA_ANALYSIS_files/figure-html/unnamed-chunk-7-1.png)<!-- -->


---

### Exploratory Data Analysis {#eda-link}


---

### Code Appendix {#codeappendix-link}


```r
# SETUP
#------

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
packages <- c("Hmisc","tidyverse","ggplot2")
suppressPackageStartupMessages(install_packages(packages))

# PREPROCESS
# -----------

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
									
		# download
		download.file(confirmed_URL, destfile=paste0(dir_path, "confirmed.csv"))
		download.file(fatal_URL, destfile=paste0(dir_path, "fatal.csv"))
		download.file(recovered_URL, destfile=paste0(dir_path, "recovered.csv"))
		
		# load csvs
		load_csv <- function(filename) { 
			filename <- read.csv(paste0(dir_path, filename, ".csv"), header=TRUE
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
		saveRDS(dfm, file = file_name)
		
	} 

	dfm <- readRDS(file_name) 

}


# read in RDS file 
dfm <- preprocess()


# DATA CLEANUP 
# ------------

# example of NA values coded as zeroes
dfm[dfm$Country_Region == "US" & dfm$Province_State == "Westchester County, NY" & dfm$Status == "confirmed"
    & as.character(dfm$Date) > "2020-03-01", !colnames(dfm) %in% c("Country.Region","Lat","Long"), ]

# Hubei vs Westchester plot 1
hubei <- dfm[dfm$Country_Region == "China" 
			& dfm$Province_State == "Hubei" 
			& dfm$Status == "confirmed", ]
			
westchester <- dfm[dfm$Country_Region == "US" 
					& dfm$Province_State == "Westchester County, NY" 
					& dfm$Status == "confirmed", ]

mult_factor <- max(hubei$Value)/max(westchester$Value)

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



# impute NAs with latest cumulative value
# NAs are 0-values at the end of a cumulative time series 
# which I impute with the last cumulative value available in the series 
Ndays <- length(unique(dfm$Date))
Ladfm_date <- unique(dfm$Date)[1]

for (i in 1:(nrow(dfm))) {

	# if today's date shows 0 as Value 
	if (dfm$Date[i] == Ladfm_date & dfm$Value[i] == 0) {

		# for each subsequent row in a given series 
		# starting at the ith row and ending in the penultimate row of the series 
		# (since we're comparing with the ith+1 row and starting the count at i 
		# we need to subtract 2)
		for (j in i:(i+(Ndays-2))) {
		
			# if the value of the jth+1 row is 0, continue
			# if the value of the jth+1 row is > 0...
			if (dfm$Value[j] == 0 & dfm$Value[j+1] > 0) {
	
				# ... for k (j to i) previous 0 values in that time series 
				for (k in j:i) {
				
					# substitute them with the jth+1 positive valuee 
					dfm$Value[k] <- dfm$Value[j+1]
				}
			}		
		}			
	} 
}

# Hubei vs Westchester data example - FIXED NAs
dfm[dfm$Country_Region == "US" 
    & dfm$Province_State == "Westchester County, NY" 
    & dfm$Status == "confirmed" 
    & as.character(dfm$Date) > "2020-03-01", !colnames(dfm) %in% c("Lat","Long")]


# Hubei vs Westchester plot - FIXED NAs
hubei <- dfm[dfm$Country_Region == "China" 
			& dfm$Province_State == "Hubei" 
			& dfm$Status == "confirmed", ]
			
westchester <- dfm[dfm$Country_Region == "US" 
					& dfm$Province_State == "Westchester County, NY" 
					& dfm$Status == "confirmed", ]

mult_factor <- max(hubei$Value)/max(westchester$Value)

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


# EXPLORATORY DATA ANALYSIS
# -------------------------
```




