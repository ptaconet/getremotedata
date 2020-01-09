#' @name getUrl_gpm
#' @aliases getUrl_gpm
#' @title Get URLs of GPM datasets
#' @description This function enables to retrieve OPeNDAP URLs of GPM products given a collection, a ROI, a time frame and a set of dimensions of interest.
#' @export
#'
#' @inheritParams getUrl_modis_vnp
#'
#' @inherit getUrl_modis_vnp return
#'
#' @details
#'
#' Argument \code{timeRange} can be provided either as a single date (e.g. \code{as.Date("2017-01-01"))} or time frame provided as two bounding dates ( e.g. \code{as.Date(c("2010-01-01","2010-01-30"))}) or as a POSIXlt single time or time range (e.g. "2010-01-01 18:00:00") for the half-hourly collection (GPM_3IMERGHH.06). If POSIXlt, times must be in UTC.
#'
#' Argument \code{optionals_opendap} is optional. This parameter is automatically calculated within the function if it is not provided. However, providing it optimizes the performances of the function (i.e. fasten the processing time).
#' It might be particularly useful to provide it if looping over the same ROI or dates is planned.
#' The parameter can be retrieved outside the function with the function \link[getRemoteData]{.getOpendapOptArguments_gpm}.
#'
#' @note
#' \itemize{
#' \item{NB1 :}{Before downloading some data, users should check which GPM collections have been implemented in the package, with the function \link[getRemoteData]{getAvailableDataSources}.}
#' \item{NB3 :}{The	NASA/JAXA OPeNDAP server where the GPM data are extracted from is located here : https://gpm1.gesdisc.eosdis.nasa.gov/opendap/}
#' }

#' @author Paul Taconet, IRD \email{paul.taconet@ird.fr}
#'
#' @family getUrl
#'
#' @examples
#'
#'\dontrun{
#'require(sf)
#'require(purrr)
#'
#' # Identify which collections are available and get details about each one
#' coll_available <- getRemoteData::getAvailableDataSources()
#' coll_available <- coll_available[which(coll_available$source %in% c("MODIS","VNP")),]
#'
#' # Set ROI and time range of interest
#' roi<-sf::st_read(system.file("extdata/roi_example.gpkg", package = "getRemoteData"),quiet=TRUE)
#' timeRange<-as.Date(c("2017-01-01","2017-01-30"))
#'
#'#' # Connect to EarthData servers
#' my.earthdata.username<-"username"
#' my.earthdata.pw<-"password"
#'
#' getRemoteData::login_earthdata(my.earthdata.username,my.earthdata.pw)
#'
#' # Retrieve the URLs to download GPM Daily precipitation final run (GPM_3IMERGDF.06) (band precipitationCal and precipitationCal_cnt)
#' df_data_to_dl<-getRemoteData::getUrl_gpm(
#' timeRange=timeRange,
#' roi=roi,
#' collection="GPM_3IMERGDF.06",
#' dimensions=c("precipitationCal","precipitationCal_cnt")
#' )
#'
#'# Set destination folder
#' df_data_to_dl$destfile<-file.path(getwd(),df_data_to_dl$name)
#'
#'# Download the data
#'res_dl<-getRemoteData::downloadData(df_data_to_dl,parallelDL=TRUE,data_source="earthdata")
#'
#'# Open the precipitationCal bands as a list of rasters
#'rasts_gpm_day<-purrr::map(res_dl$destfile,~getRemoteData::importData_gpm(.,"precipitationCal")) %>%
#' purrr::set_names(res_dl$name)
#'
#'}
#'

