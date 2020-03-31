---
title: "Coronavirus Data Analysis"
author: "Marcelo Sanches"
date: "3/30/2020"
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
## 'data.frame':	51612 obs. of  7 variables:
##  $ Province_State: chr  NA NA NA NA ...
##  $ Country_Region: chr  "Afghanistan" "Afghanistan" "Afghanistan" "Afghanistan" ...
##  $ Lat           : num  33 33 33 33 33 33 33 33 33 33 ...
##  $ Long          : num  65 65 65 65 65 65 65 65 65 65 ...
##  $ Date          : Date, format: "2020-03-30" "2020-03-29" ...
##  $ Value         : int  170 120 110 110 94 84 74 40 40 24 ...
##  $ Status        : Factor w/ 3 levels "confirmed","fatal",..: 1 1 1 1 1 1 1 1 1 1 ...
```


There are 51612 rows and 7 columns. There's a 'Status' column for the different stages, so the number of rows is 3 times the number of rows for a single status (ex. "confirmed"). Each single-status dataset is as long as the number of days in the time series (for a given day the data is pulled) times the number of countries and sub-national provinces or states. This number varies per country, and also varies per day depending on how the dataset is built. 


---

[Back to [Contents](#contents-link)]{style="float:right"}

## Data Cleanup  {#cleanup-link}


### Location Granularity 

The data's location variables have several issues. I will discard `Lat` and `Long` since I'm not doing any mapping. The variables `Country_Region` and `Province_State` are often loosely aggregated. This can be visualized in [Johns Hopkins' dashboard](https://coronavirus.jhu.edu/map.html): the totals for fatalities are grouped by a mixture of countries and subnational geographic areas. The US is conspicuously missing as a country. 

Since subnational data is sparse, I'll focus on country-level data. After some data analysis, I noticed that the anomalies will repond to one simple aggregation and I recreated the dataset at this national level. Canada is a prime example of bad data: notice how it lacks subnational data on recovered cases, but also, I doubt there's a province in Canada called 'Recovered':


<table class="table table-striped table-hover table-condensed" style="width: auto !important; margin-left: auto; margin-right: auto;">
 <thead>
  <tr>
   <th style="text-align:left;"> Country_Region </th>
   <th style="text-align:left;"> Province_State </th>
   <th style="text-align:left;"> Status </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> Canada </td>
   <td style="text-align:left;"> Alberta </td>
   <td style="text-align:left;"> confirmed </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Canada </td>
   <td style="text-align:left;"> British Columbia </td>
   <td style="text-align:left;"> confirmed </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Canada </td>
   <td style="text-align:left;"> Diamond Princess </td>
   <td style="text-align:left;"> confirmed </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Canada </td>
   <td style="text-align:left;"> Grand Princess </td>
   <td style="text-align:left;"> confirmed </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Canada </td>
   <td style="text-align:left;"> Manitoba </td>
   <td style="text-align:left;"> confirmed </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Canada </td>
   <td style="text-align:left;"> New Brunswick </td>
   <td style="text-align:left;"> confirmed </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Canada </td>
   <td style="text-align:left;"> Newfoundland and Labrador </td>
   <td style="text-align:left;"> confirmed </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Canada </td>
   <td style="text-align:left;"> Northwest Territories </td>
   <td style="text-align:left;"> confirmed </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Canada </td>
   <td style="text-align:left;"> Nova Scotia </td>
   <td style="text-align:left;"> confirmed </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Canada </td>
   <td style="text-align:left;"> Ontario </td>
   <td style="text-align:left;"> confirmed </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Canada </td>
   <td style="text-align:left;"> Prince Edward Island </td>
   <td style="text-align:left;"> confirmed </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Canada </td>
   <td style="text-align:left;"> Quebec </td>
   <td style="text-align:left;"> confirmed </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Canada </td>
   <td style="text-align:left;"> Recovered </td>
   <td style="text-align:left;"> confirmed </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Canada </td>
   <td style="text-align:left;"> Saskatchewan </td>
   <td style="text-align:left;"> confirmed </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Canada </td>
   <td style="text-align:left;"> Yukon </td>
   <td style="text-align:left;"> confirmed </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Canada </td>
   <td style="text-align:left;"> Alberta </td>
   <td style="text-align:left;"> fatal </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Canada </td>
   <td style="text-align:left;"> British Columbia </td>
   <td style="text-align:left;"> fatal </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Canada </td>
   <td style="text-align:left;"> Diamond Princess </td>
   <td style="text-align:left;"> fatal </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Canada </td>
   <td style="text-align:left;"> Grand Princess </td>
   <td style="text-align:left;"> fatal </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Canada </td>
   <td style="text-align:left;"> Manitoba </td>
   <td style="text-align:left;"> fatal </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Canada </td>
   <td style="text-align:left;"> New Brunswick </td>
   <td style="text-align:left;"> fatal </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Canada </td>
   <td style="text-align:left;"> Newfoundland and Labrador </td>
   <td style="text-align:left;"> fatal </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Canada </td>
   <td style="text-align:left;"> Northwest Territories </td>
   <td style="text-align:left;"> fatal </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Canada </td>
   <td style="text-align:left;"> Nova Scotia </td>
   <td style="text-align:left;"> fatal </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Canada </td>
   <td style="text-align:left;"> Ontario </td>
   <td style="text-align:left;"> fatal </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Canada </td>
   <td style="text-align:left;"> Prince Edward Island </td>
   <td style="text-align:left;"> fatal </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Canada </td>
   <td style="text-align:left;"> Quebec </td>
   <td style="text-align:left;"> fatal </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Canada </td>
   <td style="text-align:left;"> Recovered </td>
   <td style="text-align:left;"> fatal </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Canada </td>
   <td style="text-align:left;"> Saskatchewan </td>
   <td style="text-align:left;"> fatal </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Canada </td>
   <td style="text-align:left;"> Yukon </td>
   <td style="text-align:left;"> fatal </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Canada </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> recovered </td>
  </tr>
</tbody>
</table>



The top and bottom rows for the final dataset:

<table class="table table-striped table-hover table-condensed" style="width: auto !important; margin-left: auto; margin-right: auto;">
 <thead>
  <tr>
   <th style="text-align:left;">   </th>
   <th style="text-align:left;"> Country </th>
   <th style="text-align:left;"> Status </th>
   <th style="text-align:left;"> Date </th>
   <th style="text-align:right;"> Count </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> 1 </td>
   <td style="text-align:left;"> Afghanistan </td>
   <td style="text-align:left;"> confirmed </td>
   <td style="text-align:left;"> 2020-03-30 </td>
   <td style="text-align:right;"> 170 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 2 </td>
   <td style="text-align:left;"> Afghanistan </td>
   <td style="text-align:left;"> confirmed </td>
   <td style="text-align:left;"> 2020-03-29 </td>
   <td style="text-align:right;"> 120 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 3 </td>
   <td style="text-align:left;"> Afghanistan </td>
   <td style="text-align:left;"> confirmed </td>
   <td style="text-align:left;"> 2020-03-28 </td>
   <td style="text-align:right;"> 110 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 4 </td>
   <td style="text-align:left;"> Afghanistan </td>
   <td style="text-align:left;"> confirmed </td>
   <td style="text-align:left;"> 2020-03-27 </td>
   <td style="text-align:right;"> 110 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 5 </td>
   <td style="text-align:left;"> Afghanistan </td>
   <td style="text-align:left;"> confirmed </td>
   <td style="text-align:left;"> 2020-03-26 </td>
   <td style="text-align:right;"> 94 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 6 </td>
   <td style="text-align:left;"> Afghanistan </td>
   <td style="text-align:left;"> confirmed </td>
   <td style="text-align:left;"> 2020-03-25 </td>
   <td style="text-align:right;"> 84 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 36841 </td>
   <td style="text-align:left;"> Zimbabwe </td>
   <td style="text-align:left;"> recovered </td>
   <td style="text-align:left;"> 2020-01-27 </td>
   <td style="text-align:right;"> 0 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 36842 </td>
   <td style="text-align:left;"> Zimbabwe </td>
   <td style="text-align:left;"> recovered </td>
   <td style="text-align:left;"> 2020-01-26 </td>
   <td style="text-align:right;"> 0 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 36843 </td>
   <td style="text-align:left;"> Zimbabwe </td>
   <td style="text-align:left;"> recovered </td>
   <td style="text-align:left;"> 2020-01-25 </td>
   <td style="text-align:right;"> 0 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 36844 </td>
   <td style="text-align:left;"> Zimbabwe </td>
   <td style="text-align:left;"> recovered </td>
   <td style="text-align:left;"> 2020-01-24 </td>
   <td style="text-align:right;"> 0 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 36845 </td>
   <td style="text-align:left;"> Zimbabwe </td>
   <td style="text-align:left;"> recovered </td>
   <td style="text-align:left;"> 2020-01-23 </td>
   <td style="text-align:right;"> 0 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 36846 </td>
   <td style="text-align:left;"> Zimbabwe </td>
   <td style="text-align:left;"> recovered </td>
   <td style="text-align:left;"> 2020-01-22 </td>
   <td style="text-align:right;"> 0 </td>
  </tr>
</tbody>
</table>





---

[Back to [Contents](#contents-link)]{style="float:right"}


## Exploratory Data Analysis {#eda-link}

#### WORLD TOTALS



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
   <td style="text-align:right;"> 782365 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> fatal </td>
   <td style="text-align:right;"> 37582 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> recovered </td>
   <td style="text-align:right;"> 164566 </td>
  </tr>
</tbody>
</table>


#### TOP COUNTRIES PER STATUS

![](COVID19_DATA_ANALYSIS_files/figure-html/unnamed-chunk-8-1.png)<!-- -->![](COVID19_DATA_ANALYSIS_files/figure-html/unnamed-chunk-8-2.png)<!-- -->![](COVID19_DATA_ANALYSIS_files/figure-html/unnamed-chunk-8-3.png)<!-- -->




---

  
  

### Time Series Plots per Status and Location

This interactive time series speaks for itself: the US has overtaken Italy and China in number of confirmed cases in the last two days.



<!--html_preserve--><div id="htmlwidget-50871d001b4e72da7c93" style="width:864px;height:480px;" class="dygraphs html-widget"></div>
<script type="application/json" data-for="htmlwidget-50871d001b4e72da7c93">{"x":{"attrs":{"title":"Top Countries - Confirmed Cases","xlabel":"","ylabel":"Number of Confirmed Cases","labels":["day","US","Italy","China","Spain","Germany","France"],"legend":"auto","retainDateWindow":false,"axes":{"x":{"pixelsPerLabel":60,"drawAxis":true},"y":{"drawAxis":true}},"stackedGraph":false,"fillGraph":false,"fillAlpha":0.15,"stepPlot":false,"drawPoints":false,"pointSize":1,"drawGapEdgePoints":false,"connectSeparatedPoints":false,"strokeWidth":1,"strokeBorderColor":"white","colors":["#1B9E77","#D95F02","#7570B3","#E7298A","#66A61E","#E6AB02"],"colorValue":0.5,"colorSaturation":1,"includeZero":false,"drawAxesAtZero":false,"logscale":false,"axisTickSize":3,"axisLineColor":"black","axisLineWidth":0.3,"axisLabelColor":"black","axisLabelFontSize":14,"axisLabelWidth":60,"drawGrid":true,"gridLineWidth":0.3,"rightGap":5,"digitsAfterDecimal":2,"labelsKMB":false,"labelsKMG2":false,"labelsUTC":false,"maxNumberWidth":6,"animatedZooms":false,"mobileDisableYTouch":true,"disableZoom":false,"showRangeSelector":true,"rangeSelectorHeight":40,"rangeSelectorPlotFillColor":" #A7B1C4","rangeSelectorPlotStrokeColor":"#808FAB","interactionModel":"Dygraph.Interaction.defaultModel"},"scale":"daily","annotations":[],"shadings":[],"events":[],"format":"date","data":[["2020-01-22T00:00:00.000Z","2020-01-23T00:00:00.000Z","2020-01-24T00:00:00.000Z","2020-01-25T00:00:00.000Z","2020-01-26T00:00:00.000Z","2020-01-27T00:00:00.000Z","2020-01-28T00:00:00.000Z","2020-01-29T00:00:00.000Z","2020-01-30T00:00:00.000Z","2020-01-31T00:00:00.000Z","2020-02-01T00:00:00.000Z","2020-02-02T00:00:00.000Z","2020-02-03T00:00:00.000Z","2020-02-04T00:00:00.000Z","2020-02-05T00:00:00.000Z","2020-02-06T00:00:00.000Z","2020-02-07T00:00:00.000Z","2020-02-08T00:00:00.000Z","2020-02-09T00:00:00.000Z","2020-02-10T00:00:00.000Z","2020-02-11T00:00:00.000Z","2020-02-12T00:00:00.000Z","2020-02-13T00:00:00.000Z","2020-02-14T00:00:00.000Z","2020-02-15T00:00:00.000Z","2020-02-16T00:00:00.000Z","2020-02-17T00:00:00.000Z","2020-02-18T00:00:00.000Z","2020-02-19T00:00:00.000Z","2020-02-20T00:00:00.000Z","2020-02-21T00:00:00.000Z","2020-02-22T00:00:00.000Z","2020-02-23T00:00:00.000Z","2020-02-24T00:00:00.000Z","2020-02-25T00:00:00.000Z","2020-02-26T00:00:00.000Z","2020-02-27T00:00:00.000Z","2020-02-28T00:00:00.000Z","2020-02-29T00:00:00.000Z","2020-03-01T00:00:00.000Z","2020-03-02T00:00:00.000Z","2020-03-03T00:00:00.000Z","2020-03-04T00:00:00.000Z","2020-03-05T00:00:00.000Z","2020-03-06T00:00:00.000Z","2020-03-07T00:00:00.000Z","2020-03-08T00:00:00.000Z","2020-03-09T00:00:00.000Z","2020-03-10T00:00:00.000Z","2020-03-11T00:00:00.000Z","2020-03-12T00:00:00.000Z","2020-03-13T00:00:00.000Z","2020-03-14T00:00:00.000Z","2020-03-15T00:00:00.000Z","2020-03-16T00:00:00.000Z","2020-03-17T00:00:00.000Z","2020-03-18T00:00:00.000Z","2020-03-19T00:00:00.000Z","2020-03-20T00:00:00.000Z","2020-03-21T00:00:00.000Z","2020-03-22T00:00:00.000Z","2020-03-23T00:00:00.000Z","2020-03-24T00:00:00.000Z","2020-03-25T00:00:00.000Z","2020-03-26T00:00:00.000Z","2020-03-27T00:00:00.000Z","2020-03-28T00:00:00.000Z","2020-03-29T00:00:00.000Z","2020-03-30T00:00:00.000Z"],[1,1,2,2,5,5,5,5,5,7,8,8,11,11,11,11,11,11,11,11,12,12,13,13,13,13,13,13,13,13,15,15,15,51,51,57,58,60,68,74,98,118,149,217,262,402,518,583,959,1281,1663,2179,2727,3499,4632,6421,7783,13677,19100,25489,33276,43847,53740,65778,83836,101657,121478,140886,161807],[0,0,0,0,0,0,0,0,0,2,2,2,2,2,2,2,3,3,3,3,3,3,3,3,3,3,3,3,3,3,20,62,155,229,322,453,655,888,1128,1694,2036,2502,3089,3858,4636,5883,7375,9172,10149,12462,12462,17660,21157,24747,27980,31506,35713,41035,47021,53578,59138,63927,69176,74386,80589,86498,92472,97689,101739],[548,643,920,1406,2075,2877,5509,6087,8141,9802,11891,16630,19716,23707,27440,30587,34110,36814,39829,42354,44386,44759,59895,66358,68413,70513,72434,74211,74619,75077,75550,77001,77022,77241,77754,78166,78600,78928,79356,79932,80136,80261,80386,80537,80690,80770,80823,80860,80887,80921,80932,80945,80977,81003,81033,81058,81102,81156,81250,81305,81435,81498,81591,81661,81782,81897,81999,82122,82198],[0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,6,13,15,32,45,84,120,165,222,259,400,500,673,1073,1695,2277,2277,5232,6391,7798,9942,11748,13910,17963,20410,25374,28768,35136,39885,49515,57786,65719,73235,80110,87956],[0,0,0,0,0,1,4,4,4,5,8,10,12,12,12,12,13,13,14,14,16,16,16,16,16,16,16,16,16,16,16,16,16,16,17,27,46,48,79,130,159,196,262,482,670,799,1040,1176,1457,1908,2078,3675,4585,5795,7272,9257,12327,15320,19848,22213,24873,29056,32986,37323,43938,50871,57695,62095,66885],[0,0,2,3,3,3,4,5,5,5,6,6,6,6,6,6,6,11,11,11,11,11,11,11,12,12,12,12,12,12,12,12,12,12,14,18,38,57,100,130,191,204,288,380,656,959,1136,1219,1794,2293,2293,3681,4496,4532,6683,7715,9124,10970,12758,14463,16243,20123,22622,25600,29551,33402,38105,40708,45170]],"fixedtz":false,"tzone":"UTC"},"evals":["attrs.interactionModel"],"jsHooks":[]}</script><!--/html_preserve-->


This is the same visualization using the data on fatalities:

<!--html_preserve--><div id="htmlwidget-66e721237e6ca1e24382" style="width:864px;height:480px;" class="dygraphs html-widget"></div>
<script type="application/json" data-for="htmlwidget-66e721237e6ca1e24382">{"x":{"attrs":{"title":"Top Countries - Fatal Cases","xlabel":"","ylabel":"Number of Fatalities","labels":["day","Italy","Spain","China","France","US","Iran"],"legend":"auto","retainDateWindow":false,"axes":{"x":{"pixelsPerLabel":60,"drawAxis":true},"y":{"drawAxis":true}},"stackedGraph":false,"fillGraph":false,"fillAlpha":0.15,"stepPlot":false,"drawPoints":false,"pointSize":1,"drawGapEdgePoints":false,"connectSeparatedPoints":false,"strokeWidth":1,"strokeBorderColor":"white","colors":["#1B9E77","#D95F02","#7570B3","#E7298A","#66A61E","#E6AB02"],"colorValue":0.5,"colorSaturation":1,"includeZero":false,"drawAxesAtZero":false,"logscale":false,"axisTickSize":3,"axisLineColor":"black","axisLineWidth":0.3,"axisLabelColor":"black","axisLabelFontSize":14,"axisLabelWidth":60,"drawGrid":true,"gridLineWidth":0.3,"rightGap":5,"digitsAfterDecimal":2,"labelsKMB":false,"labelsKMG2":false,"labelsUTC":false,"maxNumberWidth":6,"animatedZooms":false,"mobileDisableYTouch":true,"disableZoom":false,"showRangeSelector":true,"rangeSelectorHeight":40,"rangeSelectorPlotFillColor":" #A7B1C4","rangeSelectorPlotStrokeColor":"#808FAB","interactionModel":"Dygraph.Interaction.defaultModel"},"scale":"daily","annotations":[],"shadings":[],"events":[],"format":"date","data":[["2020-01-22T00:00:00.000Z","2020-01-23T00:00:00.000Z","2020-01-24T00:00:00.000Z","2020-01-25T00:00:00.000Z","2020-01-26T00:00:00.000Z","2020-01-27T00:00:00.000Z","2020-01-28T00:00:00.000Z","2020-01-29T00:00:00.000Z","2020-01-30T00:00:00.000Z","2020-01-31T00:00:00.000Z","2020-02-01T00:00:00.000Z","2020-02-02T00:00:00.000Z","2020-02-03T00:00:00.000Z","2020-02-04T00:00:00.000Z","2020-02-05T00:00:00.000Z","2020-02-06T00:00:00.000Z","2020-02-07T00:00:00.000Z","2020-02-08T00:00:00.000Z","2020-02-09T00:00:00.000Z","2020-02-10T00:00:00.000Z","2020-02-11T00:00:00.000Z","2020-02-12T00:00:00.000Z","2020-02-13T00:00:00.000Z","2020-02-14T00:00:00.000Z","2020-02-15T00:00:00.000Z","2020-02-16T00:00:00.000Z","2020-02-17T00:00:00.000Z","2020-02-18T00:00:00.000Z","2020-02-19T00:00:00.000Z","2020-02-20T00:00:00.000Z","2020-02-21T00:00:00.000Z","2020-02-22T00:00:00.000Z","2020-02-23T00:00:00.000Z","2020-02-24T00:00:00.000Z","2020-02-25T00:00:00.000Z","2020-02-26T00:00:00.000Z","2020-02-27T00:00:00.000Z","2020-02-28T00:00:00.000Z","2020-02-29T00:00:00.000Z","2020-03-01T00:00:00.000Z","2020-03-02T00:00:00.000Z","2020-03-03T00:00:00.000Z","2020-03-04T00:00:00.000Z","2020-03-05T00:00:00.000Z","2020-03-06T00:00:00.000Z","2020-03-07T00:00:00.000Z","2020-03-08T00:00:00.000Z","2020-03-09T00:00:00.000Z","2020-03-10T00:00:00.000Z","2020-03-11T00:00:00.000Z","2020-03-12T00:00:00.000Z","2020-03-13T00:00:00.000Z","2020-03-14T00:00:00.000Z","2020-03-15T00:00:00.000Z","2020-03-16T00:00:00.000Z","2020-03-17T00:00:00.000Z","2020-03-18T00:00:00.000Z","2020-03-19T00:00:00.000Z","2020-03-20T00:00:00.000Z","2020-03-21T00:00:00.000Z","2020-03-22T00:00:00.000Z","2020-03-23T00:00:00.000Z","2020-03-24T00:00:00.000Z","2020-03-25T00:00:00.000Z","2020-03-26T00:00:00.000Z","2020-03-27T00:00:00.000Z","2020-03-28T00:00:00.000Z","2020-03-29T00:00:00.000Z","2020-03-30T00:00:00.000Z"],[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,2,3,7,10,12,17,21,29,34,52,79,107,148,197,233,366,463,631,827,827,1266,1441,1809,2158,2503,2978,3405,4032,4825,5476,6077,6820,7503,8215,9134,10023,10779,11591],[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,2,3,5,10,17,28,35,54,55,133,195,289,342,533,623,830,1043,1375,1772,2311,2808,3647,4365,5138,5982,6803,7716],[17,18,26,42,56,82,131,133,171,213,259,361,425,491,563,633,718,805,905,1012,1112,1117,1369,1521,1663,1766,1864,2003,2116,2238,2238,2443,2445,2595,2665,2717,2746,2790,2837,2872,2914,2947,2983,3015,3044,3072,3100,3123,3139,3161,3172,3180,3193,3203,3217,3230,3241,3249,3253,3259,3274,3274,3281,3285,3291,3296,3299,3304,3308],[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,2,2,2,2,2,3,4,4,6,9,11,19,19,33,48,48,79,91,91,149,149,149,244,451,563,676,862,1102,1333,1698,1997,2317,2611,3030],[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,6,7,11,12,14,17,21,22,28,36,40,47,54,63,85,108,118,200,244,307,417,557,706,942,1209,1581,2026,2467,2978],[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2,2,4,5,8,12,16,19,26,34,43,54,66,77,92,107,124,145,194,237,291,354,429,514,611,724,853,988,1135,1284,1433,1556,1685,1812,1934,2077,2234,2378,2517,2640,2757]],"fixedtz":false,"tzone":"UTC"},"evals":["attrs.interactionModel"],"jsHooks":[]}</script><!--/html_preserve-->


This is the same visualization using the data on recoveries:

<!--html_preserve--><div id="htmlwidget-12e077ee7fc48eddb9f8" style="width:864px;height:480px;" class="dygraphs html-widget"></div>
<script type="application/json" data-for="htmlwidget-12e077ee7fc48eddb9f8">{"x":{"attrs":{"title":"Top Countries - Recovered Cases","xlabel":"","ylabel":"Number of Recoveries","labels":["day","China","Spain","Italy","Iran","Germany","France"],"legend":"auto","retainDateWindow":false,"axes":{"x":{"pixelsPerLabel":60,"drawAxis":true},"y":{"drawAxis":true}},"stackedGraph":false,"fillGraph":false,"fillAlpha":0.15,"stepPlot":false,"drawPoints":false,"pointSize":1,"drawGapEdgePoints":false,"connectSeparatedPoints":false,"strokeWidth":1,"strokeBorderColor":"white","colors":["#1B9E77","#D95F02","#7570B3","#E7298A","#66A61E","#E6AB02"],"colorValue":0.5,"colorSaturation":1,"includeZero":false,"drawAxesAtZero":false,"logscale":false,"axisTickSize":3,"axisLineColor":"black","axisLineWidth":0.3,"axisLabelColor":"black","axisLabelFontSize":14,"axisLabelWidth":60,"drawGrid":true,"gridLineWidth":0.3,"rightGap":5,"digitsAfterDecimal":2,"labelsKMB":false,"labelsKMG2":false,"labelsUTC":false,"maxNumberWidth":6,"animatedZooms":false,"mobileDisableYTouch":true,"disableZoom":false,"showRangeSelector":true,"rangeSelectorHeight":40,"rangeSelectorPlotFillColor":" #A7B1C4","rangeSelectorPlotStrokeColor":"#808FAB","interactionModel":"Dygraph.Interaction.defaultModel"},"scale":"daily","annotations":[],"shadings":[],"events":[],"format":"date","data":[["2020-01-22T00:00:00.000Z","2020-01-23T00:00:00.000Z","2020-01-24T00:00:00.000Z","2020-01-25T00:00:00.000Z","2020-01-26T00:00:00.000Z","2020-01-27T00:00:00.000Z","2020-01-28T00:00:00.000Z","2020-01-29T00:00:00.000Z","2020-01-30T00:00:00.000Z","2020-01-31T00:00:00.000Z","2020-02-01T00:00:00.000Z","2020-02-02T00:00:00.000Z","2020-02-03T00:00:00.000Z","2020-02-04T00:00:00.000Z","2020-02-05T00:00:00.000Z","2020-02-06T00:00:00.000Z","2020-02-07T00:00:00.000Z","2020-02-08T00:00:00.000Z","2020-02-09T00:00:00.000Z","2020-02-10T00:00:00.000Z","2020-02-11T00:00:00.000Z","2020-02-12T00:00:00.000Z","2020-02-13T00:00:00.000Z","2020-02-14T00:00:00.000Z","2020-02-15T00:00:00.000Z","2020-02-16T00:00:00.000Z","2020-02-17T00:00:00.000Z","2020-02-18T00:00:00.000Z","2020-02-19T00:00:00.000Z","2020-02-20T00:00:00.000Z","2020-02-21T00:00:00.000Z","2020-02-22T00:00:00.000Z","2020-02-23T00:00:00.000Z","2020-02-24T00:00:00.000Z","2020-02-25T00:00:00.000Z","2020-02-26T00:00:00.000Z","2020-02-27T00:00:00.000Z","2020-02-28T00:00:00.000Z","2020-02-29T00:00:00.000Z","2020-03-01T00:00:00.000Z","2020-03-02T00:00:00.000Z","2020-03-03T00:00:00.000Z","2020-03-04T00:00:00.000Z","2020-03-05T00:00:00.000Z","2020-03-06T00:00:00.000Z","2020-03-07T00:00:00.000Z","2020-03-08T00:00:00.000Z","2020-03-09T00:00:00.000Z","2020-03-10T00:00:00.000Z","2020-03-11T00:00:00.000Z","2020-03-12T00:00:00.000Z","2020-03-13T00:00:00.000Z","2020-03-14T00:00:00.000Z","2020-03-15T00:00:00.000Z","2020-03-16T00:00:00.000Z","2020-03-17T00:00:00.000Z","2020-03-18T00:00:00.000Z","2020-03-19T00:00:00.000Z","2020-03-20T00:00:00.000Z","2020-03-21T00:00:00.000Z","2020-03-22T00:00:00.000Z","2020-03-23T00:00:00.000Z","2020-03-24T00:00:00.000Z","2020-03-25T00:00:00.000Z","2020-03-26T00:00:00.000Z","2020-03-27T00:00:00.000Z","2020-03-28T00:00:00.000Z","2020-03-29T00:00:00.000Z","2020-03-30T00:00:00.000Z"],[28,30,36,39,49,58,101,120,135,214,275,463,614,843,1115,1477,1999,2596,3219,3918,4636,5082,6217,7977,9298,10755,12462,14206,15962,18014,18704,22699,23187,25015,27676,30084,32930,36329,39320,42162,44854,47450,50001,52292,53944,55539,57388,58804,60181,61644,62901,64196,65660,67017,67910,68798,69755,70535,71266,71857,72362,72814,73280,73773,74181,74720,75100,75582,75923],[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,30,30,32,32,183,183,193,517,517,530,1028,1081,1107,1588,2125,2575,2575,3794,5367,7015,9357,12285,14709,16780],[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,2,1,1,3,45,46,46,83,149,160,276,414,523,589,622,724,724,1045,1045,1439,1966,2335,2749,2941,4025,4440,4440,6072,7024,7024,8326,9362,10361,10950,12384,13030,14620],[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,49,49,73,123,175,291,291,552,739,913,1669,2134,2394,2731,2959,2959,2959,2959,4590,4590,5389,5389,5710,6745,7635,7931,7931,8913,9625,10457,11133,11679,12391,13911],[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,12,12,12,14,14,14,14,14,15,16,16,16,16,16,16,16,16,17,18,18,18,18,25,25,46,46,46,67,67,105,113,180,233,266,266,3243,3547,5673,6658,8481,9211,13500],[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2,2,2,4,4,4,4,4,4,4,4,4,4,11,11,11,11,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,2206,2206,3250,3907,4955,5707,5724,7226,7964]],"fixedtz":false,"tzone":"UTC"},"evals":["attrs.interactionModel"],"jsHooks":[]}</script><!--/html_preserve-->

Since China dominates this plot too much, it would be interesting to see how the other countries are doing as far as recoveries:

<!--html_preserve--><div id="htmlwidget-f54a7b84aefb0c53e97d" style="width:864px;height:480px;" class="dygraphs html-widget"></div>
<script type="application/json" data-for="htmlwidget-f54a7b84aefb0c53e97d">{"x":{"attrs":{"title":"Top Countries (after China) - Recovered Cases","xlabel":"","ylabel":"Number of Recoveries","labels":["day","Spain","Italy","Iran","Germany","France"],"legend":"auto","retainDateWindow":false,"axes":{"x":{"pixelsPerLabel":60,"drawAxis":true},"y":{"drawAxis":true}},"stackedGraph":false,"fillGraph":false,"fillAlpha":0.15,"stepPlot":false,"drawPoints":false,"pointSize":1,"drawGapEdgePoints":false,"connectSeparatedPoints":false,"strokeWidth":1,"strokeBorderColor":"white","colors":["#1B9E77","#D95F02","#7570B3","#E7298A","#66A61E"],"colorValue":0.5,"colorSaturation":1,"includeZero":false,"drawAxesAtZero":false,"logscale":false,"axisTickSize":3,"axisLineColor":"black","axisLineWidth":0.3,"axisLabelColor":"black","axisLabelFontSize":14,"axisLabelWidth":60,"drawGrid":true,"gridLineWidth":0.3,"rightGap":5,"digitsAfterDecimal":2,"labelsKMB":false,"labelsKMG2":false,"labelsUTC":false,"maxNumberWidth":6,"animatedZooms":false,"mobileDisableYTouch":true,"disableZoom":false,"showRangeSelector":true,"rangeSelectorHeight":40,"rangeSelectorPlotFillColor":" #A7B1C4","rangeSelectorPlotStrokeColor":"#808FAB","interactionModel":"Dygraph.Interaction.defaultModel"},"scale":"daily","annotations":[],"shadings":[],"events":[],"format":"date","data":[["2020-01-22T00:00:00.000Z","2020-01-23T00:00:00.000Z","2020-01-24T00:00:00.000Z","2020-01-25T00:00:00.000Z","2020-01-26T00:00:00.000Z","2020-01-27T00:00:00.000Z","2020-01-28T00:00:00.000Z","2020-01-29T00:00:00.000Z","2020-01-30T00:00:00.000Z","2020-01-31T00:00:00.000Z","2020-02-01T00:00:00.000Z","2020-02-02T00:00:00.000Z","2020-02-03T00:00:00.000Z","2020-02-04T00:00:00.000Z","2020-02-05T00:00:00.000Z","2020-02-06T00:00:00.000Z","2020-02-07T00:00:00.000Z","2020-02-08T00:00:00.000Z","2020-02-09T00:00:00.000Z","2020-02-10T00:00:00.000Z","2020-02-11T00:00:00.000Z","2020-02-12T00:00:00.000Z","2020-02-13T00:00:00.000Z","2020-02-14T00:00:00.000Z","2020-02-15T00:00:00.000Z","2020-02-16T00:00:00.000Z","2020-02-17T00:00:00.000Z","2020-02-18T00:00:00.000Z","2020-02-19T00:00:00.000Z","2020-02-20T00:00:00.000Z","2020-02-21T00:00:00.000Z","2020-02-22T00:00:00.000Z","2020-02-23T00:00:00.000Z","2020-02-24T00:00:00.000Z","2020-02-25T00:00:00.000Z","2020-02-26T00:00:00.000Z","2020-02-27T00:00:00.000Z","2020-02-28T00:00:00.000Z","2020-02-29T00:00:00.000Z","2020-03-01T00:00:00.000Z","2020-03-02T00:00:00.000Z","2020-03-03T00:00:00.000Z","2020-03-04T00:00:00.000Z","2020-03-05T00:00:00.000Z","2020-03-06T00:00:00.000Z","2020-03-07T00:00:00.000Z","2020-03-08T00:00:00.000Z","2020-03-09T00:00:00.000Z","2020-03-10T00:00:00.000Z","2020-03-11T00:00:00.000Z","2020-03-12T00:00:00.000Z","2020-03-13T00:00:00.000Z","2020-03-14T00:00:00.000Z","2020-03-15T00:00:00.000Z","2020-03-16T00:00:00.000Z","2020-03-17T00:00:00.000Z","2020-03-18T00:00:00.000Z","2020-03-19T00:00:00.000Z","2020-03-20T00:00:00.000Z","2020-03-21T00:00:00.000Z","2020-03-22T00:00:00.000Z","2020-03-23T00:00:00.000Z","2020-03-24T00:00:00.000Z","2020-03-25T00:00:00.000Z","2020-03-26T00:00:00.000Z","2020-03-27T00:00:00.000Z","2020-03-28T00:00:00.000Z","2020-03-29T00:00:00.000Z","2020-03-30T00:00:00.000Z"],[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,30,30,32,32,183,183,193,517,517,530,1028,1081,1107,1588,2125,2575,2575,3794,5367,7015,9357,12285,14709,16780],[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,2,1,1,3,45,46,46,83,149,160,276,414,523,589,622,724,724,1045,1045,1439,1966,2335,2749,2941,4025,4440,4440,6072,7024,7024,8326,9362,10361,10950,12384,13030,14620],[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,49,49,73,123,175,291,291,552,739,913,1669,2134,2394,2731,2959,2959,2959,2959,4590,4590,5389,5389,5710,6745,7635,7931,7931,8913,9625,10457,11133,11679,12391,13911],[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,12,12,12,14,14,14,14,14,15,16,16,16,16,16,16,16,16,17,18,18,18,18,25,25,46,46,46,67,67,105,113,180,233,266,266,3243,3547,5673,6658,8481,9211,13500],[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2,2,2,4,4,4,4,4,4,4,4,4,4,11,11,11,11,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,2206,2206,3250,3907,4955,5707,5724,7226,7964]],"fixedtz":false,"tzone":"UTC"},"evals":["attrs.interactionModel"],"jsHooks":[]}</script><!--/html_preserve-->


---

#### Per Capita Analysis


Raw counts only tell part of the story. Since the probability of, say, being diagnosed with COVID-19 is somewhat dependent on the percentage of people in a country that were diagnosed with the disease, the raw count divided by the population of a country would provide a better estimate of how one country compares to another. 

For example, the number of confirmed cases in the US is much higher now than any other country, yet because there are roughly 322 million people in the US, it still ranks 25th in terms of percentage of confirmed cases.






**Top 25 Confirmed Cases by Percentage of Population**

<table class="table table-striped table-hover table-condensed" style="width: auto !important; margin-left: auto; margin-right: auto;">
 <thead>
  <tr>
   <th style="text-align:left;"> Country </th>
   <th style="text-align:left;"> Status </th>
   <th style="text-align:left;"> Date </th>
   <th style="text-align:right;"> Count </th>
   <th style="text-align:right;"> Population_thousands </th>
   <th style="text-align:right;"> Pct </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> Diamond Princess </td>
   <td style="text-align:left;"> confirmed </td>
   <td style="text-align:left;"> 2020-03-30 </td>
   <td style="text-align:right;"> 712 </td>
   <td style="text-align:right;"> 4 </td>
   <td style="text-align:right;"> 17.8000000 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> San Marino </td>
   <td style="text-align:left;"> confirmed </td>
   <td style="text-align:left;"> 2020-03-30 </td>
   <td style="text-align:right;"> 230 </td>
   <td style="text-align:right;"> 33 </td>
   <td style="text-align:right;"> 0.6969697 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Holy See </td>
   <td style="text-align:left;"> confirmed </td>
   <td style="text-align:left;"> 2020-03-30 </td>
   <td style="text-align:right;"> 6 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 0.6000000 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Andorra </td>
   <td style="text-align:left;"> confirmed </td>
   <td style="text-align:left;"> 2020-03-30 </td>
   <td style="text-align:right;"> 370 </td>
   <td style="text-align:right;"> 77 </td>
   <td style="text-align:right;"> 0.4805195 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Luxembourg </td>
   <td style="text-align:left;"> confirmed </td>
   <td style="text-align:left;"> 2020-03-30 </td>
   <td style="text-align:right;"> 1988 </td>
   <td style="text-align:right;"> 576 </td>
   <td style="text-align:right;"> 0.3451389 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Iceland </td>
   <td style="text-align:left;"> confirmed </td>
   <td style="text-align:left;"> 2020-03-30 </td>
   <td style="text-align:right;"> 1086 </td>
   <td style="text-align:right;"> 332 </td>
   <td style="text-align:right;"> 0.3271084 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Spain </td>
   <td style="text-align:left;"> confirmed </td>
   <td style="text-align:left;"> 2020-03-30 </td>
   <td style="text-align:right;"> 87956 </td>
   <td style="text-align:right;"> 46348 </td>
   <td style="text-align:right;"> 0.1897730 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Switzerland </td>
   <td style="text-align:left;"> confirmed </td>
   <td style="text-align:left;"> 2020-03-30 </td>
   <td style="text-align:right;"> 15922 </td>
   <td style="text-align:right;"> 8402 </td>
   <td style="text-align:right;"> 0.1895025 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Italy </td>
   <td style="text-align:left;"> confirmed </td>
   <td style="text-align:left;"> 2020-03-30 </td>
   <td style="text-align:right;"> 101739 </td>
   <td style="text-align:right;"> 59430 </td>
   <td style="text-align:right;"> 0.1711913 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Liechtenstein </td>
   <td style="text-align:left;"> confirmed </td>
   <td style="text-align:left;"> 2020-03-30 </td>
   <td style="text-align:right;"> 62 </td>
   <td style="text-align:right;"> 39 </td>
   <td style="text-align:right;"> 0.1589744 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Monaco </td>
   <td style="text-align:left;"> confirmed </td>
   <td style="text-align:left;"> 2020-03-30 </td>
   <td style="text-align:right;"> 49 </td>
   <td style="text-align:right;"> 38 </td>
   <td style="text-align:right;"> 0.1289474 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Austria </td>
   <td style="text-align:left;"> confirmed </td>
   <td style="text-align:left;"> 2020-03-30 </td>
   <td style="text-align:right;"> 9618 </td>
   <td style="text-align:right;"> 8712 </td>
   <td style="text-align:right;"> 0.1103994 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Belgium </td>
   <td style="text-align:left;"> confirmed </td>
   <td style="text-align:left;"> 2020-03-30 </td>
   <td style="text-align:right;"> 11899 </td>
   <td style="text-align:right;"> 11358 </td>
   <td style="text-align:right;"> 0.1047632 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> MS Zaandam </td>
   <td style="text-align:left;"> confirmed </td>
   <td style="text-align:left;"> 2020-03-30 </td>
   <td style="text-align:right;"> 2 </td>
   <td style="text-align:right;"> 2 </td>
   <td style="text-align:right;"> 0.1000000 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Norway </td>
   <td style="text-align:left;"> confirmed </td>
   <td style="text-align:left;"> 2020-03-30 </td>
   <td style="text-align:right;"> 4445 </td>
   <td style="text-align:right;"> 5255 </td>
   <td style="text-align:right;"> 0.0845861 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Germany </td>
   <td style="text-align:left;"> confirmed </td>
   <td style="text-align:left;"> 2020-03-30 </td>
   <td style="text-align:right;"> 66885 </td>
   <td style="text-align:right;"> 81915 </td>
   <td style="text-align:right;"> 0.0816517 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> France </td>
   <td style="text-align:left;"> confirmed </td>
   <td style="text-align:left;"> 2020-03-30 </td>
   <td style="text-align:right;"> 45170 </td>
   <td style="text-align:right;"> 64721 </td>
   <td style="text-align:right;"> 0.0697919 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Netherlands </td>
   <td style="text-align:left;"> confirmed </td>
   <td style="text-align:left;"> 2020-03-30 </td>
   <td style="text-align:right;"> 11817 </td>
   <td style="text-align:right;"> 16987 </td>
   <td style="text-align:right;"> 0.0695650 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Portugal </td>
   <td style="text-align:left;"> confirmed </td>
   <td style="text-align:left;"> 2020-03-30 </td>
   <td style="text-align:right;"> 6408 </td>
   <td style="text-align:right;"> 10372 </td>
   <td style="text-align:right;"> 0.0617817 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Ireland </td>
   <td style="text-align:left;"> confirmed </td>
   <td style="text-align:left;"> 2020-03-30 </td>
   <td style="text-align:right;"> 2910 </td>
   <td style="text-align:right;"> 4726 </td>
   <td style="text-align:right;"> 0.0615743 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Israel </td>
   <td style="text-align:left;"> confirmed </td>
   <td style="text-align:left;"> 2020-03-30 </td>
   <td style="text-align:right;"> 4695 </td>
   <td style="text-align:right;"> 8192 </td>
   <td style="text-align:right;"> 0.0573120 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Estonia </td>
   <td style="text-align:left;"> confirmed </td>
   <td style="text-align:left;"> 2020-03-30 </td>
   <td style="text-align:right;"> 715 </td>
   <td style="text-align:right;"> 1312 </td>
   <td style="text-align:right;"> 0.0544970 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Iran </td>
   <td style="text-align:left;"> confirmed </td>
   <td style="text-align:left;"> 2020-03-30 </td>
   <td style="text-align:right;"> 41495 </td>
   <td style="text-align:right;"> 80277 </td>
   <td style="text-align:right;"> 0.0516898 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> US </td>
   <td style="text-align:left;"> confirmed </td>
   <td style="text-align:left;"> 2020-03-30 </td>
   <td style="text-align:right;"> 161807 </td>
   <td style="text-align:right;"> 322180 </td>
   <td style="text-align:right;"> 0.0502225 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Denmark </td>
   <td style="text-align:left;"> confirmed </td>
   <td style="text-align:left;"> 2020-03-30 </td>
   <td style="text-align:right;"> 2755 </td>
   <td style="text-align:right;"> 5712 </td>
   <td style="text-align:right;"> 0.0482318 </td>
  </tr>
</tbody>
</table>


Since the Diamond Princess is not a country and it dominates the percentages so much in all statuses, I'm removing it from consideration in the plots below.







![](COVID19_DATA_ANALYSIS_files/figure-html/unnamed-chunk-16-1.png)<!-- -->![](COVID19_DATA_ANALYSIS_files/figure-html/unnamed-chunk-16-2.png)<!-- -->![](COVID19_DATA_ANALYSIS_files/figure-html/unnamed-chunk-16-3.png)<!-- -->

---


### Time Series by Percentage - Linear & Log 

```
IN PROGRESS...

