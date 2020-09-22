---
title: "Coronavirus Data Analysis"
author: "Marcelo Sanches"
date: "06/18/2020"
output: 
  html_document:
    keep_md: true
---





This is a simple exploration of the time series data which was compiled by the Johns Hopkins University Center for Systems Science and Engineering (JHU CCSE) from various sources (see website for full description). The data can be downloaded manually at [Novel Coronavirus 2019 Cases.](https://data.humdata.org/dataset/novel-coronavirus-2019-ncov-cases)This [GitHub repository](https://github.com/BigBangData/CoronavirusDataAnalysis) hosts all files for this project, including all previous versions. For full reproducibility, a similar directory structure including custom datasets should be reproduced as well - the easiest way would be to clone directly from GitHub.

This project is not intended to be a serious data analysis, which would require more datasets and study. This is a personal project to explore the daily JHU datasets. The plots produced here, therefore, have serious issues and do not reflect reality. They do not take into consideration the meaning of confirmed cases - this varies per location and time depending on differing methods of definition, availability of testing, changes in policy, and so forth. These plots should not be taken as a model for how COVID-19 spreads through populations. The data is incomplete, and represents a view of the past.


## Contents {#contents-link}

* [Data Pre-Processing](#preprocess-link): brief description of data pre-processing and cleanup steps.
* [Data Wrangling and Enrichment](#enrich-link): adding population data and calculated columns.
* [Exploratory Data Analysis](#eda-link): main section with visualizations [IN PROGRESS...]
* [Outcome Simulation](#sim-link): simulations of possible outcomes. [TO DO]
* [Code Appendix](#codeappendix-link): entire R code.

---

## Data Pre-Processing {#preprocess-link}

I downloaded three CSV files, one for each status: confirmed cases, fatal cases, and recovered cases. The confirmed status is a sum of all confirmed cases which later turn into fatalities or recoveries, so I subtracted those to get a fourth status of "active" cases. I produce a longform dataset with the following structure:






```r
# structure of dataset
str(dfm)
```

```
## 'data.frame':	111296 obs. of  4 variables:
##  $ Country: chr  "Afghanistan" "Afghanistan" "Afghanistan" "Afghanistan" ...
##  $ Status : Factor w/ 4 levels "Confirmed","Fatal",..: 1 1 1 1 1 1 1 1 1 1 ...
##  $ Date   : Date, format: "2020-06-17" "2020-06-16" ...
##  $ Count  : int  26874 26310 25527 24766 24102 23546 22890 22142 21459 20917 ...
```


There are 111296 rows and 4 columns. Each single-status dataset is as long as the number of days times the number of countries for the data in a given day. Today there are 148 daysa and 188 countries in the data. 

In pre-processing I decided to remove the sub-national province or state variable because it is too sparse and varies too much per day. For this project I am concentrating on country-level data. I also discarded latitude and longitude since there are many issues with those, and I do not plan on mapping the spread of the disease.


The top and bottom rows for the final dataset look thus:

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
   <td style="text-align:left;"> Confirmed </td>
   <td style="text-align:left;"> 2020-06-17 </td>
   <td style="text-align:right;"> 26874 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 2 </td>
   <td style="text-align:left;"> Afghanistan </td>
   <td style="text-align:left;"> Confirmed </td>
   <td style="text-align:left;"> 2020-06-16 </td>
   <td style="text-align:right;"> 26310 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 3 </td>
   <td style="text-align:left;"> Afghanistan </td>
   <td style="text-align:left;"> Confirmed </td>
   <td style="text-align:left;"> 2020-06-15 </td>
   <td style="text-align:right;"> 25527 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 4 </td>
   <td style="text-align:left;"> Afghanistan </td>
   <td style="text-align:left;"> Confirmed </td>
   <td style="text-align:left;"> 2020-06-14 </td>
   <td style="text-align:right;"> 24766 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 5 </td>
   <td style="text-align:left;"> Afghanistan </td>
   <td style="text-align:left;"> Confirmed </td>
   <td style="text-align:left;"> 2020-06-13 </td>
   <td style="text-align:right;"> 24102 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 6 </td>
   <td style="text-align:left;"> Afghanistan </td>
   <td style="text-align:left;"> Confirmed </td>
   <td style="text-align:left;"> 2020-06-12 </td>
   <td style="text-align:right;"> 23546 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 111291 </td>
   <td style="text-align:left;"> Zimbabwe </td>
   <td style="text-align:left;"> Active </td>
   <td style="text-align:left;"> 2020-01-27 </td>
   <td style="text-align:right;"> 0 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 111292 </td>
   <td style="text-align:left;"> Zimbabwe </td>
   <td style="text-align:left;"> Active </td>
   <td style="text-align:left;"> 2020-01-26 </td>
   <td style="text-align:right;"> 0 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 111293 </td>
   <td style="text-align:left;"> Zimbabwe </td>
   <td style="text-align:left;"> Active </td>
   <td style="text-align:left;"> 2020-01-25 </td>
   <td style="text-align:right;"> 0 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 111294 </td>
   <td style="text-align:left;"> Zimbabwe </td>
   <td style="text-align:left;"> Active </td>
   <td style="text-align:left;"> 2020-01-24 </td>
   <td style="text-align:right;"> 0 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 111295 </td>
   <td style="text-align:left;"> Zimbabwe </td>
   <td style="text-align:left;"> Active </td>
   <td style="text-align:left;"> 2020-01-23 </td>
   <td style="text-align:right;"> 0 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 111296 </td>
   <td style="text-align:left;"> Zimbabwe </td>
   <td style="text-align:left;"> Active </td>
   <td style="text-align:left;"> 2020-01-22 </td>
   <td style="text-align:right;"> 0 </td>
  </tr>
</tbody>
</table>

---

[Back to [Contents](#contents-link)]{style="float:right"}


## Data Wrangling and Enrichment {#enrich-link}


I maintain a static dataset of countries and their populations. This data is cobbled together with internet searches and the [World Health Organization data.](https://apps.who.int/gho/data/view.main.POP2040ALL?lang=en) I use the country's population to calculate a `Pct` column with the percentage of cases given a country and a status. I also calculate the difference between each day and the previous day's counts as the `NewCases` variable.








The top rows of the enriched dataset for Brazil and Canada are:

<table class="table table-striped table-hover table-condensed" style="width: auto !important; margin-left: auto; margin-right: auto;">
 <thead>
  <tr>
   <th style="text-align:left;">   </th>
   <th style="text-align:left;"> Country </th>
   <th style="text-align:left;"> Status </th>
   <th style="text-align:left;"> Date </th>
   <th style="text-align:right;"> Count </th>
   <th style="text-align:right;"> Population_thousands </th>
   <th style="text-align:right;"> Pct </th>
   <th style="text-align:right;"> NewCases </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> 13617 </td>
   <td style="text-align:left;"> Brazil </td>
   <td style="text-align:left;"> Confirmed </td>
   <td style="text-align:left;"> 2020-06-17 </td>
   <td style="text-align:right;"> 955377 </td>
   <td style="text-align:right;"> 207653 </td>
   <td style="text-align:right;"> 0.460 </td>
   <td style="text-align:right;"> 32188 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 13618 </td>
   <td style="text-align:left;"> Brazil </td>
   <td style="text-align:left;"> Confirmed </td>
   <td style="text-align:left;"> 2020-06-16 </td>
   <td style="text-align:right;"> 923189 </td>
   <td style="text-align:right;"> 207653 </td>
   <td style="text-align:right;"> 0.445 </td>
   <td style="text-align:right;"> 34918 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 13619 </td>
   <td style="text-align:left;"> Brazil </td>
   <td style="text-align:left;"> Confirmed </td>
   <td style="text-align:left;"> 2020-06-15 </td>
   <td style="text-align:right;"> 888271 </td>
   <td style="text-align:right;"> 207653 </td>
   <td style="text-align:right;"> 0.428 </td>
   <td style="text-align:right;"> 20647 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 13620 </td>
   <td style="text-align:left;"> Brazil </td>
   <td style="text-align:left;"> Confirmed </td>
   <td style="text-align:left;"> 2020-06-14 </td>
   <td style="text-align:right;"> 867624 </td>
   <td style="text-align:right;"> 207653 </td>
   <td style="text-align:right;"> 0.418 </td>
   <td style="text-align:right;"> 17110 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 13621 </td>
   <td style="text-align:left;"> Brazil </td>
   <td style="text-align:left;"> Confirmed </td>
   <td style="text-align:left;"> 2020-06-13 </td>
   <td style="text-align:right;"> 850514 </td>
   <td style="text-align:right;"> 207653 </td>
   <td style="text-align:right;"> 0.410 </td>
   <td style="text-align:right;"> 21704 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 13622 </td>
   <td style="text-align:left;"> Brazil </td>
   <td style="text-align:left;"> Confirmed </td>
   <td style="text-align:left;"> 2020-06-12 </td>
   <td style="text-align:right;"> 828810 </td>
   <td style="text-align:right;"> 207653 </td>
   <td style="text-align:right;"> 0.399 </td>
   <td style="text-align:right;"> 25982 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 18945 </td>
   <td style="text-align:left;"> Canada </td>
   <td style="text-align:left;"> Confirmed </td>
   <td style="text-align:left;"> 2020-06-17 </td>
   <td style="text-align:right;"> 101491 </td>
   <td style="text-align:right;"> 36290 </td>
   <td style="text-align:right;"> 0.280 </td>
   <td style="text-align:right;"> 404 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 18946 </td>
   <td style="text-align:left;"> Canada </td>
   <td style="text-align:left;"> Confirmed </td>
   <td style="text-align:left;"> 2020-06-16 </td>
   <td style="text-align:right;"> 101087 </td>
   <td style="text-align:right;"> 36290 </td>
   <td style="text-align:right;"> 0.279 </td>
   <td style="text-align:right;"> 324 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 18947 </td>
   <td style="text-align:left;"> Canada </td>
   <td style="text-align:left;"> Confirmed </td>
   <td style="text-align:left;"> 2020-06-15 </td>
   <td style="text-align:right;"> 100763 </td>
   <td style="text-align:right;"> 36290 </td>
   <td style="text-align:right;"> 0.278 </td>
   <td style="text-align:right;"> 359 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 18948 </td>
   <td style="text-align:left;"> Canada </td>
   <td style="text-align:left;"> Confirmed </td>
   <td style="text-align:left;"> 2020-06-14 </td>
   <td style="text-align:right;"> 100404 </td>
   <td style="text-align:right;"> 36290 </td>
   <td style="text-align:right;"> 0.277 </td>
   <td style="text-align:right;"> 361 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 18949 </td>
   <td style="text-align:left;"> Canada </td>
   <td style="text-align:left;"> Confirmed </td>
   <td style="text-align:left;"> 2020-06-13 </td>
   <td style="text-align:right;"> 100043 </td>
   <td style="text-align:right;"> 36290 </td>
   <td style="text-align:right;"> 0.276 </td>
   <td style="text-align:right;"> 448 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 18950 </td>
   <td style="text-align:left;"> Canada </td>
   <td style="text-align:left;"> Confirmed </td>
   <td style="text-align:left;"> 2020-06-12 </td>
   <td style="text-align:right;"> 99595 </td>
   <td style="text-align:right;"> 36290 </td>
   <td style="text-align:right;"> 0.274 </td>
   <td style="text-align:right;"> 436 </td>
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
   <th style="text-align:left;"> Total </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> Confirmed </td>
   <td style="text-align:left;"> 8,349,950 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Fatal </td>
   <td style="text-align:left;"> 448,959 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Recovered </td>
   <td style="text-align:left;"> 4,073,955 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Active </td>
   <td style="text-align:left;"> 3,827,036 </td>
  </tr>
</tbody>
</table>


In this first section I plot a series of barplots for the top ten countries per status (confirmed, fatal, recovered, active) by count, percentage of population, and number of new cases since the previous day.

UPDATE - decided to remove Active plots, in fact, this whole section is badly plotted, it leads to information overload. 
TO DO - find 1 or 2 plots to convey the same information, or the message behind it (stacked barplots a maybe).


---

### Barplots






![](COVID19_DATA_ANALYSIS_files/figure-html/unnamed-chunk-9-1.png)<!-- -->![](COVID19_DATA_ANALYSIS_files/figure-html/unnamed-chunk-9-2.png)<!-- -->![](COVID19_DATA_ANALYSIS_files/figure-html/unnamed-chunk-9-3.png)<!-- -->![](COVID19_DATA_ANALYSIS_files/figure-html/unnamed-chunk-9-4.png)<!-- -->![](COVID19_DATA_ANALYSIS_files/figure-html/unnamed-chunk-9-5.png)<!-- -->![](COVID19_DATA_ANALYSIS_files/figure-html/unnamed-chunk-9-6.png)<!-- -->![](COVID19_DATA_ANALYSIS_files/figure-html/unnamed-chunk-9-7.png)<!-- -->![](COVID19_DATA_ANALYSIS_files/figure-html/unnamed-chunk-9-8.png)<!-- -->![](COVID19_DATA_ANALYSIS_files/figure-html/unnamed-chunk-9-9.png)<!-- -->





---

### Interactive Time Series Plots - Fatal and Active cases

With 4 statuses (confirmed, fatal, recovered, and active cases), 3 types of plots (count, percentage, and new cases), and 2 scales (linear and log), we have about 24 types of plots to consider. To make sense of data in a 2D plot that fits a computer screen, the human eye needs it to be more-or-less of the same scale, so countries with huge disparities would not be able to be easily compared. Moreover, we can only choose about 5 countries per plot before it gets too busy. I could choose the top five countries and plot all 24 plots, but that leads to information overload. 

I this section I plot the top five countries for active and fatal cases. Fatal is the most relible type of data since there are more protocols involving deaths than confirmation of a virus, and active is a mildly useful way to track how many cases are out there based on this dataset. 


UPDATE - same issue as barplots, information overload. Find better ways to plot (ex: plot count + log in dual axis plot).

<table class="table table-striped table-hover table-condensed" style="width: auto !important; margin-left: auto; margin-right: auto;">
 <thead>
  <tr>
   <th style="text-align:right;"> Num </th>
   <th style="text-align:left;"> Status </th>
   <th style="text-align:left;"> Type </th>
   <th style="text-align:left;"> Scale </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:left;"> Active </td>
   <td style="text-align:left;"> Count </td>
   <td style="text-align:left;"> Linear </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2 </td>
   <td style="text-align:left;"> Active </td>
   <td style="text-align:left;"> Count </td>
   <td style="text-align:left;"> Log </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 3 </td>
   <td style="text-align:left;"> Active </td>
   <td style="text-align:left;"> Pct </td>
   <td style="text-align:left;"> Linear </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 4 </td>
   <td style="text-align:left;"> Active </td>
   <td style="text-align:left;"> Pct </td>
   <td style="text-align:left;"> Log </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 5 </td>
   <td style="text-align:left;"> Active </td>
   <td style="text-align:left;"> NewCases </td>
   <td style="text-align:left;"> Linear </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 6 </td>
   <td style="text-align:left;"> Active </td>
   <td style="text-align:left;"> NewCases </td>
   <td style="text-align:left;"> Log </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 7 </td>
   <td style="text-align:left;"> Fatal </td>
   <td style="text-align:left;"> Count </td>
   <td style="text-align:left;"> Linear </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 8 </td>
   <td style="text-align:left;"> Fatal </td>
   <td style="text-align:left;"> Count </td>
   <td style="text-align:left;"> Log </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 9 </td>
   <td style="text-align:left;"> Fatal </td>
   <td style="text-align:left;"> Pct </td>
   <td style="text-align:left;"> Linear </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 10 </td>
   <td style="text-align:left;"> Fatal </td>
   <td style="text-align:left;"> Pct </td>
   <td style="text-align:left;"> Log </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 11 </td>
   <td style="text-align:left;"> Fatal </td>
   <td style="text-align:left;"> NewCases </td>
   <td style="text-align:left;"> Linear </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 12 </td>
   <td style="text-align:left;"> Fatal </td>
   <td style="text-align:left;"> NewCases </td>
   <td style="text-align:left;"> Log </td>
  </tr>
</tbody>
</table>













<!--html_preserve--><div id="htmlwidget-7f66844aaa23d36fa2fd" style="width:960px;height:500px;" class="dygraphs html-widget"></div>
<script type="application/json" data-for="htmlwidget-7f66844aaa23d36fa2fd">{"x":{"attrs":{"axes":{"x":{"pixelsPerLabel":60,"drawGrid":false,"drawAxis":true},"y":{"drawAxis":true}},"title":"Top Countries - Count Of Fatal Cases","labels":["day","US","Brazil","United Kingdom","Italy","France"],"retainDateWindow":false,"ylabel":"Count Of Fatal Cases","stackedGraph":false,"fillGraph":false,"fillAlpha":0.15,"stepPlot":false,"drawPoints":false,"pointSize":1,"drawGapEdgePoints":false,"connectSeparatedPoints":false,"strokeWidth":1,"strokeBorderColor":"white","colors":["#1B9E77","#D95F02","#7570B3","#E7298A","#66A61E"],"colorValue":0.5,"colorSaturation":1,"includeZero":false,"drawAxesAtZero":false,"logscale":false,"axisTickSize":3,"axisLineColor":"navy","axisLineWidth":1.5,"axisLabelColor":"black","axisLabelFontSize":14,"axisLabelWidth":60,"drawGrid":true,"gridLineColor":"lightblue","gridLineWidth":0.3,"rightGap":5,"digitsAfterDecimal":2,"labelsKMB":false,"labelsKMG2":false,"labelsUTC":false,"maxNumberWidth":6,"animatedZooms":false,"mobileDisableYTouch":true,"disableZoom":false,"showRangeSelector":true,"rangeSelectorHeight":40,"rangeSelectorPlotFillColor":" #A7B1C4","rangeSelectorPlotStrokeColor":"#808FAB","interactionModel":"Dygraph.Interaction.defaultModel","legend":"auto","labelsDivWidth":750,"labelsShowZeroValues":true,"labelsSeparateLines":false,"hideOverlayOnMouseOut":true},"scale":"daily","annotations":[],"shadings":[],"events":[],"format":"date","data":[["2020-01-22T00:00:00.000Z","2020-01-23T00:00:00.000Z","2020-01-24T00:00:00.000Z","2020-01-25T00:00:00.000Z","2020-01-26T00:00:00.000Z","2020-01-27T00:00:00.000Z","2020-01-28T00:00:00.000Z","2020-01-29T00:00:00.000Z","2020-01-30T00:00:00.000Z","2020-01-31T00:00:00.000Z","2020-02-01T00:00:00.000Z","2020-02-02T00:00:00.000Z","2020-02-03T00:00:00.000Z","2020-02-04T00:00:00.000Z","2020-02-05T00:00:00.000Z","2020-02-06T00:00:00.000Z","2020-02-07T00:00:00.000Z","2020-02-08T00:00:00.000Z","2020-02-09T00:00:00.000Z","2020-02-10T00:00:00.000Z","2020-02-11T00:00:00.000Z","2020-02-12T00:00:00.000Z","2020-02-13T00:00:00.000Z","2020-02-14T00:00:00.000Z","2020-02-15T00:00:00.000Z","2020-02-16T00:00:00.000Z","2020-02-17T00:00:00.000Z","2020-02-18T00:00:00.000Z","2020-02-19T00:00:00.000Z","2020-02-20T00:00:00.000Z","2020-02-21T00:00:00.000Z","2020-02-22T00:00:00.000Z","2020-02-23T00:00:00.000Z","2020-02-24T00:00:00.000Z","2020-02-25T00:00:00.000Z","2020-02-26T00:00:00.000Z","2020-02-27T00:00:00.000Z","2020-02-28T00:00:00.000Z","2020-02-29T00:00:00.000Z","2020-03-01T00:00:00.000Z","2020-03-02T00:00:00.000Z","2020-03-03T00:00:00.000Z","2020-03-04T00:00:00.000Z","2020-03-05T00:00:00.000Z","2020-03-06T00:00:00.000Z","2020-03-07T00:00:00.000Z","2020-03-08T00:00:00.000Z","2020-03-09T00:00:00.000Z","2020-03-10T00:00:00.000Z","2020-03-11T00:00:00.000Z","2020-03-12T00:00:00.000Z","2020-03-13T00:00:00.000Z","2020-03-14T00:00:00.000Z","2020-03-15T00:00:00.000Z","2020-03-16T00:00:00.000Z","2020-03-17T00:00:00.000Z","2020-03-18T00:00:00.000Z","2020-03-19T00:00:00.000Z","2020-03-20T00:00:00.000Z","2020-03-21T00:00:00.000Z","2020-03-22T00:00:00.000Z","2020-03-23T00:00:00.000Z","2020-03-24T00:00:00.000Z","2020-03-25T00:00:00.000Z","2020-03-26T00:00:00.000Z","2020-03-27T00:00:00.000Z","2020-03-28T00:00:00.000Z","2020-03-29T00:00:00.000Z","2020-03-30T00:00:00.000Z","2020-03-31T00:00:00.000Z","2020-04-01T00:00:00.000Z","2020-04-02T00:00:00.000Z","2020-04-03T00:00:00.000Z","2020-04-04T00:00:00.000Z","2020-04-05T00:00:00.000Z","2020-04-06T00:00:00.000Z","2020-04-07T00:00:00.000Z","2020-04-08T00:00:00.000Z","2020-04-09T00:00:00.000Z","2020-04-10T00:00:00.000Z","2020-04-11T00:00:00.000Z","2020-04-12T00:00:00.000Z","2020-04-13T00:00:00.000Z","2020-04-14T00:00:00.000Z","2020-04-15T00:00:00.000Z","2020-04-16T00:00:00.000Z","2020-04-17T00:00:00.000Z","2020-04-18T00:00:00.000Z","2020-04-19T00:00:00.000Z","2020-04-20T00:00:00.000Z","2020-04-21T00:00:00.000Z","2020-04-22T00:00:00.000Z","2020-04-23T00:00:00.000Z","2020-04-24T00:00:00.000Z","2020-04-25T00:00:00.000Z","2020-04-26T00:00:00.000Z","2020-04-27T00:00:00.000Z","2020-04-28T00:00:00.000Z","2020-04-29T00:00:00.000Z","2020-04-30T00:00:00.000Z","2020-05-01T00:00:00.000Z","2020-05-02T00:00:00.000Z","2020-05-03T00:00:00.000Z","2020-05-04T00:00:00.000Z","2020-05-05T00:00:00.000Z","2020-05-06T00:00:00.000Z","2020-05-07T00:00:00.000Z","2020-05-08T00:00:00.000Z","2020-05-09T00:00:00.000Z","2020-05-10T00:00:00.000Z","2020-05-11T00:00:00.000Z","2020-05-12T00:00:00.000Z","2020-05-13T00:00:00.000Z","2020-05-14T00:00:00.000Z","2020-05-15T00:00:00.000Z","2020-05-16T00:00:00.000Z","2020-05-17T00:00:00.000Z","2020-05-18T00:00:00.000Z","2020-05-19T00:00:00.000Z","2020-05-20T00:00:00.000Z","2020-05-21T00:00:00.000Z","2020-05-22T00:00:00.000Z","2020-05-23T00:00:00.000Z","2020-05-24T00:00:00.000Z","2020-05-25T00:00:00.000Z","2020-05-26T00:00:00.000Z","2020-05-27T00:00:00.000Z","2020-05-28T00:00:00.000Z","2020-05-29T00:00:00.000Z","2020-05-30T00:00:00.000Z","2020-05-31T00:00:00.000Z","2020-06-01T00:00:00.000Z","2020-06-02T00:00:00.000Z","2020-06-03T00:00:00.000Z","2020-06-04T00:00:00.000Z","2020-06-05T00:00:00.000Z","2020-06-06T00:00:00.000Z","2020-06-07T00:00:00.000Z","2020-06-08T00:00:00.000Z","2020-06-09T00:00:00.000Z","2020-06-10T00:00:00.000Z","2020-06-11T00:00:00.000Z","2020-06-12T00:00:00.000Z","2020-06-13T00:00:00.000Z","2020-06-14T00:00:00.000Z","2020-06-15T00:00:00.000Z","2020-06-16T00:00:00.000Z","2020-06-17T00:00:00.000Z"],[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,6,7,11,12,14,17,21,22,28,32,43,52,59,72,100,134,191,269,366,456,600,784,1019,1329,1736,2284,2921,3546,4352,5568,6787,8349,9646,10912,12323,13985,16290,18369,20415,22486,24498,26238,28036,30429,32944,35031,37621,39966,41148,42918,45314,47649,49969,51746,54015,55162,56502,58632,61252,63291,65243,66668,67990,69237,71387,73775,75986,77495,79122,79856,81018,82709,84452,86229,87862,89084,89893,90683,92252,93775,95020,96296,97406,98039,98541,99239,100744,101937,103113,104054,104659,105430,106461,107444,108479,109449,110124,110575,111068,112014,112935,113823,114669,115436,115732,116127,116963,117717],[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,3,6,11,15,25,34,46,59,77,92,111,136,159,201,240,324,359,445,486,564,686,819,950,1057,1124,1223,1328,1532,1736,1924,2141,2354,2462,2587,2741,2906,3331,3704,4057,4286,4603,5083,5513,6006,6412,6761,7051,7367,7938,8588,9190,10017,10656,11123,11653,12461,13240,13999,14962,15662,16118,16853,17983,18859,20047,21048,22013,22666,23473,24512,25598,26754,27878,28834,29314,29937,31199,32548,34021,35026,35930,36455,37134,38406,39680,40919,41828,42720,43332,43959,45241,46510],[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,2,2,3,7,7,9,10,28,43,66,82,116,159,195,251,286,360,509,695,879,1163,1457,1672,2046,2429,3100,3752,4467,5228,5874,6445,7483,8519,9623,10776,11616,12302,13047,14095,14941,15974,16910,18028,18527,19092,20264,21111,21840,22853,23697,24117,24458,25369,26166,26842,27583,28205,28520,28809,29501,30150,30689,31316,31662,31930,32141,32769,33264,33693,34078,34546,34716,34876,35422,35786,36124,36475,36757,36875,36996,37130,37542,37919,38243,38458,38571,39127,39452,39811,39987,40344,40548,40625,40680,40968,41213,41364,41566,41747,41783,41821,42054,42238],[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,2,3,7,10,12,17,21,29,34,52,79,107,148,197,233,366,463,631,827,1016,1266,1441,1809,2158,2503,2978,3405,4032,4825,5476,6077,6820,7503,8215,9134,10023,10779,11591,12428,13155,13915,14681,15362,15887,16523,17127,17669,18279,18849,19468,19899,20465,21067,21645,22170,22745,23227,23660,24114,24648,25085,25549,25969,26384,26644,26977,27359,27682,27967,28236,28710,28884,29079,29315,29684,29958,30201,30395,30560,30739,30911,31106,31368,31610,31763,31908,32007,32169,32330,32486,32616,32735,32785,32877,32955,33072,33142,33229,33340,33415,33475,33530,33601,33689,33774,33846,33899,33964,34043,34114,34167,34223,34301,34345,34371,34405,34448],[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,2,2,2,2,2,3,4,4,6,9,11,19,19,33,48,48,79,91,91,149,149,149,244,451,563,676,862,1102,1333,1698,1997,2317,2611,3030,3532,4414,5398,6520,7574,8093,8926,10343,10887,12228,13215,13851,14412,14986,15731,17169,17922,18683,19325,19720,20267,20798,21342,21858,22248,22617,22859,23296,23663,24090,24379,24597,24763,24900,25204,25537,25812,25990,26233,26313,26383,26646,26994,27077,27428,27532,27532,28111,28242,28025,28135,28218,28292,28335,28370,28460,28533,28599,28665,28717,28774,28805,28836,28943,29024,29068,29114,29145,29158,29212,29299,29322,29349,29377,29401,29410,29439,29550,29578]],"fixedtz":false,"tzone":"UTC"},"evals":["attrs.interactionModel"],"jsHooks":[]}</script>
<div id="htmlwidget-4fb3749272e657af04b4" style="width:960px;height:500px;" class="dygraphs html-widget"></div>
<script type="application/json" data-for="htmlwidget-4fb3749272e657af04b4">{"x":{"attrs":{"axes":{"x":{"pixelsPerLabel":60,"drawGrid":false,"drawAxis":true},"y":{"drawAxis":true}},"title":"Top Countries - Log Count Of Fatal Cases","labels":["day","US","Brazil","United Kingdom","Italy","France"],"retainDateWindow":false,"ylabel":"Log Count Of Fatal Cases","stackedGraph":false,"fillGraph":false,"fillAlpha":0.15,"stepPlot":false,"drawPoints":false,"pointSize":1,"drawGapEdgePoints":false,"connectSeparatedPoints":false,"strokeWidth":1,"strokeBorderColor":"white","colors":["#1B9E77","#D95F02","#7570B3","#E7298A","#66A61E"],"colorValue":0.5,"colorSaturation":1,"includeZero":false,"drawAxesAtZero":false,"logscale":false,"axisTickSize":3,"axisLineColor":"navy","axisLineWidth":1.5,"axisLabelColor":"black","axisLabelFontSize":14,"axisLabelWidth":60,"drawGrid":true,"gridLineColor":"lightblue","gridLineWidth":0.3,"rightGap":5,"digitsAfterDecimal":2,"labelsKMB":false,"labelsKMG2":false,"labelsUTC":false,"maxNumberWidth":6,"animatedZooms":false,"mobileDisableYTouch":true,"disableZoom":false,"showRangeSelector":true,"rangeSelectorHeight":40,"rangeSelectorPlotFillColor":" #A7B1C4","rangeSelectorPlotStrokeColor":"#808FAB","interactionModel":"Dygraph.Interaction.defaultModel","legend":"auto","labelsDivWidth":750,"labelsShowZeroValues":true,"labelsSeparateLines":false,"hideOverlayOnMouseOut":true},"scale":"daily","annotations":[],"shadings":[],"events":[],"format":"date","data":[["2020-01-22T00:00:00.000Z","2020-01-23T00:00:00.000Z","2020-01-24T00:00:00.000Z","2020-01-25T00:00:00.000Z","2020-01-26T00:00:00.000Z","2020-01-27T00:00:00.000Z","2020-01-28T00:00:00.000Z","2020-01-29T00:00:00.000Z","2020-01-30T00:00:00.000Z","2020-01-31T00:00:00.000Z","2020-02-01T00:00:00.000Z","2020-02-02T00:00:00.000Z","2020-02-03T00:00:00.000Z","2020-02-04T00:00:00.000Z","2020-02-05T00:00:00.000Z","2020-02-06T00:00:00.000Z","2020-02-07T00:00:00.000Z","2020-02-08T00:00:00.000Z","2020-02-09T00:00:00.000Z","2020-02-10T00:00:00.000Z","2020-02-11T00:00:00.000Z","2020-02-12T00:00:00.000Z","2020-02-13T00:00:00.000Z","2020-02-14T00:00:00.000Z","2020-02-15T00:00:00.000Z","2020-02-16T00:00:00.000Z","2020-02-17T00:00:00.000Z","2020-02-18T00:00:00.000Z","2020-02-19T00:00:00.000Z","2020-02-20T00:00:00.000Z","2020-02-21T00:00:00.000Z","2020-02-22T00:00:00.000Z","2020-02-23T00:00:00.000Z","2020-02-24T00:00:00.000Z","2020-02-25T00:00:00.000Z","2020-02-26T00:00:00.000Z","2020-02-27T00:00:00.000Z","2020-02-28T00:00:00.000Z","2020-02-29T00:00:00.000Z","2020-03-01T00:00:00.000Z","2020-03-02T00:00:00.000Z","2020-03-03T00:00:00.000Z","2020-03-04T00:00:00.000Z","2020-03-05T00:00:00.000Z","2020-03-06T00:00:00.000Z","2020-03-07T00:00:00.000Z","2020-03-08T00:00:00.000Z","2020-03-09T00:00:00.000Z","2020-03-10T00:00:00.000Z","2020-03-11T00:00:00.000Z","2020-03-12T00:00:00.000Z","2020-03-13T00:00:00.000Z","2020-03-14T00:00:00.000Z","2020-03-15T00:00:00.000Z","2020-03-16T00:00:00.000Z","2020-03-17T00:00:00.000Z","2020-03-18T00:00:00.000Z","2020-03-19T00:00:00.000Z","2020-03-20T00:00:00.000Z","2020-03-21T00:00:00.000Z","2020-03-22T00:00:00.000Z","2020-03-23T00:00:00.000Z","2020-03-24T00:00:00.000Z","2020-03-25T00:00:00.000Z","2020-03-26T00:00:00.000Z","2020-03-27T00:00:00.000Z","2020-03-28T00:00:00.000Z","2020-03-29T00:00:00.000Z","2020-03-30T00:00:00.000Z","2020-03-31T00:00:00.000Z","2020-04-01T00:00:00.000Z","2020-04-02T00:00:00.000Z","2020-04-03T00:00:00.000Z","2020-04-04T00:00:00.000Z","2020-04-05T00:00:00.000Z","2020-04-06T00:00:00.000Z","2020-04-07T00:00:00.000Z","2020-04-08T00:00:00.000Z","2020-04-09T00:00:00.000Z","2020-04-10T00:00:00.000Z","2020-04-11T00:00:00.000Z","2020-04-12T00:00:00.000Z","2020-04-13T00:00:00.000Z","2020-04-14T00:00:00.000Z","2020-04-15T00:00:00.000Z","2020-04-16T00:00:00.000Z","2020-04-17T00:00:00.000Z","2020-04-18T00:00:00.000Z","2020-04-19T00:00:00.000Z","2020-04-20T00:00:00.000Z","2020-04-21T00:00:00.000Z","2020-04-22T00:00:00.000Z","2020-04-23T00:00:00.000Z","2020-04-24T00:00:00.000Z","2020-04-25T00:00:00.000Z","2020-04-26T00:00:00.000Z","2020-04-27T00:00:00.000Z","2020-04-28T00:00:00.000Z","2020-04-29T00:00:00.000Z","2020-04-30T00:00:00.000Z","2020-05-01T00:00:00.000Z","2020-05-02T00:00:00.000Z","2020-05-03T00:00:00.000Z","2020-05-04T00:00:00.000Z","2020-05-05T00:00:00.000Z","2020-05-06T00:00:00.000Z","2020-05-07T00:00:00.000Z","2020-05-08T00:00:00.000Z","2020-05-09T00:00:00.000Z","2020-05-10T00:00:00.000Z","2020-05-11T00:00:00.000Z","2020-05-12T00:00:00.000Z","2020-05-13T00:00:00.000Z","2020-05-14T00:00:00.000Z","2020-05-15T00:00:00.000Z","2020-05-16T00:00:00.000Z","2020-05-17T00:00:00.000Z","2020-05-18T00:00:00.000Z","2020-05-19T00:00:00.000Z","2020-05-20T00:00:00.000Z","2020-05-21T00:00:00.000Z","2020-05-22T00:00:00.000Z","2020-05-23T00:00:00.000Z","2020-05-24T00:00:00.000Z","2020-05-25T00:00:00.000Z","2020-05-26T00:00:00.000Z","2020-05-27T00:00:00.000Z","2020-05-28T00:00:00.000Z","2020-05-29T00:00:00.000Z","2020-05-30T00:00:00.000Z","2020-05-31T00:00:00.000Z","2020-06-01T00:00:00.000Z","2020-06-02T00:00:00.000Z","2020-06-03T00:00:00.000Z","2020-06-04T00:00:00.000Z","2020-06-05T00:00:00.000Z","2020-06-06T00:00:00.000Z","2020-06-07T00:00:00.000Z","2020-06-08T00:00:00.000Z","2020-06-09T00:00:00.000Z","2020-06-10T00:00:00.000Z","2020-06-11T00:00:00.000Z","2020-06-12T00:00:00.000Z","2020-06-13T00:00:00.000Z","2020-06-14T00:00:00.000Z","2020-06-15T00:00:00.000Z","2020-06-16T00:00:00.000Z","2020-06-17T00:00:00.000Z"],[null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,0,0,1.79175946922805,1.94591014905531,2.39789527279837,2.484906649788,2.63905732961526,2.83321334405622,3.04452243772342,3.09104245335832,3.3322045101752,3.46573590279973,3.76120011569356,3.95124371858143,4.07753744390572,4.27666611901606,4.60517018598809,4.89783979995091,5.25227342804663,5.59471137960184,5.90263333340137,6.12249280951439,6.39692965521615,6.66440902035041,6.92657703322272,7.19218205871325,7.4593388952203,7.7336835707759,7.97968130238774,8.17357548663415,8.37839078853578,8.62479120201426,8.82276429670376,9.029897050194,9.17429860062892,9.29761838008324,9.41922271393812,9.54574060563606,9.69830670159609,9.81841974014606,9.92402520375368,10.0206481723097,10.1063467605476,10.174964020641,10.2412446776202,10.3231513800441,10.4025644292676,10.4639886627438,10.5353176841073,10.5957843716412,10.6249306022509,10.6670465973364,10.7213713144974,10.7716169225033,10.8191580921308,10.8541024134542,10.8970170647511,10.918029589408,10.9420313147381,10.9790359016057,11.0227517809351,11.0554984179289,11.0858740397366,11.1074803566621,11.1271159145205,11.1452906807952,11.1758710589213,11.2087751998111,11.2383043917733,11.2579686971312,11.2787462440358,11.2879802917094,11.3024266311891,11.3230837021764,11.343938604608,11.3647618269871,11.3835226807581,11.3973350238207,11.4063753531345,11.4151251874443,11.4322792418846,11.4486535749501,11.4618426747409,11.4751820600596,11.486643089376,11.4931206376716,11.4982279842096,11.5052863611729,11.5203379246857,11.5321102543851,11.5435807532298,11.5526652741391,11.5584627251318,11.565802504571,11.575533999882,11.584725060586,11.5943118848426,11.6032139663172,11.609362282607,11.6134493027365,11.6178979053366,11.6263791424654,11.6345677109523,11.6423998892162,11.6498049963176,11.6564715428128,11.6590324522965,11.6624396987881,11.6696129244495,11.6760387178229],[null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,0,1.09861228866811,1.79175946922805,2.39789527279837,2.70805020110221,3.2188758248682,3.52636052461616,3.8286413964891,4.07753744390572,4.34380542185368,4.52178857704904,4.70953020131233,4.91265488573605,5.06890420222023,5.30330490805908,5.48063892334199,5.78074351579233,5.88332238848828,6.09807428216624,6.18620862390049,6.33505425149806,6.53087762772588,6.70808408385307,6.85646198459459,6.96318998587024,7.02464903045364,7.10906213568717,7.19142933003638,7.33432935030054,7.4593388952203,7.56216163122565,7.66902828858968,7.76387128782022,7.8087293067444,7.85825418218603,7.91607809630279,7.97453284413023,8.11102783819368,8.21716859576607,8.30819906320645,8.36310917603352,8.43446354381724,8.5336569174469,8.61486421858968,8.70051424854327,8.76592651372944,8.81892608709068,8.86092472971904,8.90476584668281,8.97941663334301,9.05812115899867,9.12587121534973,9.21203892861176,9.27387839278017,9.31677031559203,9.36331893657326,9.43035904594287,9.490997829491,9.54674117747482,9.61326893243235,9.65899267531088,9.68769193888446,9.73228396147602,9.7971821461652,9.84474553251236,9.90583479560448,9.95456082272013,9.99938846691333,10.0286212832929,10.0636061034289,10.1069180725403,10.1502695024157,10.1944392738555,10.2355931262898,10.2693105253718,10.2858204965872,10.3068504525524,10.3481413220019,10.3904712018165,10.4347332599917,10.4638459218326,10.4893278801076,10.5038339022405,10.5222882709674,10.5559689763701,10.5886025613988,10.6193497818393,10.6413212507185,10.6624224736341,10.6766466710655,10.6910126603061,10.7197590343182,10.7474226222181],[null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,0,0.693147180559945,0.693147180559945,1.09861228866811,1.94591014905531,1.94591014905531,2.19722457733622,2.30258509299405,3.3322045101752,3.76120011569356,4.18965474202643,4.40671924726425,4.75359019110636,5.06890420222023,5.27299955856375,5.52545293913178,5.65599181081985,5.88610403145016,6.23244801655052,6.54391184556479,6.77878489768518,7.05875815251866,7.2841348061952,7.42177579364465,7.62364194651157,7.79523492900217,8.03915739047324,8.23004431012611,8.40447232135212,8.56178407474411,8.67829111175856,8.77105991537329,8.92038906008036,9.05005424204284,9.1719113453564,9.2850767180902,9.36013873706458,9.41751712976831,9.47631350126575,9.55357540354821,9.61186439085109,9.67871767947733,9.73566044189263,9.79968138381054,9.82698440655001,9.85702467812579,9.91660119168151,9.95754951063466,9.99149842985884,10.0368376787329,10.0731037368325,10.0906722649961,10.1047126397493,10.1412832351827,10.1722161370708,10.1977231039578,10.224954919906,10.2472545461741,10.2583608745282,10.2684431173061,10.2921794400585,10.3139402021553,10.3316595631794,10.3518844280278,10.3628725026337,10.3713012857088,10.3778877526843,10.3972382255117,10.4122310100978,10.4250453796311,10.4364072937752,10.4500470482532,10.4549559547641,10.4595541925477,10.4750883750166,10.4853120344518,10.4947127433707,10.504382373391,10.5120839626932,10.5152890936421,10.5185650776742,10.5221805471711,10.5332155852264,10.5432075847132,10.551715815971,10.5573220157105,10.5602559777524,10.5745680447468,10.5828400220739,10.5918985349956,10.5963096802721,10.6051979637566,10.6102417365023,10.612138919632,10.6134918501625,10.6205465531424,10.6265090195478,10.6301662163049,10.635037804379,10.6393828714098,10.640244837224,10.6411538847006,10.6467097857284,10.6510755687743],[null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,0,0.693147180559945,1.09861228866811,1.94591014905531,2.30258509299405,2.484906649788,2.83321334405622,3.04452243772342,3.36729582998647,3.52636052461616,3.95124371858143,4.36944785246702,4.67282883446191,4.99721227376411,5.28320372873799,5.4510384535657,5.90263333340137,6.13772705408623,6.44730586254121,6.71780469502369,6.92362862813843,7.14361760270412,7.27309259599952,7.50052948539529,7.67693714581808,7.82524529143177,7.99900721324395,8.13300021858361,8.3020178097512,8.48156601377309,8.60813018640834,8.71226643213535,8.82761475083751,8.92305821954573,9.01371703047137,9.11975899374495,9.21263773102487,9.28535507578163,9.35798421388875,9.42770727051294,9.48455719347439,9.54072267395999,9.59430941973946,9.63965220655863,9.67325644372002,9.71250862865099,9.74841144463237,9.77956697061665,9.8135081389166,9.84421514107106,9.87652737095335,9.89842475819367,9.9264713889265,9.95546311412647,9.98252975987608,10.0064953026104,10.0321006200041,10.0530706740756,10.0715411375324,10.0905478636773,10.1124510402765,10.1300253369184,10.1483534559227,10.164658797947,10.1805130447994,10.1903192635331,10.2027399301026,10.2168008213609,10.2285376614566,10.2387805226673,10.2483530385154,10.2650007731151,10.2710430875711,10.2777715431607,10.2858546093983,10.29836345909,10.3075516797287,10.3156303153975,10.3220334001828,10.3274472432805,10.3332874856591,10.3388673865925,10.3451560056045,10.3535435439722,10.3612288052097,10.3660573693384,10.370612041031,10.3737099078596,10.3787585348883,10.3837508707195,10.3885645062793,10.3925582444991,10.3962001208752,10.3977263726977,10.4005286041315,10.4028982734868,10.4064422819215,10.4085566391897,10.4111782676066,10.4145131563048,10.4167601799452,10.4185541705594,10.4201958394603,10.4223111074132,10.4249266535617,10.4274465546921,10.429576102968,10.4311407944084,10.4330564191193,10.4353797104138,10.4374631362008,10.4390155449425,10.440653211634,10.442929787248,10.444211726648,10.4449684645617,10.4459571816366,10.4472062196041],[null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,0,0,0,0,0,0,0,0,0,0,0,0.693147180559945,0.693147180559945,0.693147180559945,0.693147180559945,0.693147180559945,1.09861228866811,1.38629436111989,1.38629436111989,1.79175946922805,2.19722457733622,2.39789527279837,2.94443897916644,2.94443897916644,3.49650756146648,3.87120101090789,3.87120101090789,4.36944785246702,4.51085950651685,4.51085950651685,5.00394630594546,5.00394630594546,5.00394630594546,5.4971682252932,6.11146733950268,6.33327962813969,6.51619307604296,6.75925527066369,7.00488198971286,7.19518732017871,7.43720636687129,7.59940133341582,7.74802852443238,7.86748856869913,8.01631789850341,8.16961956172385,8.39253658681668,8.59378379357795,8.7826296549207,8.93247660846174,8.9987547694957,9.09672364518921,9.2440652413778,9.29532469588118,9.41148368301073,9.48910782703839,9.5361127111751,9.57581647186798,9.61487171092426,9.6633885668225,9.75086071107721,9.79378428744416,9.83536929845984,9.86915487345562,9.88938862815663,9.91674922651931,9.94261210722018,9.96843224117651,9.99232226623662,10.0100073959138,10.0264571148798,10.03710019186,10.0560369509964,10.0716679257751,10.0895520956089,10.1014773849668,10.1103797632643,10.1171058826253,10.1226230824528,10.1347579910619,10.1478836598838,10.1585947790557,10.1654671276355,10.1747734391764,10.1778183926195,10.1804751423224,10.1903943245202,10.2033698980692,10.2064399380238,10.2193196684043,10.2231042435183,10.2231042435183,10.2439162377965,10.2485655106292,10.2408522479404,10.2447696318674,10.2477153511731,10.2503343581559,10.2518530686037,10.2530875278029,10.2562548716438,10.2588165911505,10.2611270311617,10.2634321453425,10.2652445608817,10.267227480597,10.2683042621665,10.2693798855245,10.2730836575634,10.2758783529149,10.2773931917365,10.2789744371246,10.2800386504796,10.2804845966648,10.28233486274,10.2853086647299,10.2860933664982,10.2870137531255,10.2879673342352,10.2887839663538,10.289090031548,10.2900756048746,10.2938390228342,10.2947861207267]],"fixedtz":false,"tzone":"UTC"},"evals":["attrs.interactionModel"],"jsHooks":[]}</script>
<div id="htmlwidget-733f55c2c9bbc7d0363a" style="width:960px;height:500px;" class="dygraphs html-widget"></div>
<script type="application/json" data-for="htmlwidget-733f55c2c9bbc7d0363a">{"x":{"attrs":{"axes":{"x":{"pixelsPerLabel":60,"drawGrid":false,"drawAxis":true},"y":{"drawAxis":true}},"title":"Top Countries - Percentage Of Fatal Cases","labels":["day","US","Brazil","United Kingdom","Italy","France"],"retainDateWindow":false,"ylabel":"Percentage Of Fatal Cases","stackedGraph":false,"fillGraph":false,"fillAlpha":0.15,"stepPlot":false,"drawPoints":false,"pointSize":1,"drawGapEdgePoints":false,"connectSeparatedPoints":false,"strokeWidth":1,"strokeBorderColor":"white","colors":["#1B9E77","#D95F02","#7570B3","#E7298A","#66A61E"],"colorValue":0.5,"colorSaturation":1,"includeZero":false,"drawAxesAtZero":false,"logscale":false,"axisTickSize":3,"axisLineColor":"navy","axisLineWidth":1.5,"axisLabelColor":"black","axisLabelFontSize":14,"axisLabelWidth":60,"drawGrid":true,"gridLineColor":"lightblue","gridLineWidth":0.3,"rightGap":5,"digitsAfterDecimal":2,"labelsKMB":false,"labelsKMG2":false,"labelsUTC":false,"maxNumberWidth":6,"animatedZooms":false,"mobileDisableYTouch":true,"disableZoom":false,"showRangeSelector":true,"rangeSelectorHeight":40,"rangeSelectorPlotFillColor":" #A7B1C4","rangeSelectorPlotStrokeColor":"#808FAB","interactionModel":"Dygraph.Interaction.defaultModel","legend":"auto","labelsDivWidth":750,"labelsShowZeroValues":true,"labelsSeparateLines":false,"hideOverlayOnMouseOut":true},"scale":"daily","annotations":[],"shadings":[],"events":[],"format":"date","data":[["2020-01-22T00:00:00.000Z","2020-01-23T00:00:00.000Z","2020-01-24T00:00:00.000Z","2020-01-25T00:00:00.000Z","2020-01-26T00:00:00.000Z","2020-01-27T00:00:00.000Z","2020-01-28T00:00:00.000Z","2020-01-29T00:00:00.000Z","2020-01-30T00:00:00.000Z","2020-01-31T00:00:00.000Z","2020-02-01T00:00:00.000Z","2020-02-02T00:00:00.000Z","2020-02-03T00:00:00.000Z","2020-02-04T00:00:00.000Z","2020-02-05T00:00:00.000Z","2020-02-06T00:00:00.000Z","2020-02-07T00:00:00.000Z","2020-02-08T00:00:00.000Z","2020-02-09T00:00:00.000Z","2020-02-10T00:00:00.000Z","2020-02-11T00:00:00.000Z","2020-02-12T00:00:00.000Z","2020-02-13T00:00:00.000Z","2020-02-14T00:00:00.000Z","2020-02-15T00:00:00.000Z","2020-02-16T00:00:00.000Z","2020-02-17T00:00:00.000Z","2020-02-18T00:00:00.000Z","2020-02-19T00:00:00.000Z","2020-02-20T00:00:00.000Z","2020-02-21T00:00:00.000Z","2020-02-22T00:00:00.000Z","2020-02-23T00:00:00.000Z","2020-02-24T00:00:00.000Z","2020-02-25T00:00:00.000Z","2020-02-26T00:00:00.000Z","2020-02-27T00:00:00.000Z","2020-02-28T00:00:00.000Z","2020-02-29T00:00:00.000Z","2020-03-01T00:00:00.000Z","2020-03-02T00:00:00.000Z","2020-03-03T00:00:00.000Z","2020-03-04T00:00:00.000Z","2020-03-05T00:00:00.000Z","2020-03-06T00:00:00.000Z","2020-03-07T00:00:00.000Z","2020-03-08T00:00:00.000Z","2020-03-09T00:00:00.000Z","2020-03-10T00:00:00.000Z","2020-03-11T00:00:00.000Z","2020-03-12T00:00:00.000Z","2020-03-13T00:00:00.000Z","2020-03-14T00:00:00.000Z","2020-03-15T00:00:00.000Z","2020-03-16T00:00:00.000Z","2020-03-17T00:00:00.000Z","2020-03-18T00:00:00.000Z","2020-03-19T00:00:00.000Z","2020-03-20T00:00:00.000Z","2020-03-21T00:00:00.000Z","2020-03-22T00:00:00.000Z","2020-03-23T00:00:00.000Z","2020-03-24T00:00:00.000Z","2020-03-25T00:00:00.000Z","2020-03-26T00:00:00.000Z","2020-03-27T00:00:00.000Z","2020-03-28T00:00:00.000Z","2020-03-29T00:00:00.000Z","2020-03-30T00:00:00.000Z","2020-03-31T00:00:00.000Z","2020-04-01T00:00:00.000Z","2020-04-02T00:00:00.000Z","2020-04-03T00:00:00.000Z","2020-04-04T00:00:00.000Z","2020-04-05T00:00:00.000Z","2020-04-06T00:00:00.000Z","2020-04-07T00:00:00.000Z","2020-04-08T00:00:00.000Z","2020-04-09T00:00:00.000Z","2020-04-10T00:00:00.000Z","2020-04-11T00:00:00.000Z","2020-04-12T00:00:00.000Z","2020-04-13T00:00:00.000Z","2020-04-14T00:00:00.000Z","2020-04-15T00:00:00.000Z","2020-04-16T00:00:00.000Z","2020-04-17T00:00:00.000Z","2020-04-18T00:00:00.000Z","2020-04-19T00:00:00.000Z","2020-04-20T00:00:00.000Z","2020-04-21T00:00:00.000Z","2020-04-22T00:00:00.000Z","2020-04-23T00:00:00.000Z","2020-04-24T00:00:00.000Z","2020-04-25T00:00:00.000Z","2020-04-26T00:00:00.000Z","2020-04-27T00:00:00.000Z","2020-04-28T00:00:00.000Z","2020-04-29T00:00:00.000Z","2020-04-30T00:00:00.000Z","2020-05-01T00:00:00.000Z","2020-05-02T00:00:00.000Z","2020-05-03T00:00:00.000Z","2020-05-04T00:00:00.000Z","2020-05-05T00:00:00.000Z","2020-05-06T00:00:00.000Z","2020-05-07T00:00:00.000Z","2020-05-08T00:00:00.000Z","2020-05-09T00:00:00.000Z","2020-05-10T00:00:00.000Z","2020-05-11T00:00:00.000Z","2020-05-12T00:00:00.000Z","2020-05-13T00:00:00.000Z","2020-05-14T00:00:00.000Z","2020-05-15T00:00:00.000Z","2020-05-16T00:00:00.000Z","2020-05-17T00:00:00.000Z","2020-05-18T00:00:00.000Z","2020-05-19T00:00:00.000Z","2020-05-20T00:00:00.000Z","2020-05-21T00:00:00.000Z","2020-05-22T00:00:00.000Z","2020-05-23T00:00:00.000Z","2020-05-24T00:00:00.000Z","2020-05-25T00:00:00.000Z","2020-05-26T00:00:00.000Z","2020-05-27T00:00:00.000Z","2020-05-28T00:00:00.000Z","2020-05-29T00:00:00.000Z","2020-05-30T00:00:00.000Z","2020-05-31T00:00:00.000Z","2020-06-01T00:00:00.000Z","2020-06-02T00:00:00.000Z","2020-06-03T00:00:00.000Z","2020-06-04T00:00:00.000Z","2020-06-05T00:00:00.000Z","2020-06-06T00:00:00.000Z","2020-06-07T00:00:00.000Z","2020-06-08T00:00:00.000Z","2020-06-09T00:00:00.000Z","2020-06-10T00:00:00.000Z","2020-06-11T00:00:00.000Z","2020-06-12T00:00:00.000Z","2020-06-13T00:00:00.000Z","2020-06-14T00:00:00.000Z","2020-06-15T00:00:00.000Z","2020-06-16T00:00:00.000Z","2020-06-17T00:00:00.000Z"],[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0.001,0.001,0.001,0.001,0.001,0.002,0.002,0.003,0.003,0.003,0.004,0.004,0.005,0.006,0.006,0.007,0.008,0.008,0.009,0.009,0.01,0.011,0.012,0.012,0.013,0.013,0.014,0.015,0.016,0.016,0.017,0.017,0.018,0.018,0.019,0.02,0.02,0.021,0.021,0.021,0.022,0.023,0.024,0.024,0.025,0.025,0.025,0.026,0.026,0.027,0.027,0.028,0.028,0.028,0.029,0.029,0.029,0.03,0.03,0.03,0.031,0.031,0.031,0.032,0.032,0.032,0.032,0.033,0.033,0.033,0.034,0.034,0.034,0.034,0.034,0.035,0.035,0.035,0.036,0.036,0.036,0.036,0.036,0.037],[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0.001,0.001,0.001,0.001,0.001,0.001,0.001,0.001,0.001,0.001,0.001,0.001,0.001,0.002,0.002,0.002,0.002,0.002,0.002,0.003,0.003,0.003,0.003,0.003,0.004,0.004,0.004,0.004,0.005,0.005,0.005,0.006,0.006,0.006,0.007,0.007,0.008,0.008,0.008,0.009,0.009,0.01,0.01,0.011,0.011,0.011,0.012,0.012,0.013,0.013,0.014,0.014,0.014,0.015,0.016,0.016,0.017,0.017,0.018,0.018,0.018,0.019,0.02,0.02,0.021,0.021,0.021,0.022,0.022],[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0.001,0.001,0.001,0.001,0.002,0.002,0.003,0.003,0.004,0.005,0.006,0.007,0.008,0.009,0.01,0.011,0.013,0.015,0.016,0.018,0.019,0.02,0.021,0.023,0.024,0.026,0.027,0.028,0.029,0.031,0.032,0.033,0.035,0.036,0.037,0.037,0.039,0.04,0.041,0.042,0.043,0.043,0.044,0.045,0.046,0.047,0.048,0.048,0.049,0.049,0.05,0.051,0.051,0.052,0.053,0.053,0.053,0.054,0.054,0.055,0.055,0.056,0.056,0.056,0.056,0.057,0.058,0.058,0.058,0.059,0.059,0.06,0.061,0.061,0.061,0.062,0.062,0.062,0.062,0.063,0.063,0.063,0.063,0.064,0.064,0.064,0.064],[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0.001,0.001,0.001,0.001,0.002,0.002,0.002,0.003,0.004,0.004,0.005,0.006,0.007,0.008,0.009,0.01,0.011,0.013,0.014,0.015,0.017,0.018,0.02,0.021,0.022,0.023,0.025,0.026,0.027,0.028,0.029,0.03,0.031,0.032,0.033,0.033,0.034,0.035,0.036,0.037,0.038,0.039,0.04,0.041,0.041,0.042,0.043,0.044,0.044,0.045,0.045,0.046,0.047,0.047,0.048,0.048,0.049,0.049,0.049,0.05,0.05,0.051,0.051,0.051,0.052,0.052,0.052,0.053,0.053,0.053,0.054,0.054,0.054,0.054,0.055,0.055,0.055,0.055,0.055,0.055,0.056,0.056,0.056,0.056,0.056,0.056,0.056,0.057,0.057,0.057,0.057,0.057,0.057,0.057,0.057,0.057,0.058,0.058,0.058,0.058,0.058,0.058],[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0.001,0.001,0.001,0.001,0.002,0.002,0.003,0.003,0.004,0.004,0.005,0.005,0.007,0.008,0.01,0.012,0.013,0.014,0.016,0.017,0.019,0.02,0.021,0.022,0.023,0.024,0.027,0.028,0.029,0.03,0.03,0.031,0.032,0.033,0.034,0.034,0.035,0.035,0.036,0.037,0.037,0.038,0.038,0.038,0.038,0.039,0.039,0.04,0.04,0.041,0.041,0.041,0.041,0.042,0.042,0.042,0.043,0.043,0.043,0.044,0.043,0.043,0.044,0.044,0.044,0.044,0.044,0.044,0.044,0.044,0.044,0.044,0.045,0.045,0.045,0.045,0.045,0.045,0.045,0.045,0.045,0.045,0.045,0.045,0.045,0.045,0.045,0.045,0.046,0.046]],"fixedtz":false,"tzone":"UTC"},"evals":["attrs.interactionModel"],"jsHooks":[]}</script>
<div id="htmlwidget-6fab77f4d970987d4bb5" style="width:960px;height:500px;" class="dygraphs html-widget"></div>
<script type="application/json" data-for="htmlwidget-6fab77f4d970987d4bb5">{"x":{"attrs":{"axes":{"x":{"pixelsPerLabel":60,"drawGrid":false,"drawAxis":true},"y":{"drawAxis":true}},"title":"Top Countries - Log Percentage Of Fatal Cases","labels":["day","US","Brazil","United Kingdom","Italy","France"],"retainDateWindow":false,"ylabel":"Log Percentage Of Fatal Cases","stackedGraph":false,"fillGraph":false,"fillAlpha":0.15,"stepPlot":false,"drawPoints":false,"pointSize":1,"drawGapEdgePoints":false,"connectSeparatedPoints":false,"strokeWidth":1,"strokeBorderColor":"white","colors":["#1B9E77","#D95F02","#7570B3","#E7298A","#66A61E"],"colorValue":0.5,"colorSaturation":1,"includeZero":false,"drawAxesAtZero":false,"logscale":false,"axisTickSize":3,"axisLineColor":"navy","axisLineWidth":1.5,"axisLabelColor":"black","axisLabelFontSize":14,"axisLabelWidth":60,"drawGrid":true,"gridLineColor":"lightblue","gridLineWidth":0.3,"rightGap":5,"digitsAfterDecimal":2,"labelsKMB":false,"labelsKMG2":false,"labelsUTC":false,"maxNumberWidth":6,"animatedZooms":false,"mobileDisableYTouch":true,"disableZoom":false,"showRangeSelector":true,"rangeSelectorHeight":40,"rangeSelectorPlotFillColor":" #A7B1C4","rangeSelectorPlotStrokeColor":"#808FAB","interactionModel":"Dygraph.Interaction.defaultModel","legend":"auto","labelsDivWidth":750,"labelsShowZeroValues":true,"labelsSeparateLines":false,"hideOverlayOnMouseOut":true},"scale":"daily","annotations":[],"shadings":[],"events":[],"format":"date","data":[["2020-01-22T00:00:00.000Z","2020-01-23T00:00:00.000Z","2020-01-24T00:00:00.000Z","2020-01-25T00:00:00.000Z","2020-01-26T00:00:00.000Z","2020-01-27T00:00:00.000Z","2020-01-28T00:00:00.000Z","2020-01-29T00:00:00.000Z","2020-01-30T00:00:00.000Z","2020-01-31T00:00:00.000Z","2020-02-01T00:00:00.000Z","2020-02-02T00:00:00.000Z","2020-02-03T00:00:00.000Z","2020-02-04T00:00:00.000Z","2020-02-05T00:00:00.000Z","2020-02-06T00:00:00.000Z","2020-02-07T00:00:00.000Z","2020-02-08T00:00:00.000Z","2020-02-09T00:00:00.000Z","2020-02-10T00:00:00.000Z","2020-02-11T00:00:00.000Z","2020-02-12T00:00:00.000Z","2020-02-13T00:00:00.000Z","2020-02-14T00:00:00.000Z","2020-02-15T00:00:00.000Z","2020-02-16T00:00:00.000Z","2020-02-17T00:00:00.000Z","2020-02-18T00:00:00.000Z","2020-02-19T00:00:00.000Z","2020-02-20T00:00:00.000Z","2020-02-21T00:00:00.000Z","2020-02-22T00:00:00.000Z","2020-02-23T00:00:00.000Z","2020-02-24T00:00:00.000Z","2020-02-25T00:00:00.000Z","2020-02-26T00:00:00.000Z","2020-02-27T00:00:00.000Z","2020-02-28T00:00:00.000Z","2020-02-29T00:00:00.000Z","2020-03-01T00:00:00.000Z","2020-03-02T00:00:00.000Z","2020-03-03T00:00:00.000Z","2020-03-04T00:00:00.000Z","2020-03-05T00:00:00.000Z","2020-03-06T00:00:00.000Z","2020-03-07T00:00:00.000Z","2020-03-08T00:00:00.000Z","2020-03-09T00:00:00.000Z","2020-03-10T00:00:00.000Z","2020-03-11T00:00:00.000Z","2020-03-12T00:00:00.000Z","2020-03-13T00:00:00.000Z","2020-03-14T00:00:00.000Z","2020-03-15T00:00:00.000Z","2020-03-16T00:00:00.000Z","2020-03-17T00:00:00.000Z","2020-03-18T00:00:00.000Z","2020-03-19T00:00:00.000Z","2020-03-20T00:00:00.000Z","2020-03-21T00:00:00.000Z","2020-03-22T00:00:00.000Z","2020-03-23T00:00:00.000Z","2020-03-24T00:00:00.000Z","2020-03-25T00:00:00.000Z","2020-03-26T00:00:00.000Z","2020-03-27T00:00:00.000Z","2020-03-28T00:00:00.000Z","2020-03-29T00:00:00.000Z","2020-03-30T00:00:00.000Z","2020-03-31T00:00:00.000Z","2020-04-01T00:00:00.000Z","2020-04-02T00:00:00.000Z","2020-04-03T00:00:00.000Z","2020-04-04T00:00:00.000Z","2020-04-05T00:00:00.000Z","2020-04-06T00:00:00.000Z","2020-04-07T00:00:00.000Z","2020-04-08T00:00:00.000Z","2020-04-09T00:00:00.000Z","2020-04-10T00:00:00.000Z","2020-04-11T00:00:00.000Z","2020-04-12T00:00:00.000Z","2020-04-13T00:00:00.000Z","2020-04-14T00:00:00.000Z","2020-04-15T00:00:00.000Z","2020-04-16T00:00:00.000Z","2020-04-17T00:00:00.000Z","2020-04-18T00:00:00.000Z","2020-04-19T00:00:00.000Z","2020-04-20T00:00:00.000Z","2020-04-21T00:00:00.000Z","2020-04-22T00:00:00.000Z","2020-04-23T00:00:00.000Z","2020-04-24T00:00:00.000Z","2020-04-25T00:00:00.000Z","2020-04-26T00:00:00.000Z","2020-04-27T00:00:00.000Z","2020-04-28T00:00:00.000Z","2020-04-29T00:00:00.000Z","2020-04-30T00:00:00.000Z","2020-05-01T00:00:00.000Z","2020-05-02T00:00:00.000Z","2020-05-03T00:00:00.000Z","2020-05-04T00:00:00.000Z","2020-05-05T00:00:00.000Z","2020-05-06T00:00:00.000Z","2020-05-07T00:00:00.000Z","2020-05-08T00:00:00.000Z","2020-05-09T00:00:00.000Z","2020-05-10T00:00:00.000Z","2020-05-11T00:00:00.000Z","2020-05-12T00:00:00.000Z","2020-05-13T00:00:00.000Z","2020-05-14T00:00:00.000Z","2020-05-15T00:00:00.000Z","2020-05-16T00:00:00.000Z","2020-05-17T00:00:00.000Z","2020-05-18T00:00:00.000Z","2020-05-19T00:00:00.000Z","2020-05-20T00:00:00.000Z","2020-05-21T00:00:00.000Z","2020-05-22T00:00:00.000Z","2020-05-23T00:00:00.000Z","2020-05-24T00:00:00.000Z","2020-05-25T00:00:00.000Z","2020-05-26T00:00:00.000Z","2020-05-27T00:00:00.000Z","2020-05-28T00:00:00.000Z","2020-05-29T00:00:00.000Z","2020-05-30T00:00:00.000Z","2020-05-31T00:00:00.000Z","2020-06-01T00:00:00.000Z","2020-06-02T00:00:00.000Z","2020-06-03T00:00:00.000Z","2020-06-04T00:00:00.000Z","2020-06-05T00:00:00.000Z","2020-06-06T00:00:00.000Z","2020-06-07T00:00:00.000Z","2020-06-08T00:00:00.000Z","2020-06-09T00:00:00.000Z","2020-06-10T00:00:00.000Z","2020-06-11T00:00:00.000Z","2020-06-12T00:00:00.000Z","2020-06-13T00:00:00.000Z","2020-06-14T00:00:00.000Z","2020-06-15T00:00:00.000Z","2020-06-16T00:00:00.000Z","2020-06-17T00:00:00.000Z"],[null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,-6.90775527898214,-6.90775527898214,-6.90775527898214,-6.90775527898214,-6.90775527898214,-6.21460809842219,-6.21460809842219,-5.80914299031403,-5.80914299031403,-5.80914299031403,-5.52146091786225,-5.52146091786225,-5.29831736654804,-5.11599580975408,-5.11599580975408,-4.96184512992682,-4.8283137373023,-4.8283137373023,-4.71053070164592,-4.71053070164592,-4.60517018598809,-4.50986000618377,-4.42284862919414,-4.42284862919414,-4.3428059215206,-4.3428059215206,-4.26869794936688,-4.19970507787993,-4.13516655674236,-4.13516655674236,-4.07454193492592,-4.07454193492592,-4.01738352108597,-4.01738352108597,-3.9633162998157,-3.91202300542815,-3.91202300542815,-3.86323284125871,-3.86323284125871,-3.86323284125871,-3.81671282562382,-3.77226106305299,-3.72970144863419,-3.72970144863419,-3.68887945411394,-3.68887945411394,-3.68887945411394,-3.64965874096066,-3.64965874096066,-3.61191841297781,-3.61191841297781,-3.57555076880693,-3.57555076880693,-3.57555076880693,-3.54045944899566,-3.54045944899566,-3.54045944899566,-3.50655789731998,-3.50655789731998,-3.50655789731998,-3.47376807449699,-3.47376807449699,-3.47376807449699,-3.44201937618241,-3.44201937618241,-3.44201937618241,-3.44201937618241,-3.41124771751566,-3.41124771751566,-3.41124771751566,-3.38139475436598,-3.38139475436598,-3.38139475436598,-3.38139475436598,-3.38139475436598,-3.35240721749272,-3.35240721749272,-3.35240721749272,-3.32423634052603,-3.32423634052603,-3.32423634052603,-3.32423634052603,-3.32423634052603,-3.29683736633791],[null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,-6.90775527898214,-6.90775527898214,-6.90775527898214,-6.90775527898214,-6.90775527898214,-6.90775527898214,-6.90775527898214,-6.90775527898214,-6.90775527898214,-6.90775527898214,-6.90775527898214,-6.90775527898214,-6.90775527898214,-6.21460809842219,-6.21460809842219,-6.21460809842219,-6.21460809842219,-6.21460809842219,-6.21460809842219,-5.80914299031403,-5.80914299031403,-5.80914299031403,-5.80914299031403,-5.80914299031403,-5.52146091786225,-5.52146091786225,-5.52146091786225,-5.52146091786225,-5.29831736654804,-5.29831736654804,-5.29831736654804,-5.11599580975408,-5.11599580975408,-5.11599580975408,-4.96184512992682,-4.96184512992682,-4.8283137373023,-4.8283137373023,-4.8283137373023,-4.71053070164592,-4.71053070164592,-4.60517018598809,-4.60517018598809,-4.50986000618377,-4.50986000618377,-4.50986000618377,-4.42284862919414,-4.42284862919414,-4.3428059215206,-4.3428059215206,-4.26869794936688,-4.26869794936688,-4.26869794936688,-4.19970507787993,-4.13516655674236,-4.13516655674236,-4.07454193492592,-4.07454193492592,-4.01738352108597,-4.01738352108597,-4.01738352108597,-3.9633162998157,-3.91202300542815,-3.91202300542815,-3.86323284125871,-3.86323284125871,-3.86323284125871,-3.81671282562382,-3.81671282562382],[null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,-6.90775527898214,-6.90775527898214,-6.90775527898214,-6.90775527898214,-6.21460809842219,-6.21460809842219,-5.80914299031403,-5.80914299031403,-5.52146091786225,-5.29831736654804,-5.11599580975408,-4.96184512992682,-4.8283137373023,-4.71053070164592,-4.60517018598809,-4.50986000618377,-4.3428059215206,-4.19970507787993,-4.13516655674236,-4.01738352108597,-3.9633162998157,-3.91202300542815,-3.86323284125871,-3.77226106305299,-3.72970144863419,-3.64965874096066,-3.61191841297781,-3.57555076880693,-3.54045944899566,-3.47376807449699,-3.44201937618241,-3.41124771751566,-3.35240721749272,-3.32423634052603,-3.29683736633791,-3.29683736633791,-3.24419363285249,-3.2188758248682,-3.19418321227783,-3.17008566069877,-3.14655516328857,-3.14655516328857,-3.12356564506388,-3.10109278921182,-3.07911388249304,-3.05760767727208,-3.03655426807425,-3.03655426807425,-3.01593498087151,-3.01593498087151,-2.99573227355399,-2.97592964625781,-2.97592964625781,-2.95651156040071,-2.93746336543002,-2.93746336543002,-2.93746336543002,-2.91877123241786,-2.91877123241786,-2.90042209374967,-2.90042209374967,-2.88240358824699,-2.88240358824699,-2.88240358824699,-2.88240358824699,-2.86470401114759,-2.84731226843572,-2.84731226843572,-2.84731226843572,-2.83021783507642,-2.83021783507642,-2.81341071676004,-2.79688141480883,-2.79688141480883,-2.79688141480883,-2.78062089393705,-2.78062089393705,-2.78062089393705,-2.78062089393705,-2.7646205525906,-2.7646205525906,-2.7646205525906,-2.7646205525906,-2.74887219562247,-2.74887219562247,-2.74887219562247,-2.74887219562247],[null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,-6.90775527898214,-6.90775527898214,-6.90775527898214,-6.90775527898214,-6.21460809842219,-6.21460809842219,-6.21460809842219,-5.80914299031403,-5.52146091786225,-5.52146091786225,-5.29831736654804,-5.11599580975408,-4.96184512992682,-4.8283137373023,-4.71053070164592,-4.60517018598809,-4.50986000618377,-4.3428059215206,-4.26869794936688,-4.19970507787993,-4.07454193492592,-4.01738352108597,-3.91202300542815,-3.86323284125871,-3.81671282562382,-3.77226106305299,-3.68887945411394,-3.64965874096066,-3.61191841297781,-3.57555076880693,-3.54045944899566,-3.50655789731998,-3.47376807449699,-3.44201937618241,-3.41124771751566,-3.41124771751566,-3.38139475436598,-3.35240721749272,-3.32423634052603,-3.29683736633791,-3.27016911925575,-3.24419363285249,-3.2188758248682,-3.19418321227783,-3.19418321227783,-3.17008566069877,-3.14655516328857,-3.12356564506388,-3.12356564506388,-3.10109278921182,-3.10109278921182,-3.07911388249304,-3.05760767727208,-3.05760767727208,-3.03655426807425,-3.03655426807425,-3.01593498087151,-3.01593498087151,-3.01593498087151,-2.99573227355399,-2.99573227355399,-2.97592964625781,-2.97592964625781,-2.97592964625781,-2.95651156040071,-2.95651156040071,-2.95651156040071,-2.93746336543002,-2.93746336543002,-2.93746336543002,-2.91877123241786,-2.91877123241786,-2.91877123241786,-2.91877123241786,-2.90042209374967,-2.90042209374967,-2.90042209374967,-2.90042209374967,-2.90042209374967,-2.90042209374967,-2.88240358824699,-2.88240358824699,-2.88240358824699,-2.88240358824699,-2.88240358824699,-2.88240358824699,-2.88240358824699,-2.86470401114759,-2.86470401114759,-2.86470401114759,-2.86470401114759,-2.86470401114759,-2.86470401114759,-2.86470401114759,-2.86470401114759,-2.86470401114759,-2.84731226843572,-2.84731226843572,-2.84731226843572,-2.84731226843572,-2.84731226843572,-2.84731226843572],[null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,-6.90775527898214,-6.90775527898214,-6.90775527898214,-6.90775527898214,-6.21460809842219,-6.21460809842219,-5.80914299031403,-5.80914299031403,-5.52146091786225,-5.52146091786225,-5.29831736654804,-5.29831736654804,-4.96184512992682,-4.8283137373023,-4.60517018598809,-4.42284862919414,-4.3428059215206,-4.26869794936688,-4.13516655674236,-4.07454193492592,-3.9633162998157,-3.91202300542815,-3.86323284125871,-3.81671282562382,-3.77226106305299,-3.72970144863419,-3.61191841297781,-3.57555076880693,-3.54045944899566,-3.50655789731998,-3.50655789731998,-3.47376807449699,-3.44201937618241,-3.41124771751566,-3.38139475436598,-3.38139475436598,-3.35240721749272,-3.35240721749272,-3.32423634052603,-3.29683736633791,-3.29683736633791,-3.27016911925575,-3.27016911925575,-3.27016911925575,-3.27016911925575,-3.24419363285249,-3.24419363285249,-3.2188758248682,-3.2188758248682,-3.19418321227783,-3.19418321227783,-3.19418321227783,-3.19418321227783,-3.17008566069877,-3.17008566069877,-3.17008566069877,-3.14655516328857,-3.14655516328857,-3.14655516328857,-3.12356564506388,-3.14655516328857,-3.14655516328857,-3.12356564506388,-3.12356564506388,-3.12356564506388,-3.12356564506388,-3.12356564506388,-3.12356564506388,-3.12356564506388,-3.12356564506388,-3.12356564506388,-3.12356564506388,-3.10109278921182,-3.10109278921182,-3.10109278921182,-3.10109278921182,-3.10109278921182,-3.10109278921182,-3.10109278921182,-3.10109278921182,-3.10109278921182,-3.10109278921182,-3.10109278921182,-3.10109278921182,-3.10109278921182,-3.10109278921182,-3.10109278921182,-3.10109278921182,-3.07911388249304,-3.07911388249304]],"fixedtz":false,"tzone":"UTC"},"evals":["attrs.interactionModel"],"jsHooks":[]}</script>
<div id="htmlwidget-5d705bd04db29ad2eaf6" style="width:960px;height:500px;" class="dygraphs html-widget"></div>
<script type="application/json" data-for="htmlwidget-5d705bd04db29ad2eaf6">{"x":{"attrs":{"axes":{"x":{"pixelsPerLabel":60,"drawGrid":false,"drawAxis":true},"y":{"drawAxis":true}},"title":"Top Countries - New Fatal Cases","labels":["day","US","Brazil","United Kingdom","Italy","France"],"retainDateWindow":false,"ylabel":"New Fatal Cases","stackedGraph":false,"fillGraph":false,"fillAlpha":0.15,"stepPlot":false,"drawPoints":false,"pointSize":1,"drawGapEdgePoints":false,"connectSeparatedPoints":false,"strokeWidth":1,"strokeBorderColor":"white","colors":["#1B9E77","#D95F02","#7570B3","#E7298A","#66A61E"],"colorValue":0.5,"colorSaturation":1,"includeZero":false,"drawAxesAtZero":false,"logscale":false,"axisTickSize":3,"axisLineColor":"navy","axisLineWidth":1.5,"axisLabelColor":"black","axisLabelFontSize":14,"axisLabelWidth":60,"drawGrid":true,"gridLineColor":"lightblue","gridLineWidth":0.3,"rightGap":5,"digitsAfterDecimal":2,"labelsKMB":false,"labelsKMG2":false,"labelsUTC":false,"maxNumberWidth":6,"animatedZooms":false,"mobileDisableYTouch":true,"disableZoom":false,"showRangeSelector":true,"rangeSelectorHeight":40,"rangeSelectorPlotFillColor":" #A7B1C4","rangeSelectorPlotStrokeColor":"#808FAB","interactionModel":"Dygraph.Interaction.defaultModel","legend":"auto","labelsDivWidth":750,"labelsShowZeroValues":true,"labelsSeparateLines":false,"hideOverlayOnMouseOut":true},"scale":"daily","annotations":[],"shadings":[],"events":[],"format":"date","data":[["2020-01-22T00:00:00.000Z","2020-01-23T00:00:00.000Z","2020-01-24T00:00:00.000Z","2020-01-25T00:00:00.000Z","2020-01-26T00:00:00.000Z","2020-01-27T00:00:00.000Z","2020-01-28T00:00:00.000Z","2020-01-29T00:00:00.000Z","2020-01-30T00:00:00.000Z","2020-01-31T00:00:00.000Z","2020-02-01T00:00:00.000Z","2020-02-02T00:00:00.000Z","2020-02-03T00:00:00.000Z","2020-02-04T00:00:00.000Z","2020-02-05T00:00:00.000Z","2020-02-06T00:00:00.000Z","2020-02-07T00:00:00.000Z","2020-02-08T00:00:00.000Z","2020-02-09T00:00:00.000Z","2020-02-10T00:00:00.000Z","2020-02-11T00:00:00.000Z","2020-02-12T00:00:00.000Z","2020-02-13T00:00:00.000Z","2020-02-14T00:00:00.000Z","2020-02-15T00:00:00.000Z","2020-02-16T00:00:00.000Z","2020-02-17T00:00:00.000Z","2020-02-18T00:00:00.000Z","2020-02-19T00:00:00.000Z","2020-02-20T00:00:00.000Z","2020-02-21T00:00:00.000Z","2020-02-22T00:00:00.000Z","2020-02-23T00:00:00.000Z","2020-02-24T00:00:00.000Z","2020-02-25T00:00:00.000Z","2020-02-26T00:00:00.000Z","2020-02-27T00:00:00.000Z","2020-02-28T00:00:00.000Z","2020-02-29T00:00:00.000Z","2020-03-01T00:00:00.000Z","2020-03-02T00:00:00.000Z","2020-03-03T00:00:00.000Z","2020-03-04T00:00:00.000Z","2020-03-05T00:00:00.000Z","2020-03-06T00:00:00.000Z","2020-03-07T00:00:00.000Z","2020-03-08T00:00:00.000Z","2020-03-09T00:00:00.000Z","2020-03-10T00:00:00.000Z","2020-03-11T00:00:00.000Z","2020-03-12T00:00:00.000Z","2020-03-13T00:00:00.000Z","2020-03-14T00:00:00.000Z","2020-03-15T00:00:00.000Z","2020-03-16T00:00:00.000Z","2020-03-17T00:00:00.000Z","2020-03-18T00:00:00.000Z","2020-03-19T00:00:00.000Z","2020-03-20T00:00:00.000Z","2020-03-21T00:00:00.000Z","2020-03-22T00:00:00.000Z","2020-03-23T00:00:00.000Z","2020-03-24T00:00:00.000Z","2020-03-25T00:00:00.000Z","2020-03-26T00:00:00.000Z","2020-03-27T00:00:00.000Z","2020-03-28T00:00:00.000Z","2020-03-29T00:00:00.000Z","2020-03-30T00:00:00.000Z","2020-03-31T00:00:00.000Z","2020-04-01T00:00:00.000Z","2020-04-02T00:00:00.000Z","2020-04-03T00:00:00.000Z","2020-04-04T00:00:00.000Z","2020-04-05T00:00:00.000Z","2020-04-06T00:00:00.000Z","2020-04-07T00:00:00.000Z","2020-04-08T00:00:00.000Z","2020-04-09T00:00:00.000Z","2020-04-10T00:00:00.000Z","2020-04-11T00:00:00.000Z","2020-04-12T00:00:00.000Z","2020-04-13T00:00:00.000Z","2020-04-14T00:00:00.000Z","2020-04-15T00:00:00.000Z","2020-04-16T00:00:00.000Z","2020-04-17T00:00:00.000Z","2020-04-18T00:00:00.000Z","2020-04-19T00:00:00.000Z","2020-04-20T00:00:00.000Z","2020-04-21T00:00:00.000Z","2020-04-22T00:00:00.000Z","2020-04-23T00:00:00.000Z","2020-04-24T00:00:00.000Z","2020-04-25T00:00:00.000Z","2020-04-26T00:00:00.000Z","2020-04-27T00:00:00.000Z","2020-04-28T00:00:00.000Z","2020-04-29T00:00:00.000Z","2020-04-30T00:00:00.000Z","2020-05-01T00:00:00.000Z","2020-05-02T00:00:00.000Z","2020-05-03T00:00:00.000Z","2020-05-04T00:00:00.000Z","2020-05-05T00:00:00.000Z","2020-05-06T00:00:00.000Z","2020-05-07T00:00:00.000Z","2020-05-08T00:00:00.000Z","2020-05-09T00:00:00.000Z","2020-05-10T00:00:00.000Z","2020-05-11T00:00:00.000Z","2020-05-12T00:00:00.000Z","2020-05-13T00:00:00.000Z","2020-05-14T00:00:00.000Z","2020-05-15T00:00:00.000Z","2020-05-16T00:00:00.000Z","2020-05-17T00:00:00.000Z","2020-05-18T00:00:00.000Z","2020-05-19T00:00:00.000Z","2020-05-20T00:00:00.000Z","2020-05-21T00:00:00.000Z","2020-05-22T00:00:00.000Z","2020-05-23T00:00:00.000Z","2020-05-24T00:00:00.000Z","2020-05-25T00:00:00.000Z","2020-05-26T00:00:00.000Z","2020-05-27T00:00:00.000Z","2020-05-28T00:00:00.000Z","2020-05-29T00:00:00.000Z","2020-05-30T00:00:00.000Z","2020-05-31T00:00:00.000Z","2020-06-01T00:00:00.000Z","2020-06-02T00:00:00.000Z","2020-06-03T00:00:00.000Z","2020-06-04T00:00:00.000Z","2020-06-05T00:00:00.000Z","2020-06-06T00:00:00.000Z","2020-06-07T00:00:00.000Z","2020-06-08T00:00:00.000Z","2020-06-09T00:00:00.000Z","2020-06-10T00:00:00.000Z","2020-06-11T00:00:00.000Z","2020-06-12T00:00:00.000Z","2020-06-13T00:00:00.000Z","2020-06-14T00:00:00.000Z","2020-06-15T00:00:00.000Z","2020-06-16T00:00:00.000Z","2020-06-17T00:00:00.000Z"],[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,5,1,4,1,2,3,4,1,6,4,11,9,7,13,28,34,57,78,97,90,144,184,235,310,407,548,637,625,806,1216,1219,1562,1297,1266,1411,1662,2305,2079,2046,2071,2012,1740,1798,2393,2515,2087,2590,2345,1182,1770,2396,2335,2320,1777,2269,1147,1340,2130,2620,2039,1952,1425,1322,1247,2150,2388,2211,1509,1627,734,1162,1691,1743,1777,1633,1222,809,790,1569,1523,1245,1276,1110,633,502,698,1505,1193,1176,941,605,771,1031,983,1035,970,675,451,493,946,921,888,846,767,296,395,836,754],[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,2,3,5,4,10,9,12,13,18,15,19,25,23,42,39,84,35,86,41,78,122,133,131,107,67,99,105,204,204,188,217,213,108,125,154,165,425,373,353,229,317,480,430,493,406,349,290,316,571,650,602,827,639,467,530,808,779,759,963,700,456,735,1130,876,1188,1001,965,653,807,1039,1086,1156,1124,956,480,623,1262,1349,1473,1005,904,525,679,1272,1274,1239,909,892,612,627,1282,1269],[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,0,1,4,0,2,1,18,15,23,16,34,43,36,56,35,74,149,186,184,284,294,215,374,383,671,652,715,761,646,571,1038,1036,1104,1153,840,686,745,1048,846,1033,936,1118,499,565,1172,847,729,1013,844,420,341,911,797,676,741,622,315,289,692,649,539,627,346,268,211,628,495,429,385,468,170,160,546,364,338,351,282,118,121,134,412,377,324,215,113,556,325,359,176,357,204,77,55,288,245,151,202,181,36,38,233,184],[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,4,3,2,5,4,8,5,18,27,28,41,49,36,133,97,168,196,189,250,175,368,349,345,475,427,627,793,651,601,743,683,712,919,889,756,812,837,727,760,766,681,525,636,604,542,610,570,619,431,566,602,578,525,575,482,433,454,534,437,464,420,415,260,333,382,323,285,269,474,174,195,236,369,274,243,194,165,179,172,195,262,242,153,145,99,162,161,156,130,119,50,92,78,117,70,87,111,75,60,55,71,88,85,72,53,65,79,71,53,56,78,44,26,34,43],[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,1,1,0,2,3,2,8,0,14,15,0,31,12,0,58,0,0,95,207,112,113,186,240,231,365,299,320,294,419,502,882,984,1122,1054,519,833,1417,544,1341,987,636,561,574,745,1438,753,761,642,395,547,531,544,516,390,369,242,437,367,427,289,218,166,137,304,333,275,178,243,80,70,263,348,83,351,104,0,579,131,-217,110,83,74,43,35,90,73,66,66,52,57,31,31,107,81,44,46,31,13,54,87,23,27,28,24,9,29,111,28]],"fixedtz":false,"tzone":"UTC"},"evals":["attrs.interactionModel"],"jsHooks":[]}</script>
<div id="htmlwidget-9ab713f1e548b2651b20" style="width:960px;height:500px;" class="dygraphs html-widget"></div>
<script type="application/json" data-for="htmlwidget-9ab713f1e548b2651b20">{"x":{"attrs":{"axes":{"x":{"pixelsPerLabel":60,"drawGrid":false,"drawAxis":true},"y":{"drawAxis":true}},"title":"Top Countries - Log Of New Fatal Cases","labels":["day","US","Brazil","United Kingdom","Italy","France"],"retainDateWindow":false,"ylabel":"Log Of New Fatal Cases","stackedGraph":false,"fillGraph":false,"fillAlpha":0.15,"stepPlot":false,"drawPoints":false,"pointSize":1,"drawGapEdgePoints":false,"connectSeparatedPoints":false,"strokeWidth":1,"strokeBorderColor":"white","colors":["#1B9E77","#D95F02","#7570B3","#E7298A","#66A61E"],"colorValue":0.5,"colorSaturation":1,"includeZero":false,"drawAxesAtZero":false,"logscale":false,"axisTickSize":3,"axisLineColor":"navy","axisLineWidth":1.5,"axisLabelColor":"black","axisLabelFontSize":14,"axisLabelWidth":60,"drawGrid":true,"gridLineColor":"lightblue","gridLineWidth":0.3,"rightGap":5,"digitsAfterDecimal":2,"labelsKMB":false,"labelsKMG2":false,"labelsUTC":false,"maxNumberWidth":6,"animatedZooms":false,"mobileDisableYTouch":true,"disableZoom":false,"showRangeSelector":true,"rangeSelectorHeight":40,"rangeSelectorPlotFillColor":" #A7B1C4","rangeSelectorPlotStrokeColor":"#808FAB","interactionModel":"Dygraph.Interaction.defaultModel","legend":"auto","labelsDivWidth":750,"labelsShowZeroValues":true,"labelsSeparateLines":false,"hideOverlayOnMouseOut":true},"scale":"daily","annotations":[],"shadings":[],"events":[],"format":"date","data":[["2020-01-22T00:00:00.000Z","2020-01-23T00:00:00.000Z","2020-01-24T00:00:00.000Z","2020-01-25T00:00:00.000Z","2020-01-26T00:00:00.000Z","2020-01-27T00:00:00.000Z","2020-01-28T00:00:00.000Z","2020-01-29T00:00:00.000Z","2020-01-30T00:00:00.000Z","2020-01-31T00:00:00.000Z","2020-02-01T00:00:00.000Z","2020-02-02T00:00:00.000Z","2020-02-03T00:00:00.000Z","2020-02-04T00:00:00.000Z","2020-02-05T00:00:00.000Z","2020-02-06T00:00:00.000Z","2020-02-07T00:00:00.000Z","2020-02-08T00:00:00.000Z","2020-02-09T00:00:00.000Z","2020-02-10T00:00:00.000Z","2020-02-11T00:00:00.000Z","2020-02-12T00:00:00.000Z","2020-02-13T00:00:00.000Z","2020-02-14T00:00:00.000Z","2020-02-15T00:00:00.000Z","2020-02-16T00:00:00.000Z","2020-02-17T00:00:00.000Z","2020-02-18T00:00:00.000Z","2020-02-19T00:00:00.000Z","2020-02-20T00:00:00.000Z","2020-02-21T00:00:00.000Z","2020-02-22T00:00:00.000Z","2020-02-23T00:00:00.000Z","2020-02-24T00:00:00.000Z","2020-02-25T00:00:00.000Z","2020-02-26T00:00:00.000Z","2020-02-27T00:00:00.000Z","2020-02-28T00:00:00.000Z","2020-02-29T00:00:00.000Z","2020-03-01T00:00:00.000Z","2020-03-02T00:00:00.000Z","2020-03-03T00:00:00.000Z","2020-03-04T00:00:00.000Z","2020-03-05T00:00:00.000Z","2020-03-06T00:00:00.000Z","2020-03-07T00:00:00.000Z","2020-03-08T00:00:00.000Z","2020-03-09T00:00:00.000Z","2020-03-10T00:00:00.000Z","2020-03-11T00:00:00.000Z","2020-03-12T00:00:00.000Z","2020-03-13T00:00:00.000Z","2020-03-14T00:00:00.000Z","2020-03-15T00:00:00.000Z","2020-03-16T00:00:00.000Z","2020-03-17T00:00:00.000Z","2020-03-18T00:00:00.000Z","2020-03-19T00:00:00.000Z","2020-03-20T00:00:00.000Z","2020-03-21T00:00:00.000Z","2020-03-22T00:00:00.000Z","2020-03-23T00:00:00.000Z","2020-03-24T00:00:00.000Z","2020-03-25T00:00:00.000Z","2020-03-26T00:00:00.000Z","2020-03-27T00:00:00.000Z","2020-03-28T00:00:00.000Z","2020-03-29T00:00:00.000Z","2020-03-30T00:00:00.000Z","2020-03-31T00:00:00.000Z","2020-04-01T00:00:00.000Z","2020-04-02T00:00:00.000Z","2020-04-03T00:00:00.000Z","2020-04-04T00:00:00.000Z","2020-04-05T00:00:00.000Z","2020-04-06T00:00:00.000Z","2020-04-07T00:00:00.000Z","2020-04-08T00:00:00.000Z","2020-04-09T00:00:00.000Z","2020-04-10T00:00:00.000Z","2020-04-11T00:00:00.000Z","2020-04-12T00:00:00.000Z","2020-04-13T00:00:00.000Z","2020-04-14T00:00:00.000Z","2020-04-15T00:00:00.000Z","2020-04-16T00:00:00.000Z","2020-04-17T00:00:00.000Z","2020-04-18T00:00:00.000Z","2020-04-19T00:00:00.000Z","2020-04-20T00:00:00.000Z","2020-04-21T00:00:00.000Z","2020-04-22T00:00:00.000Z","2020-04-23T00:00:00.000Z","2020-04-24T00:00:00.000Z","2020-04-25T00:00:00.000Z","2020-04-26T00:00:00.000Z","2020-04-27T00:00:00.000Z","2020-04-28T00:00:00.000Z","2020-04-29T00:00:00.000Z","2020-04-30T00:00:00.000Z","2020-05-01T00:00:00.000Z","2020-05-02T00:00:00.000Z","2020-05-03T00:00:00.000Z","2020-05-04T00:00:00.000Z","2020-05-05T00:00:00.000Z","2020-05-06T00:00:00.000Z","2020-05-07T00:00:00.000Z","2020-05-08T00:00:00.000Z","2020-05-09T00:00:00.000Z","2020-05-10T00:00:00.000Z","2020-05-11T00:00:00.000Z","2020-05-12T00:00:00.000Z","2020-05-13T00:00:00.000Z","2020-05-14T00:00:00.000Z","2020-05-15T00:00:00.000Z","2020-05-16T00:00:00.000Z","2020-05-17T00:00:00.000Z","2020-05-18T00:00:00.000Z","2020-05-19T00:00:00.000Z","2020-05-20T00:00:00.000Z","2020-05-21T00:00:00.000Z","2020-05-22T00:00:00.000Z","2020-05-23T00:00:00.000Z","2020-05-24T00:00:00.000Z","2020-05-25T00:00:00.000Z","2020-05-26T00:00:00.000Z","2020-05-27T00:00:00.000Z","2020-05-28T00:00:00.000Z","2020-05-29T00:00:00.000Z","2020-05-30T00:00:00.000Z","2020-05-31T00:00:00.000Z","2020-06-01T00:00:00.000Z","2020-06-02T00:00:00.000Z","2020-06-03T00:00:00.000Z","2020-06-04T00:00:00.000Z","2020-06-05T00:00:00.000Z","2020-06-06T00:00:00.000Z","2020-06-07T00:00:00.000Z","2020-06-08T00:00:00.000Z","2020-06-09T00:00:00.000Z","2020-06-10T00:00:00.000Z","2020-06-11T00:00:00.000Z","2020-06-12T00:00:00.000Z","2020-06-13T00:00:00.000Z","2020-06-14T00:00:00.000Z","2020-06-15T00:00:00.000Z","2020-06-16T00:00:00.000Z","2020-06-17T00:00:00.000Z"],[null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,0,null,1.6094379124341,0,1.38629436111989,0,0.693147180559945,1.09861228866811,1.38629436111989,0,1.79175946922805,1.38629436111989,2.39789527279837,2.19722457733622,1.94591014905531,2.56494935746154,3.3322045101752,3.52636052461616,4.04305126783455,4.35670882668959,4.57471097850338,4.49980967033027,4.969813299576,5.21493575760899,5.45958551414416,5.73657229747919,6.00881318544259,6.30627528694802,6.45676965557216,6.4377516497364,6.69208374250663,7.10332206252611,7.10578612948127,7.35372233039963,7.16780918431644,7.14361760270412,7.25205395185281,7.41577697541539,7.74283595543075,7.63964228785801,7.62364194651157,7.63578686139558,7.60688453121963,7.46164039220858,7.49443021503157,7.78030308790837,7.83002808253384,7.6434829070772,7.85941315469358,7.76004068088038,7.07496319796604,7.47873482556787,7.78155595923534,7.755767170103,7.74932246466036,7.48268182815465,7.72709448477984,7.04490511712937,7.20042489294496,7.66387725870347,7.87092959675514,7.62021477057445,7.57660976697304,7.26192709270275,7.18690102041163,7.12849594568004,7.67322312112171,7.77821147451249,7.70120018085745,7.31920245876785,7.39449310721904,6.59850902861452,7.05789793741186,7.43307534889858,7.46336304552002,7.48268182815465,7.39817409297047,7.10824413973154,6.69579891705849,6.67203294546107,7.35819375273303,7.32843735289516,7.12689080889881,7.15148546390474,7.01211529430638,6.45047042214418,6.21860011969173,6.54821910276237,7.31654817718298,7.08422642209792,7.06987412845857,6.84694313958538,6.40522845803084,6.64768837356333,6.93828448401696,6.89060912014717,6.94215670569947,6.87729607149743,6.51471269087253,6.11146733950268,6.20050917404269,6.85224256905188,6.82546003625531,6.78897174299217,6.74051935960622,6.64248680136726,5.69035945432406,5.97888576490112,6.7286286130847,6.62539236800796],[null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,0,0.693147180559945,1.09861228866811,1.6094379124341,1.38629436111989,2.30258509299405,2.19722457733622,2.484906649788,2.56494935746154,2.89037175789616,2.70805020110221,2.94443897916644,3.2188758248682,3.13549421592915,3.73766961828337,3.66356164612965,4.43081679884331,3.55534806148941,4.45434729625351,3.71357206670431,4.35670882668959,4.80402104473326,4.89034912822175,4.87519732320115,4.67282883446191,4.20469261939097,4.59511985013459,4.65396035015752,5.31811999384422,5.31811999384422,5.23644196282995,5.37989735354046,5.36129216570943,4.68213122712422,4.8283137373023,5.03695260241363,5.10594547390058,6.05208916892442,5.92157841964382,5.8664680569333,5.43372200355424,5.75890177387728,6.17378610390194,6.06378520868761,6.20050917404269,6.00635315960173,5.85507192220243,5.66988092298052,5.75574221358691,6.34738920965601,6.47697236288968,6.40025744530882,6.71780469502369,6.45990445437753,6.1463292576689,6.27287700654617,6.69456205852109,6.65801104587075,6.63200177739563,6.87005341179813,6.5510803350434,6.12249280951439,6.59987049921284,7.02997291170639,6.77536609093639,7.08002649992259,6.90875477931522,6.87212810133899,6.48157712927643,6.69332366826995,6.94601399109923,6.99025650049388,7.05272104923232,7.02464903045364,6.8627579130514,6.17378610390194,6.43454651878745,7.14045304310116,7.20711885620776,7.29505641646263,6.91274282049318,6.80682936039218,6.26339826259162,6.5206211275587,7.14834574390007,7.14991683613211,7.12205988162914,6.81234509417748,6.79346613258001,6.41673228251233,6.44094654063292,7.15617663748062,7.14598446771439],[null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,0,0,null,0,1.38629436111989,null,0.693147180559945,0,2.89037175789616,2.70805020110221,3.13549421592915,2.77258872223978,3.52636052461616,3.76120011569356,3.58351893845611,4.02535169073515,3.55534806148941,4.30406509320417,5.00394630594546,5.2257466737132,5.21493575760899,5.64897423816121,5.68357976733868,5.37063802812766,5.92425579741453,5.94803498918065,6.50876913697168,6.48004456192665,6.57228254269401,6.63463335786169,6.4707995037826,6.34738920965601,6.94505106372583,6.94312242281943,7.00669522683704,7.05012252026906,6.73340189183736,6.53087762772588,6.61338421837956,6.95463886488099,6.74051935960622,6.94022246911964,6.84161547647759,7.01929665371504,6.21260609575152,6.33682573114644,7.06646697013696,6.74170069465205,6.59167373200866,6.92067150424868,6.73815249459596,6.04025471127741,5.83188247728352,6.81454289725996,6.68085467879022,6.51619307604296,6.60800062529609,6.43294009273918,5.75257263882563,5.66642668811243,6.53958595561767,6.47543271670409,6.289715570909,6.44094654063292,5.84643877505772,5.59098698051086,5.35185813347607,6.4425401664682,6.20455776256869,6.06145691892802,5.95324333428778,6.14846829591765,5.13579843705026,5.07517381523383,6.30261897574491,5.89715386763674,5.82304589548302,5.86078622346587,5.64190707093811,4.77068462446567,4.79579054559674,4.89783979995091,6.02102334934953,5.93224518744801,5.78074351579233,5.37063802812766,4.72738781871234,6.32076829425058,5.78382518232974,5.88332238848828,5.17048399503815,5.87773578177964,5.31811999384422,4.34380542185368,4.00733318523247,5.66296048013595,5.50125821054473,5.01727983681492,5.30826769740121,5.19849703126583,3.58351893845611,3.63758615972639,5.4510384535657,5.21493575760899],[null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,0,0,0,1.38629436111989,1.09861228866811,0.693147180559945,1.6094379124341,1.38629436111989,2.07944154167984,1.6094379124341,2.89037175789616,3.29583686600433,3.3322045101752,3.71357206670431,3.89182029811063,3.58351893845611,4.89034912822175,4.57471097850338,5.12396397940326,5.27811465923052,5.24174701505964,5.52146091786225,5.16478597392351,5.90808293816893,5.85507192220243,5.84354441703136,6.16331480403464,6.05678401322862,6.44094654063292,6.67582322163485,6.47850964220857,6.39859493453521,6.61069604471776,6.52649485957079,6.56807791141198,6.82328612235569,6.7900972355139,6.62804137617953,6.69950034016168,6.72982407048948,6.58892647753352,6.63331843328038,6.64118216974059,6.52356230614951,6.26339826259162,6.45519856334012,6.40357419793482,6.29526600143965,6.41345895716736,6.3456363608286,6.4281052726846,6.06610809010375,6.33859407820318,6.40025744530882,6.35957386867238,6.26339826259162,6.35437004079735,6.1779441140506,6.07073772800249,6.11809719804135,6.2803958389602,6.07993319509559,6.13988455222626,6.04025471127741,6.0282785202307,5.56068163101553,5.80814248998044,5.94542060860658,5.77765232322266,5.65248918026865,5.59471137960184,6.16120732169508,5.15905529921453,5.27299955856375,5.46383180502561,5.91079664404053,5.61312810638807,5.49306144334055,5.26785815906333,5.10594547390058,5.18738580584075,5.14749447681345,5.27299955856375,5.5683445037611,5.48893772615669,5.03043792139244,4.97673374242057,4.59511985013459,5.08759633523238,5.08140436498446,5.04985600724954,4.86753445045558,4.77912349311153,3.91202300542815,4.52178857704904,4.35670882668959,4.76217393479776,4.24849524204936,4.46590811865458,4.70953020131233,4.31748811353631,4.0943445622221,4.00733318523247,4.26267987704132,4.47733681447821,4.44265125649032,4.27666611901606,3.97029191355212,4.17438726989564,4.36944785246702,4.26267987704132,3.97029191355212,4.02535169073515,4.35670882668959,3.78418963391826,3.25809653802148,3.52636052461616,3.76120011569356],[null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,0,null,null,null,null,null,null,null,null,null,null,0,null,null,null,null,0,0,null,0.693147180559945,1.09861228866811,0.693147180559945,2.07944154167984,null,2.63905732961526,2.70805020110221,null,3.43398720448515,2.484906649788,null,4.06044301054642,null,null,4.55387689160054,5.33271879326537,4.71849887129509,4.72738781871234,5.2257466737132,5.48063892334199,5.44241771052179,5.89989735358249,5.70044357339069,5.76832099579377,5.68357976733868,6.03787091992214,6.21860011969173,6.78219205600679,6.89162589705225,7.02286808608264,6.96034772910131,6.25190388316589,6.72503364216684,7.25629723969068,6.29894924685594,7.20117088328168,6.89467003943348,6.45519856334012,6.3297209055227,6.35262939631957,6.61338421837956,7.27100853828099,6.62406522779989,6.63463335786169,6.46458830368996,5.97888576490112,6.30444880242198,6.27476202124194,6.29894924685594,6.24610676548156,5.96614673912369,5.91079664404053,5.48893772615669,6.07993319509559,5.90536184805457,6.05678401322862,5.66642668811243,5.38449506278909,5.11198778835654,4.91998092582813,5.71702770140622,5.80814248998044,5.61677109766657,5.18178355029209,5.49306144334055,4.38202663467388,4.24849524204936,5.57215403217776,5.85220247977447,4.4188406077966,5.86078622346587,4.64439089914137,null,6.361302477573,4.87519732320115,null,4.70048036579242,4.4188406077966,4.30406509320417,3.76120011569356,3.55534806148941,4.49980967033027,4.29045944114839,4.18965474202643,4.18965474202643,3.95124371858143,4.04305126783455,3.43398720448515,3.43398720448515,4.67282883446191,4.39444915467244,3.78418963391826,3.8286413964891,3.43398720448515,2.56494935746154,3.98898404656427,4.46590811865458,3.13549421592915,3.29583686600433,3.3322045101752,3.17805383034795,2.19722457733622,3.36729582998647,4.70953020131233,3.3322045101752]],"fixedtz":false,"tzone":"UTC"},"evals":["attrs.interactionModel"],"jsHooks":[]}</script><!--/html_preserve--><!--html_preserve--><div id="htmlwidget-e3eceb8a5ceeccf726ba" style="width:960px;height:500px;" class="dygraphs html-widget"></div>
<script type="application/json" data-for="htmlwidget-e3eceb8a5ceeccf726ba">{"x":{"attrs":{"axes":{"x":{"pixelsPerLabel":60,"drawGrid":false,"drawAxis":true},"y":{"drawAxis":true}},"title":"Top Countries - Count Of Active Cases","labels":["day","US","Brazil","United Kingdom","Russia","India"],"retainDateWindow":false,"ylabel":"Count Of Active Cases","stackedGraph":false,"fillGraph":false,"fillAlpha":0.15,"stepPlot":false,"drawPoints":false,"pointSize":1,"drawGapEdgePoints":false,"connectSeparatedPoints":false,"strokeWidth":1,"strokeBorderColor":"white","colors":["#1B9E77","#D95F02","#7570B3","#E7298A","#66A61E"],"colorValue":0.5,"colorSaturation":1,"includeZero":false,"drawAxesAtZero":false,"logscale":false,"axisTickSize":3,"axisLineColor":"navy","axisLineWidth":1.5,"axisLabelColor":"black","axisLabelFontSize":14,"axisLabelWidth":60,"drawGrid":true,"gridLineColor":"lightblue","gridLineWidth":0.3,"rightGap":5,"digitsAfterDecimal":2,"labelsKMB":false,"labelsKMG2":false,"labelsUTC":false,"maxNumberWidth":6,"animatedZooms":false,"mobileDisableYTouch":true,"disableZoom":false,"showRangeSelector":true,"rangeSelectorHeight":40,"rangeSelectorPlotFillColor":" #A7B1C4","rangeSelectorPlotStrokeColor":"#808FAB","interactionModel":"Dygraph.Interaction.defaultModel","legend":"auto","labelsDivWidth":750,"labelsShowZeroValues":true,"labelsSeparateLines":false,"hideOverlayOnMouseOut":true},"scale":"daily","annotations":[],"shadings":[],"events":[],"format":"date","data":[["2020-01-22T00:00:00.000Z","2020-01-23T00:00:00.000Z","2020-01-24T00:00:00.000Z","2020-01-25T00:00:00.000Z","2020-01-26T00:00:00.000Z","2020-01-27T00:00:00.000Z","2020-01-28T00:00:00.000Z","2020-01-29T00:00:00.000Z","2020-01-30T00:00:00.000Z","2020-01-31T00:00:00.000Z","2020-02-01T00:00:00.000Z","2020-02-02T00:00:00.000Z","2020-02-03T00:00:00.000Z","2020-02-04T00:00:00.000Z","2020-02-05T00:00:00.000Z","2020-02-06T00:00:00.000Z","2020-02-07T00:00:00.000Z","2020-02-08T00:00:00.000Z","2020-02-09T00:00:00.000Z","2020-02-10T00:00:00.000Z","2020-02-11T00:00:00.000Z","2020-02-12T00:00:00.000Z","2020-02-13T00:00:00.000Z","2020-02-14T00:00:00.000Z","2020-02-15T00:00:00.000Z","2020-02-16T00:00:00.000Z","2020-02-17T00:00:00.000Z","2020-02-18T00:00:00.000Z","2020-02-19T00:00:00.000Z","2020-02-20T00:00:00.000Z","2020-02-21T00:00:00.000Z","2020-02-22T00:00:00.000Z","2020-02-23T00:00:00.000Z","2020-02-24T00:00:00.000Z","2020-02-25T00:00:00.000Z","2020-02-26T00:00:00.000Z","2020-02-27T00:00:00.000Z","2020-02-28T00:00:00.000Z","2020-02-29T00:00:00.000Z","2020-03-01T00:00:00.000Z","2020-03-02T00:00:00.000Z","2020-03-03T00:00:00.000Z","2020-03-04T00:00:00.000Z","2020-03-05T00:00:00.000Z","2020-03-06T00:00:00.000Z","2020-03-07T00:00:00.000Z","2020-03-08T00:00:00.000Z","2020-03-09T00:00:00.000Z","2020-03-10T00:00:00.000Z","2020-03-11T00:00:00.000Z","2020-03-12T00:00:00.000Z","2020-03-13T00:00:00.000Z","2020-03-14T00:00:00.000Z","2020-03-15T00:00:00.000Z","2020-03-16T00:00:00.000Z","2020-03-17T00:00:00.000Z","2020-03-18T00:00:00.000Z","2020-03-19T00:00:00.000Z","2020-03-20T00:00:00.000Z","2020-03-21T00:00:00.000Z","2020-03-22T00:00:00.000Z","2020-03-23T00:00:00.000Z","2020-03-24T00:00:00.000Z","2020-03-25T00:00:00.000Z","2020-03-26T00:00:00.000Z","2020-03-27T00:00:00.000Z","2020-03-28T00:00:00.000Z","2020-03-29T00:00:00.000Z","2020-03-30T00:00:00.000Z","2020-03-31T00:00:00.000Z","2020-04-01T00:00:00.000Z","2020-04-02T00:00:00.000Z","2020-04-03T00:00:00.000Z","2020-04-04T00:00:00.000Z","2020-04-05T00:00:00.000Z","2020-04-06T00:00:00.000Z","2020-04-07T00:00:00.000Z","2020-04-08T00:00:00.000Z","2020-04-09T00:00:00.000Z","2020-04-10T00:00:00.000Z","2020-04-11T00:00:00.000Z","2020-04-12T00:00:00.000Z","2020-04-13T00:00:00.000Z","2020-04-14T00:00:00.000Z","2020-04-15T00:00:00.000Z","2020-04-16T00:00:00.000Z","2020-04-17T00:00:00.000Z","2020-04-18T00:00:00.000Z","2020-04-19T00:00:00.000Z","2020-04-20T00:00:00.000Z","2020-04-21T00:00:00.000Z","2020-04-22T00:00:00.000Z","2020-04-23T00:00:00.000Z","2020-04-24T00:00:00.000Z","2020-04-25T00:00:00.000Z","2020-04-26T00:00:00.000Z","2020-04-27T00:00:00.000Z","2020-04-28T00:00:00.000Z","2020-04-29T00:00:00.000Z","2020-04-30T00:00:00.000Z","2020-05-01T00:00:00.000Z","2020-05-02T00:00:00.000Z","2020-05-03T00:00:00.000Z","2020-05-04T00:00:00.000Z","2020-05-05T00:00:00.000Z","2020-05-06T00:00:00.000Z","2020-05-07T00:00:00.000Z","2020-05-08T00:00:00.000Z","2020-05-09T00:00:00.000Z","2020-05-10T00:00:00.000Z","2020-05-11T00:00:00.000Z","2020-05-12T00:00:00.000Z","2020-05-13T00:00:00.000Z","2020-05-14T00:00:00.000Z","2020-05-15T00:00:00.000Z","2020-05-16T00:00:00.000Z","2020-05-17T00:00:00.000Z","2020-05-18T00:00:00.000Z","2020-05-19T00:00:00.000Z","2020-05-20T00:00:00.000Z","2020-05-21T00:00:00.000Z","2020-05-22T00:00:00.000Z","2020-05-23T00:00:00.000Z","2020-05-24T00:00:00.000Z","2020-05-25T00:00:00.000Z","2020-05-26T00:00:00.000Z","2020-05-27T00:00:00.000Z","2020-05-28T00:00:00.000Z","2020-05-29T00:00:00.000Z","2020-05-30T00:00:00.000Z","2020-05-31T00:00:00.000Z","2020-06-01T00:00:00.000Z","2020-06-02T00:00:00.000Z","2020-06-03T00:00:00.000Z","2020-06-04T00:00:00.000Z","2020-06-05T00:00:00.000Z","2020-06-06T00:00:00.000Z","2020-06-07T00:00:00.000Z","2020-06-08T00:00:00.000Z","2020-06-09T00:00:00.000Z","2020-06-10T00:00:00.000Z","2020-06-11T00:00:00.000Z","2020-06-12T00:00:00.000Z","2020-06-13T00:00:00.000Z","2020-06-14T00:00:00.000Z","2020-06-15T00:00:00.000Z","2020-06-16T00:00:00.000Z","2020-06-17T00:00:00.000Z"],[1,1,2,2,5,5,5,5,5,7,8,8,11,11,11,11,11,11,8,8,9,9,10,10,10,10,10,10,10,10,10,10,10,10,9,9,10,9,16,22,40,59,86,155,201,313,423,490,675,1069,1506,2093,2799,2884,4243,5990,8618,13763,18966,25186,32978,42883,52741,64354,81663,99101,118061,134983,152694,176109,198933,227243,257182,284135,307802,333644,359939,387758,418617,446667,472190,497291,510292,530653,552934,579538,605830,625511,644890,668469,688695,712399,741445,757083,786442,806367,823067,840950,860954,855429,877571,893974,913469,927669,947093,969842,990387,1012078,1022650,1038059,1039211,1061918,1068227,1091083,1110417,1116667,1130973,1140978,1153693,1170862,1191048,1162192,1171805,1186464,1192511,1204916,1215171,1228331,1245188,1258478,1249705,1252815,1267038,1270546,1285062,1302699,1315565,1327367,1332191,1342999,1354263,1369475,1386931,1402484,1416510,1421565,1437265,1453382],[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,2,2,2,2,4,4,13,13,20,25,31,38,52,151,151,162,199,318,367,613,780,1004,1519,1888,2199,2493,2902,3319,3787,4114,4300,5389,6469,7593,8570,9788,10517,11470,13221,15224,16969,18408,19430,20796,21929,20684,12558,14475,17515,20278,14062,16026,17347,17533,20132,22684,26107,28662,31701,35608,40040,45246,47751,49402,51784,55438,59296,66653,71233,77580,83720,86619,90557,93156,98473,109687,120359,128177,130840,138056,147108,156037,164080,174412,182798,190634,197592,208117,219576,233880,247812,268714,278980,285430,300546,312851,325957,343805,359767,371351,292021,304360,318820,331944,341859,348358,355151,366603,387943,387821],[0,0,0,0,0,0,0,0,0,2,2,2,2,2,2,2,3,3,3,8,8,8,8,8,8,1,1,1,1,1,1,1,1,5,5,5,7,12,15,28,32,43,78,108,155,187,254,301,358,433,431,773,1097,1083,1464,1825,2459,2490,3752,4749,5392,6299,7515,8805,10783,13431,15704,17957,20236,22873,26586,30229,34014,37034,42333,45547,48141,52610,55890,63241,67636,72278,76219,80427,84174,87796,92465,96872,102209,106318,109270,112844,116694,121063,125098,129142,133083,136168,139418,144780,150210,154399,158421,162113,165816,171275,176318,180316,183862,187517,191176,193949,196689,199704,202879,205857,209221,211743,213617,212717,214988,217927,220598,222890,224390,228308,229911,231422,233192,234574,236395,237388,238716,240247,241873,243162,244516,245757,246899,248356,249106,250218,251554,252798,254276,255210,256253,257175],[0,0,0,0,0,0,0,0,0,2,2,2,2,2,2,2,2,2,2,2,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,2,11,11,14,14,17,17,25,42,51,55,82,106,139,189,243,293,350,421,472,626,799,987,1211,1462,1761,2199,2563,3283,3834,4355,4989,5890,6945,8029,9357,11028,12433,14349,16710,19238,22306,25402,29145,33423,39201,43270,48434,53066,57327,62439,67657,73435,79007,84235,88141,93806,100042,107819,116768,125817,134054,143065,151732,159528,164933,173467,179534,186615,192056,196410,202199,206340,211748,217747,220974,220341,221774,223374,224558,227641,230996,227406,224504,223916,223992,224551,229267,233965,231553,230948,230965,231499,231450,234950,239854,236579,234378,234629,235194,238511,241793,245382,243671,241281],[0,0,0,0,0,0,0,0,1,1,1,2,3,3,3,3,3,3,3,3,3,3,3,3,3,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2,2,25,27,28,31,36,40,52,57,68,76,96,98,104,125,139,175,219,303,362,462,486,602,662,794,879,902,1117,1239,1792,2280,2303,2767,3260,4267,4740,5232,5879,6578,7189,7794,8914,9735,10485,11214,11825,12738,14202,14674,15460,16319,17344,18252,19519,20486,21375,22569,23546,24641,26027,27557,29339,32024,33565,35871,37686,39823,41406,43980,45925,47457,49104,51379,52773,53553,55878,57939,60864,63172,66089,69244,73170,76820,80072,82172,85803,89755,85884,89706,93349,97008,101077,106665,111900,116302,120981,126431,129360,133726,143297,141842,145779,149348,153106,153178,155227,160384]],"fixedtz":false,"tzone":"UTC"},"evals":["attrs.interactionModel"],"jsHooks":[]}</script>
<div id="htmlwidget-a93c673dfff5175a3fc0" style="width:960px;height:500px;" class="dygraphs html-widget"></div>
<script type="application/json" data-for="htmlwidget-a93c673dfff5175a3fc0">{"x":{"attrs":{"axes":{"x":{"pixelsPerLabel":60,"drawGrid":false,"drawAxis":true},"y":{"drawAxis":true}},"title":"Top Countries - Log Count Of Active Cases","labels":["day","US","Brazil","United Kingdom","Russia","India"],"retainDateWindow":false,"ylabel":"Log Count Of Active Cases","stackedGraph":false,"fillGraph":false,"fillAlpha":0.15,"stepPlot":false,"drawPoints":false,"pointSize":1,"drawGapEdgePoints":false,"connectSeparatedPoints":false,"strokeWidth":1,"strokeBorderColor":"white","colors":["#1B9E77","#D95F02","#7570B3","#E7298A","#66A61E"],"colorValue":0.5,"colorSaturation":1,"includeZero":false,"drawAxesAtZero":false,"logscale":false,"axisTickSize":3,"axisLineColor":"navy","axisLineWidth":1.5,"axisLabelColor":"black","axisLabelFontSize":14,"axisLabelWidth":60,"drawGrid":true,"gridLineColor":"lightblue","gridLineWidth":0.3,"rightGap":5,"digitsAfterDecimal":2,"labelsKMB":false,"labelsKMG2":false,"labelsUTC":false,"maxNumberWidth":6,"animatedZooms":false,"mobileDisableYTouch":true,"disableZoom":false,"showRangeSelector":true,"rangeSelectorHeight":40,"rangeSelectorPlotFillColor":" #A7B1C4","rangeSelectorPlotStrokeColor":"#808FAB","interactionModel":"Dygraph.Interaction.defaultModel","legend":"auto","labelsDivWidth":750,"labelsShowZeroValues":true,"labelsSeparateLines":false,"hideOverlayOnMouseOut":true},"scale":"daily","annotations":[],"shadings":[],"events":[],"format":"date","data":[["2020-01-22T00:00:00.000Z","2020-01-23T00:00:00.000Z","2020-01-24T00:00:00.000Z","2020-01-25T00:00:00.000Z","2020-01-26T00:00:00.000Z","2020-01-27T00:00:00.000Z","2020-01-28T00:00:00.000Z","2020-01-29T00:00:00.000Z","2020-01-30T00:00:00.000Z","2020-01-31T00:00:00.000Z","2020-02-01T00:00:00.000Z","2020-02-02T00:00:00.000Z","2020-02-03T00:00:00.000Z","2020-02-04T00:00:00.000Z","2020-02-05T00:00:00.000Z","2020-02-06T00:00:00.000Z","2020-02-07T00:00:00.000Z","2020-02-08T00:00:00.000Z","2020-02-09T00:00:00.000Z","2020-02-10T00:00:00.000Z","2020-02-11T00:00:00.000Z","2020-02-12T00:00:00.000Z","2020-02-13T00:00:00.000Z","2020-02-14T00:00:00.000Z","2020-02-15T00:00:00.000Z","2020-02-16T00:00:00.000Z","2020-02-17T00:00:00.000Z","2020-02-18T00:00:00.000Z","2020-02-19T00:00:00.000Z","2020-02-20T00:00:00.000Z","2020-02-21T00:00:00.000Z","2020-02-22T00:00:00.000Z","2020-02-23T00:00:00.000Z","2020-02-24T00:00:00.000Z","2020-02-25T00:00:00.000Z","2020-02-26T00:00:00.000Z","2020-02-27T00:00:00.000Z","2020-02-28T00:00:00.000Z","2020-02-29T00:00:00.000Z","2020-03-01T00:00:00.000Z","2020-03-02T00:00:00.000Z","2020-03-03T00:00:00.000Z","2020-03-04T00:00:00.000Z","2020-03-05T00:00:00.000Z","2020-03-06T00:00:00.000Z","2020-03-07T00:00:00.000Z","2020-03-08T00:00:00.000Z","2020-03-09T00:00:00.000Z","2020-03-10T00:00:00.000Z","2020-03-11T00:00:00.000Z","2020-03-12T00:00:00.000Z","2020-03-13T00:00:00.000Z","2020-03-14T00:00:00.000Z","2020-03-15T00:00:00.000Z","2020-03-16T00:00:00.000Z","2020-03-17T00:00:00.000Z","2020-03-18T00:00:00.000Z","2020-03-19T00:00:00.000Z","2020-03-20T00:00:00.000Z","2020-03-21T00:00:00.000Z","2020-03-22T00:00:00.000Z","2020-03-23T00:00:00.000Z","2020-03-24T00:00:00.000Z","2020-03-25T00:00:00.000Z","2020-03-26T00:00:00.000Z","2020-03-27T00:00:00.000Z","2020-03-28T00:00:00.000Z","2020-03-29T00:00:00.000Z","2020-03-30T00:00:00.000Z","2020-03-31T00:00:00.000Z","2020-04-01T00:00:00.000Z","2020-04-02T00:00:00.000Z","2020-04-03T00:00:00.000Z","2020-04-04T00:00:00.000Z","2020-04-05T00:00:00.000Z","2020-04-06T00:00:00.000Z","2020-04-07T00:00:00.000Z","2020-04-08T00:00:00.000Z","2020-04-09T00:00:00.000Z","2020-04-10T00:00:00.000Z","2020-04-11T00:00:00.000Z","2020-04-12T00:00:00.000Z","2020-04-13T00:00:00.000Z","2020-04-14T00:00:00.000Z","2020-04-15T00:00:00.000Z","2020-04-16T00:00:00.000Z","2020-04-17T00:00:00.000Z","2020-04-18T00:00:00.000Z","2020-04-19T00:00:00.000Z","2020-04-20T00:00:00.000Z","2020-04-21T00:00:00.000Z","2020-04-22T00:00:00.000Z","2020-04-23T00:00:00.000Z","2020-04-24T00:00:00.000Z","2020-04-25T00:00:00.000Z","2020-04-26T00:00:00.000Z","2020-04-27T00:00:00.000Z","2020-04-28T00:00:00.000Z","2020-04-29T00:00:00.000Z","2020-04-30T00:00:00.000Z","2020-05-01T00:00:00.000Z","2020-05-02T00:00:00.000Z","2020-05-03T00:00:00.000Z","2020-05-04T00:00:00.000Z","2020-05-05T00:00:00.000Z","2020-05-06T00:00:00.000Z","2020-05-07T00:00:00.000Z","2020-05-08T00:00:00.000Z","2020-05-09T00:00:00.000Z","2020-05-10T00:00:00.000Z","2020-05-11T00:00:00.000Z","2020-05-12T00:00:00.000Z","2020-05-13T00:00:00.000Z","2020-05-14T00:00:00.000Z","2020-05-15T00:00:00.000Z","2020-05-16T00:00:00.000Z","2020-05-17T00:00:00.000Z","2020-05-18T00:00:00.000Z","2020-05-19T00:00:00.000Z","2020-05-20T00:00:00.000Z","2020-05-21T00:00:00.000Z","2020-05-22T00:00:00.000Z","2020-05-23T00:00:00.000Z","2020-05-24T00:00:00.000Z","2020-05-25T00:00:00.000Z","2020-05-26T00:00:00.000Z","2020-05-27T00:00:00.000Z","2020-05-28T00:00:00.000Z","2020-05-29T00:00:00.000Z","2020-05-30T00:00:00.000Z","2020-05-31T00:00:00.000Z","2020-06-01T00:00:00.000Z","2020-06-02T00:00:00.000Z","2020-06-03T00:00:00.000Z","2020-06-04T00:00:00.000Z","2020-06-05T00:00:00.000Z","2020-06-06T00:00:00.000Z","2020-06-07T00:00:00.000Z","2020-06-08T00:00:00.000Z","2020-06-09T00:00:00.000Z","2020-06-10T00:00:00.000Z","2020-06-11T00:00:00.000Z","2020-06-12T00:00:00.000Z","2020-06-13T00:00:00.000Z","2020-06-14T00:00:00.000Z","2020-06-15T00:00:00.000Z","2020-06-16T00:00:00.000Z","2020-06-17T00:00:00.000Z"],[0,0,0.693147180559945,0.693147180559945,1.6094379124341,1.6094379124341,1.6094379124341,1.6094379124341,1.6094379124341,1.94591014905531,2.07944154167984,2.07944154167984,2.39789527279837,2.39789527279837,2.39789527279837,2.39789527279837,2.39789527279837,2.39789527279837,2.07944154167984,2.07944154167984,2.19722457733622,2.19722457733622,2.30258509299405,2.30258509299405,2.30258509299405,2.30258509299405,2.30258509299405,2.30258509299405,2.30258509299405,2.30258509299405,2.30258509299405,2.30258509299405,2.30258509299405,2.30258509299405,2.19722457733622,2.19722457733622,2.30258509299405,2.19722457733622,2.77258872223978,3.09104245335832,3.68887945411394,4.07753744390572,4.45434729625351,5.04342511691925,5.30330490805908,5.74620319054015,6.04737217904628,6.19440539110467,6.51471269087253,6.97447891102505,7.31721240835984,7.646353722446,7.93701748951545,7.96693349840484,8.35302584520232,8.6978466911095,9.06160831817578,9.52973911097953,9.85040318144367,10.1340435635658,10.4035959514609,10.666230755984,10.873148420668,11.0721543711546,11.3103563018916,11.5038948110845,11.6789567190282,11.8129041235653,11.9361911977039,12.0788584005037,12.200723363599,12.333775208485,12.4575392844487,12.557204756312,12.6372119980916,12.7178298352538,12.7936898516305,12.8681367126764,12.9447116997318,13.0095686295274,13.0651367259421,13.1169306468113,13.1427383898765,13.1818636026179,13.2229939243764,13.2699865133826,13.3143546976433,13.3463241946657,13.3768350385982,13.4127453019732,13.4425537814513,13.4763934266909,13.5163562638374,13.5372281697381,13.5752742543238,13.6002942528428,13.6207928858232,13.6422874841556,13.6657963557341,13.6593583764682,13.6849131427299,13.7034319709587,13.7250047188111,13.740430267108,13.7611525722039,13.7848884506142,13.8058510548166,13.8275162009582,13.8379078554063,13.8528631811697,13.8539723293479,13.8755872649969,13.8815108227339,13.9026813389151,13.9202461784158,13.9258589136406,13.9385888821343,13.9473963473262,13.9584786594618,13.9732507876421,13.9903441497923,13.9658184351026,13.9740558530235,13.9864880130576,13.9915717260207,14.0019204129335,14.0103953655945,14.0211668953427,14.0347970804971,14.0454136122764,14.0384180814261,14.0409035773271,14.0521924509609,14.054957287305,14.0663175241747,14.0799488240489,14.0897767891122,14.0987078387551,14.102335513196,14.1104157309035,14.1187679528833,14.1299380126811,14.1426039504027,14.1537555081143,14.1637066578819,14.1672689353732,14.1782525600287,14.189403812335],[null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,0,0,0,0.693147180559945,0.693147180559945,0.693147180559945,0.693147180559945,1.38629436111989,1.38629436111989,2.56494935746154,2.56494935746154,2.99573227355399,3.2188758248682,3.43398720448515,3.63758615972639,3.95124371858143,5.01727983681492,5.01727983681492,5.08759633523238,5.29330482472449,5.76205138278018,5.90536184805457,6.41836493593621,6.65929391968364,6.91174730025167,7.32580750259577,7.54327334670545,7.69575799055476,7.82124208352356,7.97315543344413,8.10741881171997,8.2393294279018,8.3221510702129,8.36637030168165,8.5921151179335,8.77477681604399,8.93498204921323,9.05602301159183,9.18891242456256,9.26074827452003,9.34749021012342,9.4895617535101,9.63062840897599,9.73914342897283,9.8205406317152,9.87457354237149,9.94251593950361,9.99556524073704,9.93711573351611,9.43811319167405,9.5801783024412,9.77081293563159,9.91729183351253,9.55123140275911,9.68196768233802,9.76117485976141,9.77184009847013,9.91006586789625,10.0294151091339,10.1699587565855,10.263327482618,10.3641035051091,10.4803256106957,10.5976342334292,10.7198695474307,10.773755288098,10.8077461881864,10.8548365002253,10.923020558177,10.9902971290851,11.1072553358467,11.173711473171,11.259064940994,11.3352331765599,11.3692744700241,11.4137347656798,11.4420307861937,11.4975376779096,11.6053861342274,11.6982342223014,11.761167400197,11.7817304816523,11.8354146789274,11.898922289883,11.9578484375962,12.0081093927463,12.0691755954293,12.1161369970233,12.1581106383441,12.1939595776464,12.2458557005396,12.2994536930275,12.3625634422896,12.4204256731548,12.5014028959631,12.5388953736462,12.5617520941278,12.6133560994451,12.6534823178414,12.6945207498085,12.7478299151643,12.7932118786714,12.8249029859712,12.5845809964727,12.6259664902905,12.6723819591876,12.7127215589727,12.7421536503319,12.7609859656029,12.7802983301337,12.8120347976603,12.868613700597,12.8682991719491],[null,null,null,null,null,null,null,null,null,0.693147180559945,0.693147180559945,0.693147180559945,0.693147180559945,0.693147180559945,0.693147180559945,0.693147180559945,1.09861228866811,1.09861228866811,1.09861228866811,2.07944154167984,2.07944154167984,2.07944154167984,2.07944154167984,2.07944154167984,2.07944154167984,0,0,0,0,0,0,0,0,1.6094379124341,1.6094379124341,1.6094379124341,1.94591014905531,2.484906649788,2.70805020110221,3.3322045101752,3.46573590279973,3.76120011569356,4.35670882668959,4.68213122712422,5.04342511691925,5.23110861685459,5.53733426701854,5.70711026474888,5.8805329864007,6.07073772800249,6.06610809010375,6.65027904858742,7.00033446027523,6.98749024700099,7.28892769452126,7.50933526601659,7.80751004221619,7.82003798945875,8.23004431012611,8.46568934854912,8.59267165259214,8.74814616962193,8.92465630218707,9.08307502093031,9.28572609888207,9.50532074690907,9.6616707359563,9.7957352900419,9.91521847541183,10.0377124546274,10.1881400404275,10.3165570075042,10.4345274835524,10.5195916885978,10.6533222027259,10.7265000388287,10.7818894838675,10.8706614947249,10.9311407522637,11.0547081039751,11.1218956646583,11.1882750741518,11.2413660544258,11.2951052196874,11.3406413639468,11.3827712204988,11.434585473519,11.4811457984342,11.5347750154968,11.574189882074,11.6015771625648,11.6337616129102,11.6673104030712,11.7040663502389,11.736852709117,11.7686678531288,11.7987282727097,11.8216446964878,11.8452318937933,11.8829706278471,11.9197895939921,11.9472954398679,11.9730113253326,11.9960489019171,12.0186340188367,12.0510257308711,12.0800444618697,12.1024661462414,12.1219407552004,12.1416247869493,12.1609497487082,12.1753505168868,12.1893790800885,12.2045915492484,12.2203650211968,12.2349370319636,12.2511463885441,12.2631285541166,12.2719399709162,12.2677179227712,12.2783374915987,12.291915423307,12.3040973195773,12.3144336552002,12.3211408883578,12.3384508735159,12.3454475564966,12.3519981626884,12.3596174275527,12.3655263821203,12.3732594136982,12.3774512122811,12.383029839825,12.3894228397619,12.3961680739981,12.4014831668658,12.4070360254288,12.4120985218357,12.4167346251023,12.422618479696,12.4256337876724,12.4300878168733,12.4354129572043,12.4403460298311,12.446175570236,12.449842014638,12.4539205166833,12.4575120659992],[null,null,null,null,null,null,null,null,null,0.693147180559945,0.693147180559945,0.693147180559945,0.693147180559945,0.693147180559945,0.693147180559945,0.693147180559945,0.693147180559945,0.693147180559945,0.693147180559945,0.693147180559945,0.693147180559945,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,0,0,0,0.693147180559945,2.39789527279837,2.39789527279837,2.63905732961526,2.63905732961526,2.83321334405622,2.83321334405622,3.2188758248682,3.73766961828337,3.93182563272433,4.00733318523247,4.40671924726425,4.66343909411207,4.93447393313069,5.24174701505964,5.49306144334055,5.68017260901707,5.85793315448346,6.04263283368238,6.15697898558556,6.4393503711001,6.68336094576627,6.89467003943348,7.09920174355309,7.28756064030972,7.47363710849621,7.69575799055476,7.84893372636407,8.09651291750159,8.25166392360559,8.3790798892866,8.51499076786104,8.68101127664563,8.84577725518844,8.99081526618468,9.14388000527591,9.30819277214369,9.42810950695294,9.57143553234841,9.72376262158944,9.86464276871256,10.0126109795545,10.1425831900643,10.2800386504796,10.4169995647274,10.5764575356573,10.6752148332189,10.7879573254204,10.8792917008313,10.9565269959095,11.0419453591264,11.1222061020079,11.204155940188,11.2772917351187,11.3413657908203,11.3866930839182,11.4489840988334,11.5133453767949,11.5882091742455,11.6679443392362,11.7425837492537,11.805997982831,11.8710543514221,11.9298710857413,11.9799747343895,12.0132946098117,12.0637426585493,12.0981198840155,12.1368029500167,12.1655422751501,12.1879595901032,12.2170076399579,12.2372805726544,12.2631521673693,12.2910891173523,12.3058003265201,12.3029316253243,12.3094141243041,12.316602775675,12.3218893046904,12.3355251056085,12.3501556733367,12.3344922451748,12.3216488033777,12.3190262605071,12.3193656159137,12.3218581318571,12.3426425422222,12.3629268105032,12.3525640679899,12.3499478559382,12.3500214628728,12.3523308328447,12.3521191464594,12.367128004531,12.387785683881,12.3740374691908,12.3646904756249,12.3657608222251,12.3681659844771,12.3821707098403,12.3958372671987,12.4105714589355,12.4035742337634,12.3937175083555],[null,null,null,null,null,null,null,null,0,0,0,0.693147180559945,1.09861228866811,1.09861228866811,1.09861228866811,1.09861228866811,1.09861228866811,1.09861228866811,1.09861228866811,1.09861228866811,1.09861228866811,1.09861228866811,1.09861228866811,1.09861228866811,1.09861228866811,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,0.693147180559945,0.693147180559945,3.2188758248682,3.29583686600433,3.3322045101752,3.43398720448515,3.58351893845611,3.68887945411394,3.95124371858143,4.04305126783455,4.21950770517611,4.33073334028633,4.56434819146784,4.58496747867057,4.64439089914137,4.8283137373023,4.93447393313069,5.16478597392351,5.3890717298165,5.71373280550937,5.89164421182577,6.13556489108174,6.18620862390049,6.40025744530882,6.49526555593701,6.67708346124714,6.77878489768518,6.80461452006262,7.0184017990692,7.12205988162914,7.49108759353488,7.73193072194849,7.74196789982069,7.92551897978693,8.08948247436075,8.358666283188,8.46379241468912,8.56254889313703,8.67914195840225,8.791486026749,8.88030735898387,8.96110948589866,9.0953783535065,9.1834829178063,9.25770094333602,9.32491827668362,9.37797121336013,9.45234493093131,9.56113807874204,9.59383249927394,9.64601132214141,9.70008535213093,9.76100190423937,9.81202994204729,9.87914362914661,9.92749700499648,9.96997729380496,10.0243325622283,10.0667112336381,10.1121670012395,10.1668897397139,10.2240118657919,10.2866729679532,10.3742409006724,10.4212391363729,10.4876844485877,10.5370439516824,10.592199913806,10.6311810768487,10.6914902641088,10.7347649100833,10.7675793168667,10.8016957768595,10.8469848076485,10.873754975267,10.8884270967157,10.9309260217497,10.9671460119407,11.0163971459051,11.0536164439899,11.0987575974679,11.1453917776966,11.2005407798781,11.2492203018999,11.2906815088989,11.3165698904124,11.3598092498998,11.4048390151052,11.3607528275266,11.404292935442,11.4441004365397,11.4825487283115,11.5236378815999,11.5774483609857,11.6253608943,11.6639455352634,11.7033887874558,11.7474519837898,11.770354494251,11.8035482094048,11.8726746784959,11.8624690410435,11.8898470552611,11.914034432192,11.9388857709497,11.9393559228436,11.9526438406726,11.9853262188157]],"fixedtz":false,"tzone":"UTC"},"evals":["attrs.interactionModel"],"jsHooks":[]}</script>
<div id="htmlwidget-3acff5d3feb1c8db1a8c" style="width:960px;height:500px;" class="dygraphs html-widget"></div>
<script type="application/json" data-for="htmlwidget-3acff5d3feb1c8db1a8c">{"x":{"attrs":{"axes":{"x":{"pixelsPerLabel":60,"drawGrid":false,"drawAxis":true},"y":{"drawAxis":true}},"title":"Top Countries - Percentage Of Active Cases","labels":["day","US","Brazil","United Kingdom","Russia","India"],"retainDateWindow":false,"ylabel":"Percentage Of Active Cases","stackedGraph":false,"fillGraph":false,"fillAlpha":0.15,"stepPlot":false,"drawPoints":false,"pointSize":1,"drawGapEdgePoints":false,"connectSeparatedPoints":false,"strokeWidth":1,"strokeBorderColor":"white","colors":["#1B9E77","#D95F02","#7570B3","#E7298A","#66A61E"],"colorValue":0.5,"colorSaturation":1,"includeZero":false,"drawAxesAtZero":false,"logscale":false,"axisTickSize":3,"axisLineColor":"navy","axisLineWidth":1.5,"axisLabelColor":"black","axisLabelFontSize":14,"axisLabelWidth":60,"drawGrid":true,"gridLineColor":"lightblue","gridLineWidth":0.3,"rightGap":5,"digitsAfterDecimal":2,"labelsKMB":false,"labelsKMG2":false,"labelsUTC":false,"maxNumberWidth":6,"animatedZooms":false,"mobileDisableYTouch":true,"disableZoom":false,"showRangeSelector":true,"rangeSelectorHeight":40,"rangeSelectorPlotFillColor":" #A7B1C4","rangeSelectorPlotStrokeColor":"#808FAB","interactionModel":"Dygraph.Interaction.defaultModel","legend":"auto","labelsDivWidth":750,"labelsShowZeroValues":true,"labelsSeparateLines":false,"hideOverlayOnMouseOut":true},"scale":"daily","annotations":[],"shadings":[],"events":[],"format":"date","data":[["2020-01-22T00:00:00.000Z","2020-01-23T00:00:00.000Z","2020-01-24T00:00:00.000Z","2020-01-25T00:00:00.000Z","2020-01-26T00:00:00.000Z","2020-01-27T00:00:00.000Z","2020-01-28T00:00:00.000Z","2020-01-29T00:00:00.000Z","2020-01-30T00:00:00.000Z","2020-01-31T00:00:00.000Z","2020-02-01T00:00:00.000Z","2020-02-02T00:00:00.000Z","2020-02-03T00:00:00.000Z","2020-02-04T00:00:00.000Z","2020-02-05T00:00:00.000Z","2020-02-06T00:00:00.000Z","2020-02-07T00:00:00.000Z","2020-02-08T00:00:00.000Z","2020-02-09T00:00:00.000Z","2020-02-10T00:00:00.000Z","2020-02-11T00:00:00.000Z","2020-02-12T00:00:00.000Z","2020-02-13T00:00:00.000Z","2020-02-14T00:00:00.000Z","2020-02-15T00:00:00.000Z","2020-02-16T00:00:00.000Z","2020-02-17T00:00:00.000Z","2020-02-18T00:00:00.000Z","2020-02-19T00:00:00.000Z","2020-02-20T00:00:00.000Z","2020-02-21T00:00:00.000Z","2020-02-22T00:00:00.000Z","2020-02-23T00:00:00.000Z","2020-02-24T00:00:00.000Z","2020-02-25T00:00:00.000Z","2020-02-26T00:00:00.000Z","2020-02-27T00:00:00.000Z","2020-02-28T00:00:00.000Z","2020-02-29T00:00:00.000Z","2020-03-01T00:00:00.000Z","2020-03-02T00:00:00.000Z","2020-03-03T00:00:00.000Z","2020-03-04T00:00:00.000Z","2020-03-05T00:00:00.000Z","2020-03-06T00:00:00.000Z","2020-03-07T00:00:00.000Z","2020-03-08T00:00:00.000Z","2020-03-09T00:00:00.000Z","2020-03-10T00:00:00.000Z","2020-03-11T00:00:00.000Z","2020-03-12T00:00:00.000Z","2020-03-13T00:00:00.000Z","2020-03-14T00:00:00.000Z","2020-03-15T00:00:00.000Z","2020-03-16T00:00:00.000Z","2020-03-17T00:00:00.000Z","2020-03-18T00:00:00.000Z","2020-03-19T00:00:00.000Z","2020-03-20T00:00:00.000Z","2020-03-21T00:00:00.000Z","2020-03-22T00:00:00.000Z","2020-03-23T00:00:00.000Z","2020-03-24T00:00:00.000Z","2020-03-25T00:00:00.000Z","2020-03-26T00:00:00.000Z","2020-03-27T00:00:00.000Z","2020-03-28T00:00:00.000Z","2020-03-29T00:00:00.000Z","2020-03-30T00:00:00.000Z","2020-03-31T00:00:00.000Z","2020-04-01T00:00:00.000Z","2020-04-02T00:00:00.000Z","2020-04-03T00:00:00.000Z","2020-04-04T00:00:00.000Z","2020-04-05T00:00:00.000Z","2020-04-06T00:00:00.000Z","2020-04-07T00:00:00.000Z","2020-04-08T00:00:00.000Z","2020-04-09T00:00:00.000Z","2020-04-10T00:00:00.000Z","2020-04-11T00:00:00.000Z","2020-04-12T00:00:00.000Z","2020-04-13T00:00:00.000Z","2020-04-14T00:00:00.000Z","2020-04-15T00:00:00.000Z","2020-04-16T00:00:00.000Z","2020-04-17T00:00:00.000Z","2020-04-18T00:00:00.000Z","2020-04-19T00:00:00.000Z","2020-04-20T00:00:00.000Z","2020-04-21T00:00:00.000Z","2020-04-22T00:00:00.000Z","2020-04-23T00:00:00.000Z","2020-04-24T00:00:00.000Z","2020-04-25T00:00:00.000Z","2020-04-26T00:00:00.000Z","2020-04-27T00:00:00.000Z","2020-04-28T00:00:00.000Z","2020-04-29T00:00:00.000Z","2020-04-30T00:00:00.000Z","2020-05-01T00:00:00.000Z","2020-05-02T00:00:00.000Z","2020-05-03T00:00:00.000Z","2020-05-04T00:00:00.000Z","2020-05-05T00:00:00.000Z","2020-05-06T00:00:00.000Z","2020-05-07T00:00:00.000Z","2020-05-08T00:00:00.000Z","2020-05-09T00:00:00.000Z","2020-05-10T00:00:00.000Z","2020-05-11T00:00:00.000Z","2020-05-12T00:00:00.000Z","2020-05-13T00:00:00.000Z","2020-05-14T00:00:00.000Z","2020-05-15T00:00:00.000Z","2020-05-16T00:00:00.000Z","2020-05-17T00:00:00.000Z","2020-05-18T00:00:00.000Z","2020-05-19T00:00:00.000Z","2020-05-20T00:00:00.000Z","2020-05-21T00:00:00.000Z","2020-05-22T00:00:00.000Z","2020-05-23T00:00:00.000Z","2020-05-24T00:00:00.000Z","2020-05-25T00:00:00.000Z","2020-05-26T00:00:00.000Z","2020-05-27T00:00:00.000Z","2020-05-28T00:00:00.000Z","2020-05-29T00:00:00.000Z","2020-05-30T00:00:00.000Z","2020-05-31T00:00:00.000Z","2020-06-01T00:00:00.000Z","2020-06-02T00:00:00.000Z","2020-06-03T00:00:00.000Z","2020-06-04T00:00:00.000Z","2020-06-05T00:00:00.000Z","2020-06-06T00:00:00.000Z","2020-06-07T00:00:00.000Z","2020-06-08T00:00:00.000Z","2020-06-09T00:00:00.000Z","2020-06-10T00:00:00.000Z","2020-06-11T00:00:00.000Z","2020-06-12T00:00:00.000Z","2020-06-13T00:00:00.000Z","2020-06-14T00:00:00.000Z","2020-06-15T00:00:00.000Z","2020-06-16T00:00:00.000Z","2020-06-17T00:00:00.000Z"],[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0.001,0.001,0.001,0.001,0.002,0.003,0.004,0.006,0.008,0.01,0.013,0.016,0.02,0.025,0.031,0.037,0.042,0.047,0.055,0.062,0.071,0.08,0.088,0.096,0.104,0.112,0.12,0.13,0.139,0.147,0.154,0.158,0.165,0.172,0.18,0.188,0.194,0.2,0.207,0.214,0.221,0.23,0.235,0.244,0.25,0.255,0.261,0.267,0.266,0.272,0.277,0.284,0.288,0.294,0.301,0.307,0.314,0.317,0.322,0.323,0.33,0.332,0.339,0.345,0.347,0.351,0.354,0.358,0.363,0.37,0.361,0.364,0.368,0.37,0.374,0.377,0.381,0.386,0.391,0.388,0.389,0.393,0.394,0.399,0.404,0.408,0.412,0.413,0.417,0.42,0.425,0.43,0.435,0.44,0.441,0.446,0.451],[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0.001,0.001,0.001,0.001,0.001,0.002,0.002,0.002,0.002,0.003,0.003,0.004,0.004,0.005,0.005,0.006,0.006,0.007,0.008,0.009,0.009,0.01,0.011,0.01,0.006,0.007,0.008,0.01,0.007,0.008,0.008,0.008,0.01,0.011,0.013,0.014,0.015,0.017,0.019,0.022,0.023,0.024,0.025,0.027,0.029,0.032,0.034,0.037,0.04,0.042,0.044,0.045,0.047,0.053,0.058,0.062,0.063,0.066,0.071,0.075,0.079,0.084,0.088,0.092,0.095,0.1,0.106,0.113,0.119,0.129,0.134,0.137,0.145,0.151,0.157,0.166,0.173,0.179,0.141,0.147,0.154,0.16,0.165,0.168,0.171,0.177,0.187,0.187],[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0.001,0.001,0.001,0.001,0.002,0.002,0.002,0.003,0.004,0.004,0.006,0.007,0.008,0.01,0.011,0.013,0.016,0.02,0.024,0.027,0.031,0.035,0.04,0.046,0.052,0.056,0.064,0.069,0.073,0.08,0.085,0.096,0.103,0.11,0.116,0.122,0.128,0.133,0.141,0.147,0.155,0.162,0.166,0.172,0.177,0.184,0.19,0.196,0.202,0.207,0.212,0.22,0.228,0.235,0.241,0.246,0.252,0.26,0.268,0.274,0.279,0.285,0.291,0.295,0.299,0.304,0.308,0.313,0.318,0.322,0.325,0.323,0.327,0.331,0.335,0.339,0.341,0.347,0.349,0.352,0.354,0.357,0.359,0.361,0.363,0.365,0.368,0.37,0.372,0.374,0.375,0.378,0.379,0.38,0.382,0.384,0.387,0.388,0.39,0.391],[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0.001,0.001,0.001,0.001,0.001,0.002,0.002,0.002,0.003,0.003,0.003,0.004,0.005,0.006,0.006,0.008,0.009,0.01,0.012,0.013,0.015,0.018,0.02,0.023,0.027,0.03,0.034,0.037,0.04,0.043,0.047,0.051,0.055,0.059,0.061,0.065,0.069,0.075,0.081,0.087,0.093,0.099,0.105,0.111,0.115,0.12,0.125,0.13,0.133,0.136,0.14,0.143,0.147,0.151,0.153,0.153,0.154,0.155,0.156,0.158,0.16,0.158,0.156,0.156,0.156,0.156,0.159,0.163,0.161,0.16,0.16,0.161,0.161,0.163,0.167,0.164,0.163,0.163,0.163,0.166,0.168,0.17,0.169,0.168],[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0.001,0.001,0.001,0.001,0.001,0.001,0.001,0.001,0.001,0.001,0.001,0.001,0.001,0.001,0.001,0.002,0.002,0.002,0.002,0.002,0.002,0.002,0.002,0.002,0.003,0.003,0.003,0.003,0.003,0.003,0.003,0.004,0.004,0.004,0.004,0.004,0.004,0.004,0.005,0.005,0.005,0.005,0.006,0.006,0.006,0.006,0.006,0.007,0.006,0.007,0.007,0.007,0.008,0.008,0.008,0.009,0.009,0.01,0.01,0.01,0.011,0.011,0.011,0.011,0.012,0.012,0.012,0.012]],"fixedtz":false,"tzone":"UTC"},"evals":["attrs.interactionModel"],"jsHooks":[]}</script>
<div id="htmlwidget-d89ff9446a9ab42fd7e5" style="width:960px;height:500px;" class="dygraphs html-widget"></div>
<script type="application/json" data-for="htmlwidget-d89ff9446a9ab42fd7e5">{"x":{"attrs":{"axes":{"x":{"pixelsPerLabel":60,"drawGrid":false,"drawAxis":true},"y":{"drawAxis":true}},"title":"Top Countries - Log Percentage Of Active Cases","labels":["day","US","Brazil","United Kingdom","Russia","India"],"retainDateWindow":false,"ylabel":"Log Percentage Of Active Cases","stackedGraph":false,"fillGraph":false,"fillAlpha":0.15,"stepPlot":false,"drawPoints":false,"pointSize":1,"drawGapEdgePoints":false,"connectSeparatedPoints":false,"strokeWidth":1,"strokeBorderColor":"white","colors":["#1B9E77","#D95F02","#7570B3","#E7298A","#66A61E"],"colorValue":0.5,"colorSaturation":1,"includeZero":false,"drawAxesAtZero":false,"logscale":false,"axisTickSize":3,"axisLineColor":"navy","axisLineWidth":1.5,"axisLabelColor":"black","axisLabelFontSize":14,"axisLabelWidth":60,"drawGrid":true,"gridLineColor":"lightblue","gridLineWidth":0.3,"rightGap":5,"digitsAfterDecimal":2,"labelsKMB":false,"labelsKMG2":false,"labelsUTC":false,"maxNumberWidth":6,"animatedZooms":false,"mobileDisableYTouch":true,"disableZoom":false,"showRangeSelector":true,"rangeSelectorHeight":40,"rangeSelectorPlotFillColor":" #A7B1C4","rangeSelectorPlotStrokeColor":"#808FAB","interactionModel":"Dygraph.Interaction.defaultModel","legend":"auto","labelsDivWidth":750,"labelsShowZeroValues":true,"labelsSeparateLines":false,"hideOverlayOnMouseOut":true},"scale":"daily","annotations":[],"shadings":[],"events":[],"format":"date","data":[["2020-01-22T00:00:00.000Z","2020-01-23T00:00:00.000Z","2020-01-24T00:00:00.000Z","2020-01-25T00:00:00.000Z","2020-01-26T00:00:00.000Z","2020-01-27T00:00:00.000Z","2020-01-28T00:00:00.000Z","2020-01-29T00:00:00.000Z","2020-01-30T00:00:00.000Z","2020-01-31T00:00:00.000Z","2020-02-01T00:00:00.000Z","2020-02-02T00:00:00.000Z","2020-02-03T00:00:00.000Z","2020-02-04T00:00:00.000Z","2020-02-05T00:00:00.000Z","2020-02-06T00:00:00.000Z","2020-02-07T00:00:00.000Z","2020-02-08T00:00:00.000Z","2020-02-09T00:00:00.000Z","2020-02-10T00:00:00.000Z","2020-02-11T00:00:00.000Z","2020-02-12T00:00:00.000Z","2020-02-13T00:00:00.000Z","2020-02-14T00:00:00.000Z","2020-02-15T00:00:00.000Z","2020-02-16T00:00:00.000Z","2020-02-17T00:00:00.000Z","2020-02-18T00:00:00.000Z","2020-02-19T00:00:00.000Z","2020-02-20T00:00:00.000Z","2020-02-21T00:00:00.000Z","2020-02-22T00:00:00.000Z","2020-02-23T00:00:00.000Z","2020-02-24T00:00:00.000Z","2020-02-25T00:00:00.000Z","2020-02-26T00:00:00.000Z","2020-02-27T00:00:00.000Z","2020-02-28T00:00:00.000Z","2020-02-29T00:00:00.000Z","2020-03-01T00:00:00.000Z","2020-03-02T00:00:00.000Z","2020-03-03T00:00:00.000Z","2020-03-04T00:00:00.000Z","2020-03-05T00:00:00.000Z","2020-03-06T00:00:00.000Z","2020-03-07T00:00:00.000Z","2020-03-08T00:00:00.000Z","2020-03-09T00:00:00.000Z","2020-03-10T00:00:00.000Z","2020-03-11T00:00:00.000Z","2020-03-12T00:00:00.000Z","2020-03-13T00:00:00.000Z","2020-03-14T00:00:00.000Z","2020-03-15T00:00:00.000Z","2020-03-16T00:00:00.000Z","2020-03-17T00:00:00.000Z","2020-03-18T00:00:00.000Z","2020-03-19T00:00:00.000Z","2020-03-20T00:00:00.000Z","2020-03-21T00:00:00.000Z","2020-03-22T00:00:00.000Z","2020-03-23T00:00:00.000Z","2020-03-24T00:00:00.000Z","2020-03-25T00:00:00.000Z","2020-03-26T00:00:00.000Z","2020-03-27T00:00:00.000Z","2020-03-28T00:00:00.000Z","2020-03-29T00:00:00.000Z","2020-03-30T00:00:00.000Z","2020-03-31T00:00:00.000Z","2020-04-01T00:00:00.000Z","2020-04-02T00:00:00.000Z","2020-04-03T00:00:00.000Z","2020-04-04T00:00:00.000Z","2020-04-05T00:00:00.000Z","2020-04-06T00:00:00.000Z","2020-04-07T00:00:00.000Z","2020-04-08T00:00:00.000Z","2020-04-09T00:00:00.000Z","2020-04-10T00:00:00.000Z","2020-04-11T00:00:00.000Z","2020-04-12T00:00:00.000Z","2020-04-13T00:00:00.000Z","2020-04-14T00:00:00.000Z","2020-04-15T00:00:00.000Z","2020-04-16T00:00:00.000Z","2020-04-17T00:00:00.000Z","2020-04-18T00:00:00.000Z","2020-04-19T00:00:00.000Z","2020-04-20T00:00:00.000Z","2020-04-21T00:00:00.000Z","2020-04-22T00:00:00.000Z","2020-04-23T00:00:00.000Z","2020-04-24T00:00:00.000Z","2020-04-25T00:00:00.000Z","2020-04-26T00:00:00.000Z","2020-04-27T00:00:00.000Z","2020-04-28T00:00:00.000Z","2020-04-29T00:00:00.000Z","2020-04-30T00:00:00.000Z","2020-05-01T00:00:00.000Z","2020-05-02T00:00:00.000Z","2020-05-03T00:00:00.000Z","2020-05-04T00:00:00.000Z","2020-05-05T00:00:00.000Z","2020-05-06T00:00:00.000Z","2020-05-07T00:00:00.000Z","2020-05-08T00:00:00.000Z","2020-05-09T00:00:00.000Z","2020-05-10T00:00:00.000Z","2020-05-11T00:00:00.000Z","2020-05-12T00:00:00.000Z","2020-05-13T00:00:00.000Z","2020-05-14T00:00:00.000Z","2020-05-15T00:00:00.000Z","2020-05-16T00:00:00.000Z","2020-05-17T00:00:00.000Z","2020-05-18T00:00:00.000Z","2020-05-19T00:00:00.000Z","2020-05-20T00:00:00.000Z","2020-05-21T00:00:00.000Z","2020-05-22T00:00:00.000Z","2020-05-23T00:00:00.000Z","2020-05-24T00:00:00.000Z","2020-05-25T00:00:00.000Z","2020-05-26T00:00:00.000Z","2020-05-27T00:00:00.000Z","2020-05-28T00:00:00.000Z","2020-05-29T00:00:00.000Z","2020-05-30T00:00:00.000Z","2020-05-31T00:00:00.000Z","2020-06-01T00:00:00.000Z","2020-06-02T00:00:00.000Z","2020-06-03T00:00:00.000Z","2020-06-04T00:00:00.000Z","2020-06-05T00:00:00.000Z","2020-06-06T00:00:00.000Z","2020-06-07T00:00:00.000Z","2020-06-08T00:00:00.000Z","2020-06-09T00:00:00.000Z","2020-06-10T00:00:00.000Z","2020-06-11T00:00:00.000Z","2020-06-12T00:00:00.000Z","2020-06-13T00:00:00.000Z","2020-06-14T00:00:00.000Z","2020-06-15T00:00:00.000Z","2020-06-16T00:00:00.000Z","2020-06-17T00:00:00.000Z"],[null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,-6.90775527898214,-6.90775527898214,-6.90775527898214,-6.90775527898214,-6.21460809842219,-5.80914299031403,-5.52146091786225,-5.11599580975408,-4.8283137373023,-4.60517018598809,-4.3428059215206,-4.13516655674236,-3.91202300542815,-3.68887945411394,-3.47376807449699,-3.29683736633791,-3.17008566069877,-3.05760767727208,-2.90042209374967,-2.78062089393705,-2.64507540194082,-2.52572864430826,-2.43041846450393,-2.3434070875143,-2.26336437984076,-2.18925640768704,-2.12026353620009,-2.04022082852655,-1.97328134585145,-1.9173226922034,-1.87080267656851,-1.84516024595517,-1.80180980508156,-1.76026080216868,-1.71479842809193,-1.67131331615219,-1.63989711991881,-1.6094379124341,-1.57503648571677,-1.54177926396029,-1.50959257746438,-1.46967597005894,-1.44816976483798,-1.41058705368894,-1.38629436111989,-1.36649173382371,-1.34323487165944,-1.32050662058189,-1.32425897020044,-1.30195321268614,-1.2837377727948,-1.25878104082093,-1.24479479884619,-1.22417551164346,-1.20064501423326,-1.18090753139494,-1.15836229307388,-1.14885350510486,-1.13320373343773,-1.13010295575948,-1.10866262452161,-1.10262031006565,-1.08175517160169,-1.06421086195078,-1.05843049903528,-1.04696905551627,-1.03845836584836,-1.02722229258144,-1.01335244471729,-0.994252273343867,-1.01887732064926,-1.0106014113454,-0.999672340813206,-0.994252273343867,-0.983499481567605,-0.975510091534126,-0.964955903855436,-0.951917909517306,-0.939047718996771,-0.946749939358864,-0.944175935363691,-0.933945667112876,-0.931404369684203,-0.918793862092274,-0.906340401020987,-0.896488104577975,-0.886731929632611,-0.884307686021104,-0.874669057183336,-0.867500567704723,-0.85566611005772,-0.843970070294529,-0.832409247893453,-0.82098055206983,-0.818710403535291,-0.807436326962073,-0.796287939479459],[null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,-6.90775527898214,-6.90775527898214,-6.90775527898214,-6.90775527898214,-6.90775527898214,-6.21460809842219,-6.21460809842219,-6.21460809842219,-6.21460809842219,-5.80914299031403,-5.80914299031403,-5.52146091786225,-5.52146091786225,-5.29831736654804,-5.29831736654804,-5.11599580975408,-5.11599580975408,-4.96184512992682,-4.8283137373023,-4.71053070164592,-4.71053070164592,-4.60517018598809,-4.50986000618377,-4.60517018598809,-5.11599580975408,-4.96184512992682,-4.8283137373023,-4.60517018598809,-4.96184512992682,-4.8283137373023,-4.8283137373023,-4.8283137373023,-4.60517018598809,-4.50986000618377,-4.3428059215206,-4.26869794936688,-4.19970507787993,-4.07454193492592,-3.9633162998157,-3.81671282562382,-3.77226106305299,-3.72970144863419,-3.68887945411394,-3.61191841297781,-3.54045944899566,-3.44201937618241,-3.38139475436598,-3.29683736633791,-3.2188758248682,-3.17008566069877,-3.12356564506388,-3.10109278921182,-3.05760767727208,-2.93746336543002,-2.84731226843572,-2.78062089393705,-2.7646205525906,-2.71810053695571,-2.64507540194082,-2.59026716544583,-2.53830742651512,-2.47693848013882,-2.43041846450393,-2.3859667019331,-2.3538783873816,-2.30258509299405,-2.24431618487007,-2.1803674602698,-2.12863178587061,-2.04794287462046,-2.00991547903123,-1.98777435315401,-1.93102153656156,-1.89047544216721,-1.85150947363383,-1.79576749062559,-1.75446368448436,-1.72036947314138,-1.95899538860397,-1.9173226922034,-1.87080267656851,-1.83258146374831,-1.80180980508156,-1.78379129957888,-1.76609172247948,-1.73160554640831,-1.67664666212755,-1.67664666212755],[null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,-6.90775527898214,-6.90775527898214,-6.90775527898214,-6.90775527898214,-6.21460809842219,-6.21460809842219,-6.21460809842219,-5.80914299031403,-5.52146091786225,-5.52146091786225,-5.11599580975408,-4.96184512992682,-4.8283137373023,-4.60517018598809,-4.50986000618377,-4.3428059215206,-4.13516655674236,-3.91202300542815,-3.72970144863419,-3.61191841297781,-3.47376807449699,-3.35240721749272,-3.2188758248682,-3.07911388249304,-2.95651156040071,-2.88240358824699,-2.74887219562247,-2.67364877438488,-2.61729583783375,-2.52572864430826,-2.46510402249182,-2.3434070875143,-2.2730262907525,-2.20727491318972,-2.15416508787577,-2.10373423424888,-2.05572501506252,-2.01740615076038,-1.95899538860397,-1.9173226922034,-1.86433016206289,-1.82015894374975,-1.79576749062559,-1.76026080216868,-1.73160554640831,-1.69281952137315,-1.66073120682165,-1.62964061975162,-1.59948758158093,-1.57503648571677,-1.55116900431012,-1.51412773262978,-1.4784096500277,-1.44816976483798,-1.42295834549148,-1.40242374304977,-1.37832619147071,-1.34707364796661,-1.31676829847128,-1.29462717259407,-1.27654349716077,-1.25526609871349,-1.23443201181064,-1.22077992264232,-1.20731170559145,-1.19072757757592,-1.17765549600856,-1.16155208844198,-1.14570389620196,-1.13320373343773,-1.1239300966524,-1.13010295575948,-1.11779510808488,-1.10563690360507,-1.09362474715707,-1.08175517160169,-1.07587280169862,-1.05843049903528,-1.05268335677971,-1.04412410338404,-1.03845836584836,-1.0300194972025,-1.02443289049386,-1.01887732064926,-1.01335244471729,-1.00785792539965,-0.999672340813206,-0.994252273343867,-0.988861424708991,-0.983499481567605,-0.980829253011726,-0.972861083362549,-0.970219073899711,-0.967584026261706,-0.962334670375562,-0.95711272639441,-0.949330585952355,-0.946749939358864,-0.941608539858445,-0.939047718996771],[null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,-6.90775527898214,-6.90775527898214,-6.90775527898214,-6.90775527898214,-6.90775527898214,-6.21460809842219,-6.21460809842219,-6.21460809842219,-5.80914299031403,-5.80914299031403,-5.80914299031403,-5.52146091786225,-5.29831736654804,-5.11599580975408,-5.11599580975408,-4.8283137373023,-4.71053070164592,-4.60517018598809,-4.42284862919414,-4.3428059215206,-4.19970507787993,-4.01738352108597,-3.91202300542815,-3.77226106305299,-3.61191841297781,-3.50655789731998,-3.38139475436598,-3.29683736633791,-3.2188758248682,-3.14655516328857,-3.05760767727208,-2.97592964625781,-2.90042209374967,-2.83021783507642,-2.79688141480883,-2.7333680090865,-2.67364877438488,-2.59026716544583,-2.5133061243097,-2.44184716032755,-2.37515578582888,-2.31263542884755,-2.25379492882461,-2.1982250776698,-2.16282315061889,-2.12026353620009,-2.07944154167984,-2.04022082852655,-2.01740615076038,-1.99510039324608,-1.96611285637283,-1.94491064872223,-1.9173226922034,-1.89047544216721,-1.8773173575897,-1.8773173575897,-1.87080267656851,-1.86433016206289,-1.8578992717326,-1.84516024595517,-1.83258146374831,-1.84516024595517,-1.8578992717326,-1.8578992717326,-1.8578992717326,-1.8578992717326,-1.83885107676191,-1.81400507817537,-1.82635091399767,-1.83258146374831,-1.83258146374831,-1.82635091399767,-1.82635091399767,-1.81400507817537,-1.78976146656538,-1.80788885115794,-1.81400507817537,-1.81400507817537,-1.81400507817537,-1.79576749062559,-1.78379129957888,-1.77195684193188,-1.77785656405906,-1.78379129957888],[null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,-6.90775527898214,-6.90775527898214,-6.90775527898214,-6.90775527898214,-6.90775527898214,-6.90775527898214,-6.90775527898214,-6.90775527898214,-6.90775527898214,-6.90775527898214,-6.90775527898214,-6.90775527898214,-6.90775527898214,-6.90775527898214,-6.90775527898214,-6.21460809842219,-6.21460809842219,-6.21460809842219,-6.21460809842219,-6.21460809842219,-6.21460809842219,-6.21460809842219,-6.21460809842219,-6.21460809842219,-5.80914299031403,-5.80914299031403,-5.80914299031403,-5.80914299031403,-5.80914299031403,-5.80914299031403,-5.80914299031403,-5.52146091786225,-5.52146091786225,-5.52146091786225,-5.52146091786225,-5.52146091786225,-5.52146091786225,-5.52146091786225,-5.29831736654804,-5.29831736654804,-5.29831736654804,-5.29831736654804,-5.11599580975408,-5.11599580975408,-5.11599580975408,-5.11599580975408,-5.11599580975408,-4.96184512992682,-5.11599580975408,-4.96184512992682,-4.96184512992682,-4.96184512992682,-4.8283137373023,-4.8283137373023,-4.8283137373023,-4.71053070164592,-4.71053070164592,-4.60517018598809,-4.60517018598809,-4.60517018598809,-4.50986000618377,-4.50986000618377,-4.50986000618377,-4.50986000618377,-4.42284862919414,-4.42284862919414,-4.42284862919414,-4.42284862919414]],"fixedtz":false,"tzone":"UTC"},"evals":["attrs.interactionModel"],"jsHooks":[]}</script>
<div id="htmlwidget-2c3eb24f203b73d34e4e" style="width:960px;height:500px;" class="dygraphs html-widget"></div>
<script type="application/json" data-for="htmlwidget-2c3eb24f203b73d34e4e">{"x":{"attrs":{"axes":{"x":{"pixelsPerLabel":60,"drawGrid":false,"drawAxis":true},"y":{"drawAxis":true}},"title":"Top Countries - New Active Cases","labels":["day","US","Brazil","United Kingdom","Russia","India"],"retainDateWindow":false,"ylabel":"New Active Cases","stackedGraph":false,"fillGraph":false,"fillAlpha":0.15,"stepPlot":false,"drawPoints":false,"pointSize":1,"drawGapEdgePoints":false,"connectSeparatedPoints":false,"strokeWidth":1,"strokeBorderColor":"white","colors":["#1B9E77","#D95F02","#7570B3","#E7298A","#66A61E"],"colorValue":0.5,"colorSaturation":1,"includeZero":false,"drawAxesAtZero":false,"logscale":false,"axisTickSize":3,"axisLineColor":"navy","axisLineWidth":1.5,"axisLabelColor":"black","axisLabelFontSize":14,"axisLabelWidth":60,"drawGrid":true,"gridLineColor":"lightblue","gridLineWidth":0.3,"rightGap":5,"digitsAfterDecimal":2,"labelsKMB":false,"labelsKMG2":false,"labelsUTC":false,"maxNumberWidth":6,"animatedZooms":false,"mobileDisableYTouch":true,"disableZoom":false,"showRangeSelector":true,"rangeSelectorHeight":40,"rangeSelectorPlotFillColor":" #A7B1C4","rangeSelectorPlotStrokeColor":"#808FAB","interactionModel":"Dygraph.Interaction.defaultModel","legend":"auto","labelsDivWidth":750,"labelsShowZeroValues":true,"labelsSeparateLines":false,"hideOverlayOnMouseOut":true},"scale":"daily","annotations":[],"shadings":[],"events":[],"format":"date","data":[["2020-01-22T00:00:00.000Z","2020-01-23T00:00:00.000Z","2020-01-24T00:00:00.000Z","2020-01-25T00:00:00.000Z","2020-01-26T00:00:00.000Z","2020-01-27T00:00:00.000Z","2020-01-28T00:00:00.000Z","2020-01-29T00:00:00.000Z","2020-01-30T00:00:00.000Z","2020-01-31T00:00:00.000Z","2020-02-01T00:00:00.000Z","2020-02-02T00:00:00.000Z","2020-02-03T00:00:00.000Z","2020-02-04T00:00:00.000Z","2020-02-05T00:00:00.000Z","2020-02-06T00:00:00.000Z","2020-02-07T00:00:00.000Z","2020-02-08T00:00:00.000Z","2020-02-09T00:00:00.000Z","2020-02-10T00:00:00.000Z","2020-02-11T00:00:00.000Z","2020-02-12T00:00:00.000Z","2020-02-13T00:00:00.000Z","2020-02-14T00:00:00.000Z","2020-02-15T00:00:00.000Z","2020-02-16T00:00:00.000Z","2020-02-17T00:00:00.000Z","2020-02-18T00:00:00.000Z","2020-02-19T00:00:00.000Z","2020-02-20T00:00:00.000Z","2020-02-21T00:00:00.000Z","2020-02-22T00:00:00.000Z","2020-02-23T00:00:00.000Z","2020-02-24T00:00:00.000Z","2020-02-25T00:00:00.000Z","2020-02-26T00:00:00.000Z","2020-02-27T00:00:00.000Z","2020-02-28T00:00:00.000Z","2020-02-29T00:00:00.000Z","2020-03-01T00:00:00.000Z","2020-03-02T00:00:00.000Z","2020-03-03T00:00:00.000Z","2020-03-04T00:00:00.000Z","2020-03-05T00:00:00.000Z","2020-03-06T00:00:00.000Z","2020-03-07T00:00:00.000Z","2020-03-08T00:00:00.000Z","2020-03-09T00:00:00.000Z","2020-03-10T00:00:00.000Z","2020-03-11T00:00:00.000Z","2020-03-12T00:00:00.000Z","2020-03-13T00:00:00.000Z","2020-03-14T00:00:00.000Z","2020-03-15T00:00:00.000Z","2020-03-16T00:00:00.000Z","2020-03-17T00:00:00.000Z","2020-03-18T00:00:00.000Z","2020-03-19T00:00:00.000Z","2020-03-20T00:00:00.000Z","2020-03-21T00:00:00.000Z","2020-03-22T00:00:00.000Z","2020-03-23T00:00:00.000Z","2020-03-24T00:00:00.000Z","2020-03-25T00:00:00.000Z","2020-03-26T00:00:00.000Z","2020-03-27T00:00:00.000Z","2020-03-28T00:00:00.000Z","2020-03-29T00:00:00.000Z","2020-03-30T00:00:00.000Z","2020-03-31T00:00:00.000Z","2020-04-01T00:00:00.000Z","2020-04-02T00:00:00.000Z","2020-04-03T00:00:00.000Z","2020-04-04T00:00:00.000Z","2020-04-05T00:00:00.000Z","2020-04-06T00:00:00.000Z","2020-04-07T00:00:00.000Z","2020-04-08T00:00:00.000Z","2020-04-09T00:00:00.000Z","2020-04-10T00:00:00.000Z","2020-04-11T00:00:00.000Z","2020-04-12T00:00:00.000Z","2020-04-13T00:00:00.000Z","2020-04-14T00:00:00.000Z","2020-04-15T00:00:00.000Z","2020-04-16T00:00:00.000Z","2020-04-17T00:00:00.000Z","2020-04-18T00:00:00.000Z","2020-04-19T00:00:00.000Z","2020-04-20T00:00:00.000Z","2020-04-21T00:00:00.000Z","2020-04-22T00:00:00.000Z","2020-04-23T00:00:00.000Z","2020-04-24T00:00:00.000Z","2020-04-25T00:00:00.000Z","2020-04-26T00:00:00.000Z","2020-04-27T00:00:00.000Z","2020-04-28T00:00:00.000Z","2020-04-29T00:00:00.000Z","2020-04-30T00:00:00.000Z","2020-05-01T00:00:00.000Z","2020-05-02T00:00:00.000Z","2020-05-03T00:00:00.000Z","2020-05-04T00:00:00.000Z","2020-05-05T00:00:00.000Z","2020-05-06T00:00:00.000Z","2020-05-07T00:00:00.000Z","2020-05-08T00:00:00.000Z","2020-05-09T00:00:00.000Z","2020-05-10T00:00:00.000Z","2020-05-11T00:00:00.000Z","2020-05-12T00:00:00.000Z","2020-05-13T00:00:00.000Z","2020-05-14T00:00:00.000Z","2020-05-15T00:00:00.000Z","2020-05-16T00:00:00.000Z","2020-05-17T00:00:00.000Z","2020-05-18T00:00:00.000Z","2020-05-19T00:00:00.000Z","2020-05-20T00:00:00.000Z","2020-05-21T00:00:00.000Z","2020-05-22T00:00:00.000Z","2020-05-23T00:00:00.000Z","2020-05-24T00:00:00.000Z","2020-05-25T00:00:00.000Z","2020-05-26T00:00:00.000Z","2020-05-27T00:00:00.000Z","2020-05-28T00:00:00.000Z","2020-05-29T00:00:00.000Z","2020-05-30T00:00:00.000Z","2020-05-31T00:00:00.000Z","2020-06-01T00:00:00.000Z","2020-06-02T00:00:00.000Z","2020-06-03T00:00:00.000Z","2020-06-04T00:00:00.000Z","2020-06-05T00:00:00.000Z","2020-06-06T00:00:00.000Z","2020-06-07T00:00:00.000Z","2020-06-08T00:00:00.000Z","2020-06-09T00:00:00.000Z","2020-06-10T00:00:00.000Z","2020-06-11T00:00:00.000Z","2020-06-12T00:00:00.000Z","2020-06-13T00:00:00.000Z","2020-06-14T00:00:00.000Z","2020-06-15T00:00:00.000Z","2020-06-16T00:00:00.000Z","2020-06-17T00:00:00.000Z"],[0,0,1,0,3,0,0,0,0,2,1,0,3,0,0,0,0,0,-3,0,1,0,1,0,0,0,0,0,0,0,0,0,0,0,-1,0,1,-1,7,6,18,19,27,69,46,112,110,67,185,394,437,587,706,85,1359,1747,2628,5145,5203,6220,7792,9905,9858,11613,17309,17438,18960,16922,17711,23415,22824,28310,29939,26953,23667,25842,26295,27819,30859,28050,25523,25101,13001,20361,22281,26604,26292,19681,19379,23579,20226,23704,29046,15638,29359,19925,16700,17883,20004,-5525,22142,16403,19495,14200,19424,22749,20545,21691,10572,15409,1152,22707,6309,22856,19334,6250,14306,10005,12715,17169,20186,-28856,9613,14659,6047,12405,10255,13160,16857,13290,-8773,3110,14223,3508,14516,17637,12866,11802,4824,10808,11264,15212,17456,15553,14026,5055,15700,16117],[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,1,0,0,0,2,0,9,0,7,5,6,7,14,99,0,11,37,119,49,246,167,224,515,369,311,294,409,417,468,327,186,1089,1080,1124,977,1218,729,953,1751,2003,1745,1439,1022,1366,1133,-1245,-8126,1917,3040,2763,-6216,1964,1321,186,2599,2552,3423,2555,3039,3907,4432,5206,2505,1651,2382,3654,3858,7357,4580,6347,6140,2899,3938,2599,5317,11214,10672,7818,2663,7216,9052,8929,8043,10332,8386,7836,6958,10525,11459,14304,13932,20902,10266,6450,15116,12305,13106,17848,15962,11584,-79330,12339,14460,13124,9915,6499,6793,11452,21340,-122],[0,0,0,0,0,0,0,0,0,2,0,0,0,0,0,0,1,0,0,5,0,0,0,0,0,-7,0,0,0,0,0,0,0,4,0,0,2,5,3,13,4,11,35,30,47,32,67,47,57,75,-2,342,324,-14,381,361,634,31,1262,997,643,907,1216,1290,1978,2648,2273,2253,2279,2637,3713,3643,3785,3020,5299,3214,2594,4469,3280,7351,4395,4642,3941,4208,3747,3622,4669,4407,5337,4109,2952,3574,3850,4369,4035,4044,3941,3085,3250,5362,5430,4189,4022,3692,3703,5459,5043,3998,3546,3655,3659,2773,2740,3015,3175,2978,3364,2522,1874,-900,2271,2939,2671,2292,1500,3918,1603,1511,1770,1382,1821,993,1328,1531,1626,1289,1354,1241,1142,1457,750,1112,1336,1244,1478,934,1043,922],[0,0,0,0,0,0,0,0,0,2,0,0,0,0,0,0,0,0,0,0,0,-2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,1,9,0,3,0,3,0,8,17,9,4,27,24,33,50,54,50,57,71,51,154,173,188,224,251,299,438,364,720,551,521,634,901,1055,1084,1328,1671,1405,1916,2361,2528,3068,3096,3743,4278,5778,4069,5164,4632,4261,5112,5218,5778,5572,5228,3906,5665,6236,7777,8949,9049,8237,9011,8667,7796,5405,8534,6067,7081,5441,4354,5789,4141,5408,5999,3227,-633,1433,1600,1184,3083,3355,-3590,-2902,-588,76,559,4716,4698,-2412,-605,17,534,-49,3500,4904,-3275,-2201,251,565,3317,3282,3589,-1711,-2390],[0,0,0,0,0,0,0,0,1,0,0,1,1,0,0,0,0,0,0,0,0,0,0,0,0,-3,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2,0,23,2,1,3,5,4,12,5,11,8,20,2,6,21,14,36,44,84,59,100,24,116,60,132,85,23,215,122,553,488,23,464,493,1007,473,492,647,699,611,605,1120,821,750,729,611,913,1464,472,786,859,1025,908,1267,967,889,1194,977,1095,1386,1530,1782,2685,1541,2306,1815,2137,1583,2574,1945,1532,1647,2275,1394,780,2325,2061,2925,2308,2917,3155,3926,3650,3252,2100,3631,3952,-3871,3822,3643,3659,4069,5588,5235,4402,4679,5450,2929,4366,9571,-1455,3937,3569,3758,72,2049,5157]],"fixedtz":false,"tzone":"UTC"},"evals":["attrs.interactionModel"],"jsHooks":[]}</script>
<div id="htmlwidget-1206b6b0ea63b92ab240" style="width:960px;height:500px;" class="dygraphs html-widget"></div>
<script type="application/json" data-for="htmlwidget-1206b6b0ea63b92ab240">{"x":{"attrs":{"axes":{"x":{"pixelsPerLabel":60,"drawGrid":false,"drawAxis":true},"y":{"drawAxis":true}},"title":"Top Countries - Log Of New Active Cases","labels":["day","US","Brazil","United Kingdom","Russia","India"],"retainDateWindow":false,"ylabel":"Log Of New Active Cases","stackedGraph":false,"fillGraph":false,"fillAlpha":0.15,"stepPlot":false,"drawPoints":false,"pointSize":1,"drawGapEdgePoints":false,"connectSeparatedPoints":false,"strokeWidth":1,"strokeBorderColor":"white","colors":["#1B9E77","#D95F02","#7570B3","#E7298A","#66A61E"],"colorValue":0.5,"colorSaturation":1,"includeZero":false,"drawAxesAtZero":false,"logscale":false,"axisTickSize":3,"axisLineColor":"navy","axisLineWidth":1.5,"axisLabelColor":"black","axisLabelFontSize":14,"axisLabelWidth":60,"drawGrid":true,"gridLineColor":"lightblue","gridLineWidth":0.3,"rightGap":5,"digitsAfterDecimal":2,"labelsKMB":false,"labelsKMG2":false,"labelsUTC":false,"maxNumberWidth":6,"animatedZooms":false,"mobileDisableYTouch":true,"disableZoom":false,"showRangeSelector":true,"rangeSelectorHeight":40,"rangeSelectorPlotFillColor":" #A7B1C4","rangeSelectorPlotStrokeColor":"#808FAB","interactionModel":"Dygraph.Interaction.defaultModel","legend":"auto","labelsDivWidth":750,"labelsShowZeroValues":true,"labelsSeparateLines":false,"hideOverlayOnMouseOut":true},"scale":"daily","annotations":[],"shadings":[],"events":[],"format":"date","data":[["2020-01-22T00:00:00.000Z","2020-01-23T00:00:00.000Z","2020-01-24T00:00:00.000Z","2020-01-25T00:00:00.000Z","2020-01-26T00:00:00.000Z","2020-01-27T00:00:00.000Z","2020-01-28T00:00:00.000Z","2020-01-29T00:00:00.000Z","2020-01-30T00:00:00.000Z","2020-01-31T00:00:00.000Z","2020-02-01T00:00:00.000Z","2020-02-02T00:00:00.000Z","2020-02-03T00:00:00.000Z","2020-02-04T00:00:00.000Z","2020-02-05T00:00:00.000Z","2020-02-06T00:00:00.000Z","2020-02-07T00:00:00.000Z","2020-02-08T00:00:00.000Z","2020-02-09T00:00:00.000Z","2020-02-10T00:00:00.000Z","2020-02-11T00:00:00.000Z","2020-02-12T00:00:00.000Z","2020-02-13T00:00:00.000Z","2020-02-14T00:00:00.000Z","2020-02-15T00:00:00.000Z","2020-02-16T00:00:00.000Z","2020-02-17T00:00:00.000Z","2020-02-18T00:00:00.000Z","2020-02-19T00:00:00.000Z","2020-02-20T00:00:00.000Z","2020-02-21T00:00:00.000Z","2020-02-22T00:00:00.000Z","2020-02-23T00:00:00.000Z","2020-02-24T00:00:00.000Z","2020-02-25T00:00:00.000Z","2020-02-26T00:00:00.000Z","2020-02-27T00:00:00.000Z","2020-02-28T00:00:00.000Z","2020-02-29T00:00:00.000Z","2020-03-01T00:00:00.000Z","2020-03-02T00:00:00.000Z","2020-03-03T00:00:00.000Z","2020-03-04T00:00:00.000Z","2020-03-05T00:00:00.000Z","2020-03-06T00:00:00.000Z","2020-03-07T00:00:00.000Z","2020-03-08T00:00:00.000Z","2020-03-09T00:00:00.000Z","2020-03-10T00:00:00.000Z","2020-03-11T00:00:00.000Z","2020-03-12T00:00:00.000Z","2020-03-13T00:00:00.000Z","2020-03-14T00:00:00.000Z","2020-03-15T00:00:00.000Z","2020-03-16T00:00:00.000Z","2020-03-17T00:00:00.000Z","2020-03-18T00:00:00.000Z","2020-03-19T00:00:00.000Z","2020-03-20T00:00:00.000Z","2020-03-21T00:00:00.000Z","2020-03-22T00:00:00.000Z","2020-03-23T00:00:00.000Z","2020-03-24T00:00:00.000Z","2020-03-25T00:00:00.000Z","2020-03-26T00:00:00.000Z","2020-03-27T00:00:00.000Z","2020-03-28T00:00:00.000Z","2020-03-29T00:00:00.000Z","2020-03-30T00:00:00.000Z","2020-03-31T00:00:00.000Z","2020-04-01T00:00:00.000Z","2020-04-02T00:00:00.000Z","2020-04-03T00:00:00.000Z","2020-04-04T00:00:00.000Z","2020-04-05T00:00:00.000Z","2020-04-06T00:00:00.000Z","2020-04-07T00:00:00.000Z","2020-04-08T00:00:00.000Z","2020-04-09T00:00:00.000Z","2020-04-10T00:00:00.000Z","2020-04-11T00:00:00.000Z","2020-04-12T00:00:00.000Z","2020-04-13T00:00:00.000Z","2020-04-14T00:00:00.000Z","2020-04-15T00:00:00.000Z","2020-04-16T00:00:00.000Z","2020-04-17T00:00:00.000Z","2020-04-18T00:00:00.000Z","2020-04-19T00:00:00.000Z","2020-04-20T00:00:00.000Z","2020-04-21T00:00:00.000Z","2020-04-22T00:00:00.000Z","2020-04-23T00:00:00.000Z","2020-04-24T00:00:00.000Z","2020-04-25T00:00:00.000Z","2020-04-26T00:00:00.000Z","2020-04-27T00:00:00.000Z","2020-04-28T00:00:00.000Z","2020-04-29T00:00:00.000Z","2020-04-30T00:00:00.000Z","2020-05-01T00:00:00.000Z","2020-05-02T00:00:00.000Z","2020-05-03T00:00:00.000Z","2020-05-04T00:00:00.000Z","2020-05-05T00:00:00.000Z","2020-05-06T00:00:00.000Z","2020-05-07T00:00:00.000Z","2020-05-08T00:00:00.000Z","2020-05-09T00:00:00.000Z","2020-05-10T00:00:00.000Z","2020-05-11T00:00:00.000Z","2020-05-12T00:00:00.000Z","2020-05-13T00:00:00.000Z","2020-05-14T00:00:00.000Z","2020-05-15T00:00:00.000Z","2020-05-16T00:00:00.000Z","2020-05-17T00:00:00.000Z","2020-05-18T00:00:00.000Z","2020-05-19T00:00:00.000Z","2020-05-20T00:00:00.000Z","2020-05-21T00:00:00.000Z","2020-05-22T00:00:00.000Z","2020-05-23T00:00:00.000Z","2020-05-24T00:00:00.000Z","2020-05-25T00:00:00.000Z","2020-05-26T00:00:00.000Z","2020-05-27T00:00:00.000Z","2020-05-28T00:00:00.000Z","2020-05-29T00:00:00.000Z","2020-05-30T00:00:00.000Z","2020-05-31T00:00:00.000Z","2020-06-01T00:00:00.000Z","2020-06-02T00:00:00.000Z","2020-06-03T00:00:00.000Z","2020-06-04T00:00:00.000Z","2020-06-05T00:00:00.000Z","2020-06-06T00:00:00.000Z","2020-06-07T00:00:00.000Z","2020-06-08T00:00:00.000Z","2020-06-09T00:00:00.000Z","2020-06-10T00:00:00.000Z","2020-06-11T00:00:00.000Z","2020-06-12T00:00:00.000Z","2020-06-13T00:00:00.000Z","2020-06-14T00:00:00.000Z","2020-06-15T00:00:00.000Z","2020-06-16T00:00:00.000Z","2020-06-17T00:00:00.000Z"],[null,null,0,null,1.09861228866811,null,null,null,null,0.693147180559945,0,null,1.09861228866811,null,null,null,null,null,null,null,0,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,0,null,1.94591014905531,1.79175946922805,2.89037175789616,2.94443897916644,3.29583686600433,4.23410650459726,3.8286413964891,4.71849887129509,4.70048036579242,4.20469261939097,5.22035582507832,5.97635090929793,6.07993319509559,6.3750248198281,6.55961523749324,4.44265125649032,7.21450441415114,7.46565531013406,7.8739783796045,8.54578064826815,8.5569906612903,8.73552518573323,8.96085284532237,9.20079495913265,9.19603858726532,9.35988043924576,9.7589818764264,9.76640701198776,9.85008677580901,9.73636982948445,9.78194119445663,10.0611321216176,10.0355678928933,10.2509703781059,10.3069172572822,10.201849887396,10.0718369517632,10.1597563542822,10.1771340860234,10.2334745194683,10.3371837209851,10.2417439109508,10.1473352854086,10.1306629649637,9.47278155656217,9.92137658537187,10.0114895763374,10.1888168594043,10.1770199893835,9.88740898232344,9.87194528452625,10.068111764371,9.91472418446212,10.0733990892534,10.2766360591677,9.65745912868446,10.2873544222029,9.89973050365842,9.72316399840485,9.79160581988804,9.90368753253879,null,10.0052315364194,9.70521952391249,9.8779133014167,9.56099724358935,9.87426469385922,10.032276467369,9.93037288131751,9.98465270695364,9.26596427572418,9.64270703328185,7.04925484125584,10.0304285259773,8.74973246437081,10.0369689439106,9.86962048302455,8.74033674273045,9.56843430866833,9.21084024701783,9.45053767785622,9.75086071107721,9.9127445737988,null,9.17087162806582,9.59280976029003,8.70731756027321,9.4258548961259,9.23552067050648,9.48493720487931,9.73252127978031,9.49476715170729,null,8.04237800517328,9.56261565157023,8.16280135349207,9.58300676833296,9.77775424707036,9.46234345197094,9.37602428761711,8.48135873840702,9.28804187964004,9.32936707839782,9.62983986904815,9.76743870807285,9.65200882504456,9.54866802909686,8.52813313145457,9.6614159913364,9.68762989452272],[null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,0,null,null,0,null,null,null,0.693147180559945,null,2.19722457733622,null,1.94591014905531,1.6094379124341,1.79175946922805,1.94591014905531,2.63905732961526,4.59511985013459,null,2.39789527279837,3.61091791264422,4.77912349311153,3.89182029811063,5.50533153593236,5.11799381241676,5.41164605185504,6.24416690066374,5.91079664404053,5.73979291217923,5.68357976733868,6.0137151560428,6.0330862217988,6.14846829591765,5.78996017089725,5.2257466737132,6.99301512293296,6.98471632011827,7.02464903045364,6.88448665204278,7.10496544826984,6.59167373200866,6.8596149036542,7.46794233228585,7.60240133566582,7.46450983463653,7.27170370688737,6.92951677076365,7.21964204013074,7.03262426102801,null,null,7.55851674304564,8.01961279440027,7.92407232492342,null,7.58273848891441,7.18614430452233,5.2257466737132,7.86288203464149,7.84463264446468,8.13827263853019,7.8458075026378,8.01928379291679,8.27052509505507,8.39660622842712,8.55756708555451,7.82604401351897,7.40913644392013,7.77569574991525,8.20357773693795,8.25790419346567,8.90340751993226,8.42945427710823,8.75573753930647,8.72258002114119,7.97212112892166,8.27842825919907,7.86288203464149,8.57866451350434,9.32491827668362,9.2753787681554,8.9641840463529,7.88720858581393,8.88405606174246,9.11074100675343,9.09705968551722,8.99255742690407,9.24300115421573,9.03431892773071,8.96648377906443,8.84764735571189,9.26150865855058,9.34653072642645,9.5682944974133,9.54194363148589,9.94760012715445,9.23659274312025,8.77183540978982,9.62350906446938,9.41776096282516,9.48082541959944,9.78964673611237,9.67796617643595,9.3573801146255,null,9.42052025689853,9.57914149571276,9.48219789408099,9.2018040409539,8.77940359789435,8.8236479491913,9.34591966621801,9.96833852485574,null],[null,null,null,null,null,null,null,null,null,0.693147180559945,null,null,null,null,null,null,0,null,null,1.6094379124341,null,null,null,null,null,null,null,null,null,null,null,null,null,1.38629436111989,null,null,0.693147180559945,1.6094379124341,1.09861228866811,2.56494935746154,1.38629436111989,2.39789527279837,3.55534806148941,3.40119738166216,3.85014760171006,3.46573590279973,4.20469261939097,3.85014760171006,4.04305126783455,4.31748811353631,null,5.8348107370626,5.78074351579233,null,5.9427993751267,5.88887795833288,6.45204895443723,3.43398720448515,7.14045304310116,6.90475076996184,6.46614472423762,6.81014245011514,7.10332206252611,7.16239749735572,7.58984151218266,7.8815599170569,7.72885582385254,7.72001794043224,7.73149202924568,7.87739718635329,8.21959545417708,8.20056279700856,8.23880116587155,8.01301211036892,8.57527340249276,8.07527154629746,7.86095636487639,8.40491994893345,8.09559870137819,8.90259163737409,8.38822281011928,8.44290058683438,8.279189777195,8.34474275441755,8.22871079879369,8.19478163844336,8.44870019497094,8.39094946484199,8.58241897633394,8.32093496888341,7.99023818572036,8.18144069571937,8.25582842728183,8.38228942895144,8.30276158070405,8.30498958014036,8.279189777195,8.03430693633949,8.08641027532378,8.58709231879591,8.59969441292798,8.34021732094704,8.2995345703326,8.21392359562274,8.21689858091361,8.60502090178176,8.52575642207673,8.29354951506035,8.17357548663415,8.20385137218388,8.20494516501921,7.92768504561578,7.91571319938212,8.01135510916129,8.06306291132679,7.99900721324395,8.12088602109284,7.83280751652486,7.53583046279837,null,7.72797554210556,7.98582466641892,7.89020821310996,7.73718007783463,7.3132203870903,8.27333659850449,7.37963215260955,7.32052696227274,7.47873482556787,7.23128700432762,7.50714107972761,6.90073066404517,7.19142933003638,7.33367639565768,7.39387829010776,7.16162200293919,7.21081845347222,7.12367278520461,7.04053639021596,7.2841348061952,6.62007320653036,7.01391547481053,7.19743535409659,7.12608727329912,7.29844510150815,6.83947643822884,6.94985645500077,6.82654522355659],[null,null,null,null,null,null,null,null,null,0.693147180559945,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,0,null,null,0,2.19722457733622,null,1.09861228866811,null,1.09861228866811,null,2.07944154167984,2.83321334405622,2.19722457733622,1.38629436111989,3.29583686600433,3.17805383034795,3.49650756146648,3.91202300542815,3.98898404656427,3.91202300542815,4.04305126783455,4.26267987704132,3.93182563272433,5.03695260241363,5.15329159449778,5.23644196282995,5.41164605185504,5.52545293913178,5.70044357339069,6.08221891037645,5.89715386763674,6.5792512120101,6.31173480915291,6.25575004175337,6.45204895443723,6.80350525760834,6.96129604591017,6.98841318199959,7.19142933003638,7.42117752859539,7.24779258176785,7.55799495853081,7.76684053708551,7.83518375526675,8.02878116248715,8.03786623470962,8.22764270790443,8.36124088964235,8.66181288102618,8.31115254800169,8.54946675196653,8.44074401925283,8.35725915349991,8.53934599605737,8.55986946569667,8.66181288102618,8.6255093348997,8.56178407474411,8.27026911143662,8.64206217346211,8.73809423017767,8.95892593869494,9.09929707318286,9.11040953335113,9.01639147894125,9.10620133223504,9.06727798913434,8.96136606062745,8.59507973007331,9.05181346374795,8.7106195279423,8.86517041965177,8.60171814648593,8.37885024179449,8.663714844079,8.32869258354557,8.5956346177228,8.69934806765309,8.07930819205196,null,7.26752542782817,7.37775890822787,7.07665381544395,8.03365842788615,8.11820704940578,null,null,null,4.33073334028633,6.3261494731551,8.45871626165726,8.45489216521886,null,null,2.83321334405622,6.2803958389602,null,8.1605182474775,8.49780647761605,null,null,5.52545293913178,6.33682573114644,8.10681603894705,8.09620827165004,8.18562889114761,null,null],[null,null,null,null,null,null,null,null,0,null,null,0,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,0.693147180559945,null,3.13549421592915,0.693147180559945,0,1.09861228866811,1.6094379124341,1.38629436111989,2.484906649788,1.6094379124341,2.39789527279837,2.07944154167984,2.99573227355399,0.693147180559945,1.79175946922805,3.04452243772342,2.63905732961526,3.58351893845611,3.78418963391826,4.43081679884331,4.07753744390572,4.60517018598809,3.17805383034795,4.75359019110636,4.0943445622221,4.88280192258637,4.44265125649032,3.13549421592915,5.37063802812766,4.80402104473326,6.31535800152233,6.19031540585315,3.13549421592915,6.13988455222626,6.20050917404269,6.91473089271856,6.15909538849193,6.19847871649231,6.4723462945009,6.54965074223381,6.4150969591716,6.40522845803084,7.02108396428914,6.71052310945243,6.62007320653036,6.59167373200866,6.4150969591716,6.81673588059497,7.28892769452126,6.15697898558556,6.66695679242921,6.75576892198425,6.93244789157251,6.81124437860129,7.14440718032114,6.87419849545329,6.7900972355139,7.08506429395255,6.88448665204278,6.9985096422506,7.23417717974985,7.33302301438648,7.48549160803075,7.89543600694297,7.34018683532012,7.743269700829,7.50384074669895,7.66715825531915,7.36707705988101,7.85321638815607,7.57301725605255,7.33432935030054,7.40671073017764,7.72973533138505,7.23993259132047,6.65929391968364,7.75147531802146,7.63094658089046,7.98104975966596,7.74413662762799,7.97831096986772,8.05674377497531,8.27537637483641,8.20248244657654,8.0870254706677,7.64969262371151,8.19726337141434,8.28197705886776,null,8.24852912480022,8.20056279700856,8.20494516501921,8.31115254800169,8.62837672037685,8.56312212330464,8.38981426208641,8.45083969086622,8.60337088765729,7.98241634682773,8.38160253710989,9.16649297219591,null,8.27817429094374,8.18004072349016,8.23164217997341,4.27666611901606,7.6251071482389,8.54811029405096]],"fixedtz":false,"tzone":"UTC"},"evals":["attrs.interactionModel"],"jsHooks":[]}</script><!--/html_preserve-->



---

#### IN CONSTRUCTION...

**Log of Rate of Change**




![](COVID19_DATA_ANALYSIS_files/figure-html/unnamed-chunk-14-1.png)<!-- -->![](COVID19_DATA_ANALYSIS_files/figure-html/unnamed-chunk-14-2.png)<!-- -->![](COVID19_DATA_ANALYSIS_files/figure-html/unnamed-chunk-14-3.png)<!-- -->![](COVID19_DATA_ANALYSIS_files/figure-html/unnamed-chunk-14-4.png)<!-- -->![](COVID19_DATA_ANALYSIS_files/figure-html/unnamed-chunk-14-5.png)<!-- -->





```

OTHER PLOTS:


  Doubling rate.
  
  Proportion of New Cases to Total Cases.
  
  Percentage increase + hline showing proportion of population to world population.
  
  Outcome Simulation section.
  
  Add more links throughough document.
  

```




---



[Back to [Contents](#contents-link)]{style="float:right"}

### Code Appendix {#codeappendix-link}



```r
## ----setup, include=FALSE------------------------------------------------
knitr::opts_chunk$set(echo = TRUE)
knitr::opts_chunk$set(message = FALSE)
knitr::opts_chunk$set(warning = FALSE)

## ----include=FALSE-------------------------------------------------------

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


packages <- c("dygraphs", "tidyverse", "xts", "RColorBrewer","kableExtra")
suppressPackageStartupMessages(install_packages(packages))

# directory structure setup 
dir_name <- "COVID19_DATA"
if (!file.exists(dir_name)) {
	dir.create(dir_name)
}

dir_path <- "COVID19_DATA/"

# check if today's RDS file exists 
rds_file <- paste0(dir_path, gsub("-", "", Sys.Date()), "_data.rds")

if (!file.exists(rds_file)) {

	# download todays's CSVs
	
	# standard fullpath names for today's CSVs 
	confirmed_csv <- paste0(dir_path, gsub("-", "", Sys.Date()), "_confirmed.csv")
	deaths_csv	  <- paste0(dir_path, gsub("-", "", Sys.Date()), "_deaths.csv")
	recovered_csv <- paste0(dir_path, gsub("-", "", Sys.Date()), "_recovered.csv")
	
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
	download_csv(recovered_csv)
	
	# load data into environment
	load_csv <- function(fullpath_csv) { 
	
		read.csv(fullpath_csv
				, header=TRUE
				, fileEncoding="UTF-8-BOM"
				, stringsAsFactors=FALSE, na.strings="")[-1, ]
	}
	
		
	confirmed_df  <- load_csv(confirmed_csv)
	fatal_df	  <- load_csv(deaths_csv) 
	recovered_df <- load_csv(recovered_csv)
	
	# need an active dataset for confirmed - deaths - recovered 
	# will fix count (Value) later after fixing data types 
	active_df 	   <- confirmed_df
	
	preprocess_csv <- function(dfm, colname) {
	
		# prep data for long format (rbing later)
		
		# add Status col identifying the dataset
		# remove Lat Long
		# rename cols 
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
	fatal_clean 	 <- preprocess_csv(fatal_df, "Fatal")
	recovered_clean  <- preprocess_csv(recovered_df, "Recovered")
	active_clean	 <- preprocess_csv(active_df, "Active")
	
	# recalculate Counts for active
	active_clean$Count <- (confirmed_clean$Count 
						- fatal_clean$Count 
						- recovered_clean$Count)
	
	# row bind (append) files into one dataset 
	dfm <- rbind(confirmed_clean
				, fatal_clean
				, recovered_clean
				, active_clean
				, make.row.names=FALSE)
	
	# save as RDS 
	saveRDS(dfm, file = rds_file)
}


# read RDS file 
dfm <- readRDS(rds_file) 

# calculate number of countries and number of days in the time series
Ncountries <- length(unique(dfm$Country))
Ndays <- length(unique(dfm$Date))

## ------------------------------------------------------------------------
# structure of dataset
str(dfm)


nrow(dfm)
length(dfm)
Ndays
Ncountries
## ----echo=FALSE----------------------------------------------------------
# top and bottom rows for final dataset
kable(rbind(head(dfm)
     ,tail(dfm))) %>%
      kable_styling(bootstrap_options = c("striped", "hover", "condensed")
                  , full_width = FALSE)

## ----include=FALSE-------------------------------------------------------
# read in static dataset of countries and populations
country_population <- read.csv("COVID19_DATA/country_population.csv")
		  
# test for new countries in data -- manual step
current_countries <- unique(dfm$Country)
current_countries[!current_countries %in% country_population$Country]

## ----include=FALSE-------------------------------------------------------
# merge datasets
percap <- merge(dfm, country_population, by="Country")

# create percentage col
percap$Pct <- round(percap$Count/(percap$Population_thousands*1000)*100, 3)

# reorder by Country, Status, and Date descending
percap <- data.frame(percap %>% 
                     arrange(Country, Status, desc(Date)))

# calculate new cases
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

## ----echo=FALSE----------------------------------------------------------
# top and bottom rows for final dataset
kable(rbind(head(percap[percap$Country == "Brazil", ])
     ,head(percap[percap$Country == "Canada", ]))) %>%
      kable_styling(bootstrap_options = c("striped", "hover", "condensed")
                  , full_width = FALSE)

## ----echo=FALSE, fig.height=6, fig.width=6-------------------------------
# subset to current counts 
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

## ----echo=FALSE----------------------------------------------------------
# subset to country totals 
country_totals <- data.frame(current_data %>%
						select(Country, Status, Count, Pct, NewCases) %>%
						group_by(Country, Status))
	
# subset to top counts 	
get_top_counts <- function(dfm, coln, num) {
	
	dfm <- dfm[dfm$Status == coln, ][1:num,]
	row.names(dfm) <- 1:num
	dfm
}					

# separate by status 
top_confirmed 	<- get_top_counts(country_totals, "Confirmed", 10)
top_fatal		<- get_top_counts(country_totals, "Fatal", 10)
top_recovered 	<- get_top_counts(country_totals, "Recovered", 10)
top_active 		<- get_top_counts(country_totals, "Active", 10)

# plot top countries per status and type
gg_plot <- function(dfm, status, type) {

	color <- if (status == "Confirmed") {
				"#D6604D"
			 } else if (status == "Fatal") {
				"gray25"
			 } else if (status == "Recovered") {
				"#74C476"
			 } else {
				"#984EA3"
			 }
	
	if (type == "Count") {	
		ggplot(data=dfm, aes(x=reorder(Country, -Count), y=Count)) +
			geom_bar(stat="identity", fill=color) + 
			ggtitle(paste0("Top Countries - ", status, " Cases")) + 
			xlab("") + ylab(paste0("Number of ", status, " Cases")) +
			geom_text(aes(label=Count), vjust=1.6, color="white", size=3.5) +
			theme_minimal() + 
			theme(axis.text.x = element_text(angle = 45, hjust = 1))
	} else if (type == "Pct") {
		ggplot(data=dfm, aes(x=reorder(Country, -Pct), y=Pct)) +
			geom_bar(stat="identity", fill=color) + 		
			ggtitle(paste0("Top Countries: ", status
						 , " Cases by Percentage of Population")) + 
			xlab("") + ylab(paste0("Percentage of ", status, " Cases")) +
			geom_text(aes(label=Pct), vjust=1.6, color="white", size=3.5) +
			theme_minimal() + 		
			theme(axis.text.x = element_text(angle = 45, hjust = 1))
	} else {
		ggplot(data=dfm, aes(x=reorder(Country, -NewCases), y=NewCases)) +
			geom_bar(stat="identity", fill=color) + 
			ggtitle(paste0("Top Countries: Yesterday's ", status
						 , " New Cases")) + 
			xlab("") + ylab("Number of New Cases") +
			geom_text(aes(label=NewCases), vjust=1.6, color="white", size=3.5) +
			theme_minimal() + 
			theme(axis.text.x = element_text(angle = 45, hjust = 1))			
	}
}

## ----fig.height=4, fig.width=8, echo=FALSE-------------------------------
# top countries by count
gg_plot(top_confirmed, "Confirmed", "Count") 
gg_plot(top_fatal, "Fatal", "Count")
gg_plot(top_recovered, "Recovered", "Count")
#gg_plot(top_active, "Active", "Count")

# top countries by percentage
gg_plot(top_confirmed, "Confirmed", "Pct") 
gg_plot(top_fatal, "Fatal", "Pct")
gg_plot(top_recovered, "Recovered", "Pct")
#gg_plot(top_active, "Active", "Pct")

# top countries by number of new cases in the last day 
gg_plot(top_confirmed, "Confirmed", "NewCases") 
gg_plot(top_fatal, "Fatal", "NewCases")
gg_plot(top_recovered, "Recovered", "NewCases")
#gg_plot(top_active, "Active", "NewCases")

## ----echo=FALSE----------------------------------------------------------
plot_types <- data.frame('Num' = 1:12
              ,'Status' = c(rep("Active", 6)
									  ,rep("Fatal", 6))
						  ,'Type' = rep(c("Count","Pct","NewCases"), each=2)									  
						  ,'Scale' = rep(c("Linear","Log"), 2)
						  )
	
kable(plot_types) %>%
      kable_styling(bootstrap_options = c("striped", "hover", "condensed")
                    , full_width = FALSE)

## ----message=FALSE, warnings=FALSE, echo=FALSE---------------------------
# functions for plotting interactive time series

# arg values:
# dfm = the dataframe
# country = country name
# status_df = to be used as the vector of country names 
#             which is passed instead of a single country
# status = Confirmed, Fatal, Recovered, Active
# scale_ = Linear, Log
# type = Count, Pct, NewCases

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
    
    txt_ <- if (scale_ == "Linear") {
	  				"Count Of "
	  			} else {
	  			  "Log Count Of "
	  			}			
				
  } else if (type == "Pct") {
    
    txt_ <- if (scale_ == "Linear") {
	  				"Percentage Of "
	  			} else {
	  			  "Log Percentage Of "
	  			} 		
				
  } else {
    
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

## ----message=FALSE, warnings=FALSE, echo=FALSE---------------------------
## INTERACTIVE TIME SERIES

# Fatal plots 
fatal_plots <- lapply(1:6, function(i) plot_interactive_df(percap
							                     , top_fatal[1:5, ]
							                     , top_fatal$Status[i]
							                     , plot_types$Scale[i]
							                     , plot_types$Type[i]))
		
htmltools::tagList(fatal_plots)

# Active plots 
active_plots <- lapply(1:6, function(i) plot_interactive_df(percap
							                     , top_active[1:5, ]
							                     , top_active$Status[i]
							                     , plot_types$Scale[i]
							                     , plot_types$Type[i]))
		
htmltools::tagList(active_plots)

## ----include=FALSE-------------------------------------------------------
# Log2 of Count
percap$Log2Count <- log2(percap$Count)


# calculate log2 rate of change
percap$Log2RateOfChange <- NULL

for (i in  seq.int(from=1, to=(nrow(percap)-1), by=Ndays)) {
	
	for (j in i:(i+Ndays-1)) {
	  
		if (percap$Count[j] > 10) {
      
			percap$Log2RateOfChange[j] <- percap$Log2Count[j] - percap$Log2Count[j+1]
		  
		} else {
		
			# avoid wild rates of change on low counts
			percap$Log2RateOfChange[j] <- 0
		}
	}
  
	if (i > 1) {
	
		# fix last row of a given time series
		percap$Log2RateOfChange[i-1] <- 0
	}  
}

## ----fig.height=6, fig.width=9, echo=FALSE-------------------------------
# Single dual-axis plot of count + log2 rate of change

# test with US fatalities
x <- percap[percap$Country == "US" & percap$Status == "Fatal" & percap$Log2RateOfChange > 0, ]

ggplot(x, aes(x = Date)) +
	geom_line(aes(y = Log2RateOfChange, colour = "Log2RateOfChange")) +
	geom_line(aes(y = Count/10000, colour = "Count/10000")) +
	scale_y_continuous(sec.axis = sec_axis(~.*10000, name = "Count")) +
	scale_colour_manual(values = c("black", "red")) +
	labs(title = "US Fatalities"
		,y = "Log2 Rate of Change"
		,x = ""
		,colour = "Parameter") +
	theme(legend.title = element_blank(), legend.position = c(.6, .9))


# test with Spain fatalities
x <- percap[percap$Country == "Spain" & percap$Status == "Fatal" & percap$Log2RateOfChange > 0, ]

ggplot(x, aes(x = Date)) +
	geom_line(aes(y = Log2RateOfChange, colour = "Log2RateOfChange")) +
	geom_line(aes(y = Count/10000, colour = "Count/10000")) +
	scale_y_continuous(sec.axis = sec_axis(~.*10000, name = "Count")) +
	scale_colour_manual(values = c("black", "red")) +
	labs(title = "Spain Fatalities"
		,y = "Log2 Rate of Change"
		,x = ""
		,colour = "Parameter") +
	theme(legend.title = element_blank(), legend.position = c(.6, .9))

# test with Italy fatalities
x <- percap[percap$Country == "Italy" & percap$Status == "Fatal" & percap$Log2RateOfChange > 0, ]

ggplot(x, aes(x = Date)) +
	geom_line(aes(y = Log2RateOfChange, colour = "Log2RateOfChange")) +
	geom_line(aes(y = Count/10000, colour = "Count/10000")) +
	scale_y_continuous(sec.axis = sec_axis(~.*10000, name = "Count")) +
	scale_colour_manual(values = c("black", "red")) +
	labs(title = "Italy Fatalities"
		,y = "Log2 Rate of Change"
		,x = ""
		,colour = "Parameter") +
	theme(legend.title = element_blank(), legend.position = c(.6, .9))

# test with Brazil fatalities
x <- percap[percap$Country == "Brazil" & percap$Status == "Fatal" & percap$Log2RateOfChange > 0, ]

ggplot(x, aes(x = Date)) +
	geom_line(aes(y = Log2RateOfChange, colour = "Log2RateOfChange")) +
	geom_line(aes(y = Count/10000, colour = "Count/10000")) +
	scale_y_continuous(sec.axis = sec_axis(~.*10000, name = "Count")) +
	scale_colour_manual(values = c("black", "red")) +
	labs(title = "Brazil Fatalities"
		,y = "Log2 Rate of Change"
		,x = ""
		,colour = "Parameter") +
	theme(legend.title = element_blank(), legend.position = c(.6, .9))


# test with Russia fatalities
x <- percap[percap$Country == "Russia" & percap$Status == "Fatal" & percap$Log2RateOfChange > 0, ]

ggplot(x, aes(x = Date)) +
	geom_line(aes(y = Log2RateOfChange, colour = "Log2RateOfChange")) +
	geom_line(aes(y = Count/10000, colour = "Count/10000")) +
	scale_y_continuous(sec.axis = sec_axis(~.*10000, name = "Count")) +
	scale_colour_manual(values = c("black", "red")) +
	labs(title = "Russia Fatalities"
		,y = "Log2 Rate of Change"
		,x = ""
		,colour = "Parameter") +
	theme(legend.title = element_blank(), legend.position = c(.6, .9))
```





```r
# uncomment to run, creates Rcode file with R code, set documentation = 1 to avoid text commentary
#library(knitr)
#options(knitr.purl.inline = TRUE)
#purl("COVID19_DATA_ANALYSIS.Rmd", output = "Rcode.R", documentation = 2)
```
