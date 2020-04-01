

percap$NewCases <- NULL 

for (i in  seq.int(from=1, to=nrow(percap), by=Ndays)) {
	
	for (j in i:(i+Ndays)) {
		percap$NewCases[j] <- percap$Count[j] - percap$Count[j+1]
	}
	
	if (i > 1) {
		percap$NewCases[i-1] <- 0
	}
}

percap$NewCases[nrow(percap)] <- 0
percap$NewCases <- as.integer(percap$NewCases)






