#' @name getData_modis
#' @aliases getData_modis
#' @title Download MODIS time series date
#' @description This function enables to retrieve URLs of MODIS datasets for a given ROI and time frame, and eventually download the data
#' @export
#'
#' @param time_range Date(s) of interest. Mandatory. Either a single date (e.g. \code{as.Date("2017-01-01"))} or time frame provided with two bounding dates ( e.g. \code{as.Date(c("2010-01-01","2010-01-30"))})
#' @param roi sf . The region of interest (point or polygon)
#' @param OpenDAPCollection The MODIS collection of interest
#' @param destFolder string. Mandatory if \code{download} is set to TRUE. The destination folder (i.e. folder where the data will be downloaded)
#' @param modisTile string. Optional. The MODIS tile name.
#' @param dimensionsToRetrieve string vector. Names of the dimensions to retrieve fot the MODIS collection of interest.
#' @param timeVector numeric vector. Optional. The OpenDAP time dimension vector.
#' @param XVector numeric vector. Optional. The OpenDAP X (longitude) dimension vector.
#' @param YVector numeric vector. Optional. The OpenDAP Y (latitude) dimension vector.
#' @param roiSpatialIndexBound numeric vector. Optional.
#' @param username string. EarthData username
#' @param password string. EarthData password
#' @param download logical. Download data ?

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
#' Parameters \code{modisTile}, \code{timeVector}, \code{XVector}, \code{YVector} and \code{roiSpatialIndexBound} are optional. They are automatically calculated from the other input parameters if not provided. However, providing them optimizes the performances (i.e. fasten the processing time).
#' It might be particularly useful to provide them when looping with the function over the same ROI.
#'
#' @author Paul Taconet, IRD \email{paul.taconet@ird.fr}
#'
#' @family getData
#'
#' @examples
#'
#' # Read ROI as sf object
#' roi=sf::st_read(system.file("extdata/ROI_example.kml", package = "getData"),quiet=T)
#' time_range<-c("2017-01-01","2017-01-30") %>% as.Date()
#'
#' \dontrun{
#' getData_modis(time_range=time_range,
#' roi=roi,
#' OpenDAPCollection="MOD11A1.006",
#' dimensionsToRetrieve=c("LST_Day_1km","LST_Night_1km"),
#' username="my.eartdata.username",
#' password="my.eartdata.pw",
#' download=FALSE
#' )
#'}

