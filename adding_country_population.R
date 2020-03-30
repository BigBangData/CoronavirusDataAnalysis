


URL <- paste0("https://apps.who.int/gho/athena/data/"
			  ,"GHO/WHS9_86,WHS9_88,WHS9_89,WHS9_92,"
			  ,"WHS9_96,WHS9_97,WHS9_90?filter=COUNTRY"
			  ,":*;REGION:*&x-sideaxis=COUNTRY;YEAR&x-"
			  ,"topaxis=GHO&profile=crosstable&format=csv")
			  
			  
dir_path <- "../GitHub/CoronavirusDataAnalysis/COVID19_DATA/"
filename <- "WHO_population_data.csv"


download.file(URL, destfile=paste0(dir_path, filename))

popdata <- read.csv(file=paste0(dir_path, filename), 
					header=TRUE,
					stringsAsFactors=FALSE,
					na.strings=c("NULL","NA","null","na",""))

popdata <- popdata[,1:3]
colnames(popdata) <- c("Country","Year","Population_thousands")

popdata$Year <- trimws(popdata$Year)

pop16 <- popdata[popdata$Year == "2016", ]

pop16$Population_thousands <- gsub("\\s", "", pop16$Population_thousands)                          

pop16 <- pop16[,c(1,3)]

pop16$Population_thousands <- as.integer(pop16$Population_thousands)

Ndiff <- (max(length(unique(dfm$Country)), length(unique(pop16$Country))) - 
		  min(length(unique(dfm$Country)), length(unique(pop16$Country))))

countries <- data.frame("JHU"=c(sort(unique(dfm$Country)), rep(NA, Ndiff)), 
						"WHO"=sort(unique(pop16$Country)))
			
#write.csv(countries, file=paste0(dir_path, "countries.csv"), row.names=FALSE)

# manual fix of countries 

countries_new <- read.csv(file=paste0(dir_path, "countries.csv"))


countries_missing <- countries$JHU[!countries$JHU %in% countries$WHO]

# countries still missing population
countries_missing <- data.frame("missing"=countries_missing[!is.na(countries_missing)])







# dump original 
dfm <- country_level_df



# per capita

dfm <- dfm %>%
	   group_by(Country, Status, Date) %>%
	   






















