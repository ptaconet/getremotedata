
<!-- README.md is generated from README.Rmd. Please edit that file -->

# getRemoteData

<!-- badges: start -->

<!-- badges: end -->

The R package `getRemoteData` offers a common framework to download and
import in R remote data (i.e. data stored on the cloud) from
heterogeneous sources. Overall, this package attempts to **facilitate**
and **speed-up** the painfull and time-consuming **data import /
download** process for some well-known and widely used environmental /
climatic products (e.g. [MODIS](https://modis.gsfc.nasa.gov/),
[VNP](https://lpdaac.usgs.gov/search/?query=VNP&page=2),
[GPM](https://www.nasa.gov/mission_pages/GPM/main/index.html), etc.) as
well as other sources (e.g. [VIIRS
DNB](https://ngdc.noaa.gov/eog/viirs/download_dnb_composites.html),
etc.). You will take the best of `getRemoteData` if you work at **local
to regional** spatial scales, i.e. typically from few decimals to a
decade squared degrees. For larger areas, other packages might be more
relevant (see section [Other relevant
packages](#other-relevant-packages) ).

`getRemoteData` makes it efficient to import remote multidimensional
data since it uses data access protocols that enable to subset them
(spatially/temporally/dimensionnally) directly at the downloading phase.

## Why such a package ? (à réécrire)

Modeling an ecological phenomenon (e.g. species distribution) using
climatic/environmental data (e.g. temperature, rainfall) is quite a
common task in ecology. The data analysis workflow generally consists in
:

  - importing, tidying and summarizing various environmental data at
    geographical locations and dates of interest ;
  - creating explicative / predictive models of the phenomenon using the
    environmental data.

Data of interest for a specific study are usually heterogeneous (various
providers and formats). Downloading long time series of several
environmental data “manually” (e.g. through user-friendly web portals)
is time consuming, not reproducible and prone to errors. In addition,
when downloaded manually, spatial datasets might cover quite large
areas, or include many dimensions (e.g. the multiple bands for a MODIS
product). If your aera of interest is smaller or if you do not need all
the dimensions, why downloading the whole dataset ? Whenever possible
(i.e. made possible by the data provider - check section [Behind the
scene… how it works](#behind-the-scene-...-how-it-works)),
`getRemoteData` enables to download the data strictly for your region
and dimensions of interest.

Finally, `getRemoteData` relies as much as possible on open and standard
data access protocols (eg.
[OPeNDAP](https://en.wikipedia.org/wiki/OPeNDAP)), which makes the
package less vulnerable to external changes than packages or
applications relying on APIs.

## When should you use `getRemoteData` ?

`getRemoteData` can hopefully help if you work at a local to regional
spatial scale and need to download long time-series of various climatic
/ environmental spatialized products. By filtering the data directly at
the downloading phase, `getRemoteData` enables to import strictly the
data that is needed, resulting in a reduction of i) the physical size of
the data that is retrieved and ii) the overall downloading time.

Apart from these performance considerations, ethical considerations have
driven the development of this package : i) reduction of the
environmental impact of our digital work and ii) promotion of open
protocols and standards for data access.

## Installation

You can install the development version of `getRemoteData` from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("ptaconet/getRemoteData")
```

## Get the data sources downloadable with `getRemoteData`

The `getAvailableDataSources()` function provides information on the
products downloadable with `getRemoteData` :

``` r
getRemoteData::getAvailableDataSources(detailed=FALSE)
# Turn the argument `detailed` to `TRUE` (default) to get a more detailed table (details for each collection).
```

<table class="table" style="margin-left: auto; margin-right: auto;">

<thead>

<tr>

<th style="text-align:left;">

Product

</th>

<th style="text-align:left;">

Type

</th>

<th style="text-align:left;">

Provider

</th>

<th style="text-align:left;">

Collections

</th>

<th style="text-align:left;">

Function.download

</th>

<th style="text-align:left;">

Function.import

</th>

<th style="text-align:left;">

Additional.information

</th>

</tr>

</thead>

<tbody>

<tr>

<td style="text-align:left;">

MODIS & VNP

</td>

<td style="text-align:left;">

Surface temperature, evoptranspiration, vegetation indices, etc.

</td>

<td style="text-align:left;">

NASA/USGS/NOAA

</td>

<td style="text-align:left;">

MOD11A1.006, MYD11A1.006, MOD11A2.006, MYD11A2.006, MOD13Q1.006,
MYD13Q1.006, MOD16A2.006, MYD16A2.006,VNP21A1D.001, VNP21A1N.001,
VNP21A2.001

</td>

<td style="text-align:left;">

getUrl\_modis\_vnp()

</td>

<td style="text-align:left;">

importData\_modis\_vnp()

</td>

<td style="text-align:left;">

<https://modis.gsfc.nasa.gov/>,
<https://lpdaac.usgs.gov/search/?query=VNP>

</td>

</tr>

<tr>

<td style="text-align:left;">

GPM

</td>

<td style="text-align:left;">

Precipitation

</td>

<td style="text-align:left;">

NASA/JAXA

</td>

<td style="text-align:left;">

GPM\_3IMERGDF.06, GPM\_3IMERGHH.06, GPM\_3IMERGM.06, GPM\_3IMERGDL.06

</td>

<td style="text-align:left;">

getUrl\_gpm()

</td>

<td style="text-align:left;">

importData\_gpm()

</td>

<td style="text-align:left;">

<https://pmm.nasa.gov/GPM>

</td>

</tr>

<tr>

<td style="text-align:left;">

SMAP

</td>

<td style="text-align:left;">

Soil moisture

</td>

<td style="text-align:left;">

NASA

</td>

<td style="text-align:left;">

SPL3SMP\_E.003

</td>

<td style="text-align:left;">

getUrl\_smap()

</td>

<td style="text-align:left;">

importData\_smap()

</td>

<td style="text-align:left;">

<https://smap.jpl.nasa.gov/>

</td>

</tr>

<tr>

<td style="text-align:left;">

VIIRS/NPP

</td>

<td style="text-align:left;">

Nigth lights

</td>

<td style="text-align:left;">

NASA/NOAA

</td>

<td style="text-align:left;">

VIIRS DNB

</td>

<td style="text-align:left;">

getUrl\_viirsDnb()

</td>

<td style="text-align:left;">

importData\_viirsDnb()

</td>

<td style="text-align:left;">

<https://ncc.nesdis.noaa.gov/VIIRS/>

</td>

</tr>

<tr>

<td style="text-align:left;">

TAMSAT

</td>

<td style="text-align:left;">

Precipitation

</td>

<td style="text-align:left;">

University of Reading

</td>

<td style="text-align:left;">

daily individual rainfall estimate, yearly individual rainfall estimate,
monthly individual rainfall estimate, monthly individual rainfall
estimate, monthly individual anomaly

</td>

<td style="text-align:left;">

getUrl\_tamsat()

</td>

<td style="text-align:left;">

importData\_tamsat()

</td>

<td style="text-align:left;">

<https://www.tamsat.org.uk/about>

</td>

</tr>

<tr>

<td style="text-align:left;">

ERA5

</td>

<td style="text-align:left;">

Wind,
etc.

</td>

<td style="text-align:left;">

Copernicus

</td>

<td style="text-align:left;">

10m\_u\_component\_of\_wind,10m\_v\_component\_of\_wind

</td>

<td style="text-align:left;">

getUrl\_era5()

</td>

<td style="text-align:left;">

importData\_era5()

</td>

<td style="text-align:left;">

<https://cds.climate.copernicus.eu/cdsapp#!/dataset/reanalysis-era5-single-levels?tab=overview>

</td>

</tr>

<tr>

<td style="text-align:left;">

SRTM

</td>

<td style="text-align:left;">

Elevation

</td>

<td style="text-align:left;">

NASA/NGA

</td>

<td style="text-align:left;">

SRTMGL1\_v003

</td>

<td style="text-align:left;">

getUrl\_srtm()

</td>

<td style="text-align:left;">

importData\_srtm()

</td>

<td style="text-align:left;">

<https://lpdaac.usgs.gov/products/srtmgl1v003/>

</td>

</tr>

</tbody>

</table>

Note that the *Collections* column provides only the product’s
collections for which data download and import via `getRemoteData` have
been tested and validated : the source products might contain more
collections.

## Functions and syntax

The functions of `getRemoteData` enable to retrieve the URLs of products
to download given a set of arguments of interest (time range, region of
interest, collection, etc. - see below). There is one *`getUrl`*
function for each product (e.g. `getUrl_modis_vnp()`, `getUrl_gpm()`,
etc.)

The function `downloadData()` takes as input the output of a *`getUrl`*
function and downloads the products.

The functions of the *`getUrl`* family share the following arguments :

  - `timeRange` : date or time frame of interest (eventually including
    hours for sub-daily resolution data) ;
  - `roi` : area of interest (either point or polygon) ;
  - `collection` {for multi-collection products only} : collection of
    interest (eg. `"MOD11A1.v006"`)
  - `dimensions` {for multi-dimension products only} : dimensions of the
    product of interest to download (eg.
    `c("LST_Day_1km","LST_Night_1km")`)

Other optional arguments might be provided (see documentation of the
functions). Absence of the `timeRange` (resp. `roi`) argument in a
function means that the product of interest does not have any temporal
(resp. spatial) dimension. The function returns a data.frame with the
URL(s) to download the dataset(s) of interest and their destination
file.

Data downloaded through the *`getUrl`* functions are usually in NetCDF
format. The functions of the *`importData`* family enable to import
these data as ready-to-use `raster` objects, eventually pre-processing
them if relevant (e.g. projection, flipping).

**The *`importData`* family** : functions to import in R (usually as an
object of class `raster`) a dataset that has been downnloaded *via* a
function of the `getUrl` family. Similarly, there is one *`importData`*
function for each product (e.g. `importData_modis_vnp()`,
`importData_gpm()`, etc.)

## Example

We want to download over a 3500 km<sup>2</sup> wide region of interest :

  - a 40 days time series of [MODIS Terra Land Surface Temperature
    (LST)](https://dx.doi.org/10.5067/MODIS/MOD11A1.006) (with a daily
    temporal resolution);
  - the same 40 days times series of [Global Precipitation Measurement
    (GPM)](https://doi.org/10.5067/GPM/IMERGDF/DAY/06) (with a daily
    temporal resolution) :

First prepare the script : set ROI, time frame and connect to EarthData

``` r
### Prepare script
# Packages
require(getRemoteData)
require(tidyverse)

# Identify which collections are available and get details about each one
coll_available <- getRemoteData::getAvailableDataSources()

# Set ROI and time range of interest
roi<-sf::st_read(system.file("extdata/roi_example.gpkg", package = "getRemoteData"),quiet=TRUE)
timeRange<-as.Date(c("2017-01-01","2017-01-30"))

# Login to EarthData servers
my.earthdata.username<-"my.earthdata.username"
my.earthdata.pw<-"my.earthdata.pw"
getRemoteData::login_earthdata(my.earthdata.username,my.earthdata.pw)
```

Retrieve MODIS data : get the URLs, download the data and finally open
the rasters

``` r
### Get MODIS Terra LST
# Get the URLs
df_data_to_dl_modis<-getRemoteData::getUrl_modis_vnp(
 timeRange=timeRange,
 roi=roi,
 collection="MOD11A1.006",
 dimensions=c("LST_Day_1km","LST_Night_1km"),
 single_ncfile = FALSE
 )

# Set destination folder
df_data_to_dl_modis$destfile<-file.path("MOD11A1",df_data_to_dl_modis$name)

# Download the data
res_dl_modis<-getRemoteData::downloadData(df_data_to_dl_modis,parallelDL=TRUE,data_source="earthdata")

# Open the time series as either : 
# a lists of rasters
rasts_modis_lst_day<-purrr::map(res_dl_modis$destfile,~getRemoteData::importData_modis_vnp(.,"LST_Day_1km")) %>%
  purrr::set_names(res_dl_modis$name)

rasts_modis_lst_night<-purrr::map(res_dl_modis$destfile,~getRemoteData::importData_modis_vnp(.,"LST_Night_1km")) %>%
 purrr::set_names(res_dl_modis$name)

# a stars object
stars_modis = stars::read_stars(res_dl_modis$destfile, quiet = TRUE)
```

Retrieve GPM data : same process

``` r
### Get GPM daily
# Get the URLs
df_data_to_dl_gpm<-getRemoteData::getUrl_gpm(
 timeRange=timeRange,
 roi=roi,
 collection="GPM_3IMERGDF.06",
 dimensions=c("precipitationCal","precipitationCal_cnt")
 )

# Set destination folder
df_data_to_dl_gpm$destfile<-file.path("GPM_3IMERGDF",df_data_to_dl_gpm$name)

# Download the data
res_dl_gpm<-getRemoteData::downloadData(df_data_to_dl_gpm,parallelDL=TRUE,data_source="earthdata")

# Open the time series as lists of rasters
rasts_gpm<-purrr::map(res_dl_gpm$destfile,~getRemoteData::importData_gpm(.,"precipitationCal")) %>%
 purrr::set_names(res_dl_gpm$name)

# Here we cannot open the time series as a stars object, since GPM data needs to be flipped (the operation is done within the getRemoteData::importData_gpm() function), and that there is no function in the stars package to flip the data
```

Have a look at the vignette [Automatic extraction of spatial-temporal
environmental data within buffers around sampling
points](https://ptaconet.github.io/malamodpkg/articles/import_tidy_transform_envdata.html)
to get a more developed example of what you can do with `getRemoteData`
\!

## Current limitations

The package is still at a an early stage of development. Here are some
of the current limitations, and ideas for future developments :

  - MODIS data cannot be downloaded if your area of interest covers
    multiple MODIS tiles (for an overview of MODIS tiles go
    [here](https://modis.ornl.gov/files/modis_sin.kmz));

## Behind the scene… how it works

As much as possible, when implemented by the data providers,
`getRemoteData` uses open and standard data access protocols to download
the data. These standard protocols enable to filter the data directly at
the downloading phase. Filters can be spatial, temporal or dimensional.
Example of widely-used standard data access protocols for geospatial
timeseries are [OGC
WFS](https://en.wikipedia.org/wiki/Web_Feature_Service) or
[OPeNDAP](https://en.wikipedia.org/wiki/OPeNDAP). If long time series
are queried, `getRemoteData` enables to speed-up the downloading time by
parallelizing it.

## Other relevant packages

  - [`getSpatialData`](http://jxsw.de/getSpatialData/)
  - \[`MODIS`\] and \[`MODISTools`\] and \[`MODISTsp`\]
  - GPM ?
  - SMAP ?
