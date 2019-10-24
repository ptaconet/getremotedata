#' @name getData_smap
#' @aliases getData_smap
#' @title Download Soil Moisture Active Passive (SMAP) time series data
#' @description This function enables to retrieve URLs of SMAP datasets for a given ROI and time frame, and eventually download the data
#' @export
#'
#' @param timeRange Date(s) of interest. Mandatory. See Details for addition information on how to provide the dates.
#' @param roi sf POINT or POLYGON. The region of interest in EPSG 4326
#' @param collection The SMAP collection of interest
#' @param dimensions string vector. Names of the dimensions to retrieve for the SMAP collection of interest.
#' @param download logical. Download data ?
#' @param destFolder string. Mandatory if \code{download} is set to TRUE. The destination folder (i.e. folder where the data will be downloaded)
#' @param OpenDAPXVector numeric vector. Optional. The OpenDAP X (longitude) dimension vector.
#' @param OpenDAPYVector numeric vector. Optional. The OpenDAP Y (latitude) dimension vector.
#' @param roiSpatialIndexBound numeric vector. Optional.
#' @param username string. EarthData username
#' @param password string. EarthData password
#'
#' @return a data.frame with 3 columns :
#'  \itemize{
#'  \item{"name": }{Names (unique identifiers) of each dataset }
#'  \item{"url": }{URL to download the dataset}
#'  \item{"destfile": }{Local destination file}
#'  }
#'
#' If \code{download} is set to TRUE, the data are downloaded to \code{destFolder}
#'
#' @details
#'
#' Argument \code{timeRange} can be provided either as a single date (e.g. \code{as.Date("2017-01-01"))} or time frame provided as two bounding dates ( e.g. \code{as.Date(c("2010-01-01","2010-01-30"))}) or as a POSIXlt single time or time range (e.g. "2010-01-01 18:00:00") for the half-hourly collection (GPM_3IMERGHH.06). If POSIXlt, times must be in UTC.
#' Arguments \code{OpenDAPOpenDAPXVector}, \code{OpenDAPOpenDAPYVector} and \code{roiSpatialIndexBound} are optional. They are automatically calculated from the other input parameters if not provided. However, providing them optimizes the performances (i.e. fasten the processing time).
#' It might be particularly useful to provide them when looping with the function over the same ROI.
#'
#' @author Paul Taconet, IRD \email{paul.taconet@ird.fr}
#'
#' @family getData
#'
#' @import purrr sf dplyr lubridate
#'
#' @examples
#'
#' # Read ROI as sf object
#' roi=sf::st_read(system.file("extdata/ROI_example.kml", package = "getRemoteData"),quiet=T)
#' timeRange<-c("2017-01-01","2017-01-30") %>% as.Date()
#'
#' \dontrun{
#' getData_smap(timeRange=timeRange,
#' roi=roi,
#' collection="SPL3SMP_E.002",
#' dimensions=c("Soil_Moisture_Retrieval_Data_AM_soil_moisture"),
#' username="my.earthdata.username",
#' password="my.earthdata.pw",
#' download=FALSE
#' )
#'}
#'