ADD: Fatalities, Recovered

DO: Number of NEW Cases per TOTAL Confirmed Cases, Linear/Log.

```

<!--html_preserve--><div id="htmlwidget-5c921057c04e62c238d3" style="width:864px;height:480px;" class="dygraphs html-widget"></div>
<script type="application/json" data-for="htmlwidget-5c921057c04e62c238d3">{"x":{"attrs":{"title":"Top Countries - Confirmed Cases by Percentage of Population (Linear)","xlabel":"","ylabel":"Percentage of Confirmed Cases","labels":["day","US","Italy","China","Spain","Germany","France"],"legend":"auto","retainDateWindow":false,"axes":{"x":{"pixelsPerLabel":60,"drawAxis":true},"y":{"drawAxis":true}},"stackedGraph":false,"fillGraph":false,"fillAlpha":0.15,"stepPlot":false,"drawPoints":false,"pointSize":1,"drawGapEdgePoints":false,"connectSeparatedPoints":false,"strokeWidth":1,"strokeBorderColor":"white","colors":["#1B9E77","#D95F02","#7570B3","#E7298A","#66A61E","#E6AB02"],"colorValue":0.5,"colorSaturation":1,"includeZero":false,"drawAxesAtZero":false,"logscale":false,"axisTickSize":3,"axisLineColor":"black","axisLineWidth":0.3,"axisLabelColor":"black","axisLabelFontSize":14,"axisLabelWidth":60,"drawGrid":true,"gridLineWidth":0.3,"rightGap":5,"digitsAfterDecimal":2,"labelsKMB":false,"labelsKMG2":false,"labelsUTC":false,"maxNumberWidth":6,"animatedZooms":false,"mobileDisableYTouch":true,"disableZoom":false,"showRangeSelector":true,"rangeSelectorHeight":40,"rangeSelectorPlotFillColor":" #A7B1C4","rangeSelectorPlotStrokeColor":"#808FAB","interactionModel":"Dygraph.Interaction.defaultModel"},"scale":"daily","annotations":[],"shadings":[],"events":[],"format":"date","data":[["2020-01-22T00:00:00.000Z","2020-01-23T00:00:00.000Z","2020-01-24T00:00:00.000Z","2020-01-25T00:00:00.000Z","2020-01-26T00:00:00.000Z","2020-01-27T00:00:00.000Z","2020-01-28T00:00:00.000Z","2020-01-29T00:00:00.000Z","2020-01-30T00:00:00.000Z","2020-01-31T00:00:00.000Z","2020-02-01T00:00:00.000Z","2020-02-02T00:00:00.000Z","2020-02-03T00:00:00.000Z","2020-02-04T00:00:00.000Z","2020-02-05T00:00:00.000Z","2020-02-06T00:00:00.000Z","2020-02-07T00:00:00.000Z","2020-02-08T00:00:00.000Z","2020-02-09T00:00:00.000Z","2020-02-10T00:00:00.000Z","2020-02-11T00:00:00.000Z","2020-02-12T00:00:00.000Z","2020-02-13T00:00:00.000Z","2020-02-14T00:00:00.000Z","2020-02-15T00:00:00.000Z","2020-02-16T00:00:00.000Z","2020-02-17T00:00:00.000Z","2020-02-18T00:00:00.000Z","2020-02-19T00:00:00.000Z","2020-02-20T00:00:00.000Z","2020-02-21T00:00:00.000Z","2020-02-22T00:00:00.000Z","2020-02-23T00:00:00.000Z","2020-02-24T00:00:00.000Z","2020-02-25T00:00:00.000Z","2020-02-26T00:00:00.000Z","2020-02-27T00:00:00.000Z","2020-02-28T00:00:00.000Z","2020-02-29T00:00:00.000Z","2020-03-01T00:00:00.000Z","2020-03-02T00:00:00.000Z","2020-03-03T00:00:00.000Z","2020-03-04T00:00:00.000Z","2020-03-05T00:00:00.000Z","2020-03-06T00:00:00.000Z","2020-03-07T00:00:00.000Z","2020-03-08T00:00:00.000Z","2020-03-09T00:00:00.000Z","2020-03-10T00:00:00.000Z","2020-03-11T00:00:00.000Z","2020-03-12T00:00:00.000Z","2020-03-13T00:00:00.000Z","2020-03-14T00:00:00.000Z","2020-03-15T00:00:00.000Z","2020-03-16T00:00:00.000Z","2020-03-17T00:00:00.000Z","2020-03-18T00:00:00.000Z","2020-03-19T00:00:00.000Z","2020-03-20T00:00:00.000Z","2020-03-21T00:00:00.000Z","2020-03-22T00:00:00.000Z","2020-03-23T00:00:00.000Z","2020-03-24T00:00:00.000Z","2020-03-25T00:00:00.000Z","2020-03-26T00:00:00.000Z","2020-03-27T00:00:00.000Z","2020-03-28T00:00:00.000Z","2020-03-29T00:00:00.000Z","2020-03-30T00:00:00.000Z"],[3.10385498789497e-007,3.10385498789497e-007,6.20770997578993e-007,6.20770997578993e-007,1.55192749394748e-006,1.55192749394748e-006,1.55192749394748e-006,1.55192749394748e-006,1.55192749394748e-006,2.17269849152648e-006,2.48308399031597e-006,2.48308399031597e-006,3.41424048668446e-006,3.41424048668446e-006,3.41424048668446e-006,3.41424048668446e-006,3.41424048668446e-006,3.41424048668446e-006,3.41424048668446e-006,3.41424048668446e-006,3.72462598547396e-006,3.72462598547396e-006,4.03501148426346e-006,4.03501148426346e-006,4.03501148426346e-006,4.03501148426346e-006,4.03501148426346e-006,4.03501148426346e-006,4.03501148426346e-006,4.03501148426346e-006,4.65578248184245e-006,4.65578248184245e-006,4.65578248184245e-006,1.58296604382643e-005,1.58296604382643e-005,1.76919734310013e-005,1.80023589297908e-005,1.86231299273698e-005,2.11062139176858e-005,2.29685269104227e-005,3.04177788813707e-005,3.66254888571606e-005,4.6247439319635e-005,6.73536532373208e-005,8.13210006828481e-005,0.000124774970513378,0.000160779688372959,0.000180954745794277,0.000297659693339127,0.000397603823949345,0.000516171084486933,0.000676330001862313,0.000846421255198957,0.00108603886026445,0.00143770563039295,0.00199298528772736,0.00241573033707865,0.00424514246694394,0.00592836302687938,0.00791141597864548,0.0103283878577193,0.0136094729654231,0.0166801167049475,0.0204165373393755,0.0260214786765162,0.0315528586504439,0.0377050096219505,0.043728971382457,0.0502225464026321],[0,0,0,0,0,0,0,0,0,3.36530371866061e-006,3.36530371866061e-006,3.36530371866061e-006,3.36530371866061e-006,3.36530371866061e-006,3.36530371866061e-006,3.36530371866061e-006,5.04795557799091e-006,5.04795557799091e-006,5.04795557799091e-006,5.04795557799091e-006,5.04795557799091e-006,5.04795557799091e-006,5.04795557799091e-006,5.04795557799091e-006,5.04795557799091e-006,5.04795557799091e-006,5.04795557799091e-006,5.04795557799091e-006,5.04795557799091e-006,5.04795557799091e-006,3.36530371866061e-005,0.000104324415278479,0.000260811038196197,0.00038532727578664,0.000541813898704358,0.000762241292276628,0.00110213696786135,0.00149419485108531,0.00189803129732458,0.00285041224970554,0.0034258791855965,0.00420999495204442,0.00519771159347131,0.00649167087329631,0.00780077401985529,0.00989904088844018,0.012409557462561,0.0154332828537776,0.0170772337203433,0.0209692074709743,0.0209692074709743,0.0297156318357732,0.0355998653878513,0.041640585562847,0.0470805990240619,0.0530136294800606,0.0600925458522632,0.0690476190476191,0.0791199730775703,0.0901531213191991,0.0995086656570756,0.107566885411408,0.116399125021033,0.125165741208144,0.13560323069157,0.145546020528353,0.155598182735992,0.164376577486118,0.171191317516406],[3.88262842608304e-005,4.55571182111569e-005,6.5182812992635e-005,9.96163424648314e-005,0.000147015583651867,0.00020383799236936,0.000390317518235246,0.000431269329006706,0.000576797044101133,0.000694480361906314,0.000842487857929808,0.00117825019572557,0.00139689602278564,0.00167966189958304,0.00194414824838903,0.00216711597935405,0.00241672364258563,0.00260830443207703,0.00282191984639528,0.00300081832770659,0.00314478732335989,0.00317121470297538,0.0042436136784716,0.00470152293974487,0.00484712150572298,0.00499590836146704,0.00513201290903101,0.00525791492934396,0.00528682208988852,0.00531927179461746,0.00535278426260172,0.00545558889483249,0.00545707676338993,0.00547259310691753,0.00550893961024929,0.0055381301743286,0.00556887945784904,0.00559211854769859,0.0056224427259169,0.00566325283492098,0.00567770641519326,0.00568656277565422,0.00569541913611518,0.00570611761955201,0.00571695780475622,0.00572262587545123,0.00572638097228668,0.00572900245498312,0.00573091542884269,0.00573332435888807,0.00573410371860863,0.00573502478009657,0.00573729200837457,0.00573913413135045,0.00574125965786108,0.00574303092995327,0.00574614836883553,0.00574997431655466,0.0057566342996213,0.00576053109822412,0.00576974171310352,0.00577420531877584,0.00578079445095879,0.00578575401281692,0.00579432696974313,0.00580247482136721,0.00580970161150335,0.00581841627019693,0.00582380093735719],[0,0,0,0,0,0,0,0,0,0,2.15759040303789e-006,2.15759040303789e-006,2.15759040303789e-006,2.15759040303789e-006,2.15759040303789e-006,2.15759040303789e-006,2.15759040303789e-006,2.15759040303789e-006,4.31518080607577e-006,4.31518080607577e-006,4.31518080607577e-006,4.31518080607577e-006,4.31518080607577e-006,4.31518080607577e-006,4.31518080607577e-006,4.31518080607577e-006,4.31518080607577e-006,4.31518080607577e-006,4.31518080607577e-006,4.31518080607577e-006,4.31518080607577e-006,4.31518080607577e-006,4.31518080607577e-006,4.31518080607577e-006,1.29455424182273e-005,2.80486752394925e-005,3.23638560455683e-005,6.90428928972124e-005,9.70915681367049e-005,0.000181237593855183,0.000258910848364546,0.000356002416501251,0.000478985069474411,0.000558815914386813,0.000863036161215155,0.00107879520151894,0.0014520583412445,0.00231509450245965,0.00365711573314922,0.00491283334771727,0.00491283334771727,0.0112885129886942,0.0137891602658151,0.0168248899628894,0.0214507637870027,0.0253473720548891,0.030012082506257,0.0387567964097696,0.0440364201260033,0.0547466988866833,0.0620695607145939,0.0758090964011392,0.0860554932251661,0.106833088806421,0.124678519029947,0.141794683697247,0.15801113316648,0.172844567187365,0.1897730214896],[0,0,0,0,0,1.22077763535372e-006,4.88311054141488e-006,4.88311054141488e-006,4.88311054141488e-006,6.1038881767686e-006,9.76622108282976e-006,1.22077763535372e-005,1.46493316242446e-005,1.46493316242446e-005,1.46493316242446e-005,1.46493316242446e-005,1.58701092595984e-005,1.58701092595984e-005,1.70908868949521e-005,1.70908868949521e-005,1.95324421656595e-005,1.95324421656595e-005,1.95324421656595e-005,1.95324421656595e-005,1.95324421656595e-005,1.95324421656595e-005,1.95324421656595e-005,1.95324421656595e-005,1.95324421656595e-005,1.95324421656595e-005,1.95324421656595e-005,1.95324421656595e-005,1.95324421656595e-005,1.95324421656595e-005,2.07532198010132e-005,3.29609961545504e-005,5.61557712262711e-005,5.85973264969786e-005,9.64414331929439e-005,0.000158701092595984,0.000194103644021242,0.000239272416529329,0.000319843740462675,0.000588414820240493,0.000817921015686993,0.000975401330647622,0.00126960874076787,0.00143563449917598,0.00177867301471037,0.0023292437282549,0.00253677592626503,0.00448635780992492,0.00559726545809681,0.00707440639687481,0.00887749496429225,0.0113007385704694,0.0150485259110053,0.018702313373619,0.0242299945065006,0.0271171336141122,0.0303644021241531,0.0354709149728377,0.0402685710797778,0.0455630836843069,0.0536385277421718,0.0621021790880791,0.0704327656717329,0.0758041872672893,0.0816517121406336],[0,0,3.09018711082956e-006,4.63528066624434e-006,4.63528066624434e-006,4.63528066624434e-006,6.18037422165912e-006,7.7254677770739e-006,7.7254677770739e-006,7.7254677770739e-006,9.27056133248868e-006,9.27056133248868e-006,9.27056133248868e-006,9.27056133248868e-006,9.27056133248868e-006,9.27056133248868e-006,9.27056133248868e-006,1.69960291095626e-005,1.69960291095626e-005,1.69960291095626e-005,1.69960291095626e-005,1.69960291095626e-005,1.69960291095626e-005,1.69960291095626e-005,1.85411226649774e-005,1.85411226649774e-005,1.85411226649774e-005,1.85411226649774e-005,1.85411226649774e-005,1.85411226649774e-005,1.85411226649774e-005,1.85411226649774e-005,1.85411226649774e-005,1.85411226649774e-005,2.16313097758069e-005,2.7811683997466e-005,5.87135551057616e-005,8.80703326586425e-005,0.000154509355541478,0.000200862162203921,0.000295112869084223,0.000315199085304615,0.000444986943959457,0.000587135551057617,0.0010135813723521,0.00148174471964277,0.00175522627895119,0.00188346904405062,0.00277189783841412,0.00354289952256609,0.00354289952256609,0.00568748937748181,0.00694674062514485,0.00700236399313978,0.010325860230837,0.011920396780025,0.0140974335996045,0.0169496763029001,0.0197123035799818,0.022346688091964,0.0250969546206023,0.0310919176156116,0.0349531064105932,0.0395543950186184,0.0456590596560622,0.0516092149379645,0.0588757899290802,0.0628976684538249,0.0697918758980856]],"fixedtz":false,"tzone":"UTC"},"evals":["attrs.interactionModel"],"jsHooks":[]}</script><!--/html_preserve--><!--html_preserve--><div id="htmlwidget-9d168b9af8e0acfd4b61" style="width:864px;height:480px;" class="dygraphs html-widget"></div>
<script type="application/json" data-for="htmlwidget-9d168b9af8e0acfd4b61">{"x":{"attrs":{"title":"Top Countries - Confirmed Cases by Percentage of Population (Log)","xlabel":"","ylabel":"Log of Percentage of Confirmed Cases","labels":["day","US","Italy","China","Spain","Germany","France"],"legend":"auto","retainDateWindow":false,"axes":{"x":{"pixelsPerLabel":60,"drawAxis":true},"y":{"drawAxis":true}},"stackedGraph":false,"fillGraph":false,"fillAlpha":0.15,"stepPlot":false,"drawPoints":false,"pointSize":1,"drawGapEdgePoints":false,"connectSeparatedPoints":false,"strokeWidth":1,"strokeBorderColor":"white","colors":["#1B9E77","#D95F02","#7570B3","#E7298A","#66A61E","#E6AB02"],"colorValue":0.5,"colorSaturation":1,"includeZero":false,"drawAxesAtZero":false,"logscale":false,"axisTickSize":3,"axisLineColor":"black","axisLineWidth":0.3,"axisLabelColor":"black","axisLabelFontSize":14,"axisLabelWidth":60,"drawGrid":true,"gridLineWidth":0.3,"rightGap":5,"digitsAfterDecimal":2,"labelsKMB":false,"labelsKMG2":false,"labelsUTC":false,"maxNumberWidth":6,"animatedZooms":false,"mobileDisableYTouch":true,"disableZoom":false,"showRangeSelector":true,"rangeSelectorHeight":40,"rangeSelectorPlotFillColor":" #A7B1C4","rangeSelectorPlotStrokeColor":"#808FAB","interactionModel":"Dygraph.Interaction.defaultModel"},"scale":"daily","annotations":[],"shadings":[],"events":[],"format":"date","data":[["2020-01-22T00:00:00.000Z","2020-01-23T00:00:00.000Z","2020-01-24T00:00:00.000Z","2020-01-25T00:00:00.000Z","2020-01-26T00:00:00.000Z","2020-01-27T00:00:00.000Z","2020-01-28T00:00:00.000Z","2020-01-29T00:00:00.000Z","2020-01-30T00:00:00.000Z","2020-01-31T00:00:00.000Z","2020-02-01T00:00:00.000Z","2020-02-02T00:00:00.000Z","2020-02-03T00:00:00.000Z","2020-02-04T00:00:00.000Z","2020-02-05T00:00:00.000Z","2020-02-06T00:00:00.000Z","2020-02-07T00:00:00.000Z","2020-02-08T00:00:00.000Z","2020-02-09T00:00:00.000Z","2020-02-10T00:00:00.000Z","2020-02-11T00:00:00.000Z","2020-02-12T00:00:00.000Z","2020-02-13T00:00:00.000Z","2020-02-14T00:00:00.000Z","2020-02-15T00:00:00.000Z","2020-02-16T00:00:00.000Z","2020-02-17T00:00:00.000Z","2020-02-18T00:00:00.000Z","2020-02-19T00:00:00.000Z","2020-02-20T00:00:00.000Z","2020-02-21T00:00:00.000Z","2020-02-22T00:00:00.000Z","2020-02-23T00:00:00.000Z","2020-02-24T00:00:00.000Z","2020-02-25T00:00:00.000Z","2020-02-26T00:00:00.000Z","2020-02-27T00:00:00.000Z","2020-02-28T00:00:00.000Z","2020-02-29T00:00:00.000Z","2020-03-01T00:00:00.000Z","2020-03-02T00:00:00.000Z","2020-03-03T00:00:00.000Z","2020-03-04T00:00:00.000Z","2020-03-05T00:00:00.000Z","2020-03-06T00:00:00.000Z","2020-03-07T00:00:00.000Z","2020-03-08T00:00:00.000Z","2020-03-09T00:00:00.000Z","2020-03-10T00:00:00.000Z","2020-03-11T00:00:00.000Z","2020-03-12T00:00:00.000Z","2020-03-13T00:00:00.000Z","2020-03-14T00:00:00.000Z","2020-03-15T00:00:00.000Z","2020-03-16T00:00:00.000Z","2020-03-17T00:00:00.000Z","2020-03-18T00:00:00.000Z","2020-03-19T00:00:00.000Z","2020-03-20T00:00:00.000Z","2020-03-21T00:00:00.000Z","2020-03-22T00:00:00.000Z","2020-03-23T00:00:00.000Z","2020-03-24T00:00:00.000Z","2020-03-25T00:00:00.000Z","2020-03-26T00:00:00.000Z","2020-03-27T00:00:00.000Z","2020-03-28T00:00:00.000Z","2020-03-29T00:00:00.000Z","2020-03-30T00:00:00.000Z"],[-14.985450767546,-14.985450767546,-14.2923035869861,-14.2923035869861,-13.3760128551119,-13.3760128551119,-13.3760128551119,-13.3760128551119,-13.3760128551119,-13.0395406184907,-12.9060092258662,-12.9060092258662,-12.5875554947476,-12.5875554947476,-12.5875554947476,-12.5875554947476,-12.5875554947476,-12.5875554947476,-12.5875554947476,-12.5875554947476,-12.500544117758,-12.500544117758,-12.4205014100845,-12.4205014100845,-12.4205014100845,-12.4205014100845,-12.4205014100845,-12.4205014100845,-12.4205014100845,-12.4205014100845,-12.2774005664438,-12.2774005664438,-12.2774005664438,-11.0536251348217,-11.0536251348217,-10.9423994997115,-10.9250077569996,-10.8911062053239,-10.7659430623699,-10.6813856743418,-10.4004832888754,-10.2147661430803,-9.98150446160054,-9.60555341400554,-9.41710626378491,-8.98899867892698,-8.73547552528652,-8.61726358119551,-8.11955969266256,-7.83005446564927,-7.56907228835307,-7.29882943260138,-7.07449338470041,-6.82521827517831,-6.54470674829317,-6.21812161975195,-6.02575362058661,-5.46197989866445,-5.12800715351128,-4.83944850201641,-4.57285907214222,-4.2969891871374,-4.09353788537652,-3.89141005264341,-3.64883297905295,-3.45609108711235,-3.27796231213725,-3.129744435845,-2.99129122158729],[null,null,null,null,null,null,null,null,null,-12.6019923407948,-12.6019923407948,-12.6019923407948,-12.6019923407948,-12.6019923407948,-12.6019923407948,-12.6019923407948,-12.1965272326866,-12.1965272326866,-12.1965272326866,-12.1965272326866,-12.1965272326866,-12.1965272326866,-12.1965272326866,-12.1965272326866,-12.1965272326866,-12.1965272326866,-12.1965272326866,-12.1965272326866,-12.1965272326866,-12.1965272326866,-10.2994072478008,-9.16800513630966,-8.25171440443551,-7.86141751780051,-7.52058797581034,-7.17924739587172,-6.8105042857195,-6.50616777836258,-6.26693808929675,-5.86029164614275,-5.67639714368434,-5.4702938303279,-5.25953682843617,-5.03723532788908,-4.85353231689511,-4.6153174064903,-4.38928834014673,-4.17122887737696,-4.07000906390593,-3.86470022825058,-3.86470022825058,-3.5160820471968,-3.33541342237143,-3.17867997282591,-3.05589427313528,-2.93720623848884,-2.8118694742137,-2.67295888129094,-2.53678993194112,-2.40624570631379,-2.30751054657897,-2.22964243502072,-2.15073026071449,-2.07811649028316,-1.99802207860059,-1.92726295008937,-1.86047834638065,-1.80559527922244,-1.76497353200212],[-10.1564131112839,-9.99654367399432,-9.63831472818885,-9.21418432586133,-8.82497196556714,-8.49818503468039,-7.84855000075922,-7.74877776973802,-7.45802009665796,-7.27234667276245,-7.07915130779436,-6.74372482604497,-6.57350263040667,-6.38916275606871,-6.24293131639212,-6.13435803716141,-6.02534252281925,-5.94905491163927,-5.87033782907492,-5.80887025160841,-5.76200901484926,-5.75364057743188,-5.46234009006651,-5.35986879301947,-5.32937025420059,-5.29913602926753,-5.27225731683226,-5.24802073208568,-5.2425379527795,-5.23641886570861,-5.23013843053105,-5.21111471046746,-5.21084202391896,-5.20800271511353,-5.20138312256847,-5.1960983488526,-5.19056141981464,-5.18639707475842,-5.18098906076928,-5.17375684603076,-5.17120792794034,-5.16964929498205,-5.16809308758039,-5.16621641309238,-5.16431846738939,-5.1633275097956,-5.16267154076352,-5.16221385503718,-5.16188000031034,-5.16145974914229,-5.16132382333285,-5.16116320755633,-5.16076795551626,-5.16044692822618,-5.16007664013782,-5.15976817143569,-5.15922549752006,-5.158559890869,-5.15740229803996,-5.15672560397212,-5.15512796322428,-5.15435463918139,-5.15321415748023,-5.15235658753573,-5.15087594875517,-5.14947075909831,-5.14822606718186,-5.14672717279262,-5.14580214838391],[null,null,null,null,null,null,null,null,null,null,-13.046518513111,-13.046518513111,-13.046518513111,-13.046518513111,-13.046518513111,-13.046518513111,-13.046518513111,-13.046518513111,-12.3533713325511,-12.3533713325511,-12.3533713325511,-12.3533713325511,-12.3533713325511,-12.3533713325511,-12.3533713325511,-12.3533713325511,-12.3533713325511,-12.3533713325511,-12.3533713325511,-12.3533713325511,-12.3533713325511,-12.3533713325511,-12.3533713325511,-12.3533713325511,-11.2547590438829,-10.4815691556495,-10.3384683120088,-9.58078261031127,-9.23985602334068,-8.61570171426768,-8.25902677032895,-7.94057303921042,-7.64384113123872,-7.48969045141146,-7.05505396600302,-6.83191041468881,-6.53477318346627,-6.0683047704803,-5.61108049329645,-5.31590444704726,-5.31590444704726,-4.48396961997396,-4.28387248346072,-4.08489594356846,-3.84199502645638,-3.67508022079249,-3.50615522819351,-3.25044914734216,-3.12273825730711,-2.90503820641046,-2.77949957583965,-2.5795369882418,-2.45276292076577,-2.2364875801556,-2.08201670232208,-1.95337515714373,-1.84508978535859,-1.75536254390184,-1.66192654469234],[null,null,null,null,null,-13.6160224962484,-12.2297281351285,-12.2297281351285,-12.2297281351285,-12.0065845838143,-11.5365809545686,-11.3134374032544,-11.1311158464604,-11.1311158464604,-11.1311158464604,-11.1311158464604,-11.0510731387869,-11.0510731387869,-10.9769651666332,-10.9769651666332,-10.8434337740086,-10.8434337740086,-10.8434337740086,-10.8434337740086,-10.8434337740086,-10.8434337740086,-10.8434337740086,-10.8434337740086,-10.8434337740086,-10.8434337740086,-10.8434337740086,-10.8434337740086,-10.8434337740086,-10.8434337740086,-10.7828091521922,-10.3201856302441,-9.78738109975931,-9.74482148534052,-9.24657464378139,-8.74848804579283,-8.54711829402818,-8.33790783701789,-8.04767799248731,-7.43807838219781,-7.1087447838634,-6.93266155048213,-6.66904650411299,-6.54614836778984,-6.3318876900532,-6.06221164424018,-5.97686132458924,-5.40671408460147,-5.18547711155784,-4.95127174047456,-4.72423586039109,-4.4828871951812,-4.19647523869689,-3.97910805295383,-3.72016397087677,-3.60758951419079,-3.49448433946408,-3.33904221484739,-3.21218398824031,-3.08865745866581,-2.92548766795928,-2.77897420067317,-2.65309670261964,-2.57960174686628,-2.50529249051872],[null,null,-12.6872789152214,-12.2818138071132,-12.2818138071132,-12.2818138071132,-11.9941317346614,-11.7709881833472,-11.7709881833472,-11.7709881833472,-11.5886666265533,-11.5886666265533,-11.5886666265533,-11.5886666265533,-11.5886666265533,-11.5886666265533,-11.5886666265533,-10.982530822983,-10.982530822983,-10.982530822983,-10.982530822983,-10.982530822983,-10.982530822983,-10.982530822983,-10.8955194459933,-10.8955194459933,-10.8955194459933,-10.8955194459933,-10.8955194459933,-10.8955194459933,-10.8955194459933,-10.8955194459933,-10.8955194459933,-10.8955194459933,-10.7413687661661,-10.4900543378852,-9.74283993605495,-9.33737482794679,-8.77525590979325,-8.51289164532576,-8.12815266773471,-8.06230610193712,-7.71746561564539,-7.44025484306091,-6.89426530683725,-6.5145350208979,-6.34515749650024,-6.27463996630007,-5.8882230531626,-5.64280981292344,-5.64280981292344,-5.16948636240232,-4.96948270420781,-4.96150747363344,-4.57310382827027,-4.42950433098408,-4.26176251237706,-4.07750654251206,-3.92651229097944,-3.80107715270761,-3.68500877006194,-3.47080737731497,-3.35374793269001,-3.23007846531369,-3.08655323257214,-2.96405503836978,-2.83232530968112,-2.76624618346952,-2.66223766713269]],"fixedtz":false,"tzone":"UTC"},"evals":["attrs.interactionModel"],"jsHooks":[]}</script><!--/html_preserve-->





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
## ----echo=FALSE----------------------------------------------------------
# Canada provinces example
kable(data.frame(dfm[dfm$Country_Region == "Canada", ]) %>% 
		   distinct(Country_Region, Province_State, Status)) %>%
      kable_styling(bootstrap_options = c("striped", "hover", "condensed")
                  , full_width = FALSE)

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
kable(rbind(head(country_level_df)
     ,tail(country_level_df))) %>%
      kable_styling(bootstrap_options = c("striped", "hover", "condensed")
                  , full_width = FALSE)

## ----echo=FALSE----------------------------------------------------------
# subset to current counts 
current_data <- data.frame(country_level_df %>%
					filter(Date == unique(country_level_df$Date)[1])) %>%
					arrange(Status, desc(Count))

# subset to world totals 
world_totals <- data.frame(current_data %>% 
					group_by(Status) %>%
					summarise('total'=sum(Count)))

kable(world_totals) %>%
      kable_styling(bootstrap_options = c("striped", "hover"), full_width = FALSE)

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
top_confirmed 	<- get_top_counts(country_totals, "confirmed")
top_fatal	<- get_top_counts(country_totals, "fatal")
top_recovered 	<- get_top_counts(country_totals, "recovered")

# plot top countries per status 
gg_plot <- function(dfm, status, color) {

	ggplot(data=dfm, aes(x=reorder(Country, -Count), y=Count)) +
		geom_bar(stat="identity", fill=color) + 
		ggtitle(paste0("Top ", status, " Cases by Country")) + 
		xlab("") + ylab(paste0("Number of ", status, " Cases")) +
		geom_text(aes(label=Count), vjust=1.6, color="white", size=3.5) +
		theme_minimal()

}

# top confirmed
gg_plot(top_confirmed, "Confirmed", "red3")

# top fatal 
gg_plot(top_fatal, "Fatal", "gray25")

# top recovered
gg_plot(top_recovered, "Recovered", "springgreen4")


## ----fig.height=5, fig.width=9, echo=FALSE-------------------------------
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
France <- create_xts_series(country_level_df, "France", "confirmed")


seriesObject <- cbind(US, Italy, China, Spain, Germany, France)
				 
dfm_interactive <- dygraph(seriesObject
						   ,main="Top Countries - Confirmed Cases"
						   ,xlab=""
						   ,ylab="Number of Confirmed Cases") %>% 
						   dyOptions(colors = brewer.pal(6,"Dark2")) %>%						  
						   dyRangeSelector()


dfm_interactive

## ----fig.height=5, fig.width=9, echo=FALSE-------------------------------
# Fatalities
Italy <- create_xts_series(country_level_df, "Italy", "fatal")
Spain <- create_xts_series(country_level_df, "Spain", "fatal")
China <- create_xts_series(country_level_df, "China", "fatal")
France <- create_xts_series(country_level_df, "France", "fatal")
US <- create_xts_series(country_level_df, "US", "fatal")
Iran <- create_xts_series(country_level_df, "Iran", "fatal")

seriesObject <- cbind(Italy, Spain, China, France, US, Iran)
				 
dfm_interactive <- dygraph(seriesObject
						   ,main="Top Countries - Fatal Cases"
						   ,xlab=""
						   ,ylab="Number of Fatalities") %>% 
						   dyOptions(colors = brewer.pal(6,"Dark2")) %>%						  
						   dyRangeSelector()

dfm_interactive

## ----fig.height=5, fig.width=9, echo=FALSE-------------------------------
# Recovered
China <- create_xts_series(country_level_df, "China", "recovered")
Spain <- create_xts_series(country_level_df, "Spain", "recovered")
Italy <- create_xts_series(country_level_df, "Italy", "recovered")
Iran <- create_xts_series(country_level_df, "Iran", "recovered")
Germany <- create_xts_series(country_level_df, "Germany", "recovered")
France <- create_xts_series(country_level_df, "France", "recovered")

seriesObject <- cbind(China, Spain, Italy, Iran, Germany, France)

dfm_interactive <- dygraph(seriesObject
						   ,main="Top Countries - Recovered Cases"
						   ,xlab=""
						   ,ylab="Number of Recoveries") %>% 
						   dyOptions(colors = brewer.pal(6,"Dark2")) %>%						  
						   dyRangeSelector()

dfm_interactive

## ----fig.height=5, fig.width=9, echo=FALSE-------------------------------
# Recovered - after China
seriesObject <- cbind(Spain, Italy, Iran, Germany, France)

dfm_interactive <- dygraph(seriesObject
						   ,main="Top Countries (after China) - Recovered Cases"
						   ,xlab=""
						   ,ylab="Number of Recoveries") %>% 
						   dyOptions(colors = brewer.pal(5,"Dark2")) %>%						  
						   dyRangeSelector()

dfm_interactive


## ----include=FALSE-------------------------------------------------------
# read in prepared dataset of countries and populations
country_population <- read.csv("COVID19_DATA/country_population.csv")
		  
# TEST
unique(country_level_df$Country)[!unique(country_level_df$Country) %in% country_population$Country]		

# per capita analysis
percap <- merge(country_level_df, country_population, by="Country")

# percentage
percap$Pct <- (percap$Count / (percap$Population_thousands*1000)) * 100 

## ----echo=FALSE----------------------------------------------------------
# subset to current counts 
current_data <- data.frame(percap %>%
					filter(Date == unique(percap$Date)[1])) %>%
					arrange(Status, desc(Pct))

kable(current_data[1:25, ]) %>%
  kable_styling(bootstrap_options = c("striped", "hover", "condensed"), full_width = FALSE)

## ----include=FALSE-------------------------------------------------------
# subset to top counts 	
get_top_pcts <- function(dfm, coln) {
	
	dfm <- dfm[dfm$Status == coln, c(1,6)][2:12,]
	row.names(dfm) <- 1:11
	dfm$Pct <- round(dfm$Pct, 4)
	dfm
}					

# separate by status 
top_confirmed 	<- get_top_pcts(current_data, "confirmed")
top_fatal	<- get_top_pcts(current_data, "fatal")
top_recovered 	<- get_top_pcts(current_data, "recovered")

# plot top countries per status 
gg_plot <- function(dfm, status, color) {

	ggplot(data=dfm, aes(x=reorder(Country, -Pct), y=Pct)) +
		geom_bar(stat="identity", fill=color) + 
		ggtitle(paste0("Top ", status, " Cases by Pct of Population")) + 
		xlab("") + ylab(paste0("Percentage of ", status, " Cases")) +
		geom_text(aes(label=Pct), vjust=1.6, color="white", size=3.5) +
    theme_minimal()

}

## ----echo=FALSE, fig.height=7, fig.width=9-------------------------------
# top confirmed
gg_plot(top_confirmed, "Confirmed", "red3")

# top fatal 
gg_plot(top_fatal, "Fatal", "gray25")

# top recovered
gg_plot(top_recovered, "Recovered", "springgreen4")
```




```r
# uncomment to run, creates Rcode file with R code, set documentation = 1 to avoid text commentary
#library(knitr)
#options(knitr.purl.inline = TRUE)
#purl("COVID19_DATA_ANALYSIS.Rmd", output = "Rcode.R", documentation = 2)
```


