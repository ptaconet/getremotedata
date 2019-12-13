
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
environmental data (e.g. temperature, rainfall) is quite a common task
in ecology. The data analysis workflow generally consists in :

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

    #> Warning: replacing previous import 'lubridate::origin' by 'raster::origin'
    #> when loading 'getRemoteData'

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

MOD11A1.v006, MYD11A1.v006, MOD11A2.v006, MYD11A2.v006, MOD13Q1.v006,
MYD13Q1.v006, MOD16A2.v006, MYD16A2.v006,VNP21A1D.v001, VNP21A1N.v001,
VNP21A2.v001

</td>

<td style="text-align:left;">

getData\_modis\_vnp()

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

GPM\_3IMERGDF, GPM\_3IMERGHH

</td>

<td style="text-align:left;">

getData\_gpm()

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

SPL3SMP\_E

</td>

<td style="text-align:left;">

getData\_smap()

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

getData\_viirsDnb()

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

getData\_tamsat()

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

getData\_era5()

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

getData\_srtm()

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

The functions of `getRemoteData` can be split into two families :

  - **The *`getData`* family** : functions to retrieve the URLs of
    products to download given a set of arguments of interest (time
    range, region of interest, collection, etc. - see below), and
    eventually download them. There is one *`getData`* function for each
    product (e.g. `getData_modis_vnp()`, `getData_gpm()`, etc.)
  - **The *`prepareData`* family** : functions to import in R (usually
    as an object of class `raster`) a dataset that has been downnloaded
    *via* a function of the `getData` family. Similarly, there is one
    *`prepareData`* function for each product (e.g.
    `prepareData_modis_vnp()`, `prepareData_gpm()`, etc.)

The ancillary function `downloadData()` takes as input the output of a
*`getData`* function and downloads the products.

The functions of the *`getData`* family share the following arguments :

  - `timeRange` : date or time frame of interest (eventually including
    hours for sub-daily resolution data) ;
  - `roi` : area of interest (either point or polygon) ;
  - `collection` {for multi-collection products only} : collection of
    interest (eg. `"MOD11A1.v006"`)
  - `dimensions` {for multi-dimension products only} : dimensions of the
    product of interest to download (eg.
    `c("LST_Day_1km","LST_Night_1km")`)
  - `username` and `password` {for products that require to log-in only}
    : login credentials
  - `destfolder` : data destination folder
  - `download` : wether to download the datasets or not

Other optional arguments might be provided (see documentation of the
functions). Absence of the `timeRange` (resp. `roi`) argument in a
function means that the product of interest does not have any temporal
(resp. spatial) dimension. The function returns a data.frame with the
URL(s) to download the dataset(s) of interest and their destination
file.

Data downloaded through the *`getData`* functions are usually in NetCDF
format. The functions of the *`prepareData`* family enable to import
these data as ready-to-use `raster` objects, eventually pre-processing
them if relevant (e.g. projection, flipping).

## Example

We want to download over 3500 km<sup>2</sup> wide region of interest :

  - a 40 days time series of [MODIS Terrra Land Surface Temperature
    (LST)](https://dx.doi.org/10.5067/MODIS/MOD11A1.006) (with a daily
    temporal resolution);
  - the same 40 days times series of [Global Precipitation Measurement
    (GPM)](https://doi.org/10.5067/GPM/IMERGDF/DAY/06) (with a daily
    temporal resolution) :

<!-- end list -->

``` r
library(getRemoteData)
library(sf)
library(purrr)
# Import the region of interest as an sf object. Here : Côte D'Ivoire, Korhogo area
roi_path<-system.file("extdata/ROI_example.kml", package = "getData")
roi<-sf::st_read(roi_path,quiet=T)
# Set-up your time frame of interest (first date, last date)
time_frame<-c("2017-05-01","2017-06-10")
# Set-up your credentials to EarthData
username_EarthData<-"my.earthdata.username"
password_EarthData<-"my.earthdata.username"
# Download the MODIS LST TERRA daily products in the current working directory
# Setting the argument 'download' to FALSE will return the URLs of the products, without downloading them 
dl_modis<-getRemoteData::getData_modis(timeRange = time_frame,
                                     roi = roi,
                                     collection="MOD11A1.006",
                                     dimensions=c("LST_Day_1km","LST_Night_1km"),
                                     destFolder=getwd(),
                                     username=username_EarthData,
                                     password=password_EarthData,
                                     download = T,
                                     parallelDL=T #setting to F will download the data linearly
                                     )
head(dl_modis)
# Download the GPM daily products in the current working directory
dl_gpm<-getRemoteData::getData_gpm(timeRange = time_frame,
                                     roi = roi,
                                     collection="GPM_3IMERGDF.06",
                                     dimensions=c("precipitationCal"),
                                     destFolder=getwd(),
                                     username=username_EarthData,
                                     password=password_EarthData,
                                     download = T,
                                     parallelDL=T
                                     )
head(dl_gpm)

# Get the data downloaded as a list of rasters
rasts_modis<-dl_modis$destfile %>%
  purrr::map(~getRemoteData::prepareData_modis(.,"LST_Day_1km")) %>%
  set_names(dl_modis$name)

rasts_gpm<-dl_gpm$destfile %>%
  purrr::map(~getRemoteData::prepareData_gpm(.,"precipitationCal")) %>%
  set_names(dl_gpm$name)
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