getData_smap<-function(timeRange=as.Date(c("2017-01-01","2017-01-30")), # mandatory. either a time range (e.g. c(date_start,date_end) ) or a single date e.g. ( date_start ) / or a as.POSIXlt single date or time range (e.g. "2010-01-01 18:00:00")
                      roi=st_read(system.file("extdata/ROI_example.kml", package = "getRemoteData"),quiet=T), # either provide roi (sf point or polygon) or provide roiSpatialIndexBound. if roiSpatialIndexBound is not provided, it will be calculated from roi
                      collection="SPL3SMP_E.003", # mandatory
                      dimensions=c("Soil_Moisture_Retrieval_Data_AM_soil_moisture","Soil_Moisture_Retrieval_Data_AM_retrieval_qual_flag","Soil_Moisture_Retrieval_Data_PM_soil_moisture_pm","Soil_Moisture_Retrieval_Data_PM_retrieval_qual_flag_pm"), # mandatory
                      OpenDAPXVector=NULL, # optional. providing it will fasten the processing time. if not provided it will be calculated automatically
                      OpenDAPYVector=NULL, # optional. providing it will fasten the processing time. if not provided it will be calculated automatically
                      roiSpatialIndexBound=NULL, # optional. providing it will fasten the processing time. if not provided it will be calculated automatically
                      username=NULL, # EarthData user name
                      password=NULL, # EarthData password
                      download=FALSE, # TRUE will download the file and return a dataframe with : the URL, the path to the output file, a boolean wether the dataset was properly downloaded or not. FALSE will return a list with the URL only
                      destFolder=getwd(),
                      ...){

  OpenDAPServerUrl="https://n5eil02u.ecs.nsidc.org/opendap/SMAP"
  SpatialOpenDAPXVectorName="Soil_Moisture_Retrieval_Data_AM_longitude"
  SpatialOpenDAPYVectorName="Soil_Moisture_Retrieval_Data_AM_latitude"

  timeRange=as.Date(timeRange,origin="1970-01-01")

  datesToRetrieve<-seq(timeRange[2],timeRange[1],-1) %>%
      data.frame(stringsAsFactors = F) %>%
      set_names("date") %>%
      mutate(date_character=substr(date,1,10)) %>%
      mutate(year=format(date,'%Y')) %>%
      mutate(month=format(date,'%m')) %>%
    mutate(day=format(date,'%d'))

    urls<-datesToRetrieve %>%
      mutate(product_name=paste0("SMAP_L3_SM_P_E_",gsub("-","",date_character),"_R16510_001.h5")) %>%
      mutate(url_product=paste(OpenDAPServerUrl,collection,gsub("-",".",date_character),product_name,sep="/"))


  # To retrieve spatial indices
  OpenDAPURL<-"https://n5eil02u.ecs.nsidc.org/opendap/hyrax/SMAP/SPL4CMDL.004/2016.01.06/SMAP_L4_C_mdl_20160106T000000_Vv4040_001.h5"
  # Calculate OpenDAPXVector if not provided
  if(is.null(OpenDAPXVector) & is.null(roiSpatialIndexBound)){
    OpenDAPXVector<-getRemoteData::getOpenDAPvector(OpenDAPURL,"x")
  }
  # Calculate OpenDAPYVector if not provided
  if(is.null(OpenDAPYVector) & is.null(roiSpatialIndexBound)){
    OpenDAPYVector<-getRemoteData::getOpenDAPvector(OpenDAPURL,"y")
  }
  # Calculate roiSpatialIndexBound if not provided
  if(is.null(roiSpatialIndexBound)){
    roi_bbox<-sf::st_bbox(st_transform(roi,6933))
    Opendap_minLon<-which.min(abs(OpenDAPXVector-roi_bbox$xmin))-2
    Opendap_maxLon<-which.min(abs(OpenDAPXVector-roi_bbox$xmax))+2
    Opendap_minLat<-which.min(abs(OpenDAPYVector-roi_bbox$ymin))+2
    Opendap_maxLat<-which.min(abs(OpenDAPYVector-roi_bbox$ymax))-2
    roiSpatialIndexBound<-c(Opendap_minLat,Opendap_maxLat,Opendap_minLon,Opendap_maxLon)
  }

  # Build URL to download data in NetCDF format

  dim <- c(dimensions,"Soil_Moisture_Retrieval_Data_AM_longitude","Soil_Moisture_Retrieval_Data_AM_latitude","Soil_Moisture_Retrieval_Data_PM_longitude_pm","Soil_Moisture_Retrieval_Data_PM_latitude_pm") %>%
    map(~paste0(.x,"[",roiSpatialIndexBound[2],":1:",roiSpatialIndexBound[1],"][",roiSpatialIndexBound[3],":1:",roiSpatialIndexBound[4],"]")) %>%
       unlist() %>%
     paste(collapse=",")

  table_urls<-urls %>%
    mutate(url=paste0(url_product,".nc4","?",dim)) %>%
    mutate(destfile=file.path(destFolder,paste0(collection,product_name,".nc4"))) #%>%
  #mutate(names=)

  urls<-table_urls$url

  destfiles<-table_urls$destfile

  names<-table_urls$product_name

  res<-data.frame(name=names,url=urls,destfile=destfiles,stringsAsFactors = F)

  if (download){
    cat("Downloading the data...\n")
    res<-getRemoteData::downloadData(res,username,password, ...)
  }

  return(res)
}
