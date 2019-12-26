#' @name getUrl_modis_vnp
#' @aliases getUrl_modis_vnp
#' @title Query MODIS or VNP collections
#' @description This function enables to retrieve OPeNDAP URLs of MODIS or VNP products given a collection, a ROI, a time frame and a set of dimensions of interest.
#' @export
#'
#' @param timeRange Date(s) of interest (single date/datetime or time frame) (see details)
#' @param roi sf POINT or POLYGON. Region of interest (EPSG 4326)
#' @param collection string. Collection of interest
#' @param dimensions string vector. Names of the dimensions to retrieve for the collection of interest
#' @param modisTile string. optional. The MODIS tile identifier
#' @param optionals_opendap list of optional arguments (see details)
#' @param username string. EarthData username
#' @param password string. EarthData password
#' @param single_ncfile boolean. Get the data as a single netcdf file encompassing the whole time frame (TRUE) or as multiple files (1 for each time step) (FALSE). Default to TRUE
#'
#' @return a data.frame with one row for each dataset and 3 columns  :
#'  \itemize{
#'  \item{*time_start*: }{Start Date/time for the dataset}
#'  \item{*name*: }{An indicative name for the dataset}
#'  \item{*url*: }{URL of the dataset}
#'  }
#'
#' @details
#'
#' Date(s) of interest (argument \code{timeRange}) must be provided either a single date (e.g. \code{as.Date("2017-01-01"))} or time frame provided with two bounding dates ( e.g. \code{as.Date(c("2010-01-01","2010-01-30"))})
#'
#' Arguments \code{modisTile} and \code{optionals_opendap} are optional. These parameters are automatically calculated within the function if they are not provided. However, providing them optimizes the performances of the function (i.e. fasten the processing time).
#' It might be particularly useful to provide them if looping over the same ROI or dates is planned.
#' The parameters can be retrieved outside the function respectively with the functions \link[getRemoteData]{getMODIStileNames} and \link[getRemoteData]{getOpendapOptArguments_modis_vnp}.
#'
#' @author Paul Taconet, IRD \email{paul.taconet@ird.fr}
#'
#' @note
#' \itemize{
#' \item{NB1 :}{Before downloading some data, users should check which MODIS/VNP collections have been implemented in the package, with the function \link[getRemoteData]{getAvailableDataSources}.}
#' \item{NB2 :}{Currently, downloading data over a ROI that covers multiple MODIS/VNP tiles is not enabled.}
#' \item{NB3 :}{The NASA/USGS OPeNDAP server where the MODIS and VNP data are extracted from is located here : https://opendap.cr.usgs.gov/opendap/hyrax}
#' }
#'
#' @family getUrl
#'
#' @examples
#'
#'require(sf)
#'require(purrr)
#'require(tidyverse)
#'
#' # Identify which collections are available and get details about each one
#' coll_available<-getRemoteData::getAvailableDataSources() %>%
#' filter(source %in% c("MODIS","VNP"))
#'
#' # Set ROI and time range of interest
#' roi<-sf::st_read(system.file("extdata/ROI_example.kml", package = "getRemoteData"),quiet=TRUE)
#' timeRange<-as.Date(c("2017-01-01","2017-01-30"))
#'
#'#' # Connect to EarthData servers
#' my.earthdata.username<-"username"
#' my.earthdata.pw<-"password"
#'
#' getRemoteData::login_earthdata(my.earthdata.username,my.earthdata.pw)
#'
#' ### Retrieve the URLs to download MODIS LST Daily (MOD11A1.006) Day + Night bands (LST_Day_1km,LST_Night_1km) for the whole time frame by two means :
#' 1) separate NetCDF files (1 for each date) with the parameter single_ncfile set to FALSE
#' 2) one single NetCDF file encompassing the whole time frame with the parameter single_ncfile set to TRUE
#'
#'
#' ## 1) separate NetCDF files (1 for each date) with the parameter single_ncfile set to FALSE
#' \dontrun{
#' df_data_to_dl<-getRemoteData::getUrl_modis_vnp(
#' timeRange=timeRange,
#' roi=roi,
#' collection="MOD11A1.006",
#' dimensions=c("LST_Day_1km","LST_Night_1km"),
#' single_ncfile=FALSE
#' )
#'
#'# Set destination folder
#' df_data_to_dl$destfile<-file.path(getwd(),df_data_to_dl$name)
#'
#'# Download the data
#'res_dl<-getRemoteData::downloadData(df_data_to_dl,parallelDL=TRUE,data_source="earthdata")
#'
#'# Open the LST_Day_1km bands as a list of rasters
#'rasts_modis_lst_day<-purrr::map(res_dl$destfile,~getRemoteData::prepareData_modis_vnp(.,"LST_Day_1km")) %>%
#' purrr::set_names(res_dl$name)
#'
#' # or :
#'
#' # Open all the datasets (all dates and bands) as a unique stars object
#'stars_modis = stars::read_stars(res_dl$destfile, quiet = TRUE)
#'
#' ## 2) one single NetCDF file encompassing the whole time frame with the parameter single_ncfile set to TRUE
#'
#' df_data_to_dl<-getRemoteData::getUrl_modis_vnp(
#' timeRange=timeRange,
#' roi=roi,
#' collection="MOD11A1.006",
#' dimensions=c("LST_Day_1km","LST_Night_1km"),
#' single_ncfile=TRUE
#' )
#'
#'# Download the data
#'res_dl<-getRemoteData::downloadData(df_data_to_dl,parallelDL=TRUE,data_source="earthdata")
#'
#'# Open the data as a stars object
#'require(stars)
#'stars_modis = stars::read_stars(res_dl$destfile, quiet = TRUE)
#'
#'
#'}

