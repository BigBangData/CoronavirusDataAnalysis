## ----setup, include=FALSE-------------------------------------------------------------------------------------------------------------------------------------------------
knitr::opts_chunk$set(echo = TRUE)
knitr::opts_chunk$set(message = FALSE)
knitr::opts_chunk$set(warning = FALSE)


## ----include=FALSE--------------------------------------------------------------------------------------------------------------------------------------------------------
# environment setup 
rm(list = ls())
options(scipen=999)

# install and load packages  
install_packages <- function(package){
  
  newpackage <- package[!(package %in% installed.packages()[, "Package"])]
      
    if (length(newpackage)) {
      suppressMessages(install.packages(newpackage, dependencies = TRUE))
    }
    sapply(package, require, character.only = TRUE)
}


packages <- c("dygraphs", "tidyverse", "xts", "RColorBrewer", "kableExtra", "sqldf")
suppressPackageStartupMessages(install_packages(packages))

# directory structure setup 
dir_name <- "data"
if (!file.exists(dir_name)) {
    dir.create(dir_name)
}

dir_path <- "data/"

# check if today's RDS file exists
rds_file <- paste0(dir_path, gsub("-", "", Sys.Date()), "_data.rds")

if (!file.exists(rds_file)) {
    
    # abspaths for today's csv files
    confirmed_csv <- paste0(dir_path, gsub("-", "", Sys.Date()), "_confirmed.csv")
    deaths_csv      <- paste0(dir_path, gsub("-", "", Sys.Date()), "_deaths.csv")
    
    # download function 
    download_csv <- function(fullpath_csv) {
    
        # check if CSV file exists first 
        if (!file.exists(fullpath_csv)) {
        
            # construct url 
            url_header <- paste0("https://data.humdata.org/hxlproxy/data/"
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
            
            # extract name and reshape into global name 
            date_name <- strsplit(fullpath_csv,"/")[[1]][2]
            name <- strsplit(strsplit(date_name, "_")[[1]][2], "\\.")[[1]][1]
            global <- paste0(name, "_global")    
            
            # download 
            final_url  <- paste0(url_header, global, url_body, global, ".csv")
            download.file(final_url, destfile = fullpath_csv)        
        }
    }
    
    download_csv(confirmed_csv)
    download_csv(deaths_csv)
    
    # load data into environment
    load_csv <- function(fullpath_csv) { 
    
        read.csv(fullpath_csv
                , header=TRUE
                , fileEncoding="UTF-8-BOM"
                , stringsAsFactors=FALSE, na.strings="")[-1, ]
    }
    
        
    confirmed_df  <- load_csv(confirmed_csv)
    fatal_df      <- load_csv(deaths_csv)
    
    # preprocess function
    preprocess_csv <- function(dfm, colname) {
    
        # prep data for long format (rbind later)
        
        # add Status col identifying the dataset
        # remove Lat Long & rename cols 
        dfm$Status <- rep(colname, nrow(dfm))
        dfm <- dfm[ ,!colnames(dfm) %in% c("Province.State", "Lat", "Long")]
        colnames(dfm) <- c("Country", "Date", "Count", "Status")
        
        # fix data types 
        dfm$Count <- as.integer(dfm$Count)
        dfm$Date <- as.Date(dfm$Date, tryFormats = c("%Y-%m-%d", "%Y/%m/%d"))
        dfm$Status <- as.factor(dfm$Status)
    
        # lose the Province_State data and group by country 
        # countries like Canada have subnational data issues 
        dfm <- dfm %>% 
            select(Country, Status, Date, Count) %>%
            group_by(Country, Status, Date) %>%
            summarise(Count=sum(Count)) %>%
            arrange(Country, Status, desc(Date))
        
        # return dataframe 
        as.data.frame(dfm)
    }
    
    confirmed_clean  <- preprocess_csv(confirmed_df, "Confirmed")
    fatal_clean      <- preprocess_csv(fatal_df, "Fatal")

    # row bind (append) files into one dataset 
    dfm <- rbind(confirmed_clean, fatal_clean
                , make.row.names=FALSE)
    
    # save as RDS 
    saveRDS(dfm, file = rds_file)
}


## ----echo=FALSE-----------------------------------------------------------------------------------------------------------------------------------------------------------
# read in RDS file 
dfm <- readRDS(rds_file) 

# calculate number of countries and number of days in the time series
Ncountries <- length(unique(dfm$Country))
Ndays <- length(unique(dfm$Date))


nrow(dfm)
length(dfm)
Ndays
Ncountries
## ----echo=FALSE-----------------------------------------------------------------------------------------------------------------------------------------------------------
# top and bottom rows for final dataset
kable(rbind(head(dfm, 3), tail(dfm, 3))) %>%
      kable_styling(bootstrap_options = c("striped", "hover", "condensed")
                    , full_width = FALSE)


## ----include=FALSE--------------------------------------------------------------------------------------------------------------------------------------------------------
# remove seasonal "countries" like Antarctica and Olympics
dfm <- dfm[!dfm$Country %in% c('Antarctica', 'Summer Olympics 2020', 'Winter Olympics 2022'), ]

# read in static data set of countries and populations
country_population <- read.csv("data/country_population.csv")
          
# test for new countries in data -- manual step
current_countries <- unique(dfm$Country)
current_countries[!current_countries %in% country_population$Country]


## ----include=FALSE--------------------------------------------------------------------------------------------------------------------------------------------------------
# merge data sets
percap <- merge(dfm, country_population, by="Country")

# calculate percentages
percap$Percentage <- round(percap$Count/(percap$Population*1000)*100, 3)

# reorder by Country, Status, and Date descending
percap <- data.frame(percap %>% arrange(Country, Status, desc(Date)))

# calculate new cases
percap <- sqldf('
    SELECT 
        sq.*
        , LEAD(sq.CountLag - Count, 1) OVER (PARTITION BY Country, Status) AS NewCases
    FROM (
        SELECT 
            p.*
            , LAG(Count, 1) OVER (PARTITION BY Country, Status) AS CountLag
        FROM percap AS p
        ) AS sq
')

# remove temp col, replace NA, convert to int
percap$CountLag <- NULL
percap$NewCases[is.na(percap$NewCases)] <- 0
percap$NewCases <- as.integer(percap$NewCases)


## ----echo=FALSE-----------------------------------------------------------------------------------------------------------------------------------------------------------
# top and bottom rows for final data set
kable(rbind(head(percap[percap$Country == "Brazil", ], 3)
            , head(percap[percap$Country == "US", ], 3))) %>%
      kable_styling(bootstrap_options = c("striped", "hover", "condensed")
                  , full_width = FALSE)


## ----echo=FALSE, fig.height=6, fig.width=6--------------------------------------------------------------------------------------------------------------------------------
# subset to current counts 
current_data <- data.frame(percap %>%
                    filter(Date == unique(percap$Date)[1])) %>%
                    arrange(Status, desc(Count))

# subset to world totals 
world_totals <- data.frame(current_data %>% 
                    group_by(Status) %>%
                    summarise('Total'=sum(Count)))

world_totals$Total <- formatC(world_totals$Total, big.mark=",")

kable(world_totals) %>%
      kable_styling(bootstrap_options = c("striped", "hover")
                    , full_width = FALSE)


## ----echo=FALSE-----------------------------------------------------------------------------------------------------------------------------------------------------------
# subset to country totals 
country_totals <- data.frame(current_data %>%
                        select(Country, Status, Count, Percentage, NewCases) %>%
                        group_by(Country, Status))
    
# subset to top counts     
get_top_counts <- function(dfm, coln, num) {
    
    dfm <- dfm[dfm$Status == coln, ][1:num,]
    row.names(dfm) <- 1:num
    dfm
}                    

# separate by status 
top_confirmed     <- get_top_counts(country_totals, "Confirmed", 10)
top_fatal        <- get_top_counts(country_totals, "Fatal", 10)


## ----message=FALSE, warnings=FALSE, echo=FALSE----------------------------------------------------------------------------------------------------------------------------
# functions for plotting interactive time series

# arg values:
# dfm = the dataframe
# country = country name
# status_df = to be used as the vector of country names 
#             which is passed instead of a single country
# status = Confirmed, Fatal, Recovered, Active
# scale_ = Linear, Log
# type = Count, Percentage, NewCases

create_xts_series <- function(dfm, country, status, scale_, type) {
  
    dfm <- dfm[dfm$Country == country & dfm$Status == status, ]
    
    if (type == "Count") {
      series <- if (scale_ == "Linear") {
                  xts(dfm$Count, order.by = dfm$Date)
              } else {
                xts(log(dfm$Count), order.by = dfm$Date)
              }
    } else if (type == "Percentage") {
      series <- if (scale_ == "Linear") {
                  xts(dfm$Percentage, order.by = dfm$Date)
              } else {
                xts(log(dfm$Percentage), order.by = dfm$Date)
              }
    } else { # for new cases
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
                                              , type))
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
    
    txt_ <- if (scale_ == "Linear") {
                      "Count Of "
                  } else {
                    "Log Count Of "
                  }            
                
  } else if (type == "Percentage") {
    
    txt_ <- if (scale_ == "Linear") {
                      "Percentage Of "
                  } else {
                    "Log Percentage Of "
                  }         
                
  } else { # for new cases
    
    txt_ <- if (scale_ == "Linear") {
                      "New "
                  } else {
                    "Log Of New "
                  }      
  }
  
  ylab_lab   <- paste0(txt_, status, " Cases")
  
  main_title <- paste0("Top Countries - ", txt_, status, " Cases")
  
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


## ----message=FALSE, warnings=FALSE, echo=FALSE----------------------------------------------------------------------------------------------------------------------------
## plot time series
plot_types <- data.frame('Num' = 1:12
              ,'Status' = c(rep("Confirmed", 6), rep("Fatal", 6))
                          ,'Type' = rep(c("Count", "Percentage", "NewCases"), each=2)
                          ,'Scale' = rep(c("Linear", "Log"), 3)
                          )

# fatal
fatal_plots <- lapply(1:6, function(i) plot_interactive_df(percap
                                                 , top_fatal[1:5, ]
                                                 , top_fatal$Status[i]
                                                 , plot_types$Scale[i]
                                                 , plot_types$Type[i]))
        
htmltools::tagList(fatal_plots)

# confirmed 
confirmed_plots <- lapply(1:6, function(i) plot_interactive_df(percap
                                                 , top_confirmed[1:5, ]
                                                 , top_confirmed$Status[i]
                                                 , plot_types$Scale[i]
                                                 , plot_types$Type[i]))
        
htmltools::tagList(confirmed_plots)
