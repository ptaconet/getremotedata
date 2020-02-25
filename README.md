
<!-- README.md is generated from README.Rmd. Please edit that file -->

# getremotedata

<!-- badges: start -->

[![CRAN\_Status\_Badge](http://www.r-pkg.org/badges/version/getRemoteData)](https://cran.r-project.org/package=getRemoteData)
[![Github\_Status\_Badge](https://img.shields.io/badge/Github-0.0.9007-blue.svg)](https://github.com/ptaconet/getRemoteData)
<!-- badges: end -->

**getremotedata** is an R package that provides functions to
**harmonize** the **download** of various open data collections
available on the web.

## Installation

The package can be installed with:

``` r
# install.packages("devtools")
devtools::install_github("ptaconet/getremotedata", build_vignettes = T, build_manual = T)
```

## Collections available in getremotedata

Currently **getremotedata** supports download of 5 data collections.
Most data collections provided through getremotedata have a spatial and
a temporal component and a global coverage. Details of each product
available for download are provided in the table above or through the
function `grd_list_collections()`. Want more details on a specific
collection ? Click on the “DOI” column \!

<details>

<summary><b>Data collections available for download with getremotedata
(click to expand)</b></summary>

<p>

<table class="table" style="margin-left: auto; margin-right: auto;">

<thead>

<tr>

<th style="text-align:left;">

Collection

</th>

<th style="text-align:left;">

Name

</th>

<th style="text-align:left;">

Source

</th>

<th style="text-align:left;">

Nature

</th>

<th style="text-align:left;">

DOI

</th>

<th style="text-align:left;">

url\_data\_server

</th>

<th style="text-align:left;">

param\_variables

</th>

<th style="text-align:left;">

param\_roi

</th>

<th style="text-align:left;">

param\_time\_range

</th>

</tr>

</thead>

<tbody>

<tr>

<td style="text-align:left;">

ERA5

</td>

<td style="text-align:left;">

ERA5 hourly data on single levels from 1979 to
present

</td>

<td style="text-align:left;">

ERA5

</td>

<td style="text-align:left;">

Wind

</td>

<td style="text-align:left;">

<https://doi.org/10.24381/cds.adbb2d47>

</td>

<td style="text-align:left;">

<https://dominicroye.github.io/en/2018/access-to-climate-reanalysis-data-from-r/>

</td>

<td style="text-align:left;">

TRUE

</td>

<td style="text-align:left;">

TRUE

</td>

<td style="text-align:left;">

TRUE

</td>

</tr>

<tr>

<td style="text-align:left;">

MIRIADE

</td>

<td style="text-align:left;">

The Virtual Observatory Solar System Object Ephemeris Generator

</td>

<td style="text-align:left;">

IMCCE

</td>

<td style="text-align:left;">

Apparent magnitude of the Moon

</td>

<td style="text-align:left;">

</td>

<td style="text-align:left;">

<http://vo.imcce.fr/webservices/miriade/?ephemcc>

</td>

<td style="text-align:left;">

FALSE

</td>

<td style="text-align:left;">

TRUE

</td>

<td style="text-align:left;">

TRUE

</td>

</tr>

<tr>

<td style="text-align:left;">

SRTMGL1.003

</td>

<td style="text-align:left;">

Digital Elevation Model from the NASA Shuttle Radar Topography Mission
Global 1 arc second

</td>

<td style="text-align:left;">

SRTM

</td>

<td style="text-align:left;">

Elevation

</td>

<td style="text-align:left;">

<https://dx.doi.org/10.5067/MEASURES/SRTM/SRTMGL1.003>

</td>

<td style="text-align:left;">

<https://opendap.cr.usgs.gov/opendap/hyrax/SRTMGL1.003/contents.html>

</td>

<td style="text-align:left;">

FALSE

</td>

<td style="text-align:left;">

TRUE

</td>

<td style="text-align:left;">

FALSE

</td>

</tr>

<tr>

<td style="text-align:left;">

TAMSAT

</td>

<td style="text-align:left;">

Tropical Applications of Meteorology using SATellite data and
ground-based observations

</td>

<td style="text-align:left;">

TAMSAT

</td>

<td style="text-align:left;">

Rainfall

</td>

<td style="text-align:left;">

<http://doi.org/10.1038/sdata.2017.63>

</td>

<td style="text-align:left;">

<https://www.tamsat.org.uk/data/archive>

</td>

<td style="text-align:left;">

TRUE

</td>

<td style="text-align:left;">

FALSE

</td>

<td style="text-align:left;">

TRUE

</td>

</tr>

<tr>

<td style="text-align:left;">

VIIRS\_DNB\_MONTH

</td>

<td style="text-align:left;">

Visible Infrared Imaging Radiometer Suite (VIIRS) Day/Night Band (DNB)

</td>

<td style="text-align:left;">

VIIRS

</td>

<td style="text-align:left;">

Nighttime
lights

</td>

<td style="text-align:left;">

<https://doi.org/10.5067/VIIRS/VNP46A1.001>

</td>

<td style="text-align:left;">

<https://gis.ngdc.noaa.gov/arcgis/rest/services/NPP_VIIRS_DNB/Monthly_AvgRadiance/ImageServer/>

</td>

<td style="text-align:left;">

TRUE

</td>

<td style="text-align:left;">

TRUE

</td>

<td style="text-align:left;">

TRUE

</td>

</tr>

</tbody>

</table>

</p>

</details>

## Get Started

Downloading the data with **getremotedata** is a simple two-steps
workflow :

  - With the function **`grd_get_url()`**, get the URL(s) of the data
    for :
    
      - a collection : see [previous
        section](#collections-available-in-getremotedata),
      - (eventually) variables,
      - (eventually) a region of interest,
      - (eventually) a time range.

  - With any data download function (e.g. `httr::GET()` or
    `opendapr::odr_download_data()`), download the data.

Additional functions include : list collection available for download (
`gdr_list_collections()` ), list variables available for the collections
that have variables ( `gdr_list_variables()` )

## Example

**Have a look at the
[`vignette("get-started")`](https://ptaconet.github.io/getremotedata/articles/get-started.html)
for a data download, import and plot workflow \!**

## Acknowledgment

We thank the data providers for making their data freely available, and
implementing open data access protocols that enable to download chunks
of data.

This research has made use of [IMCCE’s Miriade VO
tool](http://vo.imcce.fr/webservices/miriade/)

The initial development and first release of this package were financed
by the [MIVEGEC](https://www.mivegec.ird.fr/en/) unit of the [French
Research Institute for Sustainable Development](https://en.ird.fr/), as
part of the [REACT
project](https://burkina-faso.ird.fr/la-recherche/projets-de-recherche2/gestion-de-la-resistance-aux-insecticides-au-burkina-faso-et-en-cote-d-ivoire-recherche-sur-les-strategies-de-lutte-anti-vectorielle-react).

<!--

The R package `getremotedata` offers a common framework to download and import in R remote data (i.e. data stored on the cloud) from heterogeneous sources. Overall, this package attempts to **facilitate** and **speed-up** the painfull and time-consuming **data import / download** process for some well-known and widely used environmental / climatic products (e.g. [MODIS](https://modis.gsfc.nasa.gov/), [VNP](https://lpdaac.usgs.gov/search/?query=VNP&page=2), [GPM](https://www.nasa.gov/mission_pages/GPM/main/index.html), etc.) as well as other sources (e.g. [VIIRS DNB](https://ngdc.noaa.gov/eog/viirs/download_dnb_composites.html), etc.). You will take the best of `getRemoteData` if you work at **local to regional** spatial scales, i.e. typically from few decimals to a decade squared degrees. For larger areas, other packages might be more relevant (see section [Other relevant packages](#other-relevant-packages) ).

`getRemoteData` makes it efficient to import remote multidimensional data since it uses data access protocols that enable to subset them (spatially/temporally/dimensionnally) directly at the downloading phase.

## Why such a package ?  (à réécrire)

Modeling an ecological phenomenon (e.g. species distribution) using climatic/environmental data (e.g. temperature, rainfall) is quite a common task in ecology. The data analysis workflow generally consists in : 

- importing, tidying and summarizing various environmental data at geographical locations and dates of interest ;
- creating explicative / predictive models of the phenomenon using the environmental data.

Data of interest for a specific study are usually heterogeneous (various providers and formats). Downloading long time series of several environmental data "manually" (e.g. through user-friendly web portals) is time consuming, not reproducible and prone to errors. In addition, when downloaded manually, spatial datasets might cover quite large areas, or include many dimensions (e.g. the multiple bands for a MODIS product). If your aera of interest is smaller or if you do not need all the dimensions, why downloading the whole dataset ? Whenever possible (i.e. made possible by the data provider - check section [Behind the scene... how it  works](#behind-the-scene-...-how-it-works)), `getRemoteData` enables to download the data strictly for your region and dimensions of interest.

Finally, `getRemoteData` relies as much as possible on open and standard data access protocols (eg. [OPeNDAP](https://en.wikipedia.org/wiki/OPeNDAP)), which makes the package less vulnerable to external changes than packages or applications relying on APIs.

## When should you use `getRemoteData` ?

`getRemoteData` can hopefully help if you work at a local to regional spatial scale and need to download long time-series of various climatic / environmental spatialized products. By filtering the data directly at the downloading phase, `getRemoteData` enables to import strictly the data that is needed, resulting in a reduction of i) the physical size of the data that is retrieved and ii) the overall downloading time. 

Apart from these performance considerations, ethical considerations have driven the development of this package : i) reduction of the environmental impact of our digital work and ii) promotion of open protocols and standards for data access. 

## Installation

You can install the development version of `getRemoteData` from [GitHub](https://github.com/) with: 

``` r
# install.packages("devtools")
devtools::install_github("ptaconet/getRemoteData")
```

## Get the data sources downloadable with `getRemoteData`

The `get_collections_available()` function provides information on the products downloadable with `getRemoteData` :


```r
getRemoteData::get_collections_available(detailed=FALSE)
# Turn the argument `detailed` to `TRUE` (default) to get a more detailed table (details for each collection).
```



Note that the *Collections* column provides only the product's collections for which data download and import via `getRemoteData` have been tested and validated : the source products might contain more collections.

## Functions and syntax

The functions of `getRemoteData` enable to retrieve the URLs of products to download given a set of arguments of interest (time range, region of interest, collection, etc. - see below). There is one *`getUrl`* function for each product (e.g. `getUrl_modis_vnp()`, `getUrl_gpm()`, etc.)

The function `downloadData()` takes as input the output of a *`getUrl`* function and downloads the products.

The functions of the *`getUrl`* family share the following arguments : 

- `timeRange` : date or time frame of interest (eventually including hours for sub-daily resolution data) ;
- `roi` : area of interest (either point or polygon) ;
- `collection` {for multi-collection products only} : collection of interest (eg. `"MOD11A1.v006"`)
- `dimensions` {for multi-dimension products only} : dimensions of the product of interest to download (eg. `c("LST_Day_1km","LST_Night_1km")`)

Other optional arguments might be provided (see documentation of the functions). Absence of the `timeRange` (resp. `roi`) argument in a function means that the product of interest does not have any temporal (resp. spatial) dimension. The function returns a data.frame with the URL(s) to download the dataset(s) of interest and their destination file.

Data downloaded through the *`getUrl`* functions are usually in NetCDF format. The functions of the *`importData`* family enable to import these data as ready-to-use `raster` objects, eventually pre-processing them if relevant (e.g. projection, flipping).

**The *`importData`* family** : functions to import in R (usually as an object of class `raster`) a dataset that has been downnloaded *via* a function of the `getUrl` family. Similarly, there is one *`importData`* function for each product (e.g. `importData_modis_vnp()`, `importData_gpm()`, etc.)

## Behind the scene... how it works

As much as possible, when implemented by the data providers, `getRemoteData` uses open and standard data access protocols to download the data. These standard protocols enable to filter the data directly at the downloading phase. Filters can be spatial, temporal or dimensional. Example of widely-used standard data access protocols for geospatial timeseries are [OGC WFS](https://en.wikipedia.org/wiki/Web_Feature_Service) or [OPeNDAP](https://en.wikipedia.org/wiki/OPeNDAP). 
If long time series are queried, `getRemoteData` enables to speed-up the downloading time by parallelizing it.

-->
