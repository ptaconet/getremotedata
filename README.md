
<!-- README.md is generated from README.Rmd. Please edit that file -->

# getRemoteData

<!-- badges: start -->

<!-- badges: end -->

`getRemoteData` is a set of R function that offer a common grammar to
query and import remote data from heterogeneous sources. Overall, this
package attempts to **facilitate** and **speed-up** the painfull and
time-consuming **data import / download** process for some well-known
and widely used environmental / climatic data (e.g.
[MODIS](https://modis.gsfc.nasa.gov/),
[GPM](https://www.nasa.gov/mission_pages/GPM/main/index.html), etc.) as
well as other sources (e.g. [VIIRS
DNB](https://ngdc.noaa.gov/eog/viirs/download_dnb_composites.html),
etc.). You will take the best of `getRemoteData` if you work at **local
to regional** spatial scales, i.e. typically from few decimals to a
decade squared degrees. For larger areas, other packages might be more
relevant (e.g. [`getSpatialData`](http://jxsw.de/getSpatialData/)).

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
is time consuming and is not reproducible. In addition, when downloaded
manually, spatial datasets might cover quite large areas, or include
many dimensions (e.g. the multiple bands for a MODIS product). If your
aera of interest is smaller or if you do not need all the dimensions,
why donwloading the whole dataset ? Whenever possible (i.e. made
possible by the data provider - check section [Behind the scene… how it
works](#%20Behind%20the%20scene...%20how%20it%20works)), `getRemoteData`
enables to download the data strictly for your region and dimensions of
interest.

**When should you use `getRemoteData` ?**

You might have a deeper look at `getRemoteData` if you recognize
yourself in one or more of the following points :

  - work at a local to regional spatial scale ;
  - need to import data from various sources (e.g. MODIS, GPM, etc.) ;
  - are interested in importing long climatic / environmental
    time-series ;
  - have a slow internet connection ;
  - care about the digital environmental impact of your work.

`getRemoteData` is developed in the frame of PhD project, and the
sources of data implemented in the package are hence those that I use in
my work. Sources of data are mostly environmental / climatic data, but
not exclusively. Have a look at the function `getAvailableDataSources`
to check which sources are already implemented \!

Other relavant packages :

  - [`getSpatialData`](http://jxsw.de/getSpatialData/)
  - \[`MODIS`\] and \[`MODISTools`\] and \[`MODISTsp`\]
  - GPM ?

## Installation

You can install the development version of `getRemoteData` from
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

source

</th>

<th style="text-align:left;">

covariate

</th>

<th style="text-align:left;">

collection

</th>

<th style="text-align:left;">

getRemoteData\_import\_func

</th>

<th style="text-align:left;">

getRemoteData\_prepare\_func

</th>

<th style="text-align:left;">

url\_metadata

</th>

<th style="text-align:left;">

is\_timeSeries

</th>

<th style="text-align:left;">

provider

</th>

<th style="text-align:left;">

long\_name

</th>

<th style="text-align:right;">

version

</th>

<th style="text-align:left;">

DOI

</th>

<th style="text-align:right;">

spatial\_resolution\_m

</th>

<th style="text-align:right;">

temporal\_resolution

</th>

<th style="text-align:left;">

temporal\_resolution\_unit

</th>

<th style="text-align:left;">

spatial\_coverage

</th>

<th style="text-align:left;">

url\_programmatic\_access

</th>

<th style="text-align:left;">

url\_manual\_access

</th>

</tr>

</thead>

<tbody>

<tr>

<td style="text-align:left;">

MODIS

</td>

<td style="text-align:left;">

Temperature

</td>

<td style="text-align:left;">

MOD11A1.v006

</td>

<td style="text-align:left;">

getData\_modis()

</td>

<td style="text-align:left;">

prepareData\_modis()

</td>

<td style="text-align:left;">

<https://lpdaac.usgs.gov/products/mod11a1v006/>

</td>

<td style="text-align:left;">

TRUE

</td>

<td style="text-align:left;">

NASA

</td>

<td style="text-align:left;">

MODIS/Terra Land Surface Temperature/Emissivity Daily L3 Global 1km SIN
Grid V006

</td>

<td style="text-align:right;">

6

</td>

<td style="text-align:left;">

<https://dx.doi.org/10.5067/MODIS/MOD11A1.006>

</td>

<td style="text-align:right;">

1000

</td>

<td style="text-align:right;">

1

</td>

<td style="text-align:left;">

day

</td>

<td style="text-align:left;">

Global

</td>

<td style="text-align:left;">

<https://opendap.cr.usgs.gov/opendap/hyrax/MOD11A1.006/contents.html>

</td>

<td style="text-align:left;">

<https://search.earthdata.nasa.gov/search?q=MOD11A1&ok=MOD11A1>

</td>

</tr>

<tr>

<td style="text-align:left;">

MODIS

</td>

<td style="text-align:left;">

Temperature

</td>

<td style="text-align:left;">

MYD11A1.v006

</td>

<td style="text-align:left;">

getData\_modis()

</td>

<td style="text-align:left;">

prepareData\_modis()

</td>

<td style="text-align:left;">

<https://lpdaac.usgs.gov/products/myd11a1v006/>

</td>

<td style="text-align:left;">

TRUE

</td>

<td style="text-align:left;">

NASA

</td>

<td style="text-align:left;">

MODIS/Aqua Land Surface Temperature/Emissivity Daily L3 Global 1km SIN
Grid V006

</td>

<td style="text-align:right;">

6

</td>

<td style="text-align:left;">

<https://dx.doi.org/10.5067/MODIS/MYD11A1.006>

</td>

<td style="text-align:right;">

1000

</td>

<td style="text-align:right;">

1

</td>

<td style="text-align:left;">

day

</td>

<td style="text-align:left;">

Global

</td>

<td style="text-align:left;">

<https://opendap.cr.usgs.gov/opendap/hyrax/MYD11A1.006/contents.html>

</td>

<td style="text-align:left;">

<https://search.earthdata.nasa.gov/search?q=MYD11A1&ok=MYD11A1>

</td>

</tr>

<tr>

<td style="text-align:left;">

MODIS

</td>

<td style="text-align:left;">

Temperature

</td>

<td style="text-align:left;">

MOD11A2.v006

</td>

<td style="text-align:left;">

getData\_modis()

</td>

<td style="text-align:left;">

prepareData\_modis()

</td>

<td style="text-align:left;">

<https://lpdaac.usgs.gov/products/mod11a2v006/>

</td>

<td style="text-align:left;">

TRUE

</td>

<td style="text-align:left;">

NASA

</td>

<td style="text-align:left;">

MODIS/Terra Land Surface Temperature/Emissivity 8-Day L3 Global 1 km SIN
Grid V006

</td>

<td style="text-align:right;">

6

</td>

<td style="text-align:left;">

<https://dx.doi.org/10.5067/MODIS/MOD11A2.006>

</td>

<td style="text-align:right;">

1000

</td>

<td style="text-align:right;">

8

</td>

<td style="text-align:left;">

day

</td>

<td style="text-align:left;">

Global

</td>

<td style="text-align:left;">

<https://opendap.cr.usgs.gov/opendap/hyrax/MOD11A2.006/contents.html>

</td>

<td style="text-align:left;">

<https://search.earthdata.nasa.gov/search?q=MOD11A2&ok=MOD11A2>

</td>

</tr>

<tr>

<td style="text-align:left;">

MODIS

</td>

<td style="text-align:left;">

Temperature

</td>

<td style="text-align:left;">

MYD11A2.v006

</td>

<td style="text-align:left;">

getData\_modis()

</td>

<td style="text-align:left;">

prepareData\_modis()

</td>

<td style="text-align:left;">

<https://lpdaac.usgs.gov/products/myd11a2v006/>

</td>

<td style="text-align:left;">

TRUE

</td>

<td style="text-align:left;">

NASA

</td>

<td style="text-align:left;">

MODIS/Aqua Land Surface Temperature/Emissivity 8-Day L3 Global 1 km SIN
Grid V006

</td>

<td style="text-align:right;">

6

</td>

<td style="text-align:left;">

<https://dx.doi.org/10.5067/MODIS/MYD11A2.006>

</td>

<td style="text-align:right;">

1000

</td>

<td style="text-align:right;">

8

</td>

<td style="text-align:left;">

day

</td>

<td style="text-align:left;">

Global

</td>

<td style="text-align:left;">

<https://opendap.cr.usgs.gov/opendap/hyrax/MYD11A2.006/contents.html>

</td>

<td style="text-align:left;">

<https://search.earthdata.nasa.gov/search?q=MYD11A2&ok=MYD11A2>

</td>

</tr>

<tr>

<td style="text-align:left;">

MODIS

</td>

<td style="text-align:left;">

Vegetation indices

</td>

<td style="text-align:left;">

MOD13Q1.v006

</td>

<td style="text-align:left;">

getData\_modis()

</td>

<td style="text-align:left;">

prepareData\_modis()

</td>

<td style="text-align:left;">

<https://lpdaac.usgs.gov/products/mod13q1v006/>

</td>

<td style="text-align:left;">

TRUE

</td>

<td style="text-align:left;">

NASA

</td>

<td style="text-align:left;">

MODIS/Terra Vegetation Indices 16-Day L3 Global 250m SIN Grid V006

</td>

<td style="text-align:right;">

6

</td>

<td style="text-align:left;">

<https://dx.doi.org/10.5067/MODIS/MOD13Q1.006>

</td>

<td style="text-align:right;">

250

</td>

<td style="text-align:right;">

16

</td>

<td style="text-align:left;">

day

</td>

<td style="text-align:left;">

Global

</td>

<td style="text-align:left;">

<https://opendap.cr.usgs.gov/opendap/hyrax/MOD13Q1.006/contents.html>

</td>

<td style="text-align:left;">

<https://search.earthdata.nasa.gov/search?q=MOD13Q1&ok=MOD13Q1>

</td>

</tr>

<tr>

<td style="text-align:left;">

MODIS

</td>

<td style="text-align:left;">

Vegetation indices

</td>

<td style="text-align:left;">

MYD13Q1.v006

</td>

<td style="text-align:left;">

getData\_modis()

</td>

<td style="text-align:left;">

prepareData\_modis()

</td>

<td style="text-align:left;">

<https://lpdaac.usgs.gov/products/myd13q1v006/>

</td>

<td style="text-align:left;">

TRUE

</td>

<td style="text-align:left;">

NASA

</td>

<td style="text-align:left;">

MODIS/Aqua Vegetation Indices 16-Day L3 Global 250m SIN Grid V006

</td>

<td style="text-align:right;">

6

</td>

<td style="text-align:left;">

<https://dx.doi.org/10.5067/MODIS/MYD13Q1.006>

</td>

<td style="text-align:right;">

250

</td>

<td style="text-align:right;">

16

</td>

<td style="text-align:left;">

day

</td>

<td style="text-align:left;">

Global

</td>

<td style="text-align:left;">

<https://opendap.cr.usgs.gov/opendap/hyrax/MYD13Q1.006/contents.html>

</td>

<td style="text-align:left;">

<https://search.earthdata.nasa.gov/search?q=MYD13Q1&ok=MYD13Q1>

</td>

</tr>

<tr>

<td style="text-align:left;">

MODIS

</td>

<td style="text-align:left;">

Evapotranspiration

</td>

<td style="text-align:left;">

MOD16A2.v006

</td>

<td style="text-align:left;">

getData\_modis()

</td>

<td style="text-align:left;">

prepareData\_modis()

</td>

<td style="text-align:left;">

<https://lpdaac.usgs.gov/products/mod16a2v006/>

</td>

<td style="text-align:left;">

TRUE

</td>

<td style="text-align:left;">

NASA

</td>

<td style="text-align:left;">

MODIS/Terra Net Evapotranspiration 8-Day L4 Global 500m SIN Grid V006

</td>

<td style="text-align:right;">

6

</td>

<td style="text-align:left;">

<https://dx.doi.org/10.5067/MODIS/MOD16A2.006>

</td>

<td style="text-align:right;">

500

</td>

<td style="text-align:right;">

8

</td>

<td style="text-align:left;">

day

</td>

<td style="text-align:left;">

Global

</td>

<td style="text-align:left;">

<https://opendap.cr.usgs.gov/opendap/hyrax/MOD16A2.006/contents.html>

</td>

<td style="text-align:left;">

<https://search.earthdata.nasa.gov/search?q=MOD16A2&ok=MOD16A2>

</td>

</tr>

<tr>

<td style="text-align:left;">

MODIS

</td>

<td style="text-align:left;">

Evapotranspiration

</td>

<td style="text-align:left;">

MYD16A2.v006

</td>

<td style="text-align:left;">

getData\_modis()

</td>

<td style="text-align:left;">

prepareData\_modis()

</td>

<td style="text-align:left;">

<https://lpdaac.usgs.gov/products/myd16a2v006/>

</td>

<td style="text-align:left;">

TRUE

</td>

<td style="text-align:left;">

NASA

</td>

<td style="text-align:left;">

MODIS/Aqua Net Evapotranspiration 8-Day L4 Global 500m SIN Grid V006

</td>

<td style="text-align:right;">

6

</td>

<td style="text-align:left;">

<https://dx.doi.org/10.5067/MODIS/MYD16A2.006>

</td>

<td style="text-align:right;">

500

</td>

<td style="text-align:right;">

8

</td>

<td style="text-align:left;">

day

</td>

<td style="text-align:left;">

Global

</td>

<td style="text-align:left;">

<https://opendap.cr.usgs.gov/opendap/hyrax/MYD16A2.006/contents.html>

</td>

<td style="text-align:left;">

<https://search.earthdata.nasa.gov/search?q=MYD16A2&ok=MYD16A2>

</td>

</tr>

<tr>

<td style="text-align:left;">

GPM

</td>

<td style="text-align:left;">

Rainfall

</td>

<td style="text-align:left;">

GPM\_3IMERGDF

</td>

<td style="text-align:left;">

getData\_gpm()

</td>

<td style="text-align:left;">

prepareData\_gpm()

</td>

<td style="text-align:left;">

<https://disc.gsfc.nasa.gov/datasets/GPM_3IMERGDF_06/summary>

</td>

<td style="text-align:left;">

TRUE

</td>

<td style="text-align:left;">

NASA

</td>

<td style="text-align:left;">

GPM IMERG Final Precipitation L3 1 day 0.1 degree x 0.1 degree V06

</td>

<td style="text-align:right;">

6

</td>

<td style="text-align:left;">

<https://doi.org/10.5067/GPM/IMERGDF/DAY/06>

</td>

<td style="text-align:right;">

10000

</td>

<td style="text-align:right;">

1

</td>

<td style="text-align:left;">

day

</td>

<td style="text-align:left;">

Global

</td>

<td style="text-align:left;">

<https://gpm1.gesdisc.eosdis.nasa.gov/opendap/GPM_L3/GPM_3IMERGDF.06/>

</td>

<td style="text-align:left;">

<https://search.earthdata.nasa.gov/search?q=GPM_3IMERGDF_06>

</td>

</tr>

<tr>

<td style="text-align:left;">

GPM

</td>

<td style="text-align:left;">

Rainfall - Night of catch

</td>

<td style="text-align:left;">

GPM\_3IMERGHH

</td>

<td style="text-align:left;">

getData\_gpm()

</td>

<td style="text-align:left;">

prepareData\_gpm()

</td>

<td style="text-align:left;">

<https://disc.gsfc.nasa.gov/datasets/GPM_3IMERGHH_06/summary>

</td>

<td style="text-align:left;">

TRUE

</td>

<td style="text-align:left;">

NASA

</td>

<td style="text-align:left;">

GPM IMERG Final Precipitation L3 Half Hourly 0.1 degree x 0.1 degree V06

</td>

<td style="text-align:right;">

6

</td>

<td style="text-align:left;">

<https://doi.org/10.5067/GPM/IMERG/3B-HH/06>

</td>

<td style="text-align:right;">

10000

</td>

<td style="text-align:right;">

30

</td>

<td style="text-align:left;">

minute

</td>

<td style="text-align:left;">

Global

</td>

<td style="text-align:left;">

<https://gpm1.gesdisc.eosdis.nasa.gov/opendap/GPM_L3/GPM_3IMERGHH.06/>

</td>

<td style="text-align:left;">

</td>

</tr>

<tr>

<td style="text-align:left;">

TAMSAT

</td>

<td style="text-align:left;">

Rainfall

</td>

<td style="text-align:left;">

TAMSAT

</td>

<td style="text-align:left;">

getData\_tamsat()

</td>

<td style="text-align:left;">

prepareData\_tamsat()

</td>

<td style="text-align:left;">

<https://www.tamsat.org.uk/about>

</td>

<td style="text-align:left;">

TRUE

</td>

<td style="text-align:left;">

TAMSAT

</td>

<td style="text-align:left;">

Tropical Applications of Meteorology using SATellite data and
ground-based observations

</td>

<td style="text-align:right;">

3

</td>

<td style="text-align:left;">

<http://doi.org/10.1038/sdata.2017.63>

</td>

<td style="text-align:right;">

4000

</td>

<td style="text-align:right;">

1

</td>

<td style="text-align:left;">

day

</td>

<td style="text-align:left;">

Africa

</td>

<td style="text-align:left;">

<https://www.tamsat.org.uk/data/archive>

</td>

<td style="text-align:left;">

<https://www.tamsat.org.uk/data/rfe/index.cgi>

</td>

</tr>

<tr>

<td style="text-align:left;">

ERA5

</td>

<td style="text-align:left;">

Wind - Night of
catch

</td>

<td style="text-align:left;">

ERA5

</td>

<td style="text-align:left;">

getData\_era5()

</td>

<td style="text-align:left;">

prepareData\_era5()

</td>

<td style="text-align:left;">

<https://cds.climate.copernicus.eu/cdsapp#!/dataset/reanalysis-era5-single-levels?tab=overview>

</td>

<td style="text-align:left;">

TRUE

</td>

<td style="text-align:left;">

Copenicus

</td>

<td style="text-align:left;">

ERA5

</td>

<td style="text-align:right;">

5

</td>

<td style="text-align:left;">

</td>

<td style="text-align:right;">

27000

</td>

<td style="text-align:right;">

1

</td>

<td style="text-align:left;">

hour

</td>

<td style="text-align:left;">

Global

</td>

<td style="text-align:left;">

<https://dominicroye.github.io/en/2018/access-to-climate-reanalysis-data-from-r/>

</td>

<td style="text-align:left;">

<https://cds.climate.copernicus.eu/cdsapp#!/dataset/reanalysis-era5-single-levels?tab=form>

</td>

</tr>

<tr>

<td style="text-align:left;">

MIRIADE

</td>

<td style="text-align:left;">

Apparent magnitude of the Moon - Night of catch

</td>

<td style="text-align:left;">

MIRIADE

</td>

<td style="text-align:left;">

getData\_miriade()

</td>

<td style="text-align:left;">

</td>

<td style="text-align:left;">

<http://vo.imcce.fr/webservices/miriade/>

</td>

<td style="text-align:left;">

TRUE

</td>

<td style="text-align:left;">

IMCCE

</td>

<td style="text-align:left;">

The Virtual Observatory Solar System Object Ephemeris Generator

</td>

<td style="text-align:right;">

2

</td>

<td style="text-align:left;">

</td>

<td style="text-align:right;">

NA

</td>

<td style="text-align:right;">

NA

</td>

<td style="text-align:left;">

NA

</td>

<td style="text-align:left;">

Global

</td>

<td style="text-align:left;">

<http://vo.imcce.fr/webservices/miriade/?ephemcc>

</td>

<td style="text-align:left;">

<http://vo.imcce.fr/webservices/miriade/?forms>

</td>

</tr>

<tr>

<td style="text-align:left;">

VIIRS DNB

</td>

<td style="text-align:left;">

Nighttime lights - Night of catch

</td>

<td style="text-align:left;">

VIIRS DNB

</td>

<td style="text-align:left;">

getData\_viirsdnb()

</td>

<td style="text-align:left;">

</td>

<td style="text-align:left;">

<https://ngdc.noaa.gov/eog/viirs/download_dnb_composites.html>

</td>

<td style="text-align:left;">

TRUE

</td>

<td style="text-align:left;">

NOAA

</td>

<td style="text-align:left;">

Visible Infrared Imaging Radiometer Suite (VIIRS) Day/Night Band
(DNB)

</td>

<td style="text-align:right;">

NA

</td>

<td style="text-align:left;">

</td>

<td style="text-align:right;">

450

</td>

<td style="text-align:right;">

1

</td>

<td style="text-align:left;">

month

</td>

<td style="text-align:left;">

Global

</td>

<td style="text-align:left;">

<https://gis.ngdc.noaa.gov/arcgis/rest/services/NPP_VIIRS_DNB/Monthly_AvgRadiance/ImageServer/>

</td>

<td style="text-align:left;">

<https://ngdc.noaa.gov/eog/viirs/download_dnb_composites.html>

</td>

</tr>

<tr>

<td style="text-align:left;">

SRTMGL1\_v004

</td>

<td style="text-align:left;">

Elevation and elevation derivatives

</td>

<td style="text-align:left;">

SRTMGL1\_v003

</td>

<td style="text-align:left;">

getData\_srtm()

</td>

<td style="text-align:left;">

</td>

<td style="text-align:left;">

<https://lpdaac.usgs.gov/products/srtmgl1v003/>

</td>

<td style="text-align:left;">

FALSE

</td>

<td style="text-align:left;">

NASA

</td>

<td style="text-align:left;">

NASA Shuttle Radar Topography Mission Global 1 arc
second

</td>

<td style="text-align:right;">

3

</td>

<td style="text-align:left;">

<https://dx.doi.org/10.5067/MEASURES/SRTM/SRTMGL1.003>

</td>

<td style="text-align:right;">

30

</td>

<td style="text-align:right;">

NA

</td>

<td style="text-align:left;">

NA

</td>

<td style="text-align:left;">

Global

</td>

<td style="text-align:left;">

<https://e4ftl01.cr.usgs.gov/MEASURES/SRTMGL1.003/2000.02.11/>

</td>

<td style="text-align:left;">

<https://search.earthdata.nasa.gov/search/collection-details?p=C1000000240-LPDAAC_ECS&q=SRTM&ok=SRTM>

</td>

</tr>

<tr>

<td style="text-align:left;">

CGLS-LC101

</td>

<td style="text-align:left;">

Land cover

</td>

<td style="text-align:left;">

CGLS-LC100

</td>

<td style="text-align:left;">

getData\_cgls()

</td>

<td style="text-align:left;">

</td>

<td style="text-align:left;">

<https://land.copernicus.eu/global/products/lc>

</td>

<td style="text-align:left;">

FALSE

</td>

<td style="text-align:left;">

Copernicus Global Land Operations

</td>

<td style="text-align:left;">

Moderate dynamic land cover 100m

</td>

<td style="text-align:right;">

2

</td>

<td style="text-align:left;">

</td>

<td style="text-align:right;">

100

</td>

<td style="text-align:right;">

1

</td>

<td style="text-align:left;">

year

</td>

<td style="text-align:left;">

Global

</td>

<td style="text-align:left;">

NA

</td>

<td style="text-align:left;">

<https://lcviewer.vito.be/download>

</td>

</tr>

<tr>

<td style="text-align:left;">

HRSL

</td>

<td style="text-align:left;">

Built-up, Population

</td>

<td style="text-align:left;">

HRSL

</td>

<td style="text-align:left;">

getData\_hrsl()

</td>

<td style="text-align:left;">

</td>

<td style="text-align:left;">

<https://ciesin.columbia.edu/repository/hrsl/#over>

</td>

<td style="text-align:left;">

FALSE

</td>

<td style="text-align:left;">

Facebook Connectivity Lab and Center for International Earth Science
Information Network

</td>

<td style="text-align:left;">

High Resolution Settlement Layer

</td>

<td style="text-align:right;">

1

</td>

<td style="text-align:left;">

</td>

<td style="text-align:right;">

30

</td>

<td style="text-align:right;">

NA

</td>

<td style="text-align:left;">

NA

</td>

<td style="text-align:left;">

Available for some countries : see list here :
<https://ciesin.columbia.edu/repository/hrsl/#data>

</td>

<td style="text-align:left;">

NA

</td>

<td style="text-align:left;">

<https://ciesin.columbia.edu/repository/hrsl/#data>

</td>

</tr>

<tr>

<td style="text-align:left;">

WorldPop\_100m\_Population

</td>

<td style="text-align:left;">

Population

</td>

<td style="text-align:left;">

WorldPop\_100m\_Population

</td>

<td style="text-align:left;">

getData\_worldpop()

</td>

<td style="text-align:left;">

</td>

<td style="text-align:left;">

<https://journals.plos.org/plosone/article?id=10.1371/journal.pone.0107042>

</td>

<td style="text-align:left;">

FALSE

</td>

<td style="text-align:left;">

WorldPop

</td>

<td style="text-align:left;">

Alpha version 2014 estimates of numbers of people per grid square, with
national totals adjusted to match UN population division estimates

</td>

<td style="text-align:right;">

3

</td>

<td style="text-align:left;">

10.5258/SOTON/WP00033 10.5258/SOTON/WP00065

</td>

<td style="text-align:right;">

100

</td>

<td style="text-align:right;">

NA

</td>

<td style="text-align:left;">

NA

</td>

<td style="text-align:left;">

Africa, Asia, South America, Oceania

</td>

<td style="text-align:left;">

NA

</td>

<td style="text-align:left;">

<https://www.worldpop.org/geodata/listing?id=16>

</td>

</tr>

<tr>

<td style="text-align:left;">

OpenSteetMap

</td>

<td style="text-align:left;">

Roads

</td>

<td style="text-align:left;">

OpenSteetMap

</td>

<td style="text-align:left;">

</td>

<td style="text-align:left;">

</td>

<td style="text-align:left;">

<https://www.openstreetmap.org/about>

</td>

<td style="text-align:left;">

FALSE

</td>

<td style="text-align:left;">

OpenSteetMap

</td>

<td style="text-align:left;">

OpenSteetMap

</td>

<td style="text-align:right;">

NA

</td>

<td style="text-align:left;">

NA

</td>

<td style="text-align:right;">

NA

</td>

<td style="text-align:right;">

NA

</td>

<td style="text-align:left;">

NA

</td>

<td style="text-align:left;">

Global

</td>

<td style="text-align:left;">

</td>

<td style="text-align:left;">

<https://www.openstreetmap.org/>

</td>

</tr>

<tr>

<td style="text-align:left;">

Global\_Surface\_Water

</td>

<td style="text-align:left;">

Open waters /
Wetlands

</td>

<td style="text-align:left;">

Global\_Surface\_Water

</td>

<td style="text-align:left;">

getData\_gsw()

</td>

<td style="text-align:left;">

</td>

<td style="text-align:left;">

<https://storage.cloud.google.com/global-surface-water/downloads_ancillary/DataUsersGuidev2018.pdf>

</td>

<td style="text-align:left;">

FALSE

</td>

<td style="text-align:left;">

JRC

</td>

<td style="text-align:left;">

Global Surface Water

</td>

<td style="text-align:right;">

1

</td>

<td style="text-align:left;">

10.1038/nature20584

</td>

<td style="text-align:right;">

30

</td>

<td style="text-align:right;">

1

</td>

<td style="text-align:left;">

year

</td>

<td style="text-align:left;">

Global

</td>

<td style="text-align:left;">

NA

</td>

<td style="text-align:left;">

<https://global-surface-water.appspot.com/download>

</td>

</tr>

</tbody>

</table>

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
that the data of interest do not have any time (resp. spatial)
dimension.

Have a look at the vignette [Automatic extraction of spatial-temporal
environmental data within buffers around sample
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
`getRemoteData` uses web services or APIsto download the data. Web
services are in few words standard web protocols that enable to filter
the data directly at the downloading phase. Filters can be spatial,
temporal, dimensional, etc. Example of widely-used web services / data
transfer protocols for geospatial timeseries are [OGC
WFS](https://en.wikipedia.org/wiki/Web_Feature_Service) or
[OPeNDAP](https://en.wikipedia.org/wiki/OPeNDAP). If long time series
are queried, `getRemoteData` speeds-up the downloading time by
parralelizing it.
