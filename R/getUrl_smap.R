#' @name getUrl_smap
#' @aliases getUrl_smap
#' @title Query and download SMAP collections
#' @description This function enables to retrieve URLs of SMAP datasets for a given ROI and time frame, and eventually download the data
#' @export
#'
#' @inheritParams getUrl_modis_vnp
#'
#' @inherit getUrl_modis_vnp return
#'
#' @details
#'
#' Argument \code{timeRange} can be provided either as a single date (e.g. \code{as.Date("2017-01-01"))} or time frame provided as two bounding dates ( e.g. \code{as.Date(c("2010-01-01","2010-01-30"))}) or as a POSIXlt single time or time range (e.g. "2010-01-01 18:00:00") for the half-hourly collection (GPM_3IMERGHH.06). If POSIXlt, times must be in UTC.
#' Arguments \code{OpenDAPOpenDAPXVector}, \code{OpenDAPOpenDAPYVector} and \code{roiSpatialIndexBound} are optional. They are automatically calculated from the other input parameters if not provided. However, providing them optimizes the performances (i.e. fasten the processing time).
#' It might be particularly useful to provide them when looping with the function over the same ROI.
#'
#' @author Paul Taconet, IRD \email{paul.taconet@ird.fr}
#'
#' @family getUrl
#'
#' @examples
#'
#' # Read ROI as sf object
#' roi=sf::st_read(system.file("extdata/ROI_example.kml", package = "getRemoteData"),quiet=TRUE)
#' timeRange<-c("2017-01-01","2017-01-30") %>% as.Date()
#'
#' \dontrun{
#' getUrl_smap(timeRange=timeRange,
#' roi=roi,
#' collection="SPL3SMP_E.003",
#' dimensions=c("Soil_Moisture_Retrieval_Data_AM_soil_moisture","Soil_Moisture_Retrieval_Data_AM_retrieval_qual_flag","Soil_Moisture_Retrieval_Data_PM_soil_moisture_pm","Soil_Moisture_Retrieval_Data_PM_retrieval_qual_flag_pm"),
#' username="my.earthdata.username",
#' password="my.earthdata.pw",
#' download=FALSE
#' )
#'}
#'


getUrl_smap<-function(timeRange, # mandatory. either a time range (e.g. c(date_start,date_end) ) or a single date e.g. ( date_start ) / or a as.POSIXlt single date or time range (e.g. "2010-01-01 18:00:00")
                      roi, # either provide roi (sf point or polygon) or provide roiSpatialIndexBound. if roiSpatialIndexBound is not provided, it will be calculated from roi
                      collection, # mandatory
                      dimensions, # mandatory
                      optionals_opendap=NULL,
                      username=NULL, # EarthData username
                      password=NULL # EarthData password
                      ){

  if(!is.null(username) || is.null(getOption("earthdata_login"))){
    login<-getRemoteData::login_earthdata(username,password)
  }

  # Check is the collection has been tested and validated
  getRemoteData::.testCollVal("SMAP",collection)

  if(!is(timeRange,"Date")){stop("Argument timeRange is not of class Date")}

  OpenDAPServerUrl="https://n5eil02u.ecs.nsidc.org/opendap/SMAP"
  SpatialOpenDAPXVectorName="Soil_Moisture_Retrieval_Data_AM_longitude"
  SpatialOpenDAPYVectorName="Soil_Moisture_Retrieval_Data_AM_latitude"

  timeRange=as.Date(timeRange,origin="1970-01-01")

  datesToRetrieve<-seq(timeRange[2],timeRange[1],-1) %>%
      data.frame(stringsAsFactors = F) %>%
      purrr::set_names("date") %>%
      dplyr::mutate(date_character=substr(date,1,10)) %>%
      dplyr::mutate(year=format(date,'%Y')) %>%
      dplyr::mutate(month=format(date,'%m')) %>%
      dplyr::mutate(day=format(date,'%d'))

  if(collection=="SPL3SMP_E.003"){
    urls<-datesToRetrieve %>%
      dplyr::mutate(product_name=paste0("SMAP_L3_SM_P_E_",gsub("-","",date_character),"_R16510_001.h5")) %>%
      dplyr::mutate(url_product=paste(OpenDAPServerUrl,collection,gsub("-",".",date_character),product_name,sep="/"))
  }

  if(is.null(optionals_opendap)){
      optionals_opendap<-getRemoteData::.getOpendapOptArguments_smap(roi)
  }

  roiSpatialIndexBound<-optionals_opendap$roiSpatialIndexBound

  # Build URL to download data in NetCDF format
  dim <- c(dimensions,"Soil_Moisture_Retrieval_Data_AM_longitude","Soil_Moisture_Retrieval_Data_AM_latitude","Soil_Moisture_Retrieval_Data_PM_longitude_pm","Soil_Moisture_Retrieval_Data_PM_latitude_pm") %>%
    purrr::map(~paste0(.x,"[",roiSpatialIndexBound[2],":1:",roiSpatialIndexBound[1],"][",roiSpatialIndexBound[3],":1:",roiSpatialIndexBound[4],"]")) %>%
       unlist() %>%
     paste(collapse=",")

  table_urls<-urls %>%
    dplyr::mutate(url=paste0(url_product,".nc4","?",dim)) %>%
    dplyr::mutate(name=paste0(collection,product_name,".nc4"))

  res<-data.frame(time_start=table_urls$date_character,name=table_urls$name,url=table_urls$url,stringsAsFactors = F)

  return(res)
}
