#' @name getData_gpm
#' @aliases getData_gpm
#' @title Download Global Precipitation Measurement time series data
#' @description This function enables to retrieve URLs of GPM datasets for a given ROI and time frame, and eventually download the data
#' @export
#'
#' @param timeRange Date(s) of interest. Mandatory. See Details for addition information on how to provide the dates.
#' @param roi sf POINT or POLYGON. The region of interest in EPSG 4326
#' @param collection The GPM collection of interest
#' @param dimensions string vector. Names of the dimensions to retrieve for the GPM collection of interest.
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
#' @import tidyverse sf lubridate
#'
#' @examples
#'
#' # Read ROI as sf object
#' roi=sf::st_read(system.file("extdata/ROI_example.kml", package = "getRemoteData"),quiet=T)
#' timeRange<-c("2017-01-01","2017-01-30") %>% as.Date()
#'
#' \dontrun{
#' getData_gpm(timeRange=timeRange,
#' roi=roi,
#' collection="GPM_3IMERGDF.06",
#' dimensions=c("precipitationCal"),
#' username="my.earthdata.username",
#' password="my.earthdata.pw",
#' download=FALSE
#' )
#'}
#'


getData_gpm<-function(timeRange=as.Date(c("2017-01-01","2017-01-30")), # mandatory. either a time range (e.g. c(date_start,date_end) ) or a single date e.g. ( date_start ) / or a as.POSIXlt single date or time range (e.g. "2010-01-01 18:00:00")
                      roi=st_read(system.file("extdata/ROI_example.kml", package = "getRemoteData"),quiet=T), # either provide roi (sf point or polygon) or provide roiSpatialIndexBound. if roiSpatialIndexBound is not provided, it will be calculated from roi
                      collection="GPM_3IMERGDF.06", # mandatory
                      dimensions=c("precipitationCal"), # mandatory
                      OpenDAPXVector=NULL, # optional. providing it will fasten the processing time. if not provided it will be calculated automatically
                      OpenDAPYVector=NULL, # optional. providing it will fasten the processing time. if not provided it will be calculated automatically
                      roiSpatialIndexBound=NULL, # optional. providing it will fasten the processing time. if not provided it will be calculated automatically
                      username=NULL, # EarthData user name
                      password=NULL, # EarthData password
                      download=FALSE, # TRUE will download the file and return a dataframe with : the URL, the path to the output file, a boolean wether the dataset was properly downloaded or not. FALSE will return a list with the URL only
                      destFolder=getwd(),
                      ...){

  OpenDAPServerUrl="https://gpm1.gesdisc.eosdis.nasa.gov/opendap/GPM_L3"
  SpatialOpenDAPXVectorName="lon"
  SpatialOpenDAPYVectorName="lat"

  # Retrieve info to build url
  if(collection=="GPM_3IMERGHH.06"){

    #times_gpm_hhourly<-seq(from=as.POSIXlt(paste0(this_date_hlc," ",hh_rainfall_hour_begin,":00:00")),to=as.POSIXlt(as.POSIXlt(paste0(this_date_hlc+1," ",hh_rainfall_hour_end,":00:00"))),by="30 min")
    timeRange=as.POSIXlt(timeRange,tz="GMT")

    datesToRetrieve<-seq(from=timeRange[2],to=timeRange[1],by="-30 min") %>%
      data.frame(stringsAsFactors = F) %>%
      set_names("date") %>%
      mutate(date_character=as.character(as.Date(date))) %>%
      mutate(year=format(date,'%Y')) %>%
      mutate(month=format(date,'%m')) %>%
      mutate(day=sprintf("%03d",lubridate::yday(date))) %>%
      mutate(hour_start=paste0(sprintf("%02d",hour(date)),sprintf("%02d",minute(date)),sprintf("%02d",second(date)))) %>%
      mutate(hour_end=date+minutes(29)+seconds(59)) %>%
      mutate(hour_end=paste0(sprintf("%02d",hour(hour_end)),sprintf("%02d",minute(hour_end)),sprintf("%02d",second(hour_end)))) %>%
      mutate(number_minutes_from_start_day=sprintf("%04d",difftime(date,as.POSIXlt(paste0(as.Date(date)," 00:00:00"),tz="GMT"),units="mins")))

    urls<-datesToRetrieve %>%
      mutate(product_name=paste0("3B-HHR.MS.MRG.3IMERG.",gsub("-","",date_character),"-S",hour_start,"-E",hour_end,".",number_minutes_from_start_day,".V06B.HDF5")) %>%
      mutate(url_product=paste(OpenDAPServerUrl,collection,year,day,product_name,sep="/"))

  } else if(collection=="GPM_3IMERGDF.06"){

    timeRange=as.Date(timeRange,origin="1970-01-01")

    datesToRetrieve<-seq(timeRange[2],timeRange[1],-1) %>%
      data.frame(stringsAsFactors = F) %>%
      set_names("date") %>%
      mutate(date_character=substr(date,1,10)) %>%
      mutate(year=format(date,'%Y')) %>%
      mutate(month=format(date,'%m'))

    urls<-datesToRetrieve %>%
      mutate(product_name=paste0("3B-DAY.MS.MRG.3IMERG.",gsub("-","",date_character),"-S000000-E235959.V06.nc4")) %>%
      mutate(url_product=paste(OpenDAPServerUrl,collection,year,month,product_name,sep="/"))

  } else if(collection=="GPM_3IMERGM.06"){

    timeRange=as.Date(timeRange,origin="1970-01-01")

    datesToRetrieve<-seq(timeRange[2],timeRange[1],-1) %>%
      lubridate::floor_date(x, unit = "month") %>%
      unique() %>%
      data.frame(stringsAsFactors = F) %>%
      set_names("date") %>%
      mutate(date_character=substr(date,1,10)) %>%
      mutate(year=format(date,'%Y')) %>%
      mutate(month=format(date,'%m'))

    urls<-datesToRetrieve %>%
      mutate(product_name=paste0("3B-MO.MS.MRG.3IMERG.",year,month,"01-S000000-E235959.",month,".V06B.HDF5")) %>%
      mutate(url_product=paste(OpenDAPServerUrl,collection,year,product_name,sep="/"))
  }

  # To retrieve spatial indices
  OpenDAPURL<-urls$url_product[1]
  # Calculate OpenDAPXVector if not provided
  if(is.null(OpenDAPXVector) & is.null(roiSpatialIndexBound)){
    OpenDAPXVector<-getRemoteData::getOpenDAPvector(OpenDAPURL,SpatialOpenDAPXVectorName)
  }
  # Calculate OpenDAPYVector if not provided
  if(is.null(OpenDAPYVector) & is.null(roiSpatialIndexBound)){
    OpenDAPYVector<-getRemoteData::getOpenDAPvector(OpenDAPURL,SpatialOpenDAPYVectorName)
  }
  # Calculate roiSpatialIndexBound if not provided
  if(is.null(roiSpatialIndexBound)){
    roi_bbox<-sf::st_bbox(st_transform(roi,4326))
    Opendap_minLon<-which.min(abs(OpenDAPXVector-roi_bbox$xmin))-4
    Opendap_maxLon<-which.min(abs(OpenDAPXVector-roi_bbox$xmax))+4
    Opendap_minLat<-which.min(abs(OpenDAPYVector-roi_bbox$ymin))-4
    Opendap_maxLat<-which.min(abs(OpenDAPYVector-roi_bbox$ymax))+4
    roiSpatialIndexBound<-c(Opendap_minLat,Opendap_maxLat,Opendap_minLon,Opendap_maxLon)
  }

  # Build URL to download data in NetCDF format

  dim<-dimensions %>%
    map(~paste0(.x,"[0:0][",roiSpatialIndexBound[3],":",roiSpatialIndexBound[4],"][",roiSpatialIndexBound[1],":",roiSpatialIndexBound[2],"],",SpatialOpenDAPYVectorName,"[",roiSpatialIndexBound[1],":",roiSpatialIndexBound[2],"],",SpatialOpenDAPXVectorName,"[",roiSpatialIndexBound[3],":",roiSpatialIndexBound[4],"]")) %>%
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