getData_modis<-function(time_range=as.Date(c("2010-01-01","2010-01-30")), # mandatory. either a time range (e.g. c(date_start,date_end) ) or a single date e.g. ( date_start )
                        roi=st_read(system.file("extdata/ROI_example.kml", package = "getData"),quiet=T), # either provide roi (sf point or polygon) or provide roiSpatialIndexBound. if roiSpatialIndexBound is not provided, it will be calculated from roi
                        OpenDAPCollection="MOD11A1.006", # mandatory
                        destFolder=getwd(),
                        modisTile=NULL, # optional. providing it will fasten the processing time. if not provided it will be calculated automatically
                        dimensionsToRetrieve=c("LST_Day_1km","LST_Night_1km"), # mandatory
                        timeVector=NULL, # optional. providing it will fasten the processing time. if not provided it will be calculated automatically
                        XVector=NULL, # optional. providing it will fasten the processing time. if not provided it will be calculated automatically
                        YVector=NULL, # optional. providing it will fasten the processing time. if not provided it will be calculated automatically
                        roiSpatialIndexBound=NULL, # optional. providing it will fasten the processing time. if not provided it will be calculated automatically
                        username=NULL, # EarthData username
                        password=NULL, # EarthData password
                        download=FALSE, # TRUE will download the file and return a dataframe with : the URL, the path to the output file, a boolean wether the dataset was properly downloaded or not. FALSE will return a list with the URL only
                        ...
                        ){

  OpenDAPServerUrl="https://opendap.cr.usgs.gov/opendap/hyrax"
  TimeVectorName="time"
  SpatialXVectorName="XDim"
  SpatialYVectorName="YDim"
  modisCollection_crs="+proj=sinu +lon_0=0 +x_0=0 +y_0=0 +a=6371007.181 +b=6371007.181 +units=m +no_defs"

  if(!is.null(username)){
  httr::set_config(authenticate(user=username, password=password, type = "basic"))
  }

  if (OpenDAPCollection %in% c("MOD11A1.006","MYD11A1.006")){
    gridDimensionName<-"MODIS_Grid_Daily_1km_LST_eos_cf_projection"
  } else if (OpenDAPCollection %in% c("MOD11A2.006","MYD11A2.006")){
    gridDimensionName<-"MODIS_Grid_8Day_1km_LST_eos_cf_projection"
    } else if (OpenDAPCollection %in% c("MOD13Q1.006","MYD13Q1.006")){
    gridDimensionName<-"MODIS_Grid_16DAY_250m_500m_VI_eos_cf_projection"
  } else if (OpenDAPCollection %in% c("MOD16A2.006","MYD16A2.006")){
    gridDimensionName<-"MOD_Grid_MOD16A2_eos_cf_projection"
  }

  # Calculate modisTile if not provided
  if(is.null(modisTile)){
    modisTile<-getData::getMODIStileNames(roi)
  }

  OpenDAPURL<-paste0(OpenDAPServerUrl,"/",OpenDAPCollection,"/",modisTile,".ncml")

  # Calculate TimeVector if not provided
  if(is.null(timeVector)){
    timeVector<-getData::getOpenDAPvector(OpenDAPURL,TimeVectorName)
  }
  # Calculate XVector if not provided
  if(is.null(XVector) & is.null(roiSpatialIndexBound)){
    XVector<-getData::getOpenDAPvector(OpenDAPURL,SpatialXVectorName)
  }
  # Calculate YVector if not provided
  if(is.null(YVector) & is.null(roiSpatialIndexBound)){
    YVector<-getData::getOpenDAPvector(OpenDAPURL,SpatialYVectorName)
  }
  # Calculate roiSpatialIndexBound if not provided
  if(is.null(roiSpatialIndexBound)){
    roi_bbox<-sf::st_bbox(st_transform(roi,modisCollection_crs))
    Opendap_minLon<-which.min(abs(XVector-roi_bbox$xmin))-1
    Opendap_maxLon<-which.min(abs(XVector-roi_bbox$xmax))-1
    Opendap_maxLat<-which.min(abs(YVector-roi_bbox$ymin))-1
    Opendap_minLat<-which.min(abs(YVector-roi_bbox$ymax))-1
    roiSpatialIndexBound<-c(Opendap_minLat,Opendap_maxLat,Opendap_minLon,Opendap_maxLon)
  }


  # Get openDAP time indices for the time frame of interest
  time_range<-as.Date(time_range,origin="1970-01-01")
  if (length(time_range)==1){
    time_range=c(time_range,time_range)
  }

  revisit_time<-timeVector[2]-timeVector[1]

  timeIndices_of_interest<-seq(time_range[2],time_range[1],-revisit_time) %>%
    map(~getData::getOpenDAPtimeIndex_modis(.,timeVector)) %>%
    do.call(rbind.data.frame,.) %>%
    set_names("ideal_date","date_closest_to_ideal_date","days_sep_from_ideal_date","index_opendap_closest_to_date") %>%
    mutate(ideal_date=as.Date(ideal_date,origin="1970-01-01")) %>%
    mutate(date_closest_to_ideal_date=as.Date(date_closest_to_ideal_date,origin="1970-01-01"))

  # Build URL to download data in NetCDF format

  table_urls<-timeIndices_of_interest %>%
    mutate(dimensions_url=map(.x=index_opendap_closest_to_date,.f=~getData::getOpenDapURL_dimensions(dimensionsToRetrieve,.x,roiSpatialIndexBound,TimeVectorName,SpatialXVectorName,SpatialYVectorName))) %>%
    mutate(url=paste0(OpenDAPURL,".nc4?",gridDimensionName,",",dimensions_url))


  urls<-table_urls$url

  destfiles<-paste0(file.path(destFolder,paste0(OpenDAPCollection,"_",gsub("-","",table_urls$date_closest_to_ideal_date))),".nc4")

  names<-as.numeric(timeIndices_of_interest$date_closest_to_ideal_date)

  res<-data.frame(names=names,urls=urls,destfiles=destfiles,stringsAsFactors = F)

  if (download){
    cat("Downloading the data...\n")
    res<-getData::downloadData(res,username,password,parallelDL)
  }

  #return(list(name=names,url=urls,destfile=destfiles))

  return(res)
}