getUrl_modis_vnp<-function(timeRange, # mandatory. either a time range (e.g. c(date_start,date_end) ) or a single date e.g. ( date_start )
                        roi,
                        collection, # mandatory
                        dimensions, # mandatory
                        modisTile=NULL,
                        optionals_opendap=NULL, #list(OpenDAPtimeVector=NULL,OpenDAPXVector=NULL,OpenDAPYVector=NULL,roiSpatialIndexBound=NULL)
                        username=NULL, # EarthData username
                        password=NULL, # EarthData password
                        single_ncfile=TRUE
                        ){

  ### Checks
  # connection to earthdata
  if(!is.null(username) || is.null(getOption("earthdata_login"))){
    login<-getRemoteData::login_earthdata(username,password)
  }

  # Check if the collection has been tested and validated
  getRemoteData::.testCollVal(c("MODIS","VNP"),collection)

  if(!is(timeRange,"Date")){stop("Argument timeRange is not of class Date")}

  if(!is.logical(single_ncfile)){stop("Argument single_ncfile is not logical")}

  OpenDAPServerUrl="https://opendap.cr.usgs.gov/opendap/hyrax"
  OpenDAPtimeVectorName="time"
  SpatialOpenDAPXVectorName="XDim"
  SpatialOpenDAPYVectorName="YDim"

  if (collection %in% c("MOD11A1.006","MYD11A1.006")){
    gridDimensionName<-"MODIS_Grid_Daily_1km_LST_eos_cf_projection"
  } else if (collection %in% c("MOD11A2.006","MYD11A2.006")){
      gridDimensionName<-"MODIS_Grid_8Day_1km_LST_eos_cf_projection"
  } else if (collection %in% c("MOD13Q1.006","MYD13Q1.006")){
    gridDimensionName<-"MODIS_Grid_16DAY_250m_500m_VI_eos_cf_projection"
  } else if (collection %in% c("MOD16A2.006","MYD16A2.006")){
    gridDimensionName<-"MOD_Grid_MOD16A2_eos_cf_projection"
  } else {
    gridDimensionName<-"eos_cf_projection"
  }

  if(is.null(modisTile)){
    modisTile<-getRemoteData::getMODIStileNames(roi)
  }

  if(is.null(optionals_opendap)){
    optionals_opendap<-getRemoteData::.getOpendapOptArguments_modis_vnp(roi,collection,modisTile=modisTile)
  }

  OpenDAPtimeVector<-optionals_opendap$OpenDAPtimeVector
  roiSpatialIndexBound<-optionals_opendap$roiSpatialIndexBound

  # Get openDAP time indices for the time frame of interest
  timeRange<-as.Date(timeRange,origin="1970-01-01")
  if (length(timeRange)==1){
    timeRange=c(timeRange,timeRange)
  }

  revisit_time<-OpenDAPtimeVector[2]-OpenDAPtimeVector[1]

  timeIndices_of_interest<-seq(timeRange[2],timeRange[1],-revisit_time) %>%
    purrr::map(~getRemoteData::.getOpenDAPtimeIndex_modis(.,OpenDAPtimeVector)) %>%
    do.call(rbind.data.frame,.) %>%
    purrr::set_names("ideal_date","date_closest_to_ideal_date","days_sep_from_ideal_date","index_opendap_closest_to_date") %>%
    dplyr::mutate(ideal_date=as.Date(ideal_date,origin="1970-01-01")) %>%
    dplyr::mutate(date_closest_to_ideal_date=as.Date(date_closest_to_ideal_date,origin="1970-01-01"))  %>%
    dplyr::mutate(name=paste0(collection,".",lubridate::year(date_closest_to_ideal_date),sprintf("%03d",lubridate::yday(date_closest_to_ideal_date)),".",modisTile,".nc4"))

  # Build URL to download data in NetCDF format

  if(single_ncfile){ # download data in a single netcdf file
  timeIndex<-c(min(timeIndices_of_interest$index_opendap_closest_to_date),max(timeIndices_of_interest$index_opendap_closest_to_date))
  url<-getRemoteData::.getOpenDapURL_dimensions2(dimensions,timeIndex,roiSpatialIndexBound,OpenDAPtimeVectorName,SpatialOpenDAPXVectorName,SpatialOpenDAPYVectorName)
  url<-paste0(OpenDAPServerUrl,"/",collection,"/",modisTile,".ncml.nc4?",gridDimensionName,",",url)

  name=paste0(collection,".",lubridate::year(min(timeIndices_of_interest$date_closest_to_ideal_date)),sprintf("%03d",lubridate::yday(min(timeIndices_of_interest$date_closest_to_ideal_date))),"_",lubridate::year(max(timeIndices_of_interest$date_closest_to_ideal_date)),sprintf("%03d",lubridate::yday(max(timeIndices_of_interest$date_closest_to_ideal_date))),".",modisTile,".nc4")

  res<-data.frame(time_start=min(timeIndices_of_interest$date_closest_to_ideal_date),name=name,url=url,stringsAsFactors = F)
  } else { # download data in multiple netcdf files (1/each time frame)
  table_urls<-timeIndices_of_interest %>%
    dplyr::mutate(dimensions_url=map(.x=index_opendap_closest_to_date,.f=~getRemoteData::.getOpenDapURL_dimensions(dimensions,.x,roiSpatialIndexBound,OpenDAPtimeVectorName,SpatialOpenDAPXVectorName,SpatialOpenDAPYVectorName))) %>%
    dplyr::mutate(url=paste0(OpenDAPServerUrl,"/",collection,"/",modisTile,".ncml.nc4?",gridDimensionName,",",dimensions_url))

  res<-data.frame(time_start=table_urls$date_closest_to_ideal_date,name=table_urls$name,url=table_urls$url,stringsAsFactors = F)
  }

  return(res)

}

