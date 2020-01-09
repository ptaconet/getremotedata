#' @name getUrl_smap
#' @aliases getUrl_smap
#' @title Get URLs of SMAP datasets
#' @description This function enables to retrieve URLs of SMAP datasets for a given ROI and time frame, and eventually download the data
#' @export
#'
#' @inheritParams getUrl_modis_vnp
#'
#' @inherit getUrl_modis_vnp return
#'
#' @inherit getUrl_modis_vnp details
#'
#' @author Paul Taconet, IRD \email{paul.taconet@ird.fr}
#'
#' @family getUrl
#'
#' @note
#' \itemize{
#' \item{NB1 :}{Before downloading some data, users should check which GPM collections have been implemented in the package, with the function \link[getRemoteData]{getAvailableDataSources}.}
#' \item{NB2 :}{The	NASA OPeNDAP server where the GPM data are extracted from is located here : https://n5eil02u.ecs.nsidc.org/opendap/SMAP/}
#' }
#'
#' @examples
#'
#' \dontrun{
#'require(sf)
#'require(purrr)
#'
#' # Identify which collections are available and get details about each one
#' coll_available <- getRemoteData::getAvailableDataSources()
#' coll_available <- coll_available[which(coll_available$source=="SMAP"),]
#'
#' # Set ROI and time range of interest
#' roi<-sf::st_read(system.file("extdata/roi_example.gpkg", package = "getRemoteData"),quiet=TRUE)
#' timeRange<-as.Date(c("2017-01-01","2017-01-30"))
#'
#' # Connect to EarthData servers
#' my.earthdata.username<-"username"
#' my.earthdata.pw<-"password"
#'
#' getRemoteData::login_earthdata(my.earthdata.username,my.earthdata.pw)
#'
#' ### Retrieve the URLs to download SMAP Enhanced L3 Radiometer Global Daily 9 km EASE-Grid Soil Moisture, Version 3	(bands are specified in the parameters of the function) :
#'
#' df_data_to_dl<-getRemoteData::getUrl_smap(
#' timeRange=timeRange,
#' roi=roi,
#' collection="SPL3SMP_E.003",
#' dimensions=c("Soil_Moisture_Retrieval_Data_AM_soil_moisture","Soil_Moisture_Retrieval_Data_AM_retrieval_qual_flag","Soil_Moisture_Retrieval_Data_PM_soil_moisture_pm","Soil_Moisture_Retrieval_Data_PM_retrieval_qual_flag_pm")
#' )
#'
#'# Set destination folder
#' df_data_to_dl$destfile<-file.path(getwd(),df_data_to_dl$name)
#'
#'# Download the data
#'res_dl<-getRemoteData::downloadData(df_data_to_dl,parallelDL=TRUE,data_source="earthdata")
#'
#'# Open the Soil_Moisture_Retrieval_Data_AM_soil_moisture bands as a list of rasters
#'
#' opendapOptArguments<-getRemoteData::.getOpendapOptArguments_smap(roi = roi, collection = "SPL3SMP_E.003")
#' minLon<-opendapOptArguments$roiSpatialBound[[3]]
#' minLat<-opendapOptArguments$roiSpatialBound[[1]]
#' maxLon<-opendapOptArguments$roiSpatialBound[[4]]
#' maxLat<-opendapOptArguments$roiSpatialBound[[2]]
#' rasts_smap<-purrr::map(res_dl$destfile,~getRemoteData::importData_smap(.,"Soil_Moisture_Retrieval_Data_AM_soil_moisture",minLon,minLat,maxLon,maxLat)) %>%
#'  purrr::set_names(res_dl$name)
#'
#' # plot the first date :
#' raster::plot(rasts_smap[[1]])
#'
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
      optionals_opendap<-getRemoteData::.getOpendapOptArguments_smap(roi,collection)
  }

  roiSpatialIndexBound<-optionals_opendap$roiSpatialIndexBound
  available_dimensions<-optionals_opendap$availableDimensions

  ## Check if the dimensions specified exist
  getRemoteData::.testDimVal(available_dimensions,dimensions)

  # Build URL to download data in NetCDF format
  dim <- c(dimensions,"Soil_Moisture_Retrieval_Data_AM_longitude","Soil_Moisture_Retrieval_Data_AM_latitude","Soil_Moisture_Retrieval_Data_PM_longitude_pm","Soil_Moisture_Retrieval_Data_PM_latitude_pm") %>%
    purrr::map(~paste0(.x,"[",roiSpatialIndexBound[2],":1:",roiSpatialIndexBound[1],"][",roiSpatialIndexBound[3],":1:",roiSpatialIndexBound[4],"]")) %>%
       unlist() %>%
     paste(collapse=",")

  table_urls<-urls %>%
    dplyr::mutate(url=paste0(url_product,".nc4","?",dim)) %>%
    dplyr::mutate(name=paste0(product_name,".nc4"))

  res<-data.frame(time_start=table_urls$date_character,name=table_urls$name,url=table_urls$url,stringsAsFactors = F)

  return(res)
}
