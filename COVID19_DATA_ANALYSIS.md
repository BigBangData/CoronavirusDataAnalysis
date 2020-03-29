---
title: "Coronavirus Data Analysis"
author: "Marcelo Sanches"
date: "3/29/2020"
output: 
  html_document:
    keep_md: true
---











This is a simple exploration of the time series data which was compiled by the Johns Hopkins University Center for Systems Science and Engineering (JHU CCSE) from various sources (see website for full description). The data can be downloaded manually at [Novel Coronavirus 2019 Cases.](https://data.humdata.org/dataset/novel-coronavirus-2019-ncov-cases)


## Contents {#contents-link}

* [Data Pre-Processing](#preprocess-link)
* [Data Cleanup](#cleanup-link)
* [Exploratory Data Analysis](#eda-link)
* [Code Appendix](#codeappendix-link)

---

## Data Pre-Processing {#preprocess-link}

The `preprocess` function creates a local folder and pulls three csv files, one for each stage in tracking the coronavirus spread (confirmed, fatal, and recovered cases), performs various pre-processing steps to create one narrow and long dataset, saving it in compressed RDS format. See code in the [Code Appendix.](#codeappendix-link)




```r
# read in RDS file 
dfm <- preprocess()
str(dfm)
```

```
## 'data.frame':	49915 obs. of  7 variables:
##  $ Province_State: chr  NA NA NA NA ...
##  $ Country_Region: chr  "Afghanistan" "Afghanistan" "Afghanistan" "Afghanistan" ...
##  $ Lat           : num  33 33 33 33 33 33 33 33 33 33 ...
##  $ Long          : num  65 65 65 65 65 65 65 65 65 65 ...
##  $ Date          : Date, format: "2020-03-28" "2020-03-27" ...
##  $ Value         : int  110 110 94 84 74 40 40 24 24 22 ...
##  $ Status        : Factor w/ 3 levels "confirmed","fatal",..: 1 1 1 1 1 1 1 1 1 1 ...
```


There are 49915 rows and 7 columns. There's a 'Status' column for the different stages, so the number of rows is 3 times the number of rows for a single status (ex. "confirmed"). Each single-status dataset is as long as the number of days in the time series (for a given day the data is pulled) times the number of countries and sub-national provinces or states. This number varies per country, and also varies per day depending on how the dataset is built. 


---

[Back to [Contents](#contents-link)]{style="float:right"}

## Data Cleanup  {#cleanup-link}


### Location Granularity 

The data's location variables have several issues. I will discard `Lat` and `Long` since I'm not doing any mapping. The variables `Country_Region` and `Province_State` are often loosely aggregated. This can be visualized in [Johns Hopkins' dashboard](https://coronavirus.jhu.edu/map.html): the totals for fatalities are grouped by a mixture of countries and subnational geographic areas. The US is conspicuously missing as a country. 

Since subnational data is sparse, I'll focus on country-level data. After some data analysis, I noticed that the anomalies will repond to one simple aggregation and I recreated the dataset at this national level. Canada is a prime example of bad data: notice how it lacks subnational data on recovered cases, but also, I doubt there's a province in Canada called 'Recovered':



```r
# Canada provinces example
data.frame(dfm[dfm$Country_Region == "Canada", ] %>% 
		   distinct(Country_Region, Province_State, Status))
```

```
##    Country_Region            Province_State    Status
## 1          Canada                   Alberta confirmed
## 2          Canada          British Columbia confirmed
## 3          Canada          Diamond Princess confirmed
## 4          Canada            Grand Princess confirmed
## 5          Canada                  Manitoba confirmed
## 6          Canada             New Brunswick confirmed
## 7          Canada Newfoundland and Labrador confirmed
## 8          Canada     Northwest Territories confirmed
## 9          Canada               Nova Scotia confirmed
## 10         Canada                   Ontario confirmed
## 11         Canada      Prince Edward Island confirmed
## 12         Canada                    Quebec confirmed
## 13         Canada                 Recovered confirmed
## 14         Canada              Saskatchewan confirmed
## 15         Canada                     Yukon confirmed
## 16         Canada                   Alberta     fatal
## 17         Canada          British Columbia     fatal
## 18         Canada          Diamond Princess     fatal
## 19         Canada            Grand Princess     fatal
## 20         Canada                  Manitoba     fatal
## 21         Canada             New Brunswick     fatal
## 22         Canada Newfoundland and Labrador     fatal
## 23         Canada     Northwest Territories     fatal
## 24         Canada               Nova Scotia     fatal
## 25         Canada                   Ontario     fatal
## 26         Canada      Prince Edward Island     fatal
## 27         Canada                    Quebec     fatal
## 28         Canada                 Recovered     fatal
## 29         Canada              Saskatchewan     fatal
## 30         Canada                     Yukon     fatal
## 31         Canada                      <NA> recovered
```



The top and bottom rows for the final dataset:


```
##           Country    Status       Date Count
## 1     Afghanistan confirmed 2020-03-28   110
## 2     Afghanistan confirmed 2020-03-27   110
## 3     Afghanistan confirmed 2020-03-26    94
## 4     Afghanistan confirmed 2020-03-25    84
## 5     Afghanistan confirmed 2020-03-24    74
## 6     Afghanistan confirmed 2020-03-23    40
## 35572    Zimbabwe recovered 2020-01-27     0
## 35573    Zimbabwe recovered 2020-01-26     0
## 35574    Zimbabwe recovered 2020-01-25     0
## 35575    Zimbabwe recovered 2020-01-24     0
## 35576    Zimbabwe recovered 2020-01-23     0
## 35577    Zimbabwe recovered 2020-01-22     0
```





---

[Back to [Contents](#contents-link)]{style="float:right"}


## Exploratory Data Analysis {#eda-link}



**World Totals**

<table class="table table-striped table-hover" style="width: auto !important; margin-left: auto; margin-right: auto;">
 <thead>
  <tr>
   <th style="text-align:left;"> Status </th>
   <th style="text-align:right;"> total </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> confirmed </td>
   <td style="text-align:right;"> 660706 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> fatal </td>
   <td style="text-align:right;"> 30652 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> recovered </td>
   <td style="text-align:right;"> 139415 </td>
  </tr>
</tbody>
</table>



**Top Confirmed Cases by Country**


<table class="table table-striped table-hover" style="width: auto !important; margin-left: auto; margin-right: auto;">
 <thead>
  <tr>
   <th style="text-align:left;"> Country </th>
   <th style="text-align:right;"> Count </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> US </td>
   <td style="text-align:right;"> 121478 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Italy </td>
   <td style="text-align:right;"> 92472 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> China </td>
   <td style="text-align:right;"> 81999 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Spain </td>
   <td style="text-align:right;"> 73235 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Germany </td>
   <td style="text-align:right;"> 57695 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> France </td>
   <td style="text-align:right;"> 38105 </td>
  </tr>
</tbody>
</table>



**Top Fatal Cases by Country**

<table class="table table-striped table-hover" style="width: auto !important; margin-left: auto; margin-right: auto;">
 <thead>
  <tr>
   <th style="text-align:left;">   </th>
   <th style="text-align:left;"> Country </th>
   <th style="text-align:right;"> Count </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> 178 </td>
   <td style="text-align:left;"> Italy </td>
   <td style="text-align:right;"> 10023 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 179 </td>
   <td style="text-align:left;"> Spain </td>
   <td style="text-align:right;"> 5982 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 180 </td>
   <td style="text-align:left;"> China </td>
   <td style="text-align:right;"> 3299 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 181 </td>
   <td style="text-align:left;"> Iran </td>
   <td style="text-align:right;"> 2517 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 182 </td>
   <td style="text-align:left;"> France </td>
   <td style="text-align:right;"> 2317 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 183 </td>
   <td style="text-align:left;"> US </td>
   <td style="text-align:right;"> 2026 </td>
  </tr>
</tbody>
</table>


**Top Recovered Cases by Country**

<table class="table table-striped table-hover" style="width: auto !important; margin-left: auto; margin-right: auto;">
 <thead>
  <tr>
   <th style="text-align:left;">   </th>
   <th style="text-align:left;"> Country </th>
   <th style="text-align:right;"> Count </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> 355 </td>
   <td style="text-align:left;"> China </td>
   <td style="text-align:right;"> 75100 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 356 </td>
   <td style="text-align:left;"> Italy </td>
   <td style="text-align:right;"> 12384 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 357 </td>
   <td style="text-align:left;"> Spain </td>
   <td style="text-align:right;"> 12285 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 358 </td>
   <td style="text-align:left;"> Iran </td>
   <td style="text-align:right;"> 11679 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 359 </td>
   <td style="text-align:left;"> Germany </td>
   <td style="text-align:right;"> 8481 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 360 </td>
   <td style="text-align:left;"> France </td>
   <td style="text-align:right;"> 5724 </td>
  </tr>
</tbody>
</table>




---

  
  

### Time Series Plots per Status and Location

This interactive time series speaks for itself: the US has overtaken Italy and China in number of confirmed cases in the last two days.



<!--html_preserve--><div id="htmlwidget-673cc5faa361aa53cbd0" style="width:864px;height:480px;" class="dygraphs html-widget"></div>
<script type="application/json" data-for="htmlwidget-673cc5faa361aa53cbd0">{"x":{"attrs":{"title":"US Overtakes Italy and China in Confirmed Cases","xlabel":"","ylabel":"Number of Confirmed Cases","labels":["day","US","Italy","China","Spain","Germany"],"legend":"auto","retainDateWindow":false,"axes":{"x":{"pixelsPerLabel":60,"drawAxis":true},"y":{"drawAxis":true}},"stackedGraph":false,"fillGraph":false,"fillAlpha":0.15,"stepPlot":false,"drawPoints":false,"pointSize":1,"drawGapEdgePoints":false,"connectSeparatedPoints":false,"strokeWidth":1,"strokeBorderColor":"white","colors":["#1B9E77","#D95F02","#7570B3","#E7298A","#66A61E"],"colorValue":0.5,"colorSaturation":1,"includeZero":false,"drawAxesAtZero":false,"logscale":false,"axisTickSize":3,"axisLineColor":"black","axisLineWidth":0.3,"axisLabelColor":"black","axisLabelFontSize":14,"axisLabelWidth":60,"drawGrid":true,"gridLineWidth":0.3,"rightGap":5,"digitsAfterDecimal":2,"labelsKMB":false,"labelsKMG2":false,"labelsUTC":false,"maxNumberWidth":6,"animatedZooms":false,"mobileDisableYTouch":true,"disableZoom":false,"showRangeSelector":true,"rangeSelectorHeight":40,"rangeSelectorPlotFillColor":" #A7B1C4","rangeSelectorPlotStrokeColor":"#808FAB","interactionModel":"Dygraph.Interaction.defaultModel"},"scale":"daily","annotations":[],"shadings":[],"events":[],"format":"date","data":[["2020-01-22T00:00:00.000Z","2020-01-23T00:00:00.000Z","2020-01-24T00:00:00.000Z","2020-01-25T00:00:00.000Z","2020-01-26T00:00:00.000Z","2020-01-27T00:00:00.000Z","2020-01-28T00:00:00.000Z","2020-01-29T00:00:00.000Z","2020-01-30T00:00:00.000Z","2020-01-31T00:00:00.000Z","2020-02-01T00:00:00.000Z","2020-02-02T00:00:00.000Z","2020-02-03T00:00:00.000Z","2020-02-04T00:00:00.000Z","2020-02-05T00:00:00.000Z","2020-02-06T00:00:00.000Z","2020-02-07T00:00:00.000Z","2020-02-08T00:00:00.000Z","2020-02-09T00:00:00.000Z","2020-02-10T00:00:00.000Z","2020-02-11T00:00:00.000Z","2020-02-12T00:00:00.000Z","2020-02-13T00:00:00.000Z","2020-02-14T00:00:00.000Z","2020-02-15T00:00:00.000Z","2020-02-16T00:00:00.000Z","2020-02-17T00:00:00.000Z","2020-02-18T00:00:00.000Z","2020-02-19T00:00:00.000Z","2020-02-20T00:00:00.000Z","2020-02-21T00:00:00.000Z","2020-02-22T00:00:00.000Z","2020-02-23T00:00:00.000Z","2020-02-24T00:00:00.000Z","2020-02-25T00:00:00.000Z","2020-02-26T00:00:00.000Z","2020-02-27T00:00:00.000Z","2020-02-28T00:00:00.000Z","2020-02-29T00:00:00.000Z","2020-03-01T00:00:00.000Z","2020-03-02T00:00:00.000Z","2020-03-03T00:00:00.000Z","2020-03-04T00:00:00.000Z","2020-03-05T00:00:00.000Z","2020-03-06T00:00:00.000Z","2020-03-07T00:00:00.000Z","2020-03-08T00:00:00.000Z","2020-03-09T00:00:00.000Z","2020-03-10T00:00:00.000Z","2020-03-11T00:00:00.000Z","2020-03-12T00:00:00.000Z","2020-03-13T00:00:00.000Z","2020-03-14T00:00:00.000Z","2020-03-15T00:00:00.000Z","2020-03-16T00:00:00.000Z","2020-03-17T00:00:00.000Z","2020-03-18T00:00:00.000Z","2020-03-19T00:00:00.000Z","2020-03-20T00:00:00.000Z","2020-03-21T00:00:00.000Z","2020-03-22T00:00:00.000Z","2020-03-23T00:00:00.000Z","2020-03-24T00:00:00.000Z","2020-03-25T00:00:00.000Z","2020-03-26T00:00:00.000Z","2020-03-27T00:00:00.000Z","2020-03-28T00:00:00.000Z"],[1,1,2,2,5,5,5,5,5,7,8,8,11,11,11,11,11,11,11,11,12,12,13,13,13,13,13,13,13,13,15,15,15,51,51,57,58,60,68,74,98,118,149,217,262,402,518,583,959,1281,1663,2179,2727,3499,4632,6421,7783,13677,19100,25489,33276,43847,53740,65778,83836,101657,121478],[0,0,0,0,0,0,0,0,0,2,2,2,2,2,2,2,3,3,3,3,3,3,3,3,3,3,3,3,3,3,20,62,155,229,322,453,655,888,1128,1694,2036,2502,3089,3858,4636,5883,7375,9172,10149,12462,12462,17660,21157,24747,27980,31506,35713,41035,47021,53578,59138,63927,69176,74386,80589,86498,92472],[548,643,920,1406,2075,2877,5509,6087,8141,9802,11891,16630,19716,23707,27440,30587,34110,36814,39829,42354,44386,44759,59895,66358,68413,70513,72434,74211,74619,75077,75550,77001,77022,77241,77754,78166,78600,78928,79356,79932,80136,80261,80386,80537,80690,80770,80823,80860,80887,80921,80932,80945,80977,81003,81033,81058,81102,81156,81250,81305,81435,81498,81591,81661,81782,81897,81999],[0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,6,13,15,32,45,84,120,165,222,259,400,500,673,1073,1695,2277,2277,5232,6391,7798,9942,11748,13910,17963,20410,25374,28768,35136,39885,49515,57786,65719,73235],[0,0,0,0,0,1,4,4,4,5,8,10,12,12,12,12,13,13,14,14,16,16,16,16,16,16,16,16,16,16,16,16,16,16,17,27,46,48,79,130,159,196,262,482,670,799,1040,1176,1457,1908,2078,3675,4585,5795,7272,9257,12327,15320,19848,22213,24873,29056,32986,37323,43938,50871,57695]],"fixedtz":false,"tzone":"UTC"},"evals":["attrs.interactionModel"],"jsHooks":[]}</script><!--/html_preserve-->


This is the same visualization using the data on fatalities:

<!--html_preserve--><div id="htmlwidget-62edd30136ede2b32bce" style="width:864px;height:480px;" class="dygraphs html-widget"></div>
<script type="application/json" data-for="htmlwidget-62edd30136ede2b32bce">{"x":{"attrs":{"title":"Italy Leads in Fatalities","xlabel":"","ylabel":"Number of Fatalities","labels":["day","US","Italy","China","Spain","Germany"],"legend":"auto","retainDateWindow":false,"axes":{"x":{"pixelsPerLabel":60,"drawAxis":true},"y":{"drawAxis":true}},"stackedGraph":false,"fillGraph":false,"fillAlpha":0.15,"stepPlot":false,"drawPoints":false,"pointSize":1,"drawGapEdgePoints":false,"connectSeparatedPoints":false,"strokeWidth":1,"strokeBorderColor":"white","colors":["#1B9E77","#D95F02","#7570B3","#E7298A","#66A61E"],"colorValue":0.5,"colorSaturation":1,"includeZero":false,"drawAxesAtZero":false,"logscale":false,"axisTickSize":3,"axisLineColor":"black","axisLineWidth":0.3,"axisLabelColor":"black","axisLabelFontSize":14,"axisLabelWidth":60,"drawGrid":true,"gridLineWidth":0.3,"rightGap":5,"digitsAfterDecimal":2,"labelsKMB":false,"labelsKMG2":false,"labelsUTC":false,"maxNumberWidth":6,"animatedZooms":false,"mobileDisableYTouch":true,"disableZoom":false,"showRangeSelector":true,"rangeSelectorHeight":40,"rangeSelectorPlotFillColor":" #A7B1C4","rangeSelectorPlotStrokeColor":"#808FAB","interactionModel":"Dygraph.Interaction.defaultModel"},"scale":"daily","annotations":[],"shadings":[],"events":[],"format":"date","data":[["2020-01-22T00:00:00.000Z","2020-01-23T00:00:00.000Z","2020-01-24T00:00:00.000Z","2020-01-25T00:00:00.000Z","2020-01-26T00:00:00.000Z","2020-01-27T00:00:00.000Z","2020-01-28T00:00:00.000Z","2020-01-29T00:00:00.000Z","2020-01-30T00:00:00.000Z","2020-01-31T00:00:00.000Z","2020-02-01T00:00:00.000Z","2020-02-02T00:00:00.000Z","2020-02-03T00:00:00.000Z","2020-02-04T00:00:00.000Z","2020-02-05T00:00:00.000Z","2020-02-06T00:00:00.000Z","2020-02-07T00:00:00.000Z","2020-02-08T00:00:00.000Z","2020-02-09T00:00:00.000Z","2020-02-10T00:00:00.000Z","2020-02-11T00:00:00.000Z","2020-02-12T00:00:00.000Z","2020-02-13T00:00:00.000Z","2020-02-14T00:00:00.000Z","2020-02-15T00:00:00.000Z","2020-02-16T00:00:00.000Z","2020-02-17T00:00:00.000Z","2020-02-18T00:00:00.000Z","2020-02-19T00:00:00.000Z","2020-02-20T00:00:00.000Z","2020-02-21T00:00:00.000Z","2020-02-22T00:00:00.000Z","2020-02-23T00:00:00.000Z","2020-02-24T00:00:00.000Z","2020-02-25T00:00:00.000Z","2020-02-26T00:00:00.000Z","2020-02-27T00:00:00.000Z","2020-02-28T00:00:00.000Z","2020-02-29T00:00:00.000Z","2020-03-01T00:00:00.000Z","2020-03-02T00:00:00.000Z","2020-03-03T00:00:00.000Z","2020-03-04T00:00:00.000Z","2020-03-05T00:00:00.000Z","2020-03-06T00:00:00.000Z","2020-03-07T00:00:00.000Z","2020-03-08T00:00:00.000Z","2020-03-09T00:00:00.000Z","2020-03-10T00:00:00.000Z","2020-03-11T00:00:00.000Z","2020-03-12T00:00:00.000Z","2020-03-13T00:00:00.000Z","2020-03-14T00:00:00.000Z","2020-03-15T00:00:00.000Z","2020-03-16T00:00:00.000Z","2020-03-17T00:00:00.000Z","2020-03-18T00:00:00.000Z","2020-03-19T00:00:00.000Z","2020-03-20T00:00:00.000Z","2020-03-21T00:00:00.000Z","2020-03-22T00:00:00.000Z","2020-03-23T00:00:00.000Z","2020-03-24T00:00:00.000Z","2020-03-25T00:00:00.000Z","2020-03-26T00:00:00.000Z","2020-03-27T00:00:00.000Z","2020-03-28T00:00:00.000Z"],[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,6,7,11,12,14,17,21,22,28,36,40,47,54,63,85,108,118,200,244,307,417,557,706,942,1209,1581,2026],[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,2,3,7,10,12,17,21,29,34,52,79,107,148,197,233,366,463,631,827,827,1266,1441,1809,2158,2503,2978,3405,4032,4825,5476,6077,6820,7503,8215,9134,10023],[17,18,26,42,56,82,131,133,171,213,259,361,425,491,563,633,718,805,905,1012,1112,1117,1369,1521,1663,1766,1864,2003,2116,2238,2238,2443,2445,2595,2665,2717,2746,2790,2837,2872,2914,2947,2983,3015,3044,3072,3100,3123,3139,3161,3172,3180,3193,3203,3217,3230,3241,3249,3253,3259,3274,3274,3281,3285,3291,3296,3299],[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,2,3,5,10,17,28,35,54,55,133,195,289,342,533,623,830,1043,1375,1772,2311,2808,3647,4365,5138,5982],[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2,2,3,3,7,9,11,17,24,28,44,67,84,94,123,157,206,267,342,433]],"fixedtz":false,"tzone":"UTC"},"evals":["attrs.interactionModel"],"jsHooks":[]}</script><!--/html_preserve-->


This is the same visualization using the data on recoveries:

<!--html_preserve--><div id="htmlwidget-90ff9deff02d9478338e" style="width:864px;height:480px;" class="dygraphs html-widget"></div>
<script type="application/json" data-for="htmlwidget-90ff9deff02d9478338e">{"x":{"attrs":{"title":"China Leads in Recoveries","xlabel":"","ylabel":"Number of Recoveries","labels":["day","US","Italy","China","Spain","Germany"],"legend":"auto","retainDateWindow":false,"axes":{"x":{"pixelsPerLabel":60,"drawAxis":true},"y":{"drawAxis":true}},"stackedGraph":false,"fillGraph":false,"fillAlpha":0.15,"stepPlot":false,"drawPoints":false,"pointSize":1,"drawGapEdgePoints":false,"connectSeparatedPoints":false,"strokeWidth":1,"strokeBorderColor":"white","colors":["#1B9E77","#D95F02","#7570B3","#E7298A","#66A61E"],"colorValue":0.5,"colorSaturation":1,"includeZero":false,"drawAxesAtZero":false,"logscale":false,"axisTickSize":3,"axisLineColor":"black","axisLineWidth":0.3,"axisLabelColor":"black","axisLabelFontSize":14,"axisLabelWidth":60,"drawGrid":true,"gridLineWidth":0.3,"rightGap":5,"digitsAfterDecimal":2,"labelsKMB":false,"labelsKMG2":false,"labelsUTC":false,"maxNumberWidth":6,"animatedZooms":false,"mobileDisableYTouch":true,"disableZoom":false,"showRangeSelector":true,"rangeSelectorHeight":40,"rangeSelectorPlotFillColor":" #A7B1C4","rangeSelectorPlotStrokeColor":"#808FAB","interactionModel":"Dygraph.Interaction.defaultModel"},"scale":"daily","annotations":[],"shadings":[],"events":[],"format":"date","data":[["2020-01-22T00:00:00.000Z","2020-01-23T00:00:00.000Z","2020-01-24T00:00:00.000Z","2020-01-25T00:00:00.000Z","2020-01-26T00:00:00.000Z","2020-01-27T00:00:00.000Z","2020-01-28T00:00:00.000Z","2020-01-29T00:00:00.000Z","2020-01-30T00:00:00.000Z","2020-01-31T00:00:00.000Z","2020-02-01T00:00:00.000Z","2020-02-02T00:00:00.000Z","2020-02-03T00:00:00.000Z","2020-02-04T00:00:00.000Z","2020-02-05T00:00:00.000Z","2020-02-06T00:00:00.000Z","2020-02-07T00:00:00.000Z","2020-02-08T00:00:00.000Z","2020-02-09T00:00:00.000Z","2020-02-10T00:00:00.000Z","2020-02-11T00:00:00.000Z","2020-02-12T00:00:00.000Z","2020-02-13T00:00:00.000Z","2020-02-14T00:00:00.000Z","2020-02-15T00:00:00.000Z","2020-02-16T00:00:00.000Z","2020-02-17T00:00:00.000Z","2020-02-18T00:00:00.000Z","2020-02-19T00:00:00.000Z","2020-02-20T00:00:00.000Z","2020-02-21T00:00:00.000Z","2020-02-22T00:00:00.000Z","2020-02-23T00:00:00.000Z","2020-02-24T00:00:00.000Z","2020-02-25T00:00:00.000Z","2020-02-26T00:00:00.000Z","2020-02-27T00:00:00.000Z","2020-02-28T00:00:00.000Z","2020-02-29T00:00:00.000Z","2020-03-01T00:00:00.000Z","2020-03-02T00:00:00.000Z","2020-03-03T00:00:00.000Z","2020-03-04T00:00:00.000Z","2020-03-05T00:00:00.000Z","2020-03-06T00:00:00.000Z","2020-03-07T00:00:00.000Z","2020-03-08T00:00:00.000Z","2020-03-09T00:00:00.000Z","2020-03-10T00:00:00.000Z","2020-03-11T00:00:00.000Z","2020-03-12T00:00:00.000Z","2020-03-13T00:00:00.000Z","2020-03-14T00:00:00.000Z","2020-03-15T00:00:00.000Z","2020-03-16T00:00:00.000Z","2020-03-17T00:00:00.000Z","2020-03-18T00:00:00.000Z","2020-03-19T00:00:00.000Z","2020-03-20T00:00:00.000Z","2020-03-21T00:00:00.000Z","2020-03-22T00:00:00.000Z","2020-03-23T00:00:00.000Z","2020-03-24T00:00:00.000Z","2020-03-25T00:00:00.000Z","2020-03-26T00:00:00.000Z","2020-03-27T00:00:00.000Z","2020-03-28T00:00:00.000Z"],[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,3,3,3,3,3,3,3,3,3,3,3,3,5,5,5,5,6,6,6,7,7,7,7,7,7,7,7,7,7,7,8,8,12,12,12,12,17,17,105,121,147,176,178,178,348,361,681,869,1072],[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,2,1,1,3,45,46,46,83,149,160,276,414,523,589,622,724,724,1045,1045,1439,1966,2335,2749,2941,4025,4440,4440,6072,7024,7024,8326,9362,10361,10950,12384],[28,30,36,39,49,58,101,120,135,214,275,463,614,843,1115,1477,1999,2596,3219,3918,4636,5082,6217,7977,9298,10755,12462,14206,15962,18014,18704,22699,23187,25015,27676,30084,32930,36329,39320,42162,44854,47450,50001,52292,53944,55539,57388,58804,60181,61644,62901,64196,65660,67017,67910,68798,69755,70535,71266,71857,72362,72814,73280,73773,74181,74720,75100],[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,30,30,32,32,183,183,193,517,517,530,1028,1081,1107,1588,2125,2575,2575,3794,5367,7015,9357,12285],[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,12,12,12,14,14,14,14,14,15,16,16,16,16,16,16,16,16,17,18,18,18,18,25,25,46,46,46,67,67,105,113,180,233,266,266,3243,3547,5673,6658,8481]],"fixedtz":false,"tzone":"UTC"},"evals":["attrs.interactionModel"],"jsHooks":[]}</script><!--/html_preserve-->

Since China dominates this plot too much, it would be interesting to see how the other countries are doing as far as recoveries:

<!--html_preserve--><div id="htmlwidget-9c353c4b2be319f81c64" style="width:864px;height:480px;" class="dygraphs html-widget"></div>
<script type="application/json" data-for="htmlwidget-9c353c4b2be319f81c64">{"x":{"attrs":{"title":"After China, Italy and Spain Lead in Recoveries","xlabel":"","ylabel":"Number of Recoveries","labels":["day","US","Italy","Spain","Germany"],"legend":"auto","retainDateWindow":false,"axes":{"x":{"pixelsPerLabel":60,"drawAxis":true},"y":{"drawAxis":true}},"stackedGraph":false,"fillGraph":false,"fillAlpha":0.15,"stepPlot":false,"drawPoints":false,"pointSize":1,"drawGapEdgePoints":false,"connectSeparatedPoints":false,"strokeWidth":1,"strokeBorderColor":"white","colors":["#1B9E77","#D95F02","#7570B3","#E7298A"],"colorValue":0.5,"colorSaturation":1,"includeZero":false,"drawAxesAtZero":false,"logscale":false,"axisTickSize":3,"axisLineColor":"black","axisLineWidth":0.3,"axisLabelColor":"black","axisLabelFontSize":14,"axisLabelWidth":60,"drawGrid":true,"gridLineWidth":0.3,"rightGap":5,"digitsAfterDecimal":2,"labelsKMB":false,"labelsKMG2":false,"labelsUTC":false,"maxNumberWidth":6,"animatedZooms":false,"mobileDisableYTouch":true,"disableZoom":false,"showRangeSelector":true,"rangeSelectorHeight":40,"rangeSelectorPlotFillColor":" #A7B1C4","rangeSelectorPlotStrokeColor":"#808FAB","interactionModel":"Dygraph.Interaction.defaultModel"},"scale":"daily","annotations":[],"shadings":[],"events":[],"format":"date","data":[["2020-01-22T00:00:00.000Z","2020-01-23T00:00:00.000Z","2020-01-24T00:00:00.000Z","2020-01-25T00:00:00.000Z","2020-01-26T00:00:00.000Z","2020-01-27T00:00:00.000Z","2020-01-28T00:00:00.000Z","2020-01-29T00:00:00.000Z","2020-01-30T00:00:00.000Z","2020-01-31T00:00:00.000Z","2020-02-01T00:00:00.000Z","2020-02-02T00:00:00.000Z","2020-02-03T00:00:00.000Z","2020-02-04T00:00:00.000Z","2020-02-05T00:00:00.000Z","2020-02-06T00:00:00.000Z","2020-02-07T00:00:00.000Z","2020-02-08T00:00:00.000Z","2020-02-09T00:00:00.000Z","2020-02-10T00:00:00.000Z","2020-02-11T00:00:00.000Z","2020-02-12T00:00:00.000Z","2020-02-13T00:00:00.000Z","2020-02-14T00:00:00.000Z","2020-02-15T00:00:00.000Z","2020-02-16T00:00:00.000Z","2020-02-17T00:00:00.000Z","2020-02-18T00:00:00.000Z","2020-02-19T00:00:00.000Z","2020-02-20T00:00:00.000Z","2020-02-21T00:00:00.000Z","2020-02-22T00:00:00.000Z","2020-02-23T00:00:00.000Z","2020-02-24T00:00:00.000Z","2020-02-25T00:00:00.000Z","2020-02-26T00:00:00.000Z","2020-02-27T00:00:00.000Z","2020-02-28T00:00:00.000Z","2020-02-29T00:00:00.000Z","2020-03-01T00:00:00.000Z","2020-03-02T00:00:00.000Z","2020-03-03T00:00:00.000Z","2020-03-04T00:00:00.000Z","2020-03-05T00:00:00.000Z","2020-03-06T00:00:00.000Z","2020-03-07T00:00:00.000Z","2020-03-08T00:00:00.000Z","2020-03-09T00:00:00.000Z","2020-03-10T00:00:00.000Z","2020-03-11T00:00:00.000Z","2020-03-12T00:00:00.000Z","2020-03-13T00:00:00.000Z","2020-03-14T00:00:00.000Z","2020-03-15T00:00:00.000Z","2020-03-16T00:00:00.000Z","2020-03-17T00:00:00.000Z","2020-03-18T00:00:00.000Z","2020-03-19T00:00:00.000Z","2020-03-20T00:00:00.000Z","2020-03-21T00:00:00.000Z","2020-03-22T00:00:00.000Z","2020-03-23T00:00:00.000Z","2020-03-24T00:00:00.000Z","2020-03-25T00:00:00.000Z","2020-03-26T00:00:00.000Z","2020-03-27T00:00:00.000Z","2020-03-28T00:00:00.000Z"],[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,3,3,3,3,3,3,3,3,3,3,3,3,5,5,5,5,6,6,6,7,7,7,7,7,7,7,7,7,7,7,8,8,12,12,12,12,17,17,105,121,147,176,178,178,348,361,681,869,1072],[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,2,1,1,3,45,46,46,83,149,160,276,414,523,589,622,724,724,1045,1045,1439,1966,2335,2749,2941,4025,4440,4440,6072,7024,7024,8326,9362,10361,10950,12384],[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,30,30,32,32,183,183,193,517,517,530,1028,1081,1107,1588,2125,2575,2575,3794,5367,7015,9357,12285],[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,12,12,12,14,14,14,14,14,15,16,16,16,16,16,16,16,16,17,18,18,18,18,25,25,46,46,46,67,67,105,113,180,233,266,266,3243,3547,5673,6658,8481]],"fixedtz":false,"tzone":"UTC"},"evals":["attrs.interactionModel"],"jsHooks":[]}</script><!--/html_preserve-->



---

[Back to [Contents](#contents-link)]{style="float:right"}

### Code Appendix {#codeappendix-link}


```r
## ----setup, include=FALSE------------------------------------------------
knitr::opts_chunk$set(echo = TRUE)

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
		http_header <- "https://data.humdata.org/hxlproxy/data/download/time_series_covid19_"
		
		url_body <- paste0("_narrow.csv?dest=data_edit&filter01=explode&explode-header-att01="
		                  ,"date&explode-value-att01=value&filter02=rename&rename-oldtag02=%23"
		                  ,"affected%2Bdate&rename-newtag02=%23date&rename-header02=Date&filter"
		                  ,"03=rename&rename-oldtag03=%23affected%2Bvalue&rename-newtag03=%23af"
		                  ,"fected%2Binfected%2Bvalue%2Bnum&rename-header03=Value&filter04=clea"
		                  ,"n&clean-date-tags04=%23date&filter05=sort&sort-tags05=%23date&sort-"
		                  ,"reverse05=on&filter06=sort&sort-tags06=%23country%2Bname%2C%23adm1%"
		                  ,"2Bname&tagger-match-all=on&tagger-default-tag=%23affected%2Blabel&t"
		                  ,"agger-01-header=province%2Fstate&tagger-01-tag=%23adm1%2Bname&tagger"
		                  ,"-02-header=country%2Fregion&tagger-02-tag=%23country%2Bname&tagger-"
		                  ,"03-header=lat&tagger-03-tag=%23geo%2Blat&tagger-04-header=long&tagge"
		                  ,"r-04-tag=%23geo%2Blon&header-row=1&url=https%3A%2F%2Fraw.githubuserc"
		                  ,"ontent.com%2FCSSEGISandData%2FCOVID-19%2Fmaster%2Fcsse_covid_19_data"
		                  ,"%2Fcsse_covid_19_time_series%2Ftime_series_covid19_")
		
		
		confirmed_URL  <- paste0(http_header, "confirmed_global", url_body, "confirmed_global.csv")
		fatal_URL <- paste0(http_header, "deaths_global", url_body, "deaths_global.csv")
		recovered_URL  <- paste0(http_header, "recovered_global", url_body, "recovered_global.csv")
									
		# download
		download.file(confirmed_URL, destfile=paste0(dir_path, "confirmed.csv"))
		download.file(fatal_URL, destfile=paste0(dir_path, "fatal.csv"))
		download.file(recovered_URL, destfile=paste0(dir_path, "recovered.csv"))
		
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


## ------------------------------------------------------------------------
# read in RDS file 
dfm <- preprocess()
str(dfm)


nrow(dfm)
length(dfm)
## ------------------------------------------------------------------------
# Canada provinces example
data.frame(dfm[dfm$Country_Region == "Canada", ] %>% 
		   distinct(Country_Region, Province_State, Status))

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

## ----echo=FALSE----------------------------------------------------------
# top and bottom rows for final dataset
rbind(head(country_level_df)
     ,tail(country_level_df))

## ----echo=FALSE----------------------------------------------------------
# subset to current counts 
current <- data.frame(country_level_df %>%
						filter(Date == unique(country_level_df$Date)[1])) %>%
            arrange(Status, desc(Count))

# subset to world totals 
totals <- data.frame(current %>% 
						group_by(Status) %>%
						summarise('total'=sum(Count)))

country_totals <- data.frame(current %>%
                    select(Country, Status, Count) %>%
                    group_by(Country, Status))


# world totals
kable(totals) %>%
    kable_styling(bootstrap_options = c("striped", "hover")
                  , full_width = FALSE)

## ----echo=FALSE----------------------------------------------------------
confirmed <- country_totals[country_totals$Status == "confirmed", c(1,3)]
                        
# top countries confirmed
kable(confirmed[1:6, ]) %>%
      kable_styling(bootstrap_options = c("striped", "hover")
                    , full_width = FALSE)

## ----echo=FALSE----------------------------------------------------------
fatal <- country_totals[country_totals$Status == "fatal", c(1,3)]
      
# top countries fatalities    
kable(fatal[1:6, ]) %>% 
      kable_styling(bootstrap_options = c("striped", "hover")
                    , full_width = FALSE)

## ----echo=FALSE----------------------------------------------------------
recovered <- country_totals[country_totals$Status == "recovered", c(1,3)]
  
# top countries recovered  
kable(recovered[1:6, ]) %>%
      kable_styling(bootstrap_options = c("striped", "hover")
                   , full_width = FALSE)

## ----fig.height=5, fig.width=9, echo=FALSE-------------------------------
# function to create an xts series given dataframe, country, and status
create_xts_series <- function(dfm, country, status) {
  
	dfm <- dfm[dfm$Country == country & dfm$Status == status, ]
	series <- xts(dfm$Count, order.by = dfm$Date)
	series
}

# Confirmed
US <- create_xts_series(country_level_df, "US", "confirmed")
Italy <- create_xts_series(country_level_df, "Italy", "confirmed")
China <- create_xts_series(country_level_df, "China", "confirmed")
Spain <- create_xts_series(country_level_df, "Spain", "confirmed")
Germany <- create_xts_series(country_level_df, "Germany", "confirmed")

seriesObject <- cbind(US, Italy, China, Spain, Germany)
				 
dfm_interactive <- dygraph(seriesObject
						   ,main="US Overtakes Italy and China in Confirmed Cases"
						   ,xlab=""
						   ,ylab="Number of Confirmed Cases") %>% 
						   dyOptions(colors = brewer.pal(5,"Dark2")) %>%						  
						   dyRangeSelector()


dfm_interactive

## ----fig.height=5, fig.width=9, echo=FALSE-------------------------------
# Fatalities
US <- create_xts_series(country_level_df, "US", "fatal")
Italy <- create_xts_series(country_level_df, "Italy", "fatal")
China <- create_xts_series(country_level_df, "China", "fatal")
Spain <- create_xts_series(country_level_df, "Spain", "fatal")
Germany <- create_xts_series(country_level_df, "Germany", "fatal")

seriesObject <- cbind(US, Italy, China, Spain, Germany)
				 
dfm_interactive <- dygraph(seriesObject
						   ,main="Italy Leads in Fatalities"
						   ,xlab=""
						   ,ylab="Number of Fatalities") %>% 
						   dyOptions(colors = brewer.pal(5,"Dark2")) %>%						  
						   dyRangeSelector()

dfm_interactive

## ----fig.height=5, fig.width=9, echo=FALSE-------------------------------
# Recovered
US <- create_xts_series(country_level_df, "US", "recovered")
Italy <- create_xts_series(country_level_df, "Italy", "recovered")
China <- create_xts_series(country_level_df, "China", "recovered")
Spain <- create_xts_series(country_level_df, "Spain", "recovered")
Germany <- create_xts_series(country_level_df, "Germany", "recovered")

seriesObject <- cbind(US, Italy, China, Spain, Germany)
				 
dfm_interactive <- dygraph(seriesObject
						   ,main="China Leads in Recoveries"
						   ,xlab=""
						   ,ylab="Number of Recoveries") %>% 
						   dyOptions(colors = brewer.pal(5,"Dark2")) %>%						  
						   dyRangeSelector()

dfm_interactive

## ----fig.height=5, fig.width=9, echo=FALSE-------------------------------
# Recovered - other four countries
seriesObject <- cbind(US, Italy, Spain, Germany)
				 
dfm_interactive <- dygraph(seriesObject
						   ,main="After China, Italy and Spain Lead in Recoveries"
						   ,xlab=""
						   ,ylab="Number of Recoveries") %>% 
						   dyOptions(colors = brewer.pal(4,"Dark2")) %>%						  
						   dyRangeSelector()

dfm_interactive
```




```r
# uncomment to run, creates Rcode file with R code, set documentation = 1 to avoid text commentary
#library(knitr)
#options(knitr.purl.inline = TRUE)
#purl("COVID19_DATA_ANALYSIS.Rmd", output = "Rcode.R", documentation = 2)
```


