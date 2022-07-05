---
title: "Coronavirus Data Analysis"
author: "Marcelo Sanches"
date: "07/03/2022"
output: 
  html_document:
    keep_md: true
---




This is an old project from the beginning of the pandemic which I'm revising by creating this [Shiny app.](https://bigbangdata.shinyapps.io/shinyapp/)

---

__April 2020__

This is a simple exploration of the time series data compiled from various sources at the [COVID-19 Data Repository by the Center for Systems Science and Engineering (CSSE) at Johns Hopkins University](https://github.com/CSSEGISandData/COVID-19). 

The raw data can also be downloaded manually at [Novel Coronavirus 2019 Cases.](https://data.humdata.org/dataset/novel-coronavirus-2019-ncov-cases) This [GitHub repository](https://github.com/BigBangData/CoronavirusDataAnalysis) hosts all files and code.


This project is not intended to be a serious data analysis, which would require more data and study. This is a personal project to explore automated plotting of the daily JHU datasets. **The plots produced here do not reflect reality and should not be taken as a model for how COVID-19 spreads through populations.** For example, they do not take into consideration the meaning of confirmed cases - this varies per location and time, availability of testing, changes in policy, and so forth. The data also might contain reporting errors.

---


## Contents {#contents-link}

* [Data Pre-Processing](#preprocess-link): brief description of data pre-processing and cleanup steps.
* [Data Wrangling and Enrichment](#enrich-link): adding population data and calculated columns.
* [Exploratory Data Analysis](#eda-link): main section with visualizations.
* [Code Appendix](#codeappendix-link): entire R code.

---

## Data Pre-Processing {#preprocess-link}

I focused on confirmed cases and fatal cases. See [Code Appendix](#codeappendix-link) for full, commented code.







### Summary

The pre-processed dataset is comprised of 355812 rows and 4 columns. Each single-status dataset is as long as the number of days times the number of countries for the data in a given day. Today there are 894 days and 199 countries in the data, after removing the small and seasonal populations of Antarctica and the Olympics.

The project focuses on countries so latitude, longitude, and the sub-national province/state columns were discarded. 


---

[Back to [Contents](#contents-link)]{style="float:right"}


## Data Wrangling and Enrichment {#enrich-link}


I maintain a static data set of countries and their populations. This data is cobbled together with internet searches and [World Health Organization data.](https://apps.who.int/gho/data/view.main.POP2040ALL?lang=en) I use the country's population to calculate two columns: `Count Per 10K` and `New Cases Per 10K` which track the cumulative cases were observed per 10,000 people, and how many new cases.

The top rows of the enriched data set for Brazil and the US are:

<table class="table table-striped table-hover table-condensed" style="width: auto !important; margin-left: auto; margin-right: auto;">
 <thead>
  <tr>
   <th style="text-align:left;">   </th>
   <th style="text-align:left;"> Country </th>
   <th style="text-align:left;"> Status </th>
   <th style="text-align:left;"> Date </th>
   <th style="text-align:right;"> Count </th>
   <th style="text-align:right;"> Count_per10K </th>
   <th style="text-align:right;"> NewCases_per10K </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> 41125 </td>
   <td style="text-align:left;"> Brazil </td>
   <td style="text-align:left;"> Confirmed </td>
   <td style="text-align:left;"> 2022-07-03 </td>
   <td style="text-align:right;"> 32490422 </td>
   <td style="text-align:right;"> 1564.650 </td>
   <td style="text-align:right;"> 0.8945211 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 41126 </td>
   <td style="text-align:left;"> Brazil </td>
   <td style="text-align:left;"> Confirmed </td>
   <td style="text-align:left;"> 2022-07-02 </td>
   <td style="text-align:right;"> 32471847 </td>
   <td style="text-align:right;"> 1563.755 </td>
   <td style="text-align:right;"> 1.8195740 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 41127 </td>
   <td style="text-align:left;"> Brazil </td>
   <td style="text-align:left;"> Confirmed </td>
   <td style="text-align:left;"> 2022-07-01 </td>
   <td style="text-align:right;"> 32434063 </td>
   <td style="text-align:right;"> 1561.936 </td>
   <td style="text-align:right;"> 3.6621190 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 325417 </td>
   <td style="text-align:left;"> US </td>
   <td style="text-align:left;"> Confirmed </td>
   <td style="text-align:left;"> 2022-07-03 </td>
   <td style="text-align:right;"> 87843561 </td>
   <td style="text-align:right;"> 2726.537 </td>
   <td style="text-align:right;"> 0.1532684 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 325418 </td>
   <td style="text-align:left;"> US </td>
   <td style="text-align:left;"> Confirmed </td>
   <td style="text-align:left;"> 2022-07-02 </td>
   <td style="text-align:right;"> 87838623 </td>
   <td style="text-align:right;"> 2726.383 </td>
   <td style="text-align:right;"> 0.5168539 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 325419 </td>
   <td style="text-align:left;"> US </td>
   <td style="text-align:left;"> Confirmed </td>
   <td style="text-align:left;"> 2022-07-01 </td>
   <td style="text-align:right;"> 87821971 </td>
   <td style="text-align:right;"> 2725.867 </td>
   <td style="text-align:right;"> 6.0365324 </td>
  </tr>
</tbody>
</table>

---

[Back to [Contents](#contents-link)]{style="float:right"}


## Exploratory Data Analysis {#eda-link}


### Total Counts

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
   <td style="text-align:left;"> 549,181,398 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Fatal </td>
   <td style="text-align:left;"> 6,339,113 </td>
  </tr>
</tbody>
</table>



---

### Bar Charts

See this [Shiny app](https://bigbangdata.shinyapps.io/shinyapp/) for interactive bar charts with the latest counts and percentages.





---

### Interactive Time Series Plots

Counts and percentages of the top five countries for confirmed and fatal cases.









### Further Plots to Consider


Future iterations could include other interesting metrics such as:

- Doubling rates
- Proportion of New Cases to Total Cases
- Percentage increase plus a horizontal line showing proportion of population to world population


---


[Back to [Contents](#contents-link)]{style="float:right"}

### Code Appendix {#codeappendix-link}

Fork or clone this [GitHub repository](https://github.com/BigBangData/CoronavirusDataAnalysis) with all files and code, including the code for the Shiny app.



```r
# uncomment to run, creates Rcode file with R code, set documentation = 1 to avoid text commentary
#library(knitr)
#options(knitr.purl.inline = TRUE)
#purl("CoronavirusDataAnalysis.Rmd", output = "Rcode.R", documentation = 1)
```
