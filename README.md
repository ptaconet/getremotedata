
<!-- README.md is generated from README.Rmd. Please edit that file -->

# getRemoteData

<!-- badges: start -->

<!-- badges: end -->

`getRemoteData` is an R package that offers a common framework to query
and import remote data (i.e. data stored on the cloud) from
heterogeneous sources. Overall, this package attempts to **facilitate**
and **speed-up** the painfull and time-consuming **data import /
download** process for some well-known and widely used environmental /
climatic data (e.g. [MODIS](https://modis.gsfc.nasa.gov/),
[VNP](https://lpdaac.usgs.gov/search/?query=VNP&page=2),
[GPM](https://www.nasa.gov/mission_pages/GPM/main/index.html), etc.) as
well as other sources (e.g. [VIIRS
DNB](https://ngdc.noaa.gov/eog/viirs/download_dnb_composites.html),
etc.). You will take the best of `getRemoteData` if you work at **local
to regional** spatial scales, i.e. typically from few decimals to a
decade squared degrees. For larger areas, other packages might be more
relevant (see section [Other relevant
packages](#other-relevant-packages) ).

**Why such a package ?**

Modeling an ecological phenomenon (e.g. species distribution) using
environmental data (e.g. temperature, rainfall) is quite a common task
in ecology. The data analysis workflow generally consists in :

  - importing, tidying and summarizing various environmental data at
    geographical locations and dates of interest ;
  - creating explicative / predictive models of the phenomenon using the
    environmental data.

Data of interest for a specific study are usually heterogeneous (various
sources, formats, etc.). Downloading long time series of several
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

Finally, getRemoteData relies as much as possible on open and standard
data access protocols (eg.
[OPeNDAP](https://en.wikipedia.org/wiki/OPeNDAP)), which makes it (and
by extension, your script) less vulnerable to external changes than
packages or applications relying on APIs.

**When should you use `getRemoteData` ?**

`getRemoteData` can hopefully help if you recognize yourself in one or
more of the following points :

  - work at a local to regional spatial scale ;
  - need to import data from various sources (e.g. MODIS, GPM, etc.) ;
  - are interested in importing long climatic / environmental
    time-series ;
  - have a slow internet connection ;
  - care about the environmental impact of your digital work.

`getRemoteData` is developed in the frame of PhD project, and the
sources of data implemented in the package are hence those that I use in
my work. Sources of data are mostly environmental / climatic data, but
not exclusively. Have a look at the function `getAvailableDataSources`
to check which sources are already implemented \!

## Installation

You can install the development version of `getRemoteData` from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("ptaconet/getRemoteData")
```

## Get the data sources implemented in `getRemoteData`

The `getAvailableDataSources` function provides information on the data
sources/collections implemented in `getRemoteData`

``` r
getRemoteData::getAvailableDataSources(detailed=FALSE)
```

    #> Warning: replacing previous import 'dplyr::intersect' by
    #> 'lubridate::intersect' when loading 'getRemoteData'
    #> Warning: replacing previous import 'dplyr::union' by 'lubridate::union'
    #> when loading 'getRemoteData'
    #> Warning: replacing previous import 'dplyr::setdiff' by 'lubridate::setdiff'
    #> when loading 'getRemoteData'
    #> Warning: replacing previous import 'dplyr::select' by 'raster::select' when
    #> loading 'getRemoteData'
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

MODIS

</td>

<td style="text-align:left;">

Surface temperature, evoptranspiration, vegetation indices, etc.

</td>

<td style="text-align:left;">

NASA/USGS

</td>

<td style="text-align:left;">

MOD11A1.v006, MYD11A1.v006, MOD11A2.v006, MYD11A2.v006, MOD13Q1.v006,
MYD13Q1.v006, MOD16A2.v006, MYD16A2.v006

</td>

<td style="text-align:left;">

getData\_modis\_vnp()

</td>

<td style="text-align:left;">

importData\_modis\_vnp()

</td>

<td style="text-align:left;">

<https://modis.gsfc.nasa.gov/>

</td>

</tr>

<tr>

<td style="text-align:left;">

VNP

</td>

<td style="text-align:left;">

Surface temperature, vegetation indices, etc.

</td>

<td style="text-align:left;">

NASA/NOAA

</td>

<td style="text-align:left;">

VNP21A1D.v001, VNP21A1N.v001, VNP21A2.v001

</td>

<td style="text-align:left;">

getData\_modis\_vnp()

</td>

<td style="text-align:left;">

importData\_modis\_vnp()

</td>

<td style="text-align:left;">

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

Turn the argument `detailed` to `TRUE` to get more detailed information
on each data collection tested and validated.

## Example

Say you want to download over a 3500km<sup>2</sup> region of interest:

  - a 40 days time series of [MODIS Terrra Land Surface Temperature
    (LST)](https://dx.doi.org/10.5067/MODIS/MOD11A1.006) (daily time
    resolution);
  - the same 40 days times series of [Global Precipitation Measurement
    (GPM)](https://doi.org/10.5067/GPM/IMERGDF/DAY/06) (daily time
    resolution) :

<!-- end list -->

``` r
library(getRemoteData)
library(sf)
library(purrr)
# Read the region of interest as a sf object. Here : the Korhogo area in Côte D'Ivoire
roi<-sf::st_read(system.file("extdata/ROI_example.kml", package = "getData"),quiet=T)
# Set-up your time frame of interest. 
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
                                     download = T,
                                     destFolder=getwd(),
                                     username=username_EarthData,
                                     password=password_EarthData,
                                     parallelDL=T #setting to F will download the data linearly
                                     )
head(dl_modis)
# Download the GPM daily products in the current working directory
dl_gpm<-getRemoteData::getData_gpm(timeRange = time_frame,
                                     roi = roi,
                                     collection="GPM_3IMERGDF.06",
                                     dimensions=c("precipitationCal"),
                                     download = T,
                                     destFolder=getwd(),
                                     username=username_EarthData,
                                     password=password_EarthData,
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

The functions of `getRemoteData` all work the same way :

  - `timeRange` is your date / time frame of interest (eventually
    including hours for the data with less that daily resolution) ;
  - `roi` is your area of interest (as an `sf` object, either point or
    polygon) ;
  - `destfolder` is the data destination folder ;
  - by default, the function does not download the dataset. It returns a
    data.frame with the URL(s) to download the dataset(s) of interest
    given the input arguments. To download the data, set the *download*
    argument to TRUE ;
  - other arguments are specific to each data product (e.g.
    `collection`, `dimensions`,`username`,`password`)

Absence of the `timeRange` (resp. `roi`) arguments in a function means
that the data of interest do not have any temporal (resp. spatial)
dimension.

Have a look at the vignette [Automatic extraction of spatial-temporal
environmental data within buffers around sampling
points](https://ptaconet.github.io/malamodpkg/articles/import_tidy_transform_envdata.html)
to get an example of what you can do with `getRemoteData` \!

## Current limitations

The package is at a very early stage of development. Here are some of
the current limitations and ideas of future developments :

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