getUrl_gpm<-function(timeRange, # mandatory. either a time range (e.g. c(date_start,date_end) ) or a single date e.g. ( date_start ) / or a as.POSIXlt single date or time range (e.g. "2010-01-01 18:00:00")
                      roi, # either provide roi (sf point or polygon) or provide roiSpatialIndexBound. if roiSpatialIndexBound is not provided, it will be calculated from roi
                      collection, # mandatory
                      dimensions, # mandatory
                      optionals_opendap=NULL,
                      username=NULL, # EarthData user name
                      password=NULL # EarthData password
                      ){

  if(!is.null(username) || is.null(getOption("earthdata_login"))){
    login<-getRemoteData::login_earthdata(username,password)
  }

  # Check is the collection has been tested and validated
  getRemoteData::.testCollVal("GPM",collection)

  if(!is(timeRange,"Date") && !is(timeRange,"POSIXlt")){stop("Argument timeRange is not of class Date or POSIXlt")}

  OpenDAPServerUrl="https://gpm1.gesdisc.eosdis.nasa.gov/opendap/GPM_L3"
  SpatialOpenDAPXVectorName="lon"
  SpatialOpenDAPYVectorName="lat"

  # Retrieve info to build url
  if(collection=="GPM_3IMERGHH.06"){

    #times_gpm_hhourly<-seq(from=as.POSIXlt(paste0(this_date_hlc," ",hh_rainfall_hour_begin,":00:00")),to=as.POSIXlt(as.POSIXlt(paste0(this_date_hlc+1," ",hh_rainfall_hour_end,":00:00"))),by="30 min")
    timeRange=as.POSIXlt(timeRange,tz="GMT")

    datesToRetrieve<-seq(from=timeRange[2],to=timeRange[1],by="-30 min") %>%
      data.frame(stringsAsFactors = F) %>%
      purrr::set_names("date") %>%
      dplyr::mutate(date_character=as.character(as.Date(date))) %>%
      dplyr::mutate(year=format(date,'%Y')) %>%
      dplyr::mutate(month=format(date,'%m')) %>%
      dplyr::mutate(day=sprintf("%03d",lubridate::yday(date))) %>%
      dplyr::mutate(hour_start=paste0(sprintf("%02d",lubridate::hour(date)),sprintf("%02d",lubridate::minute(date)),sprintf("%02d",lubridate::second(date)))) %>%
      dplyr::mutate(hour_end=date+lubridate::minutes(29)+lubridate::seconds(59)) %>%
      dplyr::mutate(hour_end=paste0(sprintf("%02d",lubridate::hour(hour_end)),sprintf("%02d",lubridate::minute(hour_end)),sprintf("%02d",lubridate::second(hour_end)))) %>%
      dplyr::mutate(number_minutes_from_start_day=sprintf("%04d",difftime(date,as.POSIXlt(paste0(as.Date(date)," 00:00:00"),tz="GMT"),units="mins")))

    urls<-datesToRetrieve %>%
      dplyr::mutate(product_name=paste0("3B-HHR.MS.MRG.3IMERG.",gsub("-","",date_character),"-S",hour_start,"-E",hour_end,".",number_minutes_from_start_day,".V06B.HDF5.nc4")) %>%
      dplyr::mutate(url_product=paste(OpenDAPServerUrl,collection,year,day,product_name,sep="/"))

  } else if(collection %in% c("GPM_3IMERGDF.06","GPM_3IMERGDL.06")){

    if(collection=="GPM_3IMERGDL.06"){
      indicatif<-"-L"
    } else {
      indicatif<-NULL
    }

    timeRange=as.Date(timeRange,origin="1970-01-01")

    datesToRetrieve<-seq(timeRange[2],timeRange[1],-1) %>%
      data.frame(stringsAsFactors = F) %>%
      purrr::set_names("date") %>%
      dplyr::mutate(date_character=substr(date,1,10)) %>%
      dplyr::mutate(year=format(date,'%Y')) %>%
      dplyr::mutate(month=format(date,'%m'))

    urls<-datesToRetrieve %>%
      dplyr::mutate(product_name=paste0("3B-DAY",indicatif,".MS.MRG.3IMERG.",gsub("-","",date_character),"-S000000-E235959.V06.nc4.nc4")) %>%
      dplyr::mutate(url_product=paste(OpenDAPServerUrl,collection,year,month,product_name,sep="/"))

  } else if(collection=="GPM_3IMERGM.06"){

    timeRange=as.Date(timeRange,origin="1970-01-01")

    datesToRetrieve<-seq(timeRange[2],timeRange[1],-1) %>%
      lubridate::floor_date(x, unit = "month") %>%
      unique() %>%
      data.frame(stringsAsFactors = F) %>%
      purrr::set_names("date") %>%
      dplyr::mutate(date_character=substr(date,1,10)) %>%
      dplyr::mutate(year=format(date,'%Y')) %>%
      dplyr::mutate(month=format(date,'%m'))

    urls<-datesToRetrieve %>%
      dplyr::mutate(product_name=paste0("3B-MO.MS.MRG.3IMERG.",year,month,"01-S000000-E235959.",month,".V06B.HDF5.nc4")) %>%
      dplyr::mutate(url_product=paste(OpenDAPServerUrl,collection,year,product_name,sep="/"))

  }

  if(is.null(optionals_opendap)){
    optionals_opendap<-getRemoteData::.getOpendapOptArguments_gpm(roi,collection)
  }

  roiSpatialIndexBound<-optionals_opendap$roiSpatialIndexBound
  available_dimensions<-optionals_opendap$availableDimensions

  ## Check if the dimensions specified exist
  getRemoteData::.testDimVal(available_dimensions,dimensions)

  # Build URL to download data in NetCDF format

  dim<-dimensions %>%
    purrr::map(~paste0(.x,"[0:0][",roiSpatialIndexBound[3],":",roiSpatialIndexBound[4],"][",roiSpatialIndexBound[1],":",roiSpatialIndexBound[2],"],time[0:0],",SpatialOpenDAPYVectorName,"[",roiSpatialIndexBound[1],":",roiSpatialIndexBound[2],"],",SpatialOpenDAPXVectorName,"[",roiSpatialIndexBound[3],":",roiSpatialIndexBound[4],"]")) %>%
    unlist() %>%
    paste(collapse=",")

  table_urls<-urls %>%
    dplyr::mutate(url=paste0(url_product,"?",dim)) %>%
    dplyr::mutate(name=paste0(collection,product_name))

  res<-data.frame(time_start=table_urls$date_character,name=table_urls$name,url=table_urls$url,stringsAsFactors = F)

  return(res)
}
