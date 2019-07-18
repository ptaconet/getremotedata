
<!-- README.md is generated from README.Rmd. Please edit that file -->

# getRemoteData

<!-- badges: start -->

<!-- badges: end -->

Modeling an ecological phenomenon (e.g. species distribution) using
environmental data (e.g. temperature, rainfall) is quite a common task
in ecology. The data analysis workflow generally consists in :

  - importing, tidying and summarizing various environmental data at
    geographical locations and dates of interest ;
  - creating explicative / predictive models of the phenomenon using the
    environmental data.

Data of interest are usually heterogeneous: various sources, formats,
web portals to get the data, etc. In addition, scientists are mostly
interested in studying time-series rather than one-date data - past
environmental conditions might explain present situation.

`getRemoteData` attempts to **facilitate** and **speed-up** the painfull
and time-consuming **data import** process for some well-known and
widely used environmental / climatic data sources (e.g.
[MODIS](https://modis.gsfc.nasa.gov/),
[GPM](https://www.nasa.gov/mission_pages/GPM/main/index.html), etc.) as
well as other sources (e.g. [VIIRS
DNB](https://ngdc.noaa.gov/eog/viirs/download_dnb_composites.html),
etc.). You will take the best of `getRemoteData` if you work at **local
to regional** spatial scales, i.e. typically from 0.1 to a decade
squared degrees. For larger areas, other packages might be more relevant
(e.g. [`getSpatialData`)](http://jxsw.de/getSpatialData/).

## Installation

You can install the development version of getRemoteData from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("ptaconet/getRemoteData")
```

## Get the data sources implemented in `getRemoteData`

You can get the data sources/collections downloadable with
`getRemoteData` and details about each of them with :

``` r
getRemoteData::getAvailableDataSources()
```

<img src="man/figures/README-unnamed-chunk-2-1.png" width="100%" />

## Example

Say you want to download a 40 days time series of MODIS Land Surface
Temperature (LST) over a 3500 squared km region of interest :

``` r
library(getRemoteData)
# Set-up the region of interest as a sf object 
roi<-sf::st_read(system.file("extdata/ROI_example.kml", package = "getData"),quiet=T)
# Set-up your time frame of interest
time_frame<-c("2017-05-01","2017-06-10")
# Set-up your credentials to EarthData
username_EarthData<-"my.earthdata.username"
password_EarthData<-"my.earthdata.username"
# Download the MODIS LST TERRA daily products
dl_res<-getRemoteData::getData_modis(time_range = time_frame,
                                     roi = roi,
                                     OpenDAPCollection="MOD11A1.006",
                                     dimensionsToRetrieve=c("LST_Day_1km","LST_Night_1km"),
                                     download = T, # setting to F will return URLs of the products without downloading them 
                                     destFolder=getwd(),
                                     username=username_EarthData,
                                     password=password_EarthData,
                                     parallelDL=T #setting to F will download the data linearly
                                     )
```

The functions of `getRemoteData` all work the same way :

  - the *time\_range* argument is your date(s)/time(s) of interest
    (eventually including hours for the data with hourly or half-hourly
    resolution) ;
  - the *roi* argument is your area of interest (as an `sf` object,
    either point or polygon) ;
  - the *destfolder* argument is the data destination folder ;
  - by default, the function does not download the dataset. It returns a
    data.frame with the URL(s) to download the dataset(s) of interest
    given the input arguments. To download the data, set the *download*
    argument to TRUE ;
  - the other arguments are specific to each function / data sources
    (e.g. *username*, *password*, *dimensionsToRetrieve*)

You can also embed plots, for example:

<img src="man/figures/README-pressure-1.png" width="100%" />

In that case, don’t forget to commit and push the resulting figure
files, so they display on GitHub\!

## Behind the scenes… how it works

Data are often `getRemoteData`
