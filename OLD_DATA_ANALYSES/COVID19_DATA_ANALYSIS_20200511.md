---
title: "Coronavirus Data Analysis"
author: "Marcelo Sanches"
date: "05/11/2020"
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
## 'data.frame':	82280 obs. of  4 variables:
##  $ Country: chr  "Afghanistan" "Afghanistan" "Afghanistan" "Afghanistan" ...
##  $ Status : Factor w/ 4 levels "Confirmed","Fatal",..: 1 1 1 1 1 1 1 1 1 1 ...
##  $ Date   : Date, format: "2020-05-10" "2020-05-09" ...
##  $ Count  : int  4402 4033 3778 3563 3392 3224 2894 2704 2469 2335 ...
```


There are 82280 rows and 4 columns. Each single-status dataset is as long as the number of days times the number of countries for the data in a given day. Today there are 110 daysa and 187 countries in the data. 

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
   <td style="text-align:left;"> 2020-05-10 </td>
   <td style="text-align:right;"> 4402 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 2 </td>
   <td style="text-align:left;"> Afghanistan </td>
   <td style="text-align:left;"> Confirmed </td>
   <td style="text-align:left;"> 2020-05-09 </td>
   <td style="text-align:right;"> 4033 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 3 </td>
   <td style="text-align:left;"> Afghanistan </td>
   <td style="text-align:left;"> Confirmed </td>
   <td style="text-align:left;"> 2020-05-08 </td>
   <td style="text-align:right;"> 3778 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 4 </td>
   <td style="text-align:left;"> Afghanistan </td>
   <td style="text-align:left;"> Confirmed </td>
   <td style="text-align:left;"> 2020-05-07 </td>
   <td style="text-align:right;"> 3563 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 5 </td>
   <td style="text-align:left;"> Afghanistan </td>
   <td style="text-align:left;"> Confirmed </td>
   <td style="text-align:left;"> 2020-05-06 </td>
   <td style="text-align:right;"> 3392 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 6 </td>
   <td style="text-align:left;"> Afghanistan </td>
   <td style="text-align:left;"> Confirmed </td>
   <td style="text-align:left;"> 2020-05-05 </td>
   <td style="text-align:right;"> 3224 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 82275 </td>
   <td style="text-align:left;"> Zimbabwe </td>
   <td style="text-align:left;"> Active </td>
   <td style="text-align:left;"> 2020-01-27 </td>
   <td style="text-align:right;"> 0 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 82276 </td>
   <td style="text-align:left;"> Zimbabwe </td>
   <td style="text-align:left;"> Active </td>
   <td style="text-align:left;"> 2020-01-26 </td>
   <td style="text-align:right;"> 0 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 82277 </td>
   <td style="text-align:left;"> Zimbabwe </td>
   <td style="text-align:left;"> Active </td>
   <td style="text-align:left;"> 2020-01-25 </td>
   <td style="text-align:right;"> 0 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 82278 </td>
   <td style="text-align:left;"> Zimbabwe </td>
   <td style="text-align:left;"> Active </td>
   <td style="text-align:left;"> 2020-01-24 </td>
   <td style="text-align:right;"> 0 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 82279 </td>
   <td style="text-align:left;"> Zimbabwe </td>
   <td style="text-align:left;"> Active </td>
   <td style="text-align:left;"> 2020-01-23 </td>
   <td style="text-align:right;"> 0 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 82280 </td>
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
   <td style="text-align:left;"> 10121 </td>
   <td style="text-align:left;"> Brazil </td>
   <td style="text-align:left;"> Confirmed </td>
   <td style="text-align:left;"> 2020-05-10 </td>
   <td style="text-align:right;"> 162699 </td>
   <td style="text-align:right;"> 207653 </td>
   <td style="text-align:right;"> 0.078 </td>
   <td style="text-align:right;"> 6638 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 10122 </td>
   <td style="text-align:left;"> Brazil </td>
   <td style="text-align:left;"> Confirmed </td>
   <td style="text-align:left;"> 2020-05-09 </td>
   <td style="text-align:right;"> 156061 </td>
   <td style="text-align:right;"> 207653 </td>
   <td style="text-align:right;"> 0.075 </td>
   <td style="text-align:right;"> 9167 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 10123 </td>
   <td style="text-align:left;"> Brazil </td>
   <td style="text-align:left;"> Confirmed </td>
   <td style="text-align:left;"> 2020-05-08 </td>
   <td style="text-align:right;"> 146894 </td>
   <td style="text-align:right;"> 207653 </td>
   <td style="text-align:right;"> 0.071 </td>
   <td style="text-align:right;"> 11121 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 10124 </td>
   <td style="text-align:left;"> Brazil </td>
   <td style="text-align:left;"> Confirmed </td>
   <td style="text-align:left;"> 2020-05-07 </td>
   <td style="text-align:right;"> 135773 </td>
   <td style="text-align:right;"> 207653 </td>
   <td style="text-align:right;"> 0.065 </td>
   <td style="text-align:right;"> 9162 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 10125 </td>
   <td style="text-align:left;"> Brazil </td>
   <td style="text-align:left;"> Confirmed </td>
   <td style="text-align:left;"> 2020-05-06 </td>
   <td style="text-align:right;"> 126611 </td>
   <td style="text-align:right;"> 207653 </td>
   <td style="text-align:right;"> 0.061 </td>
   <td style="text-align:right;"> 11156 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 10126 </td>
   <td style="text-align:left;"> Brazil </td>
   <td style="text-align:left;"> Confirmed </td>
   <td style="text-align:left;"> 2020-05-05 </td>
   <td style="text-align:right;"> 115455 </td>
   <td style="text-align:right;"> 207653 </td>
   <td style="text-align:right;"> 0.056 </td>
   <td style="text-align:right;"> 6835 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 14081 </td>
   <td style="text-align:left;"> Canada </td>
   <td style="text-align:left;"> Confirmed </td>
   <td style="text-align:left;"> 2020-05-10 </td>
   <td style="text-align:right;"> 70091 </td>
   <td style="text-align:right;"> 36290 </td>
   <td style="text-align:right;"> 0.193 </td>
   <td style="text-align:right;"> 1173 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 14082 </td>
   <td style="text-align:left;"> Canada </td>
   <td style="text-align:left;"> Confirmed </td>
   <td style="text-align:left;"> 2020-05-09 </td>
   <td style="text-align:right;"> 68918 </td>
   <td style="text-align:right;"> 36290 </td>
   <td style="text-align:right;"> 0.190 </td>
   <td style="text-align:right;"> 1244 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 14083 </td>
   <td style="text-align:left;"> Canada </td>
   <td style="text-align:left;"> Confirmed </td>
   <td style="text-align:left;"> 2020-05-08 </td>
   <td style="text-align:right;"> 67674 </td>
   <td style="text-align:right;"> 36290 </td>
   <td style="text-align:right;"> 0.186 </td>
   <td style="text-align:right;"> 1473 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 14084 </td>
   <td style="text-align:left;"> Canada </td>
   <td style="text-align:left;"> Confirmed </td>
   <td style="text-align:left;"> 2020-05-07 </td>
   <td style="text-align:right;"> 66201 </td>
   <td style="text-align:right;"> 36290 </td>
   <td style="text-align:right;"> 0.182 </td>
   <td style="text-align:right;"> 1507 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 14085 </td>
   <td style="text-align:left;"> Canada </td>
   <td style="text-align:left;"> Confirmed </td>
   <td style="text-align:left;"> 2020-05-06 </td>
   <td style="text-align:right;"> 64694 </td>
   <td style="text-align:right;"> 36290 </td>
   <td style="text-align:right;"> 0.178 </td>
   <td style="text-align:right;"> 1479 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 14086 </td>
   <td style="text-align:left;"> Canada </td>
   <td style="text-align:left;"> Confirmed </td>
   <td style="text-align:left;"> 2020-05-05 </td>
   <td style="text-align:right;"> 63215 </td>
   <td style="text-align:right;"> 36290 </td>
   <td style="text-align:right;"> 0.174 </td>
   <td style="text-align:right;"> 1258 </td>
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
   <td style="text-align:left;"> 4,101,699 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Fatal </td>
   <td style="text-align:left;"> 282,709 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Recovered </td>
   <td style="text-align:left;"> 1,408,980 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Active </td>
   <td style="text-align:left;"> 2,410,010 </td>
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













<!--html_preserve--><div id="htmlwidget-cfe786d677d3b17fbf40" style="width:960px;height:500px;" class="dygraphs html-widget"></div>
<script type="application/json" data-for="htmlwidget-cfe786d677d3b17fbf40">{"x":{"attrs":{"axes":{"x":{"pixelsPerLabel":60,"drawGrid":false,"drawAxis":true},"y":{"drawAxis":true}},"title":"Top Countries - Count Of Fatal Cases","labels":["day","US","United Kingdom","Italy","Spain","France"],"retainDateWindow":false,"ylabel":"Count Of Fatal Cases","stackedGraph":false,"fillGraph":false,"fillAlpha":0.15,"stepPlot":false,"drawPoints":false,"pointSize":1,"drawGapEdgePoints":false,"connectSeparatedPoints":false,"strokeWidth":1,"strokeBorderColor":"white","colors":["#1B9E77","#D95F02","#7570B3","#E7298A","#66A61E"],"colorValue":0.5,"colorSaturation":1,"includeZero":false,"drawAxesAtZero":false,"logscale":false,"axisTickSize":3,"axisLineColor":"navy","axisLineWidth":1.5,"axisLabelColor":"black","axisLabelFontSize":14,"axisLabelWidth":60,"drawGrid":true,"gridLineColor":"lightblue","gridLineWidth":0.3,"rightGap":5,"digitsAfterDecimal":2,"labelsKMB":false,"labelsKMG2":false,"labelsUTC":false,"maxNumberWidth":6,"animatedZooms":false,"mobileDisableYTouch":true,"disableZoom":false,"showRangeSelector":true,"rangeSelectorHeight":40,"rangeSelectorPlotFillColor":" #A7B1C4","rangeSelectorPlotStrokeColor":"#808FAB","interactionModel":"Dygraph.Interaction.defaultModel","legend":"auto","labelsDivWidth":750,"labelsShowZeroValues":true,"labelsSeparateLines":false,"hideOverlayOnMouseOut":true},"scale":"daily","annotations":[],"shadings":[],"events":[],"format":"date","data":[["2020-01-22T00:00:00.000Z","2020-01-23T00:00:00.000Z","2020-01-24T00:00:00.000Z","2020-01-25T00:00:00.000Z","2020-01-26T00:00:00.000Z","2020-01-27T00:00:00.000Z","2020-01-28T00:00:00.000Z","2020-01-29T00:00:00.000Z","2020-01-30T00:00:00.000Z","2020-01-31T00:00:00.000Z","2020-02-01T00:00:00.000Z","2020-02-02T00:00:00.000Z","2020-02-03T00:00:00.000Z","2020-02-04T00:00:00.000Z","2020-02-05T00:00:00.000Z","2020-02-06T00:00:00.000Z","2020-02-07T00:00:00.000Z","2020-02-08T00:00:00.000Z","2020-02-09T00:00:00.000Z","2020-02-10T00:00:00.000Z","2020-02-11T00:00:00.000Z","2020-02-12T00:00:00.000Z","2020-02-13T00:00:00.000Z","2020-02-14T00:00:00.000Z","2020-02-15T00:00:00.000Z","2020-02-16T00:00:00.000Z","2020-02-17T00:00:00.000Z","2020-02-18T00:00:00.000Z","2020-02-19T00:00:00.000Z","2020-02-20T00:00:00.000Z","2020-02-21T00:00:00.000Z","2020-02-22T00:00:00.000Z","2020-02-23T00:00:00.000Z","2020-02-24T00:00:00.000Z","2020-02-25T00:00:00.000Z","2020-02-26T00:00:00.000Z","2020-02-27T00:00:00.000Z","2020-02-28T00:00:00.000Z","2020-02-29T00:00:00.000Z","2020-03-01T00:00:00.000Z","2020-03-02T00:00:00.000Z","2020-03-03T00:00:00.000Z","2020-03-04T00:00:00.000Z","2020-03-05T00:00:00.000Z","2020-03-06T00:00:00.000Z","2020-03-07T00:00:00.000Z","2020-03-08T00:00:00.000Z","2020-03-09T00:00:00.000Z","2020-03-10T00:00:00.000Z","2020-03-11T00:00:00.000Z","2020-03-12T00:00:00.000Z","2020-03-13T00:00:00.000Z","2020-03-14T00:00:00.000Z","2020-03-15T00:00:00.000Z","2020-03-16T00:00:00.000Z","2020-03-17T00:00:00.000Z","2020-03-18T00:00:00.000Z","2020-03-19T00:00:00.000Z","2020-03-20T00:00:00.000Z","2020-03-21T00:00:00.000Z","2020-03-22T00:00:00.000Z","2020-03-23T00:00:00.000Z","2020-03-24T00:00:00.000Z","2020-03-25T00:00:00.000Z","2020-03-26T00:00:00.000Z","2020-03-27T00:00:00.000Z","2020-03-28T00:00:00.000Z","2020-03-29T00:00:00.000Z","2020-03-30T00:00:00.000Z","2020-03-31T00:00:00.000Z","2020-04-01T00:00:00.000Z","2020-04-02T00:00:00.000Z","2020-04-03T00:00:00.000Z","2020-04-04T00:00:00.000Z","2020-04-05T00:00:00.000Z","2020-04-06T00:00:00.000Z","2020-04-07T00:00:00.000Z","2020-04-08T00:00:00.000Z","2020-04-09T00:00:00.000Z","2020-04-10T00:00:00.000Z","2020-04-11T00:00:00.000Z","2020-04-12T00:00:00.000Z","2020-04-13T00:00:00.000Z","2020-04-14T00:00:00.000Z","2020-04-15T00:00:00.000Z","2020-04-16T00:00:00.000Z","2020-04-17T00:00:00.000Z","2020-04-18T00:00:00.000Z","2020-04-19T00:00:00.000Z","2020-04-20T00:00:00.000Z","2020-04-21T00:00:00.000Z","2020-04-22T00:00:00.000Z","2020-04-23T00:00:00.000Z","2020-04-24T00:00:00.000Z","2020-04-25T00:00:00.000Z","2020-04-26T00:00:00.000Z","2020-04-27T00:00:00.000Z","2020-04-28T00:00:00.000Z","2020-04-29T00:00:00.000Z","2020-04-30T00:00:00.000Z","2020-05-01T00:00:00.000Z","2020-05-02T00:00:00.000Z","2020-05-03T00:00:00.000Z","2020-05-04T00:00:00.000Z","2020-05-05T00:00:00.000Z","2020-05-06T00:00:00.000Z","2020-05-07T00:00:00.000Z","2020-05-08T00:00:00.000Z","2020-05-09T00:00:00.000Z","2020-05-10T00:00:00.000Z"],[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,6,7,11,12,14,17,21,22,28,36,41,49,58,73,99,133,164,258,349,442,586,786,1008,1316,1726,2265,2731,3420,4192,5367,6501,7921,9246,10855,12375,13894,16191,18270,20255,22333,24342,26086,27870,30262,32734,34827,37411,39753,40945,42659,45086,47412,49724,51493,53755,54881,56219,58355,60967,62996,64943,66369,67682,68922,71064,73455,75662,77180,78795,79526],[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,2,2,3,7,7,9,10,28,43,66,82,116,159,195,251,286,360,509,695,879,1163,1457,1672,2046,2429,3100,3752,4467,5228,5874,6445,7483,8519,9623,10776,11616,12302,13047,14095,14941,15974,16910,18028,18527,19092,20264,21111,21840,22853,23697,24117,24458,25369,26166,26842,27583,28205,28520,28809,29501,30150,30689,31316,31662,31930],[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,2,3,7,10,12,17,21,29,34,52,79,107,148,197,233,366,463,631,827,827,1266,1441,1809,2158,2503,2978,3405,4032,4825,5476,6077,6820,7503,8215,9134,10023,10779,11591,12428,13155,13915,14681,15362,15887,16523,17127,17669,18279,18849,19468,19899,20465,21067,21645,22170,22745,23227,23660,24114,24648,25085,25549,25969,26384,26644,26977,27359,27682,27967,28236,28710,28884,29079,29315,29684,29958,30201,30395,30560],[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,2,3,5,10,17,28,35,54,55,133,195,289,342,533,623,830,1043,1375,1772,2311,2808,3647,4365,5138,5982,6803,7716,8464,9387,10348,11198,11947,12641,13341,14045,14792,15447,16081,16606,17209,17756,18056,18708,19315,20002,20043,20453,20852,21282,21717,22157,22524,22902,23190,23521,23822,24275,24543,24543,25100,25264,25428,25613,25857,26070,26299,26478,26621],[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,2,2,2,2,2,3,4,4,6,9,11,19,19,33,48,48,79,91,91,149,149,149,244,451,563,676,862,1102,1333,1698,1997,2317,2611,3030,3532,4414,5398,6520,7574,8093,8926,10343,10887,12228,13215,13851,14412,14986,15731,17169,17922,18683,19325,19720,20267,20798,21342,21858,22248,22617,22859,23296,23663,24090,24379,24597,24763,24900,25204,25537,25812,25990,26233,26313,26383]],"fixedtz":false,"tzone":"UTC"},"evals":["attrs.interactionModel"],"jsHooks":[]}</script>
<div id="htmlwidget-2e9a74c7eff0fae8c92c" style="width:960px;height:500px;" class="dygraphs html-widget"></div>
<script type="application/json" data-for="htmlwidget-2e9a74c7eff0fae8c92c">{"x":{"attrs":{"axes":{"x":{"pixelsPerLabel":60,"drawGrid":false,"drawAxis":true},"y":{"drawAxis":true}},"title":"Top Countries - Log Count Of Fatal Cases","labels":["day","US","United Kingdom","Italy","Spain","France"],"retainDateWindow":false,"ylabel":"Log Count Of Fatal Cases","stackedGraph":false,"fillGraph":false,"fillAlpha":0.15,"stepPlot":false,"drawPoints":false,"pointSize":1,"drawGapEdgePoints":false,"connectSeparatedPoints":false,"strokeWidth":1,"strokeBorderColor":"white","colors":["#1B9E77","#D95F02","#7570B3","#E7298A","#66A61E"],"colorValue":0.5,"colorSaturation":1,"includeZero":false,"drawAxesAtZero":false,"logscale":false,"axisTickSize":3,"axisLineColor":"navy","axisLineWidth":1.5,"axisLabelColor":"black","axisLabelFontSize":14,"axisLabelWidth":60,"drawGrid":true,"gridLineColor":"lightblue","gridLineWidth":0.3,"rightGap":5,"digitsAfterDecimal":2,"labelsKMB":false,"labelsKMG2":false,"labelsUTC":false,"maxNumberWidth":6,"animatedZooms":false,"mobileDisableYTouch":true,"disableZoom":false,"showRangeSelector":true,"rangeSelectorHeight":40,"rangeSelectorPlotFillColor":" #A7B1C4","rangeSelectorPlotStrokeColor":"#808FAB","interactionModel":"Dygraph.Interaction.defaultModel","legend":"auto","labelsDivWidth":750,"labelsShowZeroValues":true,"labelsSeparateLines":false,"hideOverlayOnMouseOut":true},"scale":"daily","annotations":[],"shadings":[],"events":[],"format":"date","data":[["2020-01-22T00:00:00.000Z","2020-01-23T00:00:00.000Z","2020-01-24T00:00:00.000Z","2020-01-25T00:00:00.000Z","2020-01-26T00:00:00.000Z","2020-01-27T00:00:00.000Z","2020-01-28T00:00:00.000Z","2020-01-29T00:00:00.000Z","2020-01-30T00:00:00.000Z","2020-01-31T00:00:00.000Z","2020-02-01T00:00:00.000Z","2020-02-02T00:00:00.000Z","2020-02-03T00:00:00.000Z","2020-02-04T00:00:00.000Z","2020-02-05T00:00:00.000Z","2020-02-06T00:00:00.000Z","2020-02-07T00:00:00.000Z","2020-02-08T00:00:00.000Z","2020-02-09T00:00:00.000Z","2020-02-10T00:00:00.000Z","2020-02-11T00:00:00.000Z","2020-02-12T00:00:00.000Z","2020-02-13T00:00:00.000Z","2020-02-14T00:00:00.000Z","2020-02-15T00:00:00.000Z","2020-02-16T00:00:00.000Z","2020-02-17T00:00:00.000Z","2020-02-18T00:00:00.000Z","2020-02-19T00:00:00.000Z","2020-02-20T00:00:00.000Z","2020-02-21T00:00:00.000Z","2020-02-22T00:00:00.000Z","2020-02-23T00:00:00.000Z","2020-02-24T00:00:00.000Z","2020-02-25T00:00:00.000Z","2020-02-26T00:00:00.000Z","2020-02-27T00:00:00.000Z","2020-02-28T00:00:00.000Z","2020-02-29T00:00:00.000Z","2020-03-01T00:00:00.000Z","2020-03-02T00:00:00.000Z","2020-03-03T00:00:00.000Z","2020-03-04T00:00:00.000Z","2020-03-05T00:00:00.000Z","2020-03-06T00:00:00.000Z","2020-03-07T00:00:00.000Z","2020-03-08T00:00:00.000Z","2020-03-09T00:00:00.000Z","2020-03-10T00:00:00.000Z","2020-03-11T00:00:00.000Z","2020-03-12T00:00:00.000Z","2020-03-13T00:00:00.000Z","2020-03-14T00:00:00.000Z","2020-03-15T00:00:00.000Z","2020-03-16T00:00:00.000Z","2020-03-17T00:00:00.000Z","2020-03-18T00:00:00.000Z","2020-03-19T00:00:00.000Z","2020-03-20T00:00:00.000Z","2020-03-21T00:00:00.000Z","2020-03-22T00:00:00.000Z","2020-03-23T00:00:00.000Z","2020-03-24T00:00:00.000Z","2020-03-25T00:00:00.000Z","2020-03-26T00:00:00.000Z","2020-03-27T00:00:00.000Z","2020-03-28T00:00:00.000Z","2020-03-29T00:00:00.000Z","2020-03-30T00:00:00.000Z","2020-03-31T00:00:00.000Z","2020-04-01T00:00:00.000Z","2020-04-02T00:00:00.000Z","2020-04-03T00:00:00.000Z","2020-04-04T00:00:00.000Z","2020-04-05T00:00:00.000Z","2020-04-06T00:00:00.000Z","2020-04-07T00:00:00.000Z","2020-04-08T00:00:00.000Z","2020-04-09T00:00:00.000Z","2020-04-10T00:00:00.000Z","2020-04-11T00:00:00.000Z","2020-04-12T00:00:00.000Z","2020-04-13T00:00:00.000Z","2020-04-14T00:00:00.000Z","2020-04-15T00:00:00.000Z","2020-04-16T00:00:00.000Z","2020-04-17T00:00:00.000Z","2020-04-18T00:00:00.000Z","2020-04-19T00:00:00.000Z","2020-04-20T00:00:00.000Z","2020-04-21T00:00:00.000Z","2020-04-22T00:00:00.000Z","2020-04-23T00:00:00.000Z","2020-04-24T00:00:00.000Z","2020-04-25T00:00:00.000Z","2020-04-26T00:00:00.000Z","2020-04-27T00:00:00.000Z","2020-04-28T00:00:00.000Z","2020-04-29T00:00:00.000Z","2020-04-30T00:00:00.000Z","2020-05-01T00:00:00.000Z","2020-05-02T00:00:00.000Z","2020-05-03T00:00:00.000Z","2020-05-04T00:00:00.000Z","2020-05-05T00:00:00.000Z","2020-05-06T00:00:00.000Z","2020-05-07T00:00:00.000Z","2020-05-08T00:00:00.000Z","2020-05-09T00:00:00.000Z","2020-05-10T00:00:00.000Z"],[null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,0,0,1.79175946922805,1.94591014905531,2.39789527279837,2.484906649788,2.63905732961526,2.83321334405622,3.04452243772342,3.09104245335832,3.3322045101752,3.58351893845611,3.71357206670431,3.89182029811063,4.06044301054642,4.29045944114839,4.59511985013459,4.89034912822175,5.0998664278242,5.55295958492162,5.85507192220243,6.0913098820777,6.37331978957701,6.66695679242921,6.91572344863131,7.18235211188526,7.45356187164337,7.72533003791713,7.91242312147371,8.13739583005665,8.34093322600088,8.58802437217683,8.77971129020447,8.97727273946428,9.13194630454817,9.29238108231239,9.42343358743689,9.53921237125283,9.69221081128675,9.81301564937205,9.91615695563679,10.0138206842205,10.0999585324345,10.1691540509302,10.235306120476,10.3176480790115,10.3961695720658,10.4581482270061,10.5297200578056,10.5904405889327,10.6199849817043,10.6609935505879,10.7163270560141,10.7666306401994,10.8142429929116,10.8492011550835,10.8921919649193,10.9129224838081,10.937010057038,10.9743003238465,11.0180880131645,11.0508265112945,11.0812652410789,11.1029853589781,11.1225755446709,11.1407307093735,11.1713361584495,11.2044282528045,11.2340313318847,11.2538956350916,11.2746048220562,11.2838392912003],[null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,0,0.693147180559945,0.693147180559945,1.09861228866811,1.94591014905531,1.94591014905531,2.19722457733622,2.30258509299405,3.3322045101752,3.76120011569356,4.18965474202643,4.40671924726425,4.75359019110636,5.06890420222023,5.27299955856375,5.52545293913178,5.65599181081985,5.88610403145016,6.23244801655052,6.54391184556479,6.77878489768518,7.05875815251866,7.2841348061952,7.42177579364465,7.62364194651157,7.79523492900217,8.03915739047324,8.23004431012611,8.40447232135212,8.56178407474411,8.67829111175856,8.77105991537329,8.92038906008036,9.05005424204284,9.1719113453564,9.2850767180902,9.36013873706458,9.41751712976831,9.47631350126575,9.55357540354821,9.61186439085109,9.67871767947733,9.73566044189263,9.79968138381054,9.82698440655001,9.85702467812579,9.91660119168151,9.95754951063466,9.99149842985884,10.0368376787329,10.0731037368325,10.0906722649961,10.1047126397493,10.1412832351827,10.1722161370708,10.1977231039578,10.224954919906,10.2472545461741,10.2583608745282,10.2684431173061,10.2921794400585,10.3139402021553,10.3316595631794,10.3518844280278,10.3628725026337,10.3713012857088],[null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,0,0.693147180559945,1.09861228866811,1.94591014905531,2.30258509299405,2.484906649788,2.83321334405622,3.04452243772342,3.36729582998647,3.52636052461616,3.95124371858143,4.36944785246702,4.67282883446191,4.99721227376411,5.28320372873799,5.4510384535657,5.90263333340137,6.13772705408623,6.44730586254121,6.71780469502369,6.71780469502369,7.14361760270412,7.27309259599952,7.50052948539529,7.67693714581808,7.82524529143177,7.99900721324395,8.13300021858361,8.3020178097512,8.48156601377309,8.60813018640834,8.71226643213535,8.82761475083751,8.92305821954573,9.01371703047137,9.11975899374495,9.21263773102487,9.28535507578163,9.35798421388875,9.42770727051294,9.48455719347439,9.54072267395999,9.59430941973946,9.63965220655863,9.67325644372002,9.71250862865099,9.74841144463237,9.77956697061665,9.8135081389166,9.84421514107106,9.87652737095335,9.89842475819367,9.9264713889265,9.95546311412647,9.98252975987608,10.0064953026104,10.0321006200041,10.0530706740756,10.0715411375324,10.0905478636773,10.1124510402765,10.1300253369184,10.1483534559227,10.164658797947,10.1805130447994,10.1903192635331,10.2027399301026,10.2168008213609,10.2285376614566,10.2387805226673,10.2483530385154,10.2650007731151,10.2710430875711,10.2777715431607,10.2858546093983,10.29836345909,10.3075516797287,10.3156303153975,10.3220334001828,10.3274472432805],[null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,0,0.693147180559945,1.09861228866811,1.6094379124341,2.30258509299405,2.83321334405622,3.3322045101752,3.55534806148941,3.98898404656427,4.00733318523247,4.89034912822175,5.27299955856375,5.66642668811243,5.8348107370626,6.27852142416584,6.43454651878745,6.72142570079064,6.94985645500077,7.22620901010067,7.47986413116503,7.74543561027438,7.9402277651457,8.20166019080868,8.3813734682737,8.54441917766983,8.69651023918989,8.82511897034506,8.95105137402562,9.04357715409808,9.14708103233699,9.24454854330592,9.32349046990884,9.38823547981722,9.44470077849556,9.49859727917881,9.55002173953834,9.60184177306696,9.64517008871425,9.68539372985402,9.71751935482198,9.75318778176491,9.78447876595393,9.80123331849737,9.83670651884578,9.86863727510038,9.90358754753646,9.90563524459359,9.92588484997817,9.945205145888,9.96561692400168,9.98585064296125,10.0059087526353,10.0223366863745,10.0389795219733,10.0514764302496,10.0656489181155,10.0783648024408,10.0972022931595,10.1081819601818,10.1081819601818,10.1306231251199,10.1371357364954,10.1436062080563,10.1508553140745,10.1603366363155,10.1685405069275,10.1772861946293,10.1840694784976,10.1894556569836],[null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,0,0,0,0,0,0,0,0,0,0,0,0.693147180559945,0.693147180559945,0.693147180559945,0.693147180559945,0.693147180559945,1.09861228866811,1.38629436111989,1.38629436111989,1.79175946922805,2.19722457733622,2.39789527279837,2.94443897916644,2.94443897916644,3.49650756146648,3.87120101090789,3.87120101090789,4.36944785246702,4.51085950651685,4.51085950651685,5.00394630594546,5.00394630594546,5.00394630594546,5.4971682252932,6.11146733950268,6.33327962813969,6.51619307604296,6.75925527066369,7.00488198971286,7.19518732017871,7.43720636687129,7.59940133341582,7.74802852443238,7.86748856869913,8.01631789850341,8.16961956172385,8.39253658681668,8.59378379357795,8.7826296549207,8.93247660846174,8.9987547694957,9.09672364518921,9.2440652413778,9.29532469588118,9.41148368301073,9.48910782703839,9.5361127111751,9.57581647186798,9.61487171092426,9.6633885668225,9.75086071107721,9.79378428744416,9.83536929845984,9.86915487345562,9.88938862815663,9.91674922651931,9.94261210722018,9.96843224117651,9.99232226623662,10.0100073959138,10.0264571148798,10.03710019186,10.0560369509964,10.0716679257751,10.0895520956089,10.1014773849668,10.1103797632643,10.1171058826253,10.1226230824528,10.1347579910619,10.1478836598838,10.1585947790557,10.1654671276355,10.1747734391764,10.1778183926195,10.1804751423224]],"fixedtz":false,"tzone":"UTC"},"evals":["attrs.interactionModel"],"jsHooks":[]}</script>
<div id="htmlwidget-f56e169946f6e1386b30" style="width:960px;height:500px;" class="dygraphs html-widget"></div>
<script type="application/json" data-for="htmlwidget-f56e169946f6e1386b30">{"x":{"attrs":{"axes":{"x":{"pixelsPerLabel":60,"drawGrid":false,"drawAxis":true},"y":{"drawAxis":true}},"title":"Top Countries - Percentage Of Fatal Cases","labels":["day","US","United Kingdom","Italy","Spain","France"],"retainDateWindow":false,"ylabel":"Percentage Of Fatal Cases","stackedGraph":false,"fillGraph":false,"fillAlpha":0.15,"stepPlot":false,"drawPoints":false,"pointSize":1,"drawGapEdgePoints":false,"connectSeparatedPoints":false,"strokeWidth":1,"strokeBorderColor":"white","colors":["#1B9E77","#D95F02","#7570B3","#E7298A","#66A61E"],"colorValue":0.5,"colorSaturation":1,"includeZero":false,"drawAxesAtZero":false,"logscale":false,"axisTickSize":3,"axisLineColor":"navy","axisLineWidth":1.5,"axisLabelColor":"black","axisLabelFontSize":14,"axisLabelWidth":60,"drawGrid":true,"gridLineColor":"lightblue","gridLineWidth":0.3,"rightGap":5,"digitsAfterDecimal":2,"labelsKMB":false,"labelsKMG2":false,"labelsUTC":false,"maxNumberWidth":6,"animatedZooms":false,"mobileDisableYTouch":true,"disableZoom":false,"showRangeSelector":true,"rangeSelectorHeight":40,"rangeSelectorPlotFillColor":" #A7B1C4","rangeSelectorPlotStrokeColor":"#808FAB","interactionModel":"Dygraph.Interaction.defaultModel","legend":"auto","labelsDivWidth":750,"labelsShowZeroValues":true,"labelsSeparateLines":false,"hideOverlayOnMouseOut":true},"scale":"daily","annotations":[],"shadings":[],"events":[],"format":"date","data":[["2020-01-22T00:00:00.000Z","2020-01-23T00:00:00.000Z","2020-01-24T00:00:00.000Z","2020-01-25T00:00:00.000Z","2020-01-26T00:00:00.000Z","2020-01-27T00:00:00.000Z","2020-01-28T00:00:00.000Z","2020-01-29T00:00:00.000Z","2020-01-30T00:00:00.000Z","2020-01-31T00:00:00.000Z","2020-02-01T00:00:00.000Z","2020-02-02T00:00:00.000Z","2020-02-03T00:00:00.000Z","2020-02-04T00:00:00.000Z","2020-02-05T00:00:00.000Z","2020-02-06T00:00:00.000Z","2020-02-07T00:00:00.000Z","2020-02-08T00:00:00.000Z","2020-02-09T00:00:00.000Z","2020-02-10T00:00:00.000Z","2020-02-11T00:00:00.000Z","2020-02-12T00:00:00.000Z","2020-02-13T00:00:00.000Z","2020-02-14T00:00:00.000Z","2020-02-15T00:00:00.000Z","2020-02-16T00:00:00.000Z","2020-02-17T00:00:00.000Z","2020-02-18T00:00:00.000Z","2020-02-19T00:00:00.000Z","2020-02-20T00:00:00.000Z","2020-02-21T00:00:00.000Z","2020-02-22T00:00:00.000Z","2020-02-23T00:00:00.000Z","2020-02-24T00:00:00.000Z","2020-02-25T00:00:00.000Z","2020-02-26T00:00:00.000Z","2020-02-27T00:00:00.000Z","2020-02-28T00:00:00.000Z","2020-02-29T00:00:00.000Z","2020-03-01T00:00:00.000Z","2020-03-02T00:00:00.000Z","2020-03-03T00:00:00.000Z","2020-03-04T00:00:00.000Z","2020-03-05T00:00:00.000Z","2020-03-06T00:00:00.000Z","2020-03-07T00:00:00.000Z","2020-03-08T00:00:00.000Z","2020-03-09T00:00:00.000Z","2020-03-10T00:00:00.000Z","2020-03-11T00:00:00.000Z","2020-03-12T00:00:00.000Z","2020-03-13T00:00:00.000Z","2020-03-14T00:00:00.000Z","2020-03-15T00:00:00.000Z","2020-03-16T00:00:00.000Z","2020-03-17T00:00:00.000Z","2020-03-18T00:00:00.000Z","2020-03-19T00:00:00.000Z","2020-03-20T00:00:00.000Z","2020-03-21T00:00:00.000Z","2020-03-22T00:00:00.000Z","2020-03-23T00:00:00.000Z","2020-03-24T00:00:00.000Z","2020-03-25T00:00:00.000Z","2020-03-26T00:00:00.000Z","2020-03-27T00:00:00.000Z","2020-03-28T00:00:00.000Z","2020-03-29T00:00:00.000Z","2020-03-30T00:00:00.000Z","2020-03-31T00:00:00.000Z","2020-04-01T00:00:00.000Z","2020-04-02T00:00:00.000Z","2020-04-03T00:00:00.000Z","2020-04-04T00:00:00.000Z","2020-04-05T00:00:00.000Z","2020-04-06T00:00:00.000Z","2020-04-07T00:00:00.000Z","2020-04-08T00:00:00.000Z","2020-04-09T00:00:00.000Z","2020-04-10T00:00:00.000Z","2020-04-11T00:00:00.000Z","2020-04-12T00:00:00.000Z","2020-04-13T00:00:00.000Z","2020-04-14T00:00:00.000Z","2020-04-15T00:00:00.000Z","2020-04-16T00:00:00.000Z","2020-04-17T00:00:00.000Z","2020-04-18T00:00:00.000Z","2020-04-19T00:00:00.000Z","2020-04-20T00:00:00.000Z","2020-04-21T00:00:00.000Z","2020-04-22T00:00:00.000Z","2020-04-23T00:00:00.000Z","2020-04-24T00:00:00.000Z","2020-04-25T00:00:00.000Z","2020-04-26T00:00:00.000Z","2020-04-27T00:00:00.000Z","2020-04-28T00:00:00.000Z","2020-04-29T00:00:00.000Z","2020-04-30T00:00:00.000Z","2020-05-01T00:00:00.000Z","2020-05-02T00:00:00.000Z","2020-05-03T00:00:00.000Z","2020-05-04T00:00:00.000Z","2020-05-05T00:00:00.000Z","2020-05-06T00:00:00.000Z","2020-05-07T00:00:00.000Z","2020-05-08T00:00:00.000Z","2020-05-09T00:00:00.000Z","2020-05-10T00:00:00.000Z"],[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0.001,0.001,0.001,0.001,0.001,0.002,0.002,0.002,0.003,0.003,0.004,0.004,0.005,0.006,0.006,0.007,0.008,0.008,0.009,0.009,0.01,0.011,0.012,0.012,0.013,0.013,0.014,0.015,0.015,0.016,0.017,0.017,0.017,0.018,0.019,0.02,0.02,0.021,0.021,0.021,0.022,0.023,0.023,0.024,0.024,0.025],[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0.001,0.001,0.001,0.001,0.002,0.002,0.003,0.003,0.004,0.005,0.006,0.007,0.008,0.009,0.01,0.011,0.013,0.015,0.016,0.018,0.019,0.02,0.021,0.023,0.024,0.026,0.027,0.028,0.029,0.031,0.032,0.033,0.035,0.036,0.037,0.037,0.039,0.04,0.041,0.042,0.043,0.043,0.044,0.045,0.046,0.047,0.048,0.048,0.049],[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0.001,0.001,0.001,0.001,0.001,0.002,0.002,0.003,0.004,0.004,0.005,0.006,0.007,0.008,0.009,0.01,0.011,0.013,0.014,0.015,0.017,0.018,0.02,0.021,0.022,0.023,0.025,0.026,0.027,0.028,0.029,0.03,0.031,0.032,0.033,0.033,0.034,0.035,0.036,0.037,0.038,0.039,0.04,0.041,0.041,0.042,0.043,0.044,0.044,0.045,0.045,0.046,0.047,0.047,0.048,0.048,0.049,0.049,0.049,0.05,0.05,0.051,0.051,0.051],[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0.001,0.001,0.001,0.001,0.002,0.002,0.003,0.004,0.005,0.006,0.008,0.009,0.011,0.013,0.015,0.017,0.018,0.02,0.022,0.024,0.026,0.027,0.029,0.03,0.032,0.033,0.035,0.036,0.037,0.038,0.039,0.04,0.042,0.043,0.043,0.044,0.045,0.046,0.047,0.048,0.049,0.049,0.05,0.051,0.051,0.052,0.053,0.053,0.054,0.055,0.055,0.055,0.056,0.056,0.057,0.057,0.057],[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0.001,0.001,0.001,0.001,0.002,0.002,0.003,0.003,0.004,0.004,0.005,0.005,0.007,0.008,0.01,0.012,0.013,0.014,0.016,0.017,0.019,0.02,0.021,0.022,0.023,0.024,0.027,0.028,0.029,0.03,0.03,0.031,0.032,0.033,0.034,0.034,0.035,0.035,0.036,0.037,0.037,0.038,0.038,0.038,0.038,0.039,0.039,0.04,0.04,0.041,0.041,0.041]],"fixedtz":false,"tzone":"UTC"},"evals":["attrs.interactionModel"],"jsHooks":[]}</script>
<div id="htmlwidget-330649033450391e8ed0" style="width:960px;height:500px;" class="dygraphs html-widget"></div>
<script type="application/json" data-for="htmlwidget-330649033450391e8ed0">{"x":{"attrs":{"axes":{"x":{"pixelsPerLabel":60,"drawGrid":false,"drawAxis":true},"y":{"drawAxis":true}},"title":"Top Countries - Log Percentage Of Fatal Cases","labels":["day","US","United Kingdom","Italy","Spain","France"],"retainDateWindow":false,"ylabel":"Log Percentage Of Fatal Cases","stackedGraph":false,"fillGraph":false,"fillAlpha":0.15,"stepPlot":false,"drawPoints":false,"pointSize":1,"drawGapEdgePoints":false,"connectSeparatedPoints":false,"strokeWidth":1,"strokeBorderColor":"white","colors":["#1B9E77","#D95F02","#7570B3","#E7298A","#66A61E"],"colorValue":0.5,"colorSaturation":1,"includeZero":false,"drawAxesAtZero":false,"logscale":false,"axisTickSize":3,"axisLineColor":"navy","axisLineWidth":1.5,"axisLabelColor":"black","axisLabelFontSize":14,"axisLabelWidth":60,"drawGrid":true,"gridLineColor":"lightblue","gridLineWidth":0.3,"rightGap":5,"digitsAfterDecimal":2,"labelsKMB":false,"labelsKMG2":false,"labelsUTC":false,"maxNumberWidth":6,"animatedZooms":false,"mobileDisableYTouch":true,"disableZoom":false,"showRangeSelector":true,"rangeSelectorHeight":40,"rangeSelectorPlotFillColor":" #A7B1C4","rangeSelectorPlotStrokeColor":"#808FAB","interactionModel":"Dygraph.Interaction.defaultModel","legend":"auto","labelsDivWidth":750,"labelsShowZeroValues":true,"labelsSeparateLines":false,"hideOverlayOnMouseOut":true},"scale":"daily","annotations":[],"shadings":[],"events":[],"format":"date","data":[["2020-01-22T00:00:00.000Z","2020-01-23T00:00:00.000Z","2020-01-24T00:00:00.000Z","2020-01-25T00:00:00.000Z","2020-01-26T00:00:00.000Z","2020-01-27T00:00:00.000Z","2020-01-28T00:00:00.000Z","2020-01-29T00:00:00.000Z","2020-01-30T00:00:00.000Z","2020-01-31T00:00:00.000Z","2020-02-01T00:00:00.000Z","2020-02-02T00:00:00.000Z","2020-02-03T00:00:00.000Z","2020-02-04T00:00:00.000Z","2020-02-05T00:00:00.000Z","2020-02-06T00:00:00.000Z","2020-02-07T00:00:00.000Z","2020-02-08T00:00:00.000Z","2020-02-09T00:00:00.000Z","2020-02-10T00:00:00.000Z","2020-02-11T00:00:00.000Z","2020-02-12T00:00:00.000Z","2020-02-13T00:00:00.000Z","2020-02-14T00:00:00.000Z","2020-02-15T00:00:00.000Z","2020-02-16T00:00:00.000Z","2020-02-17T00:00:00.000Z","2020-02-18T00:00:00.000Z","2020-02-19T00:00:00.000Z","2020-02-20T00:00:00.000Z","2020-02-21T00:00:00.000Z","2020-02-22T00:00:00.000Z","2020-02-23T00:00:00.000Z","2020-02-24T00:00:00.000Z","2020-02-25T00:00:00.000Z","2020-02-26T00:00:00.000Z","2020-02-27T00:00:00.000Z","2020-02-28T00:00:00.000Z","2020-02-29T00:00:00.000Z","2020-03-01T00:00:00.000Z","2020-03-02T00:00:00.000Z","2020-03-03T00:00:00.000Z","2020-03-04T00:00:00.000Z","2020-03-05T00:00:00.000Z","2020-03-06T00:00:00.000Z","2020-03-07T00:00:00.000Z","2020-03-08T00:00:00.000Z","2020-03-09T00:00:00.000Z","2020-03-10T00:00:00.000Z","2020-03-11T00:00:00.000Z","2020-03-12T00:00:00.000Z","2020-03-13T00:00:00.000Z","2020-03-14T00:00:00.000Z","2020-03-15T00:00:00.000Z","2020-03-16T00:00:00.000Z","2020-03-17T00:00:00.000Z","2020-03-18T00:00:00.000Z","2020-03-19T00:00:00.000Z","2020-03-20T00:00:00.000Z","2020-03-21T00:00:00.000Z","2020-03-22T00:00:00.000Z","2020-03-23T00:00:00.000Z","2020-03-24T00:00:00.000Z","2020-03-25T00:00:00.000Z","2020-03-26T00:00:00.000Z","2020-03-27T00:00:00.000Z","2020-03-28T00:00:00.000Z","2020-03-29T00:00:00.000Z","2020-03-30T00:00:00.000Z","2020-03-31T00:00:00.000Z","2020-04-01T00:00:00.000Z","2020-04-02T00:00:00.000Z","2020-04-03T00:00:00.000Z","2020-04-04T00:00:00.000Z","2020-04-05T00:00:00.000Z","2020-04-06T00:00:00.000Z","2020-04-07T00:00:00.000Z","2020-04-08T00:00:00.000Z","2020-04-09T00:00:00.000Z","2020-04-10T00:00:00.000Z","2020-04-11T00:00:00.000Z","2020-04-12T00:00:00.000Z","2020-04-13T00:00:00.000Z","2020-04-14T00:00:00.000Z","2020-04-15T00:00:00.000Z","2020-04-16T00:00:00.000Z","2020-04-17T00:00:00.000Z","2020-04-18T00:00:00.000Z","2020-04-19T00:00:00.000Z","2020-04-20T00:00:00.000Z","2020-04-21T00:00:00.000Z","2020-04-22T00:00:00.000Z","2020-04-23T00:00:00.000Z","2020-04-24T00:00:00.000Z","2020-04-25T00:00:00.000Z","2020-04-26T00:00:00.000Z","2020-04-27T00:00:00.000Z","2020-04-28T00:00:00.000Z","2020-04-29T00:00:00.000Z","2020-04-30T00:00:00.000Z","2020-05-01T00:00:00.000Z","2020-05-02T00:00:00.000Z","2020-05-03T00:00:00.000Z","2020-05-04T00:00:00.000Z","2020-05-05T00:00:00.000Z","2020-05-06T00:00:00.000Z","2020-05-07T00:00:00.000Z","2020-05-08T00:00:00.000Z","2020-05-09T00:00:00.000Z","2020-05-10T00:00:00.000Z"],[null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,-6.90775527898214,-6.90775527898214,-6.90775527898214,-6.90775527898214,-6.90775527898214,-6.21460809842219,-6.21460809842219,-6.21460809842219,-5.80914299031403,-5.80914299031403,-5.52146091786225,-5.52146091786225,-5.29831736654804,-5.11599580975408,-5.11599580975408,-4.96184512992682,-4.8283137373023,-4.8283137373023,-4.71053070164592,-4.71053070164592,-4.60517018598809,-4.50986000618377,-4.42284862919414,-4.42284862919414,-4.3428059215206,-4.3428059215206,-4.26869794936688,-4.19970507787993,-4.19970507787993,-4.13516655674236,-4.07454193492592,-4.07454193492592,-4.07454193492592,-4.01738352108597,-3.9633162998157,-3.91202300542815,-3.91202300542815,-3.86323284125871,-3.86323284125871,-3.86323284125871,-3.81671282562382,-3.77226106305299,-3.77226106305299,-3.72970144863419,-3.72970144863419,-3.68887945411394],[null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,-6.90775527898214,-6.90775527898214,-6.90775527898214,-6.90775527898214,-6.21460809842219,-6.21460809842219,-5.80914299031403,-5.80914299031403,-5.52146091786225,-5.29831736654804,-5.11599580975408,-4.96184512992682,-4.8283137373023,-4.71053070164592,-4.60517018598809,-4.50986000618377,-4.3428059215206,-4.19970507787993,-4.13516655674236,-4.01738352108597,-3.9633162998157,-3.91202300542815,-3.86323284125871,-3.77226106305299,-3.72970144863419,-3.64965874096066,-3.61191841297781,-3.57555076880693,-3.54045944899566,-3.47376807449699,-3.44201937618241,-3.41124771751566,-3.35240721749272,-3.32423634052603,-3.29683736633791,-3.29683736633791,-3.24419363285249,-3.2188758248682,-3.19418321227783,-3.17008566069877,-3.14655516328857,-3.14655516328857,-3.12356564506388,-3.10109278921182,-3.07911388249304,-3.05760767727208,-3.03655426807425,-3.03655426807425,-3.01593498087151],[null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,-6.90775527898214,-6.90775527898214,-6.90775527898214,-6.90775527898214,-6.90775527898214,-6.21460809842219,-6.21460809842219,-5.80914299031403,-5.52146091786225,-5.52146091786225,-5.29831736654804,-5.11599580975408,-4.96184512992682,-4.8283137373023,-4.71053070164592,-4.60517018598809,-4.50986000618377,-4.3428059215206,-4.26869794936688,-4.19970507787993,-4.07454193492592,-4.01738352108597,-3.91202300542815,-3.86323284125871,-3.81671282562382,-3.77226106305299,-3.68887945411394,-3.64965874096066,-3.61191841297781,-3.57555076880693,-3.54045944899566,-3.50655789731998,-3.47376807449699,-3.44201937618241,-3.41124771751566,-3.41124771751566,-3.38139475436598,-3.35240721749272,-3.32423634052603,-3.29683736633791,-3.27016911925575,-3.24419363285249,-3.2188758248682,-3.19418321227783,-3.19418321227783,-3.17008566069877,-3.14655516328857,-3.12356564506388,-3.12356564506388,-3.10109278921182,-3.10109278921182,-3.07911388249304,-3.05760767727208,-3.05760767727208,-3.03655426807425,-3.03655426807425,-3.01593498087151,-3.01593498087151,-3.01593498087151,-2.99573227355399,-2.99573227355399,-2.97592964625781,-2.97592964625781,-2.97592964625781],[null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,-6.90775527898214,-6.90775527898214,-6.90775527898214,-6.90775527898214,-6.21460809842219,-6.21460809842219,-5.80914299031403,-5.52146091786225,-5.29831736654804,-5.11599580975408,-4.8283137373023,-4.71053070164592,-4.50986000618377,-4.3428059215206,-4.19970507787993,-4.07454193492592,-4.01738352108597,-3.91202300542815,-3.81671282562382,-3.72970144863419,-3.64965874096066,-3.61191841297781,-3.54045944899566,-3.50655789731998,-3.44201937618241,-3.41124771751566,-3.35240721749272,-3.32423634052603,-3.29683736633791,-3.27016911925575,-3.24419363285249,-3.2188758248682,-3.17008566069877,-3.14655516328857,-3.14655516328857,-3.12356564506388,-3.10109278921182,-3.07911388249304,-3.05760767727208,-3.03655426807425,-3.01593498087151,-3.01593498087151,-2.99573227355399,-2.97592964625781,-2.97592964625781,-2.95651156040071,-2.93746336543002,-2.93746336543002,-2.91877123241786,-2.90042209374967,-2.90042209374967,-2.90042209374967,-2.88240358824699,-2.88240358824699,-2.86470401114759,-2.86470401114759,-2.86470401114759],[null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,-6.90775527898214,-6.90775527898214,-6.90775527898214,-6.90775527898214,-6.21460809842219,-6.21460809842219,-5.80914299031403,-5.80914299031403,-5.52146091786225,-5.52146091786225,-5.29831736654804,-5.29831736654804,-4.96184512992682,-4.8283137373023,-4.60517018598809,-4.42284862919414,-4.3428059215206,-4.26869794936688,-4.13516655674236,-4.07454193492592,-3.9633162998157,-3.91202300542815,-3.86323284125871,-3.81671282562382,-3.77226106305299,-3.72970144863419,-3.61191841297781,-3.57555076880693,-3.54045944899566,-3.50655789731998,-3.50655789731998,-3.47376807449699,-3.44201937618241,-3.41124771751566,-3.38139475436598,-3.38139475436598,-3.35240721749272,-3.35240721749272,-3.32423634052603,-3.29683736633791,-3.29683736633791,-3.27016911925575,-3.27016911925575,-3.27016911925575,-3.27016911925575,-3.24419363285249,-3.24419363285249,-3.2188758248682,-3.2188758248682,-3.19418321227783,-3.19418321227783,-3.19418321227783]],"fixedtz":false,"tzone":"UTC"},"evals":["attrs.interactionModel"],"jsHooks":[]}</script>
<div id="htmlwidget-ab5864436fd6d7c00360" style="width:960px;height:500px;" class="dygraphs html-widget"></div>
<script type="application/json" data-for="htmlwidget-ab5864436fd6d7c00360">{"x":{"attrs":{"axes":{"x":{"pixelsPerLabel":60,"drawGrid":false,"drawAxis":true},"y":{"drawAxis":true}},"title":"Top Countries - New Fatal Cases","labels":["day","US","United Kingdom","Italy","Spain","France"],"retainDateWindow":false,"ylabel":"New Fatal Cases","stackedGraph":false,"fillGraph":false,"fillAlpha":0.15,"stepPlot":false,"drawPoints":false,"pointSize":1,"drawGapEdgePoints":false,"connectSeparatedPoints":false,"strokeWidth":1,"strokeBorderColor":"white","colors":["#1B9E77","#D95F02","#7570B3","#E7298A","#66A61E"],"colorValue":0.5,"colorSaturation":1,"includeZero":false,"drawAxesAtZero":false,"logscale":false,"axisTickSize":3,"axisLineColor":"navy","axisLineWidth":1.5,"axisLabelColor":"black","axisLabelFontSize":14,"axisLabelWidth":60,"drawGrid":true,"gridLineColor":"lightblue","gridLineWidth":0.3,"rightGap":5,"digitsAfterDecimal":2,"labelsKMB":false,"labelsKMG2":false,"labelsUTC":false,"maxNumberWidth":6,"animatedZooms":false,"mobileDisableYTouch":true,"disableZoom":false,"showRangeSelector":true,"rangeSelectorHeight":40,"rangeSelectorPlotFillColor":" #A7B1C4","rangeSelectorPlotStrokeColor":"#808FAB","interactionModel":"Dygraph.Interaction.defaultModel","legend":"auto","labelsDivWidth":750,"labelsShowZeroValues":true,"labelsSeparateLines":false,"hideOverlayOnMouseOut":true},"scale":"daily","annotations":[],"shadings":[],"events":[],"format":"date","data":[["2020-01-22T00:00:00.000Z","2020-01-23T00:00:00.000Z","2020-01-24T00:00:00.000Z","2020-01-25T00:00:00.000Z","2020-01-26T00:00:00.000Z","2020-01-27T00:00:00.000Z","2020-01-28T00:00:00.000Z","2020-01-29T00:00:00.000Z","2020-01-30T00:00:00.000Z","2020-01-31T00:00:00.000Z","2020-02-01T00:00:00.000Z","2020-02-02T00:00:00.000Z","2020-02-03T00:00:00.000Z","2020-02-04T00:00:00.000Z","2020-02-05T00:00:00.000Z","2020-02-06T00:00:00.000Z","2020-02-07T00:00:00.000Z","2020-02-08T00:00:00.000Z","2020-02-09T00:00:00.000Z","2020-02-10T00:00:00.000Z","2020-02-11T00:00:00.000Z","2020-02-12T00:00:00.000Z","2020-02-13T00:00:00.000Z","2020-02-14T00:00:00.000Z","2020-02-15T00:00:00.000Z","2020-02-16T00:00:00.000Z","2020-02-17T00:00:00.000Z","2020-02-18T00:00:00.000Z","2020-02-19T00:00:00.000Z","2020-02-20T00:00:00.000Z","2020-02-21T00:00:00.000Z","2020-02-22T00:00:00.000Z","2020-02-23T00:00:00.000Z","2020-02-24T00:00:00.000Z","2020-02-25T00:00:00.000Z","2020-02-26T00:00:00.000Z","2020-02-27T00:00:00.000Z","2020-02-28T00:00:00.000Z","2020-02-29T00:00:00.000Z","2020-03-01T00:00:00.000Z","2020-03-02T00:00:00.000Z","2020-03-03T00:00:00.000Z","2020-03-04T00:00:00.000Z","2020-03-05T00:00:00.000Z","2020-03-06T00:00:00.000Z","2020-03-07T00:00:00.000Z","2020-03-08T00:00:00.000Z","2020-03-09T00:00:00.000Z","2020-03-10T00:00:00.000Z","2020-03-11T00:00:00.000Z","2020-03-12T00:00:00.000Z","2020-03-13T00:00:00.000Z","2020-03-14T00:00:00.000Z","2020-03-15T00:00:00.000Z","2020-03-16T00:00:00.000Z","2020-03-17T00:00:00.000Z","2020-03-18T00:00:00.000Z","2020-03-19T00:00:00.000Z","2020-03-20T00:00:00.000Z","2020-03-21T00:00:00.000Z","2020-03-22T00:00:00.000Z","2020-03-23T00:00:00.000Z","2020-03-24T00:00:00.000Z","2020-03-25T00:00:00.000Z","2020-03-26T00:00:00.000Z","2020-03-27T00:00:00.000Z","2020-03-28T00:00:00.000Z","2020-03-29T00:00:00.000Z","2020-03-30T00:00:00.000Z","2020-03-31T00:00:00.000Z","2020-04-01T00:00:00.000Z","2020-04-02T00:00:00.000Z","2020-04-03T00:00:00.000Z","2020-04-04T00:00:00.000Z","2020-04-05T00:00:00.000Z","2020-04-06T00:00:00.000Z","2020-04-07T00:00:00.000Z","2020-04-08T00:00:00.000Z","2020-04-09T00:00:00.000Z","2020-04-10T00:00:00.000Z","2020-04-11T00:00:00.000Z","2020-04-12T00:00:00.000Z","2020-04-13T00:00:00.000Z","2020-04-14T00:00:00.000Z","2020-04-15T00:00:00.000Z","2020-04-16T00:00:00.000Z","2020-04-17T00:00:00.000Z","2020-04-18T00:00:00.000Z","2020-04-19T00:00:00.000Z","2020-04-20T00:00:00.000Z","2020-04-21T00:00:00.000Z","2020-04-22T00:00:00.000Z","2020-04-23T00:00:00.000Z","2020-04-24T00:00:00.000Z","2020-04-25T00:00:00.000Z","2020-04-26T00:00:00.000Z","2020-04-27T00:00:00.000Z","2020-04-28T00:00:00.000Z","2020-04-29T00:00:00.000Z","2020-04-30T00:00:00.000Z","2020-05-01T00:00:00.000Z","2020-05-02T00:00:00.000Z","2020-05-03T00:00:00.000Z","2020-05-04T00:00:00.000Z","2020-05-05T00:00:00.000Z","2020-05-06T00:00:00.000Z","2020-05-07T00:00:00.000Z","2020-05-08T00:00:00.000Z","2020-05-09T00:00:00.000Z","2020-05-10T00:00:00.000Z"],[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,5,1,4,1,2,3,4,1,6,8,5,8,9,15,26,34,31,94,91,93,144,200,222,308,410,539,466,689,772,1175,1134,1420,1325,1609,1520,1519,2297,2079,1985,2078,2009,1744,1784,2392,2472,2093,2584,2342,1192,1714,2427,2326,2312,1769,2262,1126,1338,2136,2612,2029,1947,1426,1313,1240,2142,2391,2207,1518,1615,731],[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,0,1,4,0,2,1,18,15,23,16,34,43,36,56,35,74,149,186,184,284,294,215,374,383,671,652,715,761,646,571,1038,1036,1104,1153,840,686,745,1048,846,1033,936,1118,499,565,1172,847,729,1013,844,420,341,911,797,676,741,622,315,289,692,649,539,627,346,268],[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,4,3,2,5,4,8,5,18,27,28,41,49,36,133,97,168,196,0,439,175,368,349,345,475,427,627,793,651,601,743,683,712,919,889,756,812,837,727,760,766,681,525,636,604,542,610,570,619,431,566,602,578,525,575,482,433,454,534,437,464,420,415,260,333,382,323,285,269,474,174,195,236,369,274,243,194,165],[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,2,5,7,11,7,19,1,78,62,94,53,191,90,207,213,332,397,539,497,839,718,773,844,821,913,748,923,961,850,749,694,700,704,747,655,634,525,603,547,300,652,607,687,41,410,399,430,435,440,367,378,288,331,301,453,268,0,557,164,164,185,244,213,229,179,143],[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,1,1,0,2,3,2,8,0,14,15,0,31,12,0,58,0,0,95,207,112,113,186,240,231,365,299,320,294,419,502,882,984,1122,1054,519,833,1417,544,1341,987,636,561,574,745,1438,753,761,642,395,547,531,544,516,390,369,242,437,367,427,289,218,166,137,304,333,275,178,243,80,70]],"fixedtz":false,"tzone":"UTC"},"evals":["attrs.interactionModel"],"jsHooks":[]}</script>
<div id="htmlwidget-43a262d76524ceb9c99f" style="width:960px;height:500px;" class="dygraphs html-widget"></div>
<script type="application/json" data-for="htmlwidget-43a262d76524ceb9c99f">{"x":{"attrs":{"axes":{"x":{"pixelsPerLabel":60,"drawGrid":false,"drawAxis":true},"y":{"drawAxis":true}},"title":"Top Countries - Log Of New Fatal Cases","labels":["day","US","United Kingdom","Italy","Spain","France"],"retainDateWindow":false,"ylabel":"Log Of New Fatal Cases","stackedGraph":false,"fillGraph":false,"fillAlpha":0.15,"stepPlot":false,"drawPoints":false,"pointSize":1,"drawGapEdgePoints":false,"connectSeparatedPoints":false,"strokeWidth":1,"strokeBorderColor":"white","colors":["#1B9E77","#D95F02","#7570B3","#E7298A","#66A61E"],"colorValue":0.5,"colorSaturation":1,"includeZero":false,"drawAxesAtZero":false,"logscale":false,"axisTickSize":3,"axisLineColor":"navy","axisLineWidth":1.5,"axisLabelColor":"black","axisLabelFontSize":14,"axisLabelWidth":60,"drawGrid":true,"gridLineColor":"lightblue","gridLineWidth":0.3,"rightGap":5,"digitsAfterDecimal":2,"labelsKMB":false,"labelsKMG2":false,"labelsUTC":false,"maxNumberWidth":6,"animatedZooms":false,"mobileDisableYTouch":true,"disableZoom":false,"showRangeSelector":true,"rangeSelectorHeight":40,"rangeSelectorPlotFillColor":" #A7B1C4","rangeSelectorPlotStrokeColor":"#808FAB","interactionModel":"Dygraph.Interaction.defaultModel","legend":"auto","labelsDivWidth":750,"labelsShowZeroValues":true,"labelsSeparateLines":false,"hideOverlayOnMouseOut":true},"scale":"daily","annotations":[],"shadings":[],"events":[],"format":"date","data":[["2020-01-22T00:00:00.000Z","2020-01-23T00:00:00.000Z","2020-01-24T00:00:00.000Z","2020-01-25T00:00:00.000Z","2020-01-26T00:00:00.000Z","2020-01-27T00:00:00.000Z","2020-01-28T00:00:00.000Z","2020-01-29T00:00:00.000Z","2020-01-30T00:00:00.000Z","2020-01-31T00:00:00.000Z","2020-02-01T00:00:00.000Z","2020-02-02T00:00:00.000Z","2020-02-03T00:00:00.000Z","2020-02-04T00:00:00.000Z","2020-02-05T00:00:00.000Z","2020-02-06T00:00:00.000Z","2020-02-07T00:00:00.000Z","2020-02-08T00:00:00.000Z","2020-02-09T00:00:00.000Z","2020-02-10T00:00:00.000Z","2020-02-11T00:00:00.000Z","2020-02-12T00:00:00.000Z","2020-02-13T00:00:00.000Z","2020-02-14T00:00:00.000Z","2020-02-15T00:00:00.000Z","2020-02-16T00:00:00.000Z","2020-02-17T00:00:00.000Z","2020-02-18T00:00:00.000Z","2020-02-19T00:00:00.000Z","2020-02-20T00:00:00.000Z","2020-02-21T00:00:00.000Z","2020-02-22T00:00:00.000Z","2020-02-23T00:00:00.000Z","2020-02-24T00:00:00.000Z","2020-02-25T00:00:00.000Z","2020-02-26T00:00:00.000Z","2020-02-27T00:00:00.000Z","2020-02-28T00:00:00.000Z","2020-02-29T00:00:00.000Z","2020-03-01T00:00:00.000Z","2020-03-02T00:00:00.000Z","2020-03-03T00:00:00.000Z","2020-03-04T00:00:00.000Z","2020-03-05T00:00:00.000Z","2020-03-06T00:00:00.000Z","2020-03-07T00:00:00.000Z","2020-03-08T00:00:00.000Z","2020-03-09T00:00:00.000Z","2020-03-10T00:00:00.000Z","2020-03-11T00:00:00.000Z","2020-03-12T00:00:00.000Z","2020-03-13T00:00:00.000Z","2020-03-14T00:00:00.000Z","2020-03-15T00:00:00.000Z","2020-03-16T00:00:00.000Z","2020-03-17T00:00:00.000Z","2020-03-18T00:00:00.000Z","2020-03-19T00:00:00.000Z","2020-03-20T00:00:00.000Z","2020-03-21T00:00:00.000Z","2020-03-22T00:00:00.000Z","2020-03-23T00:00:00.000Z","2020-03-24T00:00:00.000Z","2020-03-25T00:00:00.000Z","2020-03-26T00:00:00.000Z","2020-03-27T00:00:00.000Z","2020-03-28T00:00:00.000Z","2020-03-29T00:00:00.000Z","2020-03-30T00:00:00.000Z","2020-03-31T00:00:00.000Z","2020-04-01T00:00:00.000Z","2020-04-02T00:00:00.000Z","2020-04-03T00:00:00.000Z","2020-04-04T00:00:00.000Z","2020-04-05T00:00:00.000Z","2020-04-06T00:00:00.000Z","2020-04-07T00:00:00.000Z","2020-04-08T00:00:00.000Z","2020-04-09T00:00:00.000Z","2020-04-10T00:00:00.000Z","2020-04-11T00:00:00.000Z","2020-04-12T00:00:00.000Z","2020-04-13T00:00:00.000Z","2020-04-14T00:00:00.000Z","2020-04-15T00:00:00.000Z","2020-04-16T00:00:00.000Z","2020-04-17T00:00:00.000Z","2020-04-18T00:00:00.000Z","2020-04-19T00:00:00.000Z","2020-04-20T00:00:00.000Z","2020-04-21T00:00:00.000Z","2020-04-22T00:00:00.000Z","2020-04-23T00:00:00.000Z","2020-04-24T00:00:00.000Z","2020-04-25T00:00:00.000Z","2020-04-26T00:00:00.000Z","2020-04-27T00:00:00.000Z","2020-04-28T00:00:00.000Z","2020-04-29T00:00:00.000Z","2020-04-30T00:00:00.000Z","2020-05-01T00:00:00.000Z","2020-05-02T00:00:00.000Z","2020-05-03T00:00:00.000Z","2020-05-04T00:00:00.000Z","2020-05-05T00:00:00.000Z","2020-05-06T00:00:00.000Z","2020-05-07T00:00:00.000Z","2020-05-08T00:00:00.000Z","2020-05-09T00:00:00.000Z","2020-05-10T00:00:00.000Z"],[null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,0,null,1.6094379124341,0,1.38629436111989,0,0.693147180559945,1.09861228866811,1.38629436111989,0,1.79175946922805,2.07944154167984,1.6094379124341,2.07944154167984,2.19722457733622,2.70805020110221,3.25809653802148,3.52636052461616,3.43398720448515,4.54329478227,4.51085950651685,4.53259949315326,4.969813299576,5.29831736654804,5.40267738187228,5.73009978297357,6.01615715969835,6.289715570909,6.14418563412565,6.53524127101366,6.64898455002478,7.06902342657826,7.0335064842877,7.25841215059531,7.18916773842032,7.38336814699238,7.32646561384032,7.32580750259577,7.7393592026891,7.63964228785801,7.59337419312129,7.63916117165917,7.60539236481493,7.46393660446893,7.48661331313996,7.77988511507052,7.81278281857758,7.646353722446,7.85709386490249,7.75876054415766,7.0833878476253,7.44658509915773,7.7944112057266,7.75190533307861,7.74586822979227,7.47816969415979,7.72400465667607,7.02642680869964,7.19893124068817,7.66669020008009,7.86787149039632,7.61529833982581,7.5740450053722,7.26262860097424,7.1800698743028,7.12286665859908,7.66949525100769,7.77946696745832,7.69938940625674,7.32514895795557,7.38709023565676,6.59441345974978],[null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,0,0,null,0,1.38629436111989,null,0.693147180559945,0,2.89037175789616,2.70805020110221,3.13549421592915,2.77258872223978,3.52636052461616,3.76120011569356,3.58351893845611,4.02535169073515,3.55534806148941,4.30406509320417,5.00394630594546,5.2257466737132,5.21493575760899,5.64897423816121,5.68357976733868,5.37063802812766,5.92425579741453,5.94803498918065,6.50876913697168,6.48004456192665,6.57228254269401,6.63463335786169,6.4707995037826,6.34738920965601,6.94505106372583,6.94312242281943,7.00669522683704,7.05012252026906,6.73340189183736,6.53087762772588,6.61338421837956,6.95463886488099,6.74051935960622,6.94022246911964,6.84161547647759,7.01929665371504,6.21260609575152,6.33682573114644,7.06646697013696,6.74170069465205,6.59167373200866,6.92067150424868,6.73815249459596,6.04025471127741,5.83188247728352,6.81454289725996,6.68085467879022,6.51619307604296,6.60800062529609,6.43294009273918,5.75257263882563,5.66642668811243,6.53958595561767,6.47543271670409,6.289715570909,6.44094654063292,5.84643877505772,5.59098698051086],[null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,0,0,0,1.38629436111989,1.09861228866811,0.693147180559945,1.6094379124341,1.38629436111989,2.07944154167984,1.6094379124341,2.89037175789616,3.29583686600433,3.3322045101752,3.71357206670431,3.89182029811063,3.58351893845611,4.89034912822175,4.57471097850338,5.12396397940326,5.27811465923052,null,6.08449941307517,5.16478597392351,5.90808293816893,5.85507192220243,5.84354441703136,6.16331480403464,6.05678401322862,6.44094654063292,6.67582322163485,6.47850964220857,6.39859493453521,6.61069604471776,6.52649485957079,6.56807791141198,6.82328612235569,6.7900972355139,6.62804137617953,6.69950034016168,6.72982407048948,6.58892647753352,6.63331843328038,6.64118216974059,6.52356230614951,6.26339826259162,6.45519856334012,6.40357419793482,6.29526600143965,6.41345895716736,6.3456363608286,6.4281052726846,6.06610809010375,6.33859407820318,6.40025744530882,6.35957386867238,6.26339826259162,6.35437004079735,6.1779441140506,6.07073772800249,6.11809719804135,6.2803958389602,6.07993319509559,6.13988455222626,6.04025471127741,6.0282785202307,5.56068163101553,5.80814248998044,5.94542060860658,5.77765232322266,5.65248918026865,5.59471137960184,6.16120732169508,5.15905529921453,5.27299955856375,5.46383180502561,5.91079664404053,5.61312810638807,5.49306144334055,5.26785815906333,5.10594547390058],[null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,0,0,0,0.693147180559945,1.6094379124341,1.94591014905531,2.39789527279837,1.94591014905531,2.94443897916644,0,4.35670882668959,4.12713438504509,4.54329478227,3.97029191355212,5.25227342804663,4.49980967033027,5.33271879326537,5.36129216570943,5.80513496891649,5.98393628068719,6.289715570909,6.20859002609663,6.73221070646721,6.57646956904822,6.65027904858742,6.73815249459596,6.71052310945243,6.81673588059497,6.61740297797448,6.82762923450285,6.86797440897029,6.74523634948436,6.61873898351722,6.5424719605068,6.5510803350434,6.55677835615804,6.61606518513282,6.48463523563525,6.45204895443723,6.26339826259162,6.40191719672719,6.30444880242198,5.7037824746562,6.48004456192665,6.4085287910595,6.53233429222235,3.71357206670431,6.01615715969835,5.98896141688986,6.06378520868761,6.07534603108868,6.08677472691231,5.90536184805457,5.93489419561959,5.66296048013595,5.80211837537706,5.70711026474888,6.11589212548303,5.59098698051086,null,6.32256523992728,5.0998664278242,5.0998664278242,5.22035582507832,5.4971682252932,5.36129216570943,5.43372200355424,5.18738580584075,4.96284463025991],[null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,0,null,null,null,null,null,null,null,null,null,null,0,null,null,null,null,0,0,null,0.693147180559945,1.09861228866811,0.693147180559945,2.07944154167984,null,2.63905732961526,2.70805020110221,null,3.43398720448515,2.484906649788,null,4.06044301054642,null,null,4.55387689160054,5.33271879326537,4.71849887129509,4.72738781871234,5.2257466737132,5.48063892334199,5.44241771052179,5.89989735358249,5.70044357339069,5.76832099579377,5.68357976733868,6.03787091992214,6.21860011969173,6.78219205600679,6.89162589705225,7.02286808608264,6.96034772910131,6.25190388316589,6.72503364216684,7.25629723969068,6.29894924685594,7.20117088328168,6.89467003943348,6.45519856334012,6.3297209055227,6.35262939631957,6.61338421837956,7.27100853828099,6.62406522779989,6.63463335786169,6.46458830368996,5.97888576490112,6.30444880242198,6.27476202124194,6.29894924685594,6.24610676548156,5.96614673912369,5.91079664404053,5.48893772615669,6.07993319509559,5.90536184805457,6.05678401322862,5.66642668811243,5.38449506278909,5.11198778835654,4.91998092582813,5.71702770140622,5.80814248998044,5.61677109766657,5.18178355029209,5.49306144334055,4.38202663467388,4.24849524204936]],"fixedtz":false,"tzone":"UTC"},"evals":["attrs.interactionModel"],"jsHooks":[]}</script><!--/html_preserve--><!--html_preserve--><div id="htmlwidget-b1f705daa0720ba0ad5b" style="width:960px;height:500px;" class="dygraphs html-widget"></div>
<script type="application/json" data-for="htmlwidget-b1f705daa0720ba0ad5b">{"x":{"attrs":{"axes":{"x":{"pixelsPerLabel":60,"drawGrid":false,"drawAxis":true},"y":{"drawAxis":true}},"title":"Top Countries - Count Of Active Cases","labels":["day","US","United Kingdom","Russia","France","Brazil"],"retainDateWindow":false,"ylabel":"Count Of Active Cases","stackedGraph":false,"fillGraph":false,"fillAlpha":0.15,"stepPlot":false,"drawPoints":false,"pointSize":1,"drawGapEdgePoints":false,"connectSeparatedPoints":false,"strokeWidth":1,"strokeBorderColor":"white","colors":["#1B9E77","#D95F02","#7570B3","#E7298A","#66A61E"],"colorValue":0.5,"colorSaturation":1,"includeZero":false,"drawAxesAtZero":false,"logscale":false,"axisTickSize":3,"axisLineColor":"navy","axisLineWidth":1.5,"axisLabelColor":"black","axisLabelFontSize":14,"axisLabelWidth":60,"drawGrid":true,"gridLineColor":"lightblue","gridLineWidth":0.3,"rightGap":5,"digitsAfterDecimal":2,"labelsKMB":false,"labelsKMG2":false,"labelsUTC":false,"maxNumberWidth":6,"animatedZooms":false,"mobileDisableYTouch":true,"disableZoom":false,"showRangeSelector":true,"rangeSelectorHeight":40,"rangeSelectorPlotFillColor":" #A7B1C4","rangeSelectorPlotStrokeColor":"#808FAB","interactionModel":"Dygraph.Interaction.defaultModel","legend":"auto","labelsDivWidth":750,"labelsShowZeroValues":true,"labelsSeparateLines":false,"hideOverlayOnMouseOut":true},"scale":"daily","annotations":[],"shadings":[],"events":[],"format":"date","data":[["2020-01-22T00:00:00.000Z","2020-01-23T00:00:00.000Z","2020-01-24T00:00:00.000Z","2020-01-25T00:00:00.000Z","2020-01-26T00:00:00.000Z","2020-01-27T00:00:00.000Z","2020-01-28T00:00:00.000Z","2020-01-29T00:00:00.000Z","2020-01-30T00:00:00.000Z","2020-01-31T00:00:00.000Z","2020-02-01T00:00:00.000Z","2020-02-02T00:00:00.000Z","2020-02-03T00:00:00.000Z","2020-02-04T00:00:00.000Z","2020-02-05T00:00:00.000Z","2020-02-06T00:00:00.000Z","2020-02-07T00:00:00.000Z","2020-02-08T00:00:00.000Z","2020-02-09T00:00:00.000Z","2020-02-10T00:00:00.000Z","2020-02-11T00:00:00.000Z","2020-02-12T00:00:00.000Z","2020-02-13T00:00:00.000Z","2020-02-14T00:00:00.000Z","2020-02-15T00:00:00.000Z","2020-02-16T00:00:00.000Z","2020-02-17T00:00:00.000Z","2020-02-18T00:00:00.000Z","2020-02-19T00:00:00.000Z","2020-02-20T00:00:00.000Z","2020-02-21T00:00:00.000Z","2020-02-22T00:00:00.000Z","2020-02-23T00:00:00.000Z","2020-02-24T00:00:00.000Z","2020-02-25T00:00:00.000Z","2020-02-26T00:00:00.000Z","2020-02-27T00:00:00.000Z","2020-02-28T00:00:00.000Z","2020-02-29T00:00:00.000Z","2020-03-01T00:00:00.000Z","2020-03-02T00:00:00.000Z","2020-03-03T00:00:00.000Z","2020-03-04T00:00:00.000Z","2020-03-05T00:00:00.000Z","2020-03-06T00:00:00.000Z","2020-03-07T00:00:00.000Z","2020-03-08T00:00:00.000Z","2020-03-09T00:00:00.000Z","2020-03-10T00:00:00.000Z","2020-03-11T00:00:00.000Z","2020-03-12T00:00:00.000Z","2020-03-13T00:00:00.000Z","2020-03-14T00:00:00.000Z","2020-03-15T00:00:00.000Z","2020-03-16T00:00:00.000Z","2020-03-17T00:00:00.000Z","2020-03-18T00:00:00.000Z","2020-03-19T00:00:00.000Z","2020-03-20T00:00:00.000Z","2020-03-21T00:00:00.000Z","2020-03-22T00:00:00.000Z","2020-03-23T00:00:00.000Z","2020-03-24T00:00:00.000Z","2020-03-25T00:00:00.000Z","2020-03-26T00:00:00.000Z","2020-03-27T00:00:00.000Z","2020-03-28T00:00:00.000Z","2020-03-29T00:00:00.000Z","2020-03-30T00:00:00.000Z","2020-03-31T00:00:00.000Z","2020-04-01T00:00:00.000Z","2020-04-02T00:00:00.000Z","2020-04-03T00:00:00.000Z","2020-04-04T00:00:00.000Z","2020-04-05T00:00:00.000Z","2020-04-06T00:00:00.000Z","2020-04-07T00:00:00.000Z","2020-04-08T00:00:00.000Z","2020-04-09T00:00:00.000Z","2020-04-10T00:00:00.000Z","2020-04-11T00:00:00.000Z","2020-04-12T00:00:00.000Z","2020-04-13T00:00:00.000Z","2020-04-14T00:00:00.000Z","2020-04-15T00:00:00.000Z","2020-04-16T00:00:00.000Z","2020-04-17T00:00:00.000Z","2020-04-18T00:00:00.000Z","2020-04-19T00:00:00.000Z","2020-04-20T00:00:00.000Z","2020-04-21T00:00:00.000Z","2020-04-22T00:00:00.000Z","2020-04-23T00:00:00.000Z","2020-04-24T00:00:00.000Z","2020-04-25T00:00:00.000Z","2020-04-26T00:00:00.000Z","2020-04-27T00:00:00.000Z","2020-04-28T00:00:00.000Z","2020-04-29T00:00:00.000Z","2020-04-30T00:00:00.000Z","2020-05-01T00:00:00.000Z","2020-05-02T00:00:00.000Z","2020-05-03T00:00:00.000Z","2020-05-04T00:00:00.000Z","2020-05-05T00:00:00.000Z","2020-05-06T00:00:00.000Z","2020-05-07T00:00:00.000Z","2020-05-08T00:00:00.000Z","2020-05-09T00:00:00.000Z","2020-05-10T00:00:00.000Z"],[1,1,2,2,5,5,5,5,5,7,8,8,11,11,11,11,11,11,8,8,9,9,10,10,10,10,10,10,10,10,10,10,10,46,45,51,52,53,60,66,85,104,131,198,241,378,490,554,923,1237,1610,2118,2657,3414,4516,6271,7514,13368,18777,24982,32512,42879,52380,64101,81429,98523,117662,134824,151995,175781,198267,226700,256414,283143,306979,332842,359167,386825,417115,445412,470784,496239,509267,529645,551520,578062,603750,627604,647527,669338,691575,715573,739243,754786,784027,803916,820554,838291,858222,852481,874503,890788,910206,924273,943496,965966,986325,1007756,1018221,1033565],[0,0,0,0,0,0,0,0,0,2,2,2,2,2,2,2,3,3,3,8,8,8,8,8,8,1,1,1,1,1,1,1,1,5,5,5,7,12,15,28,32,43,78,108,155,187,254,301,358,433,431,773,1097,1083,1464,1825,2459,2490,3752,4749,5392,6299,7515,8805,10783,13431,15704,17957,20236,22873,26586,30229,34014,37034,42333,45547,48141,52610,55890,63241,67636,72278,76219,80427,84174,87796,92465,96872,102209,106318,109270,112844,116694,121063,125098,129142,133083,136168,139418,144780,150210,154399,158421,162113,165816,171275,176318,180316,183862,187517],[0,0,0,0,0,0,0,0,0,2,2,2,2,2,2,2,2,2,2,2,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,2,11,11,14,14,17,17,25,42,51,55,82,106,139,189,243,293,350,421,472,626,799,987,1211,1462,1761,2199,2563,3283,3834,4355,4989,5890,6945,8029,9357,11028,12433,14349,16710,19238,22306,25402,29145,33423,39201,43270,48434,53066,57327,62439,67657,73435,79007,84235,88141,93806,100042,107819,116768,125817,134054,143065,151732,159528,164933,173467],[0,0,2,3,3,3,4,5,5,5,6,6,6,6,6,6,6,11,11,11,11,9,9,9,7,7,7,7,7,7,7,7,7,7,2,5,25,44,86,116,176,188,272,362,635,936,1105,1188,1749,2233,2233,3590,4393,4429,6522,7554,8963,10714,12295,13888,13361,17055,18270,20360,22898,25698,30064,30871,34176,39782,42282,41983,44547,46354,46970,48989,49297,50718,51725,53328,54349,79831,82407,85829,85461,95341,94981,92778,96713,97717,98189,93981,94357,94211,94433,94458,97154,98504,94225,93444,92496,93092,93140,92903,92308,94333,93737,94077,94321,94384],[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,2,2,2,2,4,4,13,13,20,25,31,38,52,151,151,162,199,318,367,613,780,1004,1519,1888,2199,2493,2902,3319,3787,4114,4300,5389,6469,7593,8570,9788,10517,11470,13221,15224,16969,18408,19430,20796,21929,20684,12558,14475,17515,20278,14062,16026,17347,17533,20132,22684,26107,28662,31701,35608,40040,45246,47751,49402,51784,55438,59296,66653,71233,77580,83720,86619]],"fixedtz":false,"tzone":"UTC"},"evals":["attrs.interactionModel"],"jsHooks":[]}</script>
<div id="htmlwidget-5cfb5cf7819b1dc761b8" style="width:960px;height:500px;" class="dygraphs html-widget"></div>
<script type="application/json" data-for="htmlwidget-5cfb5cf7819b1dc761b8">{"x":{"attrs":{"axes":{"x":{"pixelsPerLabel":60,"drawGrid":false,"drawAxis":true},"y":{"drawAxis":true}},"title":"Top Countries - Log Count Of Active Cases","labels":["day","US","United Kingdom","Russia","France","Brazil"],"retainDateWindow":false,"ylabel":"Log Count Of Active Cases","stackedGraph":false,"fillGraph":false,"fillAlpha":0.15,"stepPlot":false,"drawPoints":false,"pointSize":1,"drawGapEdgePoints":false,"connectSeparatedPoints":false,"strokeWidth":1,"strokeBorderColor":"white","colors":["#1B9E77","#D95F02","#7570B3","#E7298A","#66A61E"],"colorValue":0.5,"colorSaturation":1,"includeZero":false,"drawAxesAtZero":false,"logscale":false,"axisTickSize":3,"axisLineColor":"navy","axisLineWidth":1.5,"axisLabelColor":"black","axisLabelFontSize":14,"axisLabelWidth":60,"drawGrid":true,"gridLineColor":"lightblue","gridLineWidth":0.3,"rightGap":5,"digitsAfterDecimal":2,"labelsKMB":false,"labelsKMG2":false,"labelsUTC":false,"maxNumberWidth":6,"animatedZooms":false,"mobileDisableYTouch":true,"disableZoom":false,"showRangeSelector":true,"rangeSelectorHeight":40,"rangeSelectorPlotFillColor":" #A7B1C4","rangeSelectorPlotStrokeColor":"#808FAB","interactionModel":"Dygraph.Interaction.defaultModel","legend":"auto","labelsDivWidth":750,"labelsShowZeroValues":true,"labelsSeparateLines":false,"hideOverlayOnMouseOut":true},"scale":"daily","annotations":[],"shadings":[],"events":[],"format":"date","data":[["2020-01-22T00:00:00.000Z","2020-01-23T00:00:00.000Z","2020-01-24T00:00:00.000Z","2020-01-25T00:00:00.000Z","2020-01-26T00:00:00.000Z","2020-01-27T00:00:00.000Z","2020-01-28T00:00:00.000Z","2020-01-29T00:00:00.000Z","2020-01-30T00:00:00.000Z","2020-01-31T00:00:00.000Z","2020-02-01T00:00:00.000Z","2020-02-02T00:00:00.000Z","2020-02-03T00:00:00.000Z","2020-02-04T00:00:00.000Z","2020-02-05T00:00:00.000Z","2020-02-06T00:00:00.000Z","2020-02-07T00:00:00.000Z","2020-02-08T00:00:00.000Z","2020-02-09T00:00:00.000Z","2020-02-10T00:00:00.000Z","2020-02-11T00:00:00.000Z","2020-02-12T00:00:00.000Z","2020-02-13T00:00:00.000Z","2020-02-14T00:00:00.000Z","2020-02-15T00:00:00.000Z","2020-02-16T00:00:00.000Z","2020-02-17T00:00:00.000Z","2020-02-18T00:00:00.000Z","2020-02-19T00:00:00.000Z","2020-02-20T00:00:00.000Z","2020-02-21T00:00:00.000Z","2020-02-22T00:00:00.000Z","2020-02-23T00:00:00.000Z","2020-02-24T00:00:00.000Z","2020-02-25T00:00:00.000Z","2020-02-26T00:00:00.000Z","2020-02-27T00:00:00.000Z","2020-02-28T00:00:00.000Z","2020-02-29T00:00:00.000Z","2020-03-01T00:00:00.000Z","2020-03-02T00:00:00.000Z","2020-03-03T00:00:00.000Z","2020-03-04T00:00:00.000Z","2020-03-05T00:00:00.000Z","2020-03-06T00:00:00.000Z","2020-03-07T00:00:00.000Z","2020-03-08T00:00:00.000Z","2020-03-09T00:00:00.000Z","2020-03-10T00:00:00.000Z","2020-03-11T00:00:00.000Z","2020-03-12T00:00:00.000Z","2020-03-13T00:00:00.000Z","2020-03-14T00:00:00.000Z","2020-03-15T00:00:00.000Z","2020-03-16T00:00:00.000Z","2020-03-17T00:00:00.000Z","2020-03-18T00:00:00.000Z","2020-03-19T00:00:00.000Z","2020-03-20T00:00:00.000Z","2020-03-21T00:00:00.000Z","2020-03-22T00:00:00.000Z","2020-03-23T00:00:00.000Z","2020-03-24T00:00:00.000Z","2020-03-25T00:00:00.000Z","2020-03-26T00:00:00.000Z","2020-03-27T00:00:00.000Z","2020-03-28T00:00:00.000Z","2020-03-29T00:00:00.000Z","2020-03-30T00:00:00.000Z","2020-03-31T00:00:00.000Z","2020-04-01T00:00:00.000Z","2020-04-02T00:00:00.000Z","2020-04-03T00:00:00.000Z","2020-04-04T00:00:00.000Z","2020-04-05T00:00:00.000Z","2020-04-06T00:00:00.000Z","2020-04-07T00:00:00.000Z","2020-04-08T00:00:00.000Z","2020-04-09T00:00:00.000Z","2020-04-10T00:00:00.000Z","2020-04-11T00:00:00.000Z","2020-04-12T00:00:00.000Z","2020-04-13T00:00:00.000Z","2020-04-14T00:00:00.000Z","2020-04-15T00:00:00.000Z","2020-04-16T00:00:00.000Z","2020-04-17T00:00:00.000Z","2020-04-18T00:00:00.000Z","2020-04-19T00:00:00.000Z","2020-04-20T00:00:00.000Z","2020-04-21T00:00:00.000Z","2020-04-22T00:00:00.000Z","2020-04-23T00:00:00.000Z","2020-04-24T00:00:00.000Z","2020-04-25T00:00:00.000Z","2020-04-26T00:00:00.000Z","2020-04-27T00:00:00.000Z","2020-04-28T00:00:00.000Z","2020-04-29T00:00:00.000Z","2020-04-30T00:00:00.000Z","2020-05-01T00:00:00.000Z","2020-05-02T00:00:00.000Z","2020-05-03T00:00:00.000Z","2020-05-04T00:00:00.000Z","2020-05-05T00:00:00.000Z","2020-05-06T00:00:00.000Z","2020-05-07T00:00:00.000Z","2020-05-08T00:00:00.000Z","2020-05-09T00:00:00.000Z","2020-05-10T00:00:00.000Z"],[0,0,0.693147180559945,0.693147180559945,1.6094379124341,1.6094379124341,1.6094379124341,1.6094379124341,1.6094379124341,1.94591014905531,2.07944154167984,2.07944154167984,2.39789527279837,2.39789527279837,2.39789527279837,2.39789527279837,2.39789527279837,2.39789527279837,2.07944154167984,2.07944154167984,2.19722457733622,2.19722457733622,2.30258509299405,2.30258509299405,2.30258509299405,2.30258509299405,2.30258509299405,2.30258509299405,2.30258509299405,2.30258509299405,2.30258509299405,2.30258509299405,2.30258509299405,3.8286413964891,3.80666248977032,3.93182563272433,3.95124371858143,3.97029191355212,4.0943445622221,4.18965474202643,4.44265125649032,4.64439089914137,4.87519732320115,5.28826703069454,5.48479693349065,5.93489419561959,6.19440539110467,6.31716468674728,6.82762923450285,7.12044437239249,7.38398945797851,7.65822752616135,7.88495294575981,8.13563990335439,8.41538192526955,8.74369111054302,8.92452322613391,9.50061907027523,9.84038799559281,10.1259108445259,10.3893645309382,10.6661374745772,10.8662801180617,11.0682152434111,11.3074867538995,11.4980453024408,11.6755713864042,11.8117255031559,11.9316029045505,12.0769941810318,12.197369886136,12.3313828364956,12.4545486047221,12.5537073493575,12.6345346203209,12.7154231818895,12.7915427403657,12.8657276733579,12.9411172421373,13.006754975517,13.0621546690839,13.114812944491,13.140727715957,13.1799622497837,13.2204333817507,13.2674364083379,13.3109154839489,13.349664673307,13.3809157705282,13.4140444432129,13.4467268840755,13.4808388993291,13.5133819686134,13.5341895443448,13.5721987375151,13.597250065091,13.617735000875,13.639120574555,13.6626180862611,13.6559062005014,13.6814110039666,13.6998617432373,13.7214262265008,13.7367627615312,13.7573474042481,13.7808839158879,13.8017411938783,13.8232366348193,13.8335675448694,13.848524549208],[null,null,null,null,null,null,null,null,null,0.693147180559945,0.693147180559945,0.693147180559945,0.693147180559945,0.693147180559945,0.693147180559945,0.693147180559945,1.09861228866811,1.09861228866811,1.09861228866811,2.07944154167984,2.07944154167984,2.07944154167984,2.07944154167984,2.07944154167984,2.07944154167984,0,0,0,0,0,0,0,0,1.6094379124341,1.6094379124341,1.6094379124341,1.94591014905531,2.484906649788,2.70805020110221,3.3322045101752,3.46573590279973,3.76120011569356,4.35670882668959,4.68213122712422,5.04342511691925,5.23110861685459,5.53733426701854,5.70711026474888,5.8805329864007,6.07073772800249,6.06610809010375,6.65027904858742,7.00033446027523,6.98749024700099,7.28892769452126,7.50933526601659,7.80751004221619,7.82003798945875,8.23004431012611,8.46568934854912,8.59267165259214,8.74814616962193,8.92465630218707,9.08307502093031,9.28572609888207,9.50532074690907,9.6616707359563,9.7957352900419,9.91521847541183,10.0377124546274,10.1881400404275,10.3165570075042,10.4345274835524,10.5195916885978,10.6533222027259,10.7265000388287,10.7818894838675,10.8706614947249,10.9311407522637,11.0547081039751,11.1218956646583,11.1882750741518,11.2413660544258,11.2951052196874,11.3406413639468,11.3827712204988,11.434585473519,11.4811457984342,11.5347750154968,11.574189882074,11.6015771625648,11.6337616129102,11.6673104030712,11.7040663502389,11.736852709117,11.7686678531288,11.7987282727097,11.8216446964878,11.8452318937933,11.8829706278471,11.9197895939921,11.9472954398679,11.9730113253326,11.9960489019171,12.0186340188367,12.0510257308711,12.0800444618697,12.1024661462414,12.1219407552004,12.1416247869493],[null,null,null,null,null,null,null,null,null,0.693147180559945,0.693147180559945,0.693147180559945,0.693147180559945,0.693147180559945,0.693147180559945,0.693147180559945,0.693147180559945,0.693147180559945,0.693147180559945,0.693147180559945,0.693147180559945,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,0,0,0,0.693147180559945,2.39789527279837,2.39789527279837,2.63905732961526,2.63905732961526,2.83321334405622,2.83321334405622,3.2188758248682,3.73766961828337,3.93182563272433,4.00733318523247,4.40671924726425,4.66343909411207,4.93447393313069,5.24174701505964,5.49306144334055,5.68017260901707,5.85793315448346,6.04263283368238,6.15697898558556,6.4393503711001,6.68336094576627,6.89467003943348,7.09920174355309,7.28756064030972,7.47363710849621,7.69575799055476,7.84893372636407,8.09651291750159,8.25166392360559,8.3790798892866,8.51499076786104,8.68101127664563,8.84577725518844,8.99081526618468,9.14388000527591,9.30819277214369,9.42810950695294,9.57143553234841,9.72376262158944,9.86464276871256,10.0126109795545,10.1425831900643,10.2800386504796,10.4169995647274,10.5764575356573,10.6752148332189,10.7879573254204,10.8792917008313,10.9565269959095,11.0419453591264,11.1222061020079,11.204155940188,11.2772917351187,11.3413657908203,11.3866930839182,11.4489840988334,11.5133453767949,11.5882091742455,11.6679443392362,11.7425837492537,11.805997982831,11.8710543514221,11.9298710857413,11.9799747343895,12.0132946098117,12.0637426585493],[null,null,0.693147180559945,1.09861228866811,1.09861228866811,1.09861228866811,1.38629436111989,1.6094379124341,1.6094379124341,1.6094379124341,1.79175946922805,1.79175946922805,1.79175946922805,1.79175946922805,1.79175946922805,1.79175946922805,1.79175946922805,2.39789527279837,2.39789527279837,2.39789527279837,2.39789527279837,2.19722457733622,2.19722457733622,2.19722457733622,1.94591014905531,1.94591014905531,1.94591014905531,1.94591014905531,1.94591014905531,1.94591014905531,1.94591014905531,1.94591014905531,1.94591014905531,1.94591014905531,0.693147180559945,1.6094379124341,3.2188758248682,3.78418963391826,4.45434729625351,4.75359019110636,5.17048399503815,5.23644196282995,5.605802066296,5.89164421182577,6.45362499889269,6.84161547647759,7.00760061395185,7.08002649992259,7.4667994750186,7.71110125184016,7.71110125184016,8.18590748148232,8.38776764397578,8.3959291039232,8.78293635634926,8.9298325032724,9.10086027135736,9.27930657644091,9.41694795465029,9.53878043690013,9.50009529458889,9.74419869485275,9.81301564937205,9.92132747066446,10.0388048494838,10.1541684468434,10.3110837216532,10.3375725108815,10.4392789223199,10.591169827665,10.6521167425551,10.6450200534225,10.7043000905642,10.7440628671625,10.757264379021,10.7993510620952,10.8056185062522,10.834036156157,10.8536965026137,10.8842168005475,10.9031814931161,11.2876671791805,11.3194256637457,11.3601122237065,11.3558154105103,11.4652152174808,11.46143215058,11.4379648217035,11.4795031088069,11.4898308249414,11.494649471775,11.450847913162,11.4548407398835,11.4532922265708,11.4556458673172,11.4559105702427,11.4840526274011,11.4978524354727,11.4534408181353,11.445117605365,11.4349206793223,11.4413435304646,11.4418590165364,11.4393112170685,11.4328860906245,11.4545863543821,11.4482482675509,11.4518688748689,11.4544591373603,11.4551268462429],[null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,0,0,0,0.693147180559945,0.693147180559945,0.693147180559945,0.693147180559945,1.38629436111989,1.38629436111989,2.56494935746154,2.56494935746154,2.99573227355399,3.2188758248682,3.43398720448515,3.63758615972639,3.95124371858143,5.01727983681492,5.01727983681492,5.08759633523238,5.29330482472449,5.76205138278018,5.90536184805457,6.41836493593621,6.65929391968364,6.91174730025167,7.32580750259577,7.54327334670545,7.69575799055476,7.82124208352356,7.97315543344413,8.10741881171997,8.2393294279018,8.3221510702129,8.36637030168165,8.5921151179335,8.77477681604399,8.93498204921323,9.05602301159183,9.18891242456256,9.26074827452003,9.34749021012342,9.4895617535101,9.63062840897599,9.73914342897283,9.8205406317152,9.87457354237149,9.94251593950361,9.99556524073704,9.93711573351611,9.43811319167405,9.5801783024412,9.77081293563159,9.91729183351253,9.55123140275911,9.68196768233802,9.76117485976141,9.77184009847013,9.91006586789625,10.0294151091339,10.1699587565855,10.263327482618,10.3641035051091,10.4803256106957,10.5976342334292,10.7198695474307,10.773755288098,10.8077461881864,10.8548365002253,10.923020558177,10.9902971290851,11.1072553358467,11.173711473171,11.259064940994,11.3352331765599,11.3692744700241]],"fixedtz":false,"tzone":"UTC"},"evals":["attrs.interactionModel"],"jsHooks":[]}</script>
<div id="htmlwidget-efba80d904ffc0826440" style="width:960px;height:500px;" class="dygraphs html-widget"></div>
<script type="application/json" data-for="htmlwidget-efba80d904ffc0826440">{"x":{"attrs":{"axes":{"x":{"pixelsPerLabel":60,"drawGrid":false,"drawAxis":true},"y":{"drawAxis":true}},"title":"Top Countries - Percentage Of Active Cases","labels":["day","US","United Kingdom","Russia","France","Brazil"],"retainDateWindow":false,"ylabel":"Percentage Of Active Cases","stackedGraph":false,"fillGraph":false,"fillAlpha":0.15,"stepPlot":false,"drawPoints":false,"pointSize":1,"drawGapEdgePoints":false,"connectSeparatedPoints":false,"strokeWidth":1,"strokeBorderColor":"white","colors":["#1B9E77","#D95F02","#7570B3","#E7298A","#66A61E"],"colorValue":0.5,"colorSaturation":1,"includeZero":false,"drawAxesAtZero":false,"logscale":false,"axisTickSize":3,"axisLineColor":"navy","axisLineWidth":1.5,"axisLabelColor":"black","axisLabelFontSize":14,"axisLabelWidth":60,"drawGrid":true,"gridLineColor":"lightblue","gridLineWidth":0.3,"rightGap":5,"digitsAfterDecimal":2,"labelsKMB":false,"labelsKMG2":false,"labelsUTC":false,"maxNumberWidth":6,"animatedZooms":false,"mobileDisableYTouch":true,"disableZoom":false,"showRangeSelector":true,"rangeSelectorHeight":40,"rangeSelectorPlotFillColor":" #A7B1C4","rangeSelectorPlotStrokeColor":"#808FAB","interactionModel":"Dygraph.Interaction.defaultModel","legend":"auto","labelsDivWidth":750,"labelsShowZeroValues":true,"labelsSeparateLines":false,"hideOverlayOnMouseOut":true},"scale":"daily","annotations":[],"shadings":[],"events":[],"format":"date","data":[["2020-01-22T00:00:00.000Z","2020-01-23T00:00:00.000Z","2020-01-24T00:00:00.000Z","2020-01-25T00:00:00.000Z","2020-01-26T00:00:00.000Z","2020-01-27T00:00:00.000Z","2020-01-28T00:00:00.000Z","2020-01-29T00:00:00.000Z","2020-01-30T00:00:00.000Z","2020-01-31T00:00:00.000Z","2020-02-01T00:00:00.000Z","2020-02-02T00:00:00.000Z","2020-02-03T00:00:00.000Z","2020-02-04T00:00:00.000Z","2020-02-05T00:00:00.000Z","2020-02-06T00:00:00.000Z","2020-02-07T00:00:00.000Z","2020-02-08T00:00:00.000Z","2020-02-09T00:00:00.000Z","2020-02-10T00:00:00.000Z","2020-02-11T00:00:00.000Z","2020-02-12T00:00:00.000Z","2020-02-13T00:00:00.000Z","2020-02-14T00:00:00.000Z","2020-02-15T00:00:00.000Z","2020-02-16T00:00:00.000Z","2020-02-17T00:00:00.000Z","2020-02-18T00:00:00.000Z","2020-02-19T00:00:00.000Z","2020-02-20T00:00:00.000Z","2020-02-21T00:00:00.000Z","2020-02-22T00:00:00.000Z","2020-02-23T00:00:00.000Z","2020-02-24T00:00:00.000Z","2020-02-25T00:00:00.000Z","2020-02-26T00:00:00.000Z","2020-02-27T00:00:00.000Z","2020-02-28T00:00:00.000Z","2020-02-29T00:00:00.000Z","2020-03-01T00:00:00.000Z","2020-03-02T00:00:00.000Z","2020-03-03T00:00:00.000Z","2020-03-04T00:00:00.000Z","2020-03-05T00:00:00.000Z","2020-03-06T00:00:00.000Z","2020-03-07T00:00:00.000Z","2020-03-08T00:00:00.000Z","2020-03-09T00:00:00.000Z","2020-03-10T00:00:00.000Z","2020-03-11T00:00:00.000Z","2020-03-12T00:00:00.000Z","2020-03-13T00:00:00.000Z","2020-03-14T00:00:00.000Z","2020-03-15T00:00:00.000Z","2020-03-16T00:00:00.000Z","2020-03-17T00:00:00.000Z","2020-03-18T00:00:00.000Z","2020-03-19T00:00:00.000Z","2020-03-20T00:00:00.000Z","2020-03-21T00:00:00.000Z","2020-03-22T00:00:00.000Z","2020-03-23T00:00:00.000Z","2020-03-24T00:00:00.000Z","2020-03-25T00:00:00.000Z","2020-03-26T00:00:00.000Z","2020-03-27T00:00:00.000Z","2020-03-28T00:00:00.000Z","2020-03-29T00:00:00.000Z","2020-03-30T00:00:00.000Z","2020-03-31T00:00:00.000Z","2020-04-01T00:00:00.000Z","2020-04-02T00:00:00.000Z","2020-04-03T00:00:00.000Z","2020-04-04T00:00:00.000Z","2020-04-05T00:00:00.000Z","2020-04-06T00:00:00.000Z","2020-04-07T00:00:00.000Z","2020-04-08T00:00:00.000Z","2020-04-09T00:00:00.000Z","2020-04-10T00:00:00.000Z","2020-04-11T00:00:00.000Z","2020-04-12T00:00:00.000Z","2020-04-13T00:00:00.000Z","2020-04-14T00:00:00.000Z","2020-04-15T00:00:00.000Z","2020-04-16T00:00:00.000Z","2020-04-17T00:00:00.000Z","2020-04-18T00:00:00.000Z","2020-04-19T00:00:00.000Z","2020-04-20T00:00:00.000Z","2020-04-21T00:00:00.000Z","2020-04-22T00:00:00.000Z","2020-04-23T00:00:00.000Z","2020-04-24T00:00:00.000Z","2020-04-25T00:00:00.000Z","2020-04-26T00:00:00.000Z","2020-04-27T00:00:00.000Z","2020-04-28T00:00:00.000Z","2020-04-29T00:00:00.000Z","2020-04-30T00:00:00.000Z","2020-05-01T00:00:00.000Z","2020-05-02T00:00:00.000Z","2020-05-03T00:00:00.000Z","2020-05-04T00:00:00.000Z","2020-05-05T00:00:00.000Z","2020-05-06T00:00:00.000Z","2020-05-07T00:00:00.000Z","2020-05-08T00:00:00.000Z","2020-05-09T00:00:00.000Z","2020-05-10T00:00:00.000Z"],[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0.001,0.001,0.001,0.001,0.002,0.002,0.004,0.006,0.008,0.01,0.013,0.016,0.02,0.025,0.031,0.037,0.042,0.047,0.055,0.062,0.07,0.08,0.088,0.095,0.103,0.111,0.12,0.129,0.138,0.146,0.154,0.158,0.164,0.171,0.179,0.187,0.195,0.201,0.208,0.215,0.222,0.229,0.234,0.243,0.25,0.255,0.26,0.266,0.265,0.271,0.276,0.283,0.287,0.293,0.3,0.306,0.313,0.316,0.321],[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0.001,0.001,0.001,0.001,0.002,0.002,0.002,0.003,0.004,0.004,0.006,0.007,0.008,0.01,0.011,0.013,0.016,0.02,0.024,0.027,0.031,0.035,0.04,0.046,0.052,0.056,0.064,0.069,0.073,0.08,0.085,0.096,0.103,0.11,0.116,0.122,0.128,0.133,0.141,0.147,0.155,0.162,0.166,0.172,0.177,0.184,0.19,0.196,0.202,0.207,0.212,0.22,0.228,0.235,0.241,0.246,0.252,0.26,0.268,0.274,0.279,0.285],[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0.001,0.001,0.001,0.001,0.001,0.002,0.002,0.002,0.003,0.003,0.003,0.004,0.005,0.006,0.006,0.008,0.009,0.01,0.012,0.013,0.015,0.018,0.02,0.023,0.027,0.03,0.034,0.037,0.04,0.043,0.047,0.051,0.055,0.059,0.061,0.065,0.069,0.075,0.081,0.087,0.093,0.099,0.105,0.111,0.115,0.12],[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0.001,0.001,0.001,0.002,0.002,0.003,0.003,0.003,0.006,0.007,0.007,0.01,0.012,0.014,0.017,0.019,0.021,0.021,0.026,0.028,0.031,0.035,0.04,0.046,0.048,0.053,0.061,0.065,0.065,0.069,0.072,0.073,0.076,0.076,0.078,0.08,0.082,0.084,0.123,0.127,0.133,0.132,0.147,0.147,0.143,0.149,0.151,0.152,0.145,0.146,0.146,0.146,0.146,0.15,0.152,0.146,0.144,0.143,0.144,0.144,0.144,0.143,0.146,0.145,0.145,0.146,0.146],[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0.001,0.001,0.001,0.001,0.001,0.002,0.002,0.002,0.002,0.003,0.003,0.004,0.004,0.005,0.005,0.006,0.006,0.007,0.008,0.009,0.009,0.01,0.011,0.01,0.006,0.007,0.008,0.01,0.007,0.008,0.008,0.008,0.01,0.011,0.013,0.014,0.015,0.017,0.019,0.022,0.023,0.024,0.025,0.027,0.029,0.032,0.034,0.037,0.04,0.042]],"fixedtz":false,"tzone":"UTC"},"evals":["attrs.interactionModel"],"jsHooks":[]}</script>
<div id="htmlwidget-e13de2c8ff8c77cd6f09" style="width:960px;height:500px;" class="dygraphs html-widget"></div>
<script type="application/json" data-for="htmlwidget-e13de2c8ff8c77cd6f09">{"x":{"attrs":{"axes":{"x":{"pixelsPerLabel":60,"drawGrid":false,"drawAxis":true},"y":{"drawAxis":true}},"title":"Top Countries - Log Percentage Of Active Cases","labels":["day","US","United Kingdom","Russia","France","Brazil"],"retainDateWindow":false,"ylabel":"Log Percentage Of Active Cases","stackedGraph":false,"fillGraph":false,"fillAlpha":0.15,"stepPlot":false,"drawPoints":false,"pointSize":1,"drawGapEdgePoints":false,"connectSeparatedPoints":false,"strokeWidth":1,"strokeBorderColor":"white","colors":["#1B9E77","#D95F02","#7570B3","#E7298A","#66A61E"],"colorValue":0.5,"colorSaturation":1,"includeZero":false,"drawAxesAtZero":false,"logscale":false,"axisTickSize":3,"axisLineColor":"navy","axisLineWidth":1.5,"axisLabelColor":"black","axisLabelFontSize":14,"axisLabelWidth":60,"drawGrid":true,"gridLineColor":"lightblue","gridLineWidth":0.3,"rightGap":5,"digitsAfterDecimal":2,"labelsKMB":false,"labelsKMG2":false,"labelsUTC":false,"maxNumberWidth":6,"animatedZooms":false,"mobileDisableYTouch":true,"disableZoom":false,"showRangeSelector":true,"rangeSelectorHeight":40,"rangeSelectorPlotFillColor":" #A7B1C4","rangeSelectorPlotStrokeColor":"#808FAB","interactionModel":"Dygraph.Interaction.defaultModel","legend":"auto","labelsDivWidth":750,"labelsShowZeroValues":true,"labelsSeparateLines":false,"hideOverlayOnMouseOut":true},"scale":"daily","annotations":[],"shadings":[],"events":[],"format":"date","data":[["2020-01-22T00:00:00.000Z","2020-01-23T00:00:00.000Z","2020-01-24T00:00:00.000Z","2020-01-25T00:00:00.000Z","2020-01-26T00:00:00.000Z","2020-01-27T00:00:00.000Z","2020-01-28T00:00:00.000Z","2020-01-29T00:00:00.000Z","2020-01-30T00:00:00.000Z","2020-01-31T00:00:00.000Z","2020-02-01T00:00:00.000Z","2020-02-02T00:00:00.000Z","2020-02-03T00:00:00.000Z","2020-02-04T00:00:00.000Z","2020-02-05T00:00:00.000Z","2020-02-06T00:00:00.000Z","2020-02-07T00:00:00.000Z","2020-02-08T00:00:00.000Z","2020-02-09T00:00:00.000Z","2020-02-10T00:00:00.000Z","2020-02-11T00:00:00.000Z","2020-02-12T00:00:00.000Z","2020-02-13T00:00:00.000Z","2020-02-14T00:00:00.000Z","2020-02-15T00:00:00.000Z","2020-02-16T00:00:00.000Z","2020-02-17T00:00:00.000Z","2020-02-18T00:00:00.000Z","2020-02-19T00:00:00.000Z","2020-02-20T00:00:00.000Z","2020-02-21T00:00:00.000Z","2020-02-22T00:00:00.000Z","2020-02-23T00:00:00.000Z","2020-02-24T00:00:00.000Z","2020-02-25T00:00:00.000Z","2020-02-26T00:00:00.000Z","2020-02-27T00:00:00.000Z","2020-02-28T00:00:00.000Z","2020-02-29T00:00:00.000Z","2020-03-01T00:00:00.000Z","2020-03-02T00:00:00.000Z","2020-03-03T00:00:00.000Z","2020-03-04T00:00:00.000Z","2020-03-05T00:00:00.000Z","2020-03-06T00:00:00.000Z","2020-03-07T00:00:00.000Z","2020-03-08T00:00:00.000Z","2020-03-09T00:00:00.000Z","2020-03-10T00:00:00.000Z","2020-03-11T00:00:00.000Z","2020-03-12T00:00:00.000Z","2020-03-13T00:00:00.000Z","2020-03-14T00:00:00.000Z","2020-03-15T00:00:00.000Z","2020-03-16T00:00:00.000Z","2020-03-17T00:00:00.000Z","2020-03-18T00:00:00.000Z","2020-03-19T00:00:00.000Z","2020-03-20T00:00:00.000Z","2020-03-21T00:00:00.000Z","2020-03-22T00:00:00.000Z","2020-03-23T00:00:00.000Z","2020-03-24T00:00:00.000Z","2020-03-25T00:00:00.000Z","2020-03-26T00:00:00.000Z","2020-03-27T00:00:00.000Z","2020-03-28T00:00:00.000Z","2020-03-29T00:00:00.000Z","2020-03-30T00:00:00.000Z","2020-03-31T00:00:00.000Z","2020-04-01T00:00:00.000Z","2020-04-02T00:00:00.000Z","2020-04-03T00:00:00.000Z","2020-04-04T00:00:00.000Z","2020-04-05T00:00:00.000Z","2020-04-06T00:00:00.000Z","2020-04-07T00:00:00.000Z","2020-04-08T00:00:00.000Z","2020-04-09T00:00:00.000Z","2020-04-10T00:00:00.000Z","2020-04-11T00:00:00.000Z","2020-04-12T00:00:00.000Z","2020-04-13T00:00:00.000Z","2020-04-14T00:00:00.000Z","2020-04-15T00:00:00.000Z","2020-04-16T00:00:00.000Z","2020-04-17T00:00:00.000Z","2020-04-18T00:00:00.000Z","2020-04-19T00:00:00.000Z","2020-04-20T00:00:00.000Z","2020-04-21T00:00:00.000Z","2020-04-22T00:00:00.000Z","2020-04-23T00:00:00.000Z","2020-04-24T00:00:00.000Z","2020-04-25T00:00:00.000Z","2020-04-26T00:00:00.000Z","2020-04-27T00:00:00.000Z","2020-04-28T00:00:00.000Z","2020-04-29T00:00:00.000Z","2020-04-30T00:00:00.000Z","2020-05-01T00:00:00.000Z","2020-05-02T00:00:00.000Z","2020-05-03T00:00:00.000Z","2020-05-04T00:00:00.000Z","2020-05-05T00:00:00.000Z","2020-05-06T00:00:00.000Z","2020-05-07T00:00:00.000Z","2020-05-08T00:00:00.000Z","2020-05-09T00:00:00.000Z","2020-05-10T00:00:00.000Z"],[null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,-6.90775527898214,-6.90775527898214,-6.90775527898214,-6.90775527898214,-6.21460809842219,-6.21460809842219,-5.52146091786225,-5.11599580975408,-4.8283137373023,-4.60517018598809,-4.3428059215206,-4.13516655674236,-3.91202300542815,-3.68887945411394,-3.47376807449699,-3.29683736633791,-3.17008566069877,-3.05760767727208,-2.90042209374967,-2.78062089393705,-2.65926003693278,-2.52572864430826,-2.43041846450393,-2.3538783873816,-2.2730262907525,-2.1982250776698,-2.12026353620009,-2.04794287462046,-1.98050159382493,-1.9241486572738,-1.87080267656851,-1.84516024595517,-1.80788885115794,-1.76609172247948,-1.72036947314138,-1.67664666212755,-1.63475572041839,-1.60445037092306,-1.57021719928082,-1.53711725085447,-1.50507789710986,-1.4740332754279,-1.45243416362444,-1.41469383564159,-1.38629436111989,-1.36649173382371,-1.34707364796661,-1.32425897020044,-1.32802545299591,-1.30563645810244,-1.28735441326499,-1.2623083813389,-1.24827306322252,-1.22758266996507,-1.20397280432594,-1.18417017702976,-1.16155208844198,-1.15201306539522,-1.13631415585212],[null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,-6.90775527898214,-6.90775527898214,-6.90775527898214,-6.90775527898214,-6.21460809842219,-6.21460809842219,-6.21460809842219,-5.80914299031403,-5.52146091786225,-5.52146091786225,-5.11599580975408,-4.96184512992682,-4.8283137373023,-4.60517018598809,-4.50986000618377,-4.3428059215206,-4.13516655674236,-3.91202300542815,-3.72970144863419,-3.61191841297781,-3.47376807449699,-3.35240721749272,-3.2188758248682,-3.07911388249304,-2.95651156040071,-2.88240358824699,-2.74887219562247,-2.67364877438488,-2.61729583783375,-2.52572864430826,-2.46510402249182,-2.3434070875143,-2.2730262907525,-2.20727491318972,-2.15416508787577,-2.10373423424888,-2.05572501506252,-2.01740615076038,-1.95899538860397,-1.9173226922034,-1.86433016206289,-1.82015894374975,-1.79576749062559,-1.76026080216868,-1.73160554640831,-1.69281952137315,-1.66073120682165,-1.62964061975162,-1.59948758158093,-1.57503648571677,-1.55116900431012,-1.51412773262978,-1.4784096500277,-1.44816976483798,-1.42295834549148,-1.40242374304977,-1.37832619147071,-1.34707364796661,-1.31676829847128,-1.29462717259407,-1.27654349716077,-1.25526609871349],[null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,-6.90775527898214,-6.90775527898214,-6.90775527898214,-6.90775527898214,-6.90775527898214,-6.21460809842219,-6.21460809842219,-6.21460809842219,-5.80914299031403,-5.80914299031403,-5.80914299031403,-5.52146091786225,-5.29831736654804,-5.11599580975408,-5.11599580975408,-4.8283137373023,-4.71053070164592,-4.60517018598809,-4.42284862919414,-4.3428059215206,-4.19970507787993,-4.01738352108597,-3.91202300542815,-3.77226106305299,-3.61191841297781,-3.50655789731998,-3.38139475436598,-3.29683736633791,-3.2188758248682,-3.14655516328857,-3.05760767727208,-2.97592964625781,-2.90042209374967,-2.83021783507642,-2.79688141480883,-2.7333680090865,-2.67364877438488,-2.59026716544583,-2.5133061243097,-2.44184716032755,-2.37515578582888,-2.31263542884755,-2.25379492882461,-2.1982250776698,-2.16282315061889,-2.12026353620009],[null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,-6.90775527898214,-6.90775527898214,-6.90775527898214,-6.21460809842219,-6.21460809842219,-5.80914299031403,-5.80914299031403,-5.80914299031403,-5.11599580975408,-4.96184512992682,-4.96184512992682,-4.60517018598809,-4.42284862919414,-4.26869794936688,-4.07454193492592,-3.9633162998157,-3.86323284125871,-3.86323284125871,-3.64965874096066,-3.57555076880693,-3.47376807449699,-3.35240721749272,-3.2188758248682,-3.07911388249304,-3.03655426807425,-2.93746336543002,-2.79688141480883,-2.7333680090865,-2.7333680090865,-2.67364877438488,-2.63108915996608,-2.61729583783375,-2.57702193869581,-2.57702193869581,-2.55104645229255,-2.52572864430826,-2.50103603171788,-2.47693848013882,-2.09557092360972,-2.06356819252355,-2.01740615076038,-2.02495335639577,-1.9173226922034,-1.9173226922034,-1.94491064872223,-1.90380897303668,-1.89047544216721,-1.88387475813586,-1.93102153656156,-1.9241486572738,-1.9241486572738,-1.9241486572738,-1.9241486572738,-1.89711998488588,-1.88387475813586,-1.9241486572738,-1.93794197940614,-1.94491064872223,-1.93794197940614,-1.93794197940614,-1.93794197940614,-1.94491064872223,-1.9241486572738,-1.93102153656156,-1.93102153656156,-1.9241486572738,-1.9241486572738],[null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,-6.90775527898214,-6.90775527898214,-6.90775527898214,-6.90775527898214,-6.90775527898214,-6.21460809842219,-6.21460809842219,-6.21460809842219,-6.21460809842219,-5.80914299031403,-5.80914299031403,-5.52146091786225,-5.52146091786225,-5.29831736654804,-5.29831736654804,-5.11599580975408,-5.11599580975408,-4.96184512992682,-4.8283137373023,-4.71053070164592,-4.71053070164592,-4.60517018598809,-4.50986000618377,-4.60517018598809,-5.11599580975408,-4.96184512992682,-4.8283137373023,-4.60517018598809,-4.96184512992682,-4.8283137373023,-4.8283137373023,-4.8283137373023,-4.60517018598809,-4.50986000618377,-4.3428059215206,-4.26869794936688,-4.19970507787993,-4.07454193492592,-3.9633162998157,-3.81671282562382,-3.77226106305299,-3.72970144863419,-3.68887945411394,-3.61191841297781,-3.54045944899566,-3.44201937618241,-3.38139475436598,-3.29683736633791,-3.2188758248682,-3.17008566069877]],"fixedtz":false,"tzone":"UTC"},"evals":["attrs.interactionModel"],"jsHooks":[]}</script>
<div id="htmlwidget-934e5a98ca8a249cb572" style="width:960px;height:500px;" class="dygraphs html-widget"></div>
<script type="application/json" data-for="htmlwidget-934e5a98ca8a249cb572">{"x":{"attrs":{"axes":{"x":{"pixelsPerLabel":60,"drawGrid":false,"drawAxis":true},"y":{"drawAxis":true}},"title":"Top Countries - New Active Cases","labels":["day","US","United Kingdom","Russia","France","Brazil"],"retainDateWindow":false,"ylabel":"New Active Cases","stackedGraph":false,"fillGraph":false,"fillAlpha":0.15,"stepPlot":false,"drawPoints":false,"pointSize":1,"drawGapEdgePoints":false,"connectSeparatedPoints":false,"strokeWidth":1,"strokeBorderColor":"white","colors":["#1B9E77","#D95F02","#7570B3","#E7298A","#66A61E"],"colorValue":0.5,"colorSaturation":1,"includeZero":false,"drawAxesAtZero":false,"logscale":false,"axisTickSize":3,"axisLineColor":"navy","axisLineWidth":1.5,"axisLabelColor":"black","axisLabelFontSize":14,"axisLabelWidth":60,"drawGrid":true,"gridLineColor":"lightblue","gridLineWidth":0.3,"rightGap":5,"digitsAfterDecimal":2,"labelsKMB":false,"labelsKMG2":false,"labelsUTC":false,"maxNumberWidth":6,"animatedZooms":false,"mobileDisableYTouch":true,"disableZoom":false,"showRangeSelector":true,"rangeSelectorHeight":40,"rangeSelectorPlotFillColor":" #A7B1C4","rangeSelectorPlotStrokeColor":"#808FAB","interactionModel":"Dygraph.Interaction.defaultModel","legend":"auto","labelsDivWidth":750,"labelsShowZeroValues":true,"labelsSeparateLines":false,"hideOverlayOnMouseOut":true},"scale":"daily","annotations":[],"shadings":[],"events":[],"format":"date","data":[["2020-01-22T00:00:00.000Z","2020-01-23T00:00:00.000Z","2020-01-24T00:00:00.000Z","2020-01-25T00:00:00.000Z","2020-01-26T00:00:00.000Z","2020-01-27T00:00:00.000Z","2020-01-28T00:00:00.000Z","2020-01-29T00:00:00.000Z","2020-01-30T00:00:00.000Z","2020-01-31T00:00:00.000Z","2020-02-01T00:00:00.000Z","2020-02-02T00:00:00.000Z","2020-02-03T00:00:00.000Z","2020-02-04T00:00:00.000Z","2020-02-05T00:00:00.000Z","2020-02-06T00:00:00.000Z","2020-02-07T00:00:00.000Z","2020-02-08T00:00:00.000Z","2020-02-09T00:00:00.000Z","2020-02-10T00:00:00.000Z","2020-02-11T00:00:00.000Z","2020-02-12T00:00:00.000Z","2020-02-13T00:00:00.000Z","2020-02-14T00:00:00.000Z","2020-02-15T00:00:00.000Z","2020-02-16T00:00:00.000Z","2020-02-17T00:00:00.000Z","2020-02-18T00:00:00.000Z","2020-02-19T00:00:00.000Z","2020-02-20T00:00:00.000Z","2020-02-21T00:00:00.000Z","2020-02-22T00:00:00.000Z","2020-02-23T00:00:00.000Z","2020-02-24T00:00:00.000Z","2020-02-25T00:00:00.000Z","2020-02-26T00:00:00.000Z","2020-02-27T00:00:00.000Z","2020-02-28T00:00:00.000Z","2020-02-29T00:00:00.000Z","2020-03-01T00:00:00.000Z","2020-03-02T00:00:00.000Z","2020-03-03T00:00:00.000Z","2020-03-04T00:00:00.000Z","2020-03-05T00:00:00.000Z","2020-03-06T00:00:00.000Z","2020-03-07T00:00:00.000Z","2020-03-08T00:00:00.000Z","2020-03-09T00:00:00.000Z","2020-03-10T00:00:00.000Z","2020-03-11T00:00:00.000Z","2020-03-12T00:00:00.000Z","2020-03-13T00:00:00.000Z","2020-03-14T00:00:00.000Z","2020-03-15T00:00:00.000Z","2020-03-16T00:00:00.000Z","2020-03-17T00:00:00.000Z","2020-03-18T00:00:00.000Z","2020-03-19T00:00:00.000Z","2020-03-20T00:00:00.000Z","2020-03-21T00:00:00.000Z","2020-03-22T00:00:00.000Z","2020-03-23T00:00:00.000Z","2020-03-24T00:00:00.000Z","2020-03-25T00:00:00.000Z","2020-03-26T00:00:00.000Z","2020-03-27T00:00:00.000Z","2020-03-28T00:00:00.000Z","2020-03-29T00:00:00.000Z","2020-03-30T00:00:00.000Z","2020-03-31T00:00:00.000Z","2020-04-01T00:00:00.000Z","2020-04-02T00:00:00.000Z","2020-04-03T00:00:00.000Z","2020-04-04T00:00:00.000Z","2020-04-05T00:00:00.000Z","2020-04-06T00:00:00.000Z","2020-04-07T00:00:00.000Z","2020-04-08T00:00:00.000Z","2020-04-09T00:00:00.000Z","2020-04-10T00:00:00.000Z","2020-04-11T00:00:00.000Z","2020-04-12T00:00:00.000Z","2020-04-13T00:00:00.000Z","2020-04-14T00:00:00.000Z","2020-04-15T00:00:00.000Z","2020-04-16T00:00:00.000Z","2020-04-17T00:00:00.000Z","2020-04-18T00:00:00.000Z","2020-04-19T00:00:00.000Z","2020-04-20T00:00:00.000Z","2020-04-21T00:00:00.000Z","2020-04-22T00:00:00.000Z","2020-04-23T00:00:00.000Z","2020-04-24T00:00:00.000Z","2020-04-25T00:00:00.000Z","2020-04-26T00:00:00.000Z","2020-04-27T00:00:00.000Z","2020-04-28T00:00:00.000Z","2020-04-29T00:00:00.000Z","2020-04-30T00:00:00.000Z","2020-05-01T00:00:00.000Z","2020-05-02T00:00:00.000Z","2020-05-03T00:00:00.000Z","2020-05-04T00:00:00.000Z","2020-05-05T00:00:00.000Z","2020-05-06T00:00:00.000Z","2020-05-07T00:00:00.000Z","2020-05-08T00:00:00.000Z","2020-05-09T00:00:00.000Z","2020-05-10T00:00:00.000Z"],[0,0,1,0,3,0,0,0,0,2,1,0,3,0,0,0,0,0,-3,0,1,0,1,0,0,0,0,0,0,0,0,0,0,36,-1,6,1,1,7,6,19,19,27,67,43,137,112,64,369,314,373,508,539,757,1102,1755,1243,5854,5409,6205,7530,10367,9501,11721,17328,17094,19139,17162,17171,23786,22486,28433,29714,26729,23836,25863,26325,27658,30290,28297,25372,25455,13028,20378,21875,26542,25688,23854,19923,21811,22237,23998,23670,15543,29241,19889,16638,17737,19931,-5741,22022,16285,19418,14067,19223,22470,20359,21431,10465,15344],[0,0,0,0,0,0,0,0,0,2,0,0,0,0,0,0,1,0,0,5,0,0,0,0,0,-7,0,0,0,0,0,0,0,4,0,0,2,5,3,13,4,11,35,30,47,32,67,47,57,75,-2,342,324,-14,381,361,634,31,1262,997,643,907,1216,1290,1978,2648,2273,2253,2279,2637,3713,3643,3785,3020,5299,3214,2594,4469,3280,7351,4395,4642,3941,4208,3747,3622,4669,4407,5337,4109,2952,3574,3850,4369,4035,4044,3941,3085,3250,5362,5430,4189,4022,3692,3703,5459,5043,3998,3546,3655],[0,0,0,0,0,0,0,0,0,2,0,0,0,0,0,0,0,0,0,0,0,-2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,1,9,0,3,0,3,0,8,17,9,4,27,24,33,50,54,50,57,71,51,154,173,188,224,251,299,438,364,720,551,521,634,901,1055,1084,1328,1671,1405,1916,2361,2528,3068,3096,3743,4278,5778,4069,5164,4632,4261,5112,5218,5778,5572,5228,3906,5665,6236,7777,8949,9049,8237,9011,8667,7796,5405,8534],[0,0,2,1,0,0,1,1,0,0,1,0,0,0,0,0,0,5,0,0,0,-2,0,0,-2,0,0,0,0,0,0,0,0,0,-5,3,20,19,42,30,60,12,84,90,273,301,169,83,561,484,0,1357,803,36,2093,1032,1409,1751,1581,1593,-527,3694,1215,2090,2538,2800,4366,807,3305,5606,2500,-299,2564,1807,616,2019,308,1421,1007,1603,1021,25482,2576,3422,-368,9880,-360,-2203,3935,1004,472,-4208,376,-146,222,25,2696,1350,-4279,-781,-948,596,48,-237,-595,2025,-596,340,244,63],[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,1,0,0,0,2,0,9,0,7,5,6,7,14,99,0,11,37,119,49,246,167,224,515,369,311,294,409,417,468,327,186,1089,1080,1124,977,1218,729,953,1751,2003,1745,1439,1022,1366,1133,-1245,-8126,1917,3040,2763,-6216,1964,1321,186,2599,2552,3423,2555,3039,3907,4432,5206,2505,1651,2382,3654,3858,7357,4580,6347,6140,2899]],"fixedtz":false,"tzone":"UTC"},"evals":["attrs.interactionModel"],"jsHooks":[]}</script>
<div id="htmlwidget-b36723829bf326e4aa64" style="width:960px;height:500px;" class="dygraphs html-widget"></div>
<script type="application/json" data-for="htmlwidget-b36723829bf326e4aa64">{"x":{"attrs":{"axes":{"x":{"pixelsPerLabel":60,"drawGrid":false,"drawAxis":true},"y":{"drawAxis":true}},"title":"Top Countries - Log Of New Active Cases","labels":["day","US","United Kingdom","Russia","France","Brazil"],"retainDateWindow":false,"ylabel":"Log Of New Active Cases","stackedGraph":false,"fillGraph":false,"fillAlpha":0.15,"stepPlot":false,"drawPoints":false,"pointSize":1,"drawGapEdgePoints":false,"connectSeparatedPoints":false,"strokeWidth":1,"strokeBorderColor":"white","colors":["#1B9E77","#D95F02","#7570B3","#E7298A","#66A61E"],"colorValue":0.5,"colorSaturation":1,"includeZero":false,"drawAxesAtZero":false,"logscale":false,"axisTickSize":3,"axisLineColor":"navy","axisLineWidth":1.5,"axisLabelColor":"black","axisLabelFontSize":14,"axisLabelWidth":60,"drawGrid":true,"gridLineColor":"lightblue","gridLineWidth":0.3,"rightGap":5,"digitsAfterDecimal":2,"labelsKMB":false,"labelsKMG2":false,"labelsUTC":false,"maxNumberWidth":6,"animatedZooms":false,"mobileDisableYTouch":true,"disableZoom":false,"showRangeSelector":true,"rangeSelectorHeight":40,"rangeSelectorPlotFillColor":" #A7B1C4","rangeSelectorPlotStrokeColor":"#808FAB","interactionModel":"Dygraph.Interaction.defaultModel","legend":"auto","labelsDivWidth":750,"labelsShowZeroValues":true,"labelsSeparateLines":false,"hideOverlayOnMouseOut":true},"scale":"daily","annotations":[],"shadings":[],"events":[],"format":"date","data":[["2020-01-22T00:00:00.000Z","2020-01-23T00:00:00.000Z","2020-01-24T00:00:00.000Z","2020-01-25T00:00:00.000Z","2020-01-26T00:00:00.000Z","2020-01-27T00:00:00.000Z","2020-01-28T00:00:00.000Z","2020-01-29T00:00:00.000Z","2020-01-30T00:00:00.000Z","2020-01-31T00:00:00.000Z","2020-02-01T00:00:00.000Z","2020-02-02T00:00:00.000Z","2020-02-03T00:00:00.000Z","2020-02-04T00:00:00.000Z","2020-02-05T00:00:00.000Z","2020-02-06T00:00:00.000Z","2020-02-07T00:00:00.000Z","2020-02-08T00:00:00.000Z","2020-02-09T00:00:00.000Z","2020-02-10T00:00:00.000Z","2020-02-11T00:00:00.000Z","2020-02-12T00:00:00.000Z","2020-02-13T00:00:00.000Z","2020-02-14T00:00:00.000Z","2020-02-15T00:00:00.000Z","2020-02-16T00:00:00.000Z","2020-02-17T00:00:00.000Z","2020-02-18T00:00:00.000Z","2020-02-19T00:00:00.000Z","2020-02-20T00:00:00.000Z","2020-02-21T00:00:00.000Z","2020-02-22T00:00:00.000Z","2020-02-23T00:00:00.000Z","2020-02-24T00:00:00.000Z","2020-02-25T00:00:00.000Z","2020-02-26T00:00:00.000Z","2020-02-27T00:00:00.000Z","2020-02-28T00:00:00.000Z","2020-02-29T00:00:00.000Z","2020-03-01T00:00:00.000Z","2020-03-02T00:00:00.000Z","2020-03-03T00:00:00.000Z","2020-03-04T00:00:00.000Z","2020-03-05T00:00:00.000Z","2020-03-06T00:00:00.000Z","2020-03-07T00:00:00.000Z","2020-03-08T00:00:00.000Z","2020-03-09T00:00:00.000Z","2020-03-10T00:00:00.000Z","2020-03-11T00:00:00.000Z","2020-03-12T00:00:00.000Z","2020-03-13T00:00:00.000Z","2020-03-14T00:00:00.000Z","2020-03-15T00:00:00.000Z","2020-03-16T00:00:00.000Z","2020-03-17T00:00:00.000Z","2020-03-18T00:00:00.000Z","2020-03-19T00:00:00.000Z","2020-03-20T00:00:00.000Z","2020-03-21T00:00:00.000Z","2020-03-22T00:00:00.000Z","2020-03-23T00:00:00.000Z","2020-03-24T00:00:00.000Z","2020-03-25T00:00:00.000Z","2020-03-26T00:00:00.000Z","2020-03-27T00:00:00.000Z","2020-03-28T00:00:00.000Z","2020-03-29T00:00:00.000Z","2020-03-30T00:00:00.000Z","2020-03-31T00:00:00.000Z","2020-04-01T00:00:00.000Z","2020-04-02T00:00:00.000Z","2020-04-03T00:00:00.000Z","2020-04-04T00:00:00.000Z","2020-04-05T00:00:00.000Z","2020-04-06T00:00:00.000Z","2020-04-07T00:00:00.000Z","2020-04-08T00:00:00.000Z","2020-04-09T00:00:00.000Z","2020-04-10T00:00:00.000Z","2020-04-11T00:00:00.000Z","2020-04-12T00:00:00.000Z","2020-04-13T00:00:00.000Z","2020-04-14T00:00:00.000Z","2020-04-15T00:00:00.000Z","2020-04-16T00:00:00.000Z","2020-04-17T00:00:00.000Z","2020-04-18T00:00:00.000Z","2020-04-19T00:00:00.000Z","2020-04-20T00:00:00.000Z","2020-04-21T00:00:00.000Z","2020-04-22T00:00:00.000Z","2020-04-23T00:00:00.000Z","2020-04-24T00:00:00.000Z","2020-04-25T00:00:00.000Z","2020-04-26T00:00:00.000Z","2020-04-27T00:00:00.000Z","2020-04-28T00:00:00.000Z","2020-04-29T00:00:00.000Z","2020-04-30T00:00:00.000Z","2020-05-01T00:00:00.000Z","2020-05-02T00:00:00.000Z","2020-05-03T00:00:00.000Z","2020-05-04T00:00:00.000Z","2020-05-05T00:00:00.000Z","2020-05-06T00:00:00.000Z","2020-05-07T00:00:00.000Z","2020-05-08T00:00:00.000Z","2020-05-09T00:00:00.000Z","2020-05-10T00:00:00.000Z"],[null,null,0,null,1.09861228866811,null,null,null,null,0.693147180559945,0,null,1.09861228866811,null,null,null,null,null,null,null,0,null,0,null,null,null,null,null,null,null,null,null,null,3.58351893845611,null,1.79175946922805,0,0,1.94591014905531,1.79175946922805,2.94443897916644,2.94443897916644,3.29583686600433,4.20469261939097,3.76120011569356,4.91998092582813,4.71849887129509,4.15888308335967,5.91079664404053,5.74939298590825,5.92157841964382,6.23048144757848,6.289715570909,6.62936325343745,7.00488198971286,7.47022413589997,7.12528309151071,8.67488046725183,8.59581951187143,8.73311069763871,8.92665032079394,9.24638296332311,9.15915233520675,9.36913738372318,9.76007896924077,9.74648280372596,9.85948341703807,9.75045291636707,9.7509771933138,10.0768524512872,10.0206481723097,10.2553057214135,10.2993735941973,10.1935043972846,10.0789523218669,10.160568654878,10.1782743370022,10.2276702960246,10.3185729040213,10.250511070945,10.1414014827538,10.1446674663364,9.47485616639612,9.92221116653423,9.99309971122582,10.1864836629972,10.1537792357693,10.0797071971386,9.89963012220882,9.99016970867185,10.0095128471794,10.0857257725243,10.071963702508,9.6513656554829,10.2833271130053,9.89792209406325,9.71944451484383,9.78340813220559,9.90003158756274,null,9.99979723267354,9.69799971771033,9.87395574993009,9.5515869077577,9.86386275775286,10.0199363651794,9.92127835354468,9.97259375093468,9.2557916348801,9.63847979712322],[null,null,null,null,null,null,null,null,null,0.693147180559945,null,null,null,null,null,null,0,null,null,1.6094379124341,null,null,null,null,null,null,null,null,null,null,null,null,null,1.38629436111989,null,null,0.693147180559945,1.6094379124341,1.09861228866811,2.56494935746154,1.38629436111989,2.39789527279837,3.55534806148941,3.40119738166216,3.85014760171006,3.46573590279973,4.20469261939097,3.85014760171006,4.04305126783455,4.31748811353631,null,5.8348107370626,5.78074351579233,null,5.9427993751267,5.88887795833288,6.45204895443723,3.43398720448515,7.14045304310116,6.90475076996184,6.46614472423762,6.81014245011514,7.10332206252611,7.16239749735572,7.58984151218266,7.8815599170569,7.72885582385254,7.72001794043224,7.73149202924568,7.87739718635329,8.21959545417708,8.20056279700856,8.23880116587155,8.01301211036892,8.57527340249276,8.07527154629746,7.86095636487639,8.40491994893345,8.09559870137819,8.90259163737409,8.38822281011928,8.44290058683438,8.279189777195,8.34474275441755,8.22871079879369,8.19478163844336,8.44870019497094,8.39094946484199,8.58241897633394,8.32093496888341,7.99023818572036,8.18144069571937,8.25582842728183,8.38228942895144,8.30276158070405,8.30498958014036,8.279189777195,8.03430693633949,8.08641027532378,8.58709231879591,8.59969441292798,8.34021732094704,8.2995345703326,8.21392359562274,8.21689858091361,8.60502090178176,8.52575642207673,8.29354951506035,8.17357548663415,8.20385137218388],[null,null,null,null,null,null,null,null,null,0.693147180559945,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,0,null,null,0,2.19722457733622,null,1.09861228866811,null,1.09861228866811,null,2.07944154167984,2.83321334405622,2.19722457733622,1.38629436111989,3.29583686600433,3.17805383034795,3.49650756146648,3.91202300542815,3.98898404656427,3.91202300542815,4.04305126783455,4.26267987704132,3.93182563272433,5.03695260241363,5.15329159449778,5.23644196282995,5.41164605185504,5.52545293913178,5.70044357339069,6.08221891037645,5.89715386763674,6.5792512120101,6.31173480915291,6.25575004175337,6.45204895443723,6.80350525760834,6.96129604591017,6.98841318199959,7.19142933003638,7.42117752859539,7.24779258176785,7.55799495853081,7.76684053708551,7.83518375526675,8.02878116248715,8.03786623470962,8.22764270790443,8.36124088964235,8.66181288102618,8.31115254800169,8.54946675196653,8.44074401925283,8.35725915349991,8.53934599605737,8.55986946569667,8.66181288102618,8.6255093348997,8.56178407474411,8.27026911143662,8.64206217346211,8.73809423017767,8.95892593869494,9.09929707318286,9.11040953335113,9.01639147894125,9.10620133223504,9.06727798913434,8.96136606062745,8.59507973007331,9.05181346374795],[null,null,0.693147180559945,0,null,null,0,0,null,null,0,null,null,null,null,null,null,1.6094379124341,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1.09861228866811,2.99573227355399,2.94443897916644,3.73766961828337,3.40119738166216,4.0943445622221,2.484906649788,4.43081679884331,4.49980967033027,5.60947179518496,5.70711026474888,5.12989871492307,4.4188406077966,6.3297209055227,6.18208490671663,null,7.21303165983487,6.68835471394676,3.58351893845611,7.646353722446,6.93925394604151,7.25063551189868,7.46794233228585,7.36581283720947,7.37337430991005,null,8.21446516075919,7.10249935577465,7.64491934495886,7.83913164827433,7.9373746961633,8.38160253710989,6.69332366826995,8.10319175228579,8.63159273172473,7.82404601085629,null,7.84932381804056,7.49942329059223,6.42324696353352,7.61035761831284,5.73009978297357,7.2591161280971,6.91473089271856,7.37963215260955,6.92853781816467,10.1457275995413,7.85399308722424,8.13798045445214,null,9.19826779074191,null,null,8.2776661608515,6.91174730025167,6.15697898558556,null,5.92958914338989,null,5.40267738187228,3.2188758248682,7.8995244720322,7.20785987143248,null,null,null,6.39024066706535,3.87120101090789,null,null,7.61332497954064,null,5.82894561761021,5.4971682252932,4.14313472639153],[null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,0,null,null,0,null,null,null,0.693147180559945,null,2.19722457733622,null,1.94591014905531,1.6094379124341,1.79175946922805,1.94591014905531,2.63905732961526,4.59511985013459,null,2.39789527279837,3.61091791264422,4.77912349311153,3.89182029811063,5.50533153593236,5.11799381241676,5.41164605185504,6.24416690066374,5.91079664404053,5.73979291217923,5.68357976733868,6.0137151560428,6.0330862217988,6.14846829591765,5.78996017089725,5.2257466737132,6.99301512293296,6.98471632011827,7.02464903045364,6.88448665204278,7.10496544826984,6.59167373200866,6.8596149036542,7.46794233228585,7.60240133566582,7.46450983463653,7.27170370688737,6.92951677076365,7.21964204013074,7.03262426102801,null,null,7.55851674304564,8.01961279440027,7.92407232492342,null,7.58273848891441,7.18614430452233,5.2257466737132,7.86288203464149,7.84463264446468,8.13827263853019,7.8458075026378,8.01928379291679,8.27052509505507,8.39660622842712,8.55756708555451,7.82604401351897,7.40913644392013,7.77569574991525,8.20357773693795,8.25790419346567,8.90340751993226,8.42945427710823,8.75573753930647,8.72258002114119,7.97212112892166]],"fixedtz":false,"tzone":"UTC"},"evals":["attrs.interactionModel"],"jsHooks":[]}</script><!--/html_preserve-->



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


# test with China fatalities
x <- percap[percap$Country == "China" & percap$Status == "Fatal" & percap$Log2RateOfChange > 0, ]


ggplot(x, aes(x = Date)) +
	geom_line(aes(y = Log2RateOfChange, colour = "Log2RateOfChange")) +
	geom_line(aes(y = Count/10000, colour = "Count/10000")) +
	scale_y_continuous(sec.axis = sec_axis(~.*10000, name = "Count")) +
	scale_colour_manual(values = c("black", "red")) +
	labs(title = "China Fatalities"
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
	geom_line(aes(y = Count/1000, colour = "Count/1000")) +
	scale_y_continuous(sec.axis = sec_axis(~.*1000, name = "Count")) +
	scale_colour_manual(values = c("black", "red")) +
	labs(title = "Brazil Fatalities"
		,y = "Log2 Rate of Change"
		,x = ""
		,colour = "Parameter") +
	theme(legend.title = element_blank(), legend.position = c(.6, .9))


# test with Japan fatalities
x <- percap[percap$Country == "Japan" & percap$Status == "Fatal" & percap$Log2RateOfChange > 0, ]


ggplot(x, aes(x = Date)) +
	geom_line(aes(y = Log2RateOfChange, colour = "Log2RateOfChange")) +
	geom_line(aes(y = Count/100, colour = "Count/100")) +
	scale_y_continuous(sec.axis = sec_axis(~.*100, name = "Count")) +
	scale_colour_manual(values = c("black", "red")) +
	labs(title = "Japan Fatalities"
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
