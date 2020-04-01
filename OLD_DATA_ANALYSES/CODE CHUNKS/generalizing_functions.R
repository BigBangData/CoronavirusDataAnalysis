







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
  
  interactive_df <- dygraph(seriesObject
                            , main=paste0("Top Countries - "
                                          , status, " Cases ("
										  , scale_, " Scale)")
                            , xlab=""
                            , ylab=paste0(ylab_txt, "Percentage Of "
                                          , status, " Cases")
						    ) %>%
                    dyOptions(colors=brewer.pal(6, "Dark2")
							) %>%
                    dyRangeSelector()
  interactive_df
}

# Confirmed Cases 
plot_interactive_df(percap, top_confirmed, "Confirmed", "Linear")
plot_interactive_df(percap, top_confirmed, "Confirmed", "Log")

# Fatal Cases 
plot_interactive_df(percap, top_fatal, "Fatal", "Linear")
plot_interactive_df(percap, top_fatal, "Fatal", "Log")

# Recovered Cases
plot_interactive_df(percap, top_recovered, "Recovered", "Linear")
plot_interactive_df(percap, top_recovered, "Recovered", "Log")




















							