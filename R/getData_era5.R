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
#' @import reticulate sf tidyverse
#'
#' @examples
#'
#' # Read ROI as sf object
#' roi=sf::st_read(system.file("extdata/ROI_example.kml", package = "getRemoteData"),quiet=T)
#' timeRange<-c("2010-01-01 18:00:00","2010-01-02 09:00:00") %>% as.POSIXlt()
#'
#' \dontrun{
#' getData_era5(timeRange=timeRange,
#' roi=roi,
#' dimensions=c("10m_u_component_of_wind","10m_v_component_of_wind"),
#' username="my.cophub.username",
#' password="my.cophub.pw",
#' download=FALSE
#' )
#'}
#'

getData_era5<-function(timeRange=as.POSIXlt(c("2010-01-01 18:00:00","2010-01-02 09:00:00")), # mandatory. either a time range (e.g. c(date_start,date_end) ) or a single date e.g. ( date_start )
                       roi=st_read(system.file("extdata/ROI_example.kml", package = "getRemoteData"),quiet=T), # either provide roi (sf point or polygon) or provide roiSpatialIndexBound. if roiSpatialIndexBound is not provided, it will be calculated from roi
                       dimensions=c("10m_u_component_of_wind","10m_v_component_of_wind"), # mandatory,
                       username=NULL, # EarthData user name
                       password=NULL, # EarthData password
                       download=FALSE, # TRUE will download the file and return a dataframe with : the URL, the path to the output file, a boolean wether the dataset was properly downloaded or not. FALSE will return a list with the URL only
                       destFolder=getwd(),
                       ...){


  # Check : https://dominicroye.github.io/en/2018/access-to-climate-reanalysis-data-from-r/

  # ERA 5 : https://cds.climate.copernicus.eu/cdsapp#!/dataset/reanalysis-era5-single-levels?tab=overview

  # Description of the wind data: https://apps.ecmwf.int/codes/grib/param-db?id=165 and https://apps.ecmwf.int/codes/grib/param-db?id=166

  getQuery<-function(dimensions,year,month,day,hour,roi_bbox){

    query <- reticulate::r_to_py(list(
      variable= dimensions,
      product_type= "reanalysis",
      year= year,
      month=month, #formato: "01","01", etc.
      day= day, #stringr::str_pad(1:31,2,"left","0"),
      time= hour,
      format= "netcdf",
      area = paste0(roi_bbox$ymax+1,"/",roi_bbox$xmin-1,"/",roi_bbox$ymin-1,"/",roi_bbox$xmax+1) # North, West, South, East
    ))

    return(query)

  }

  roi_bbox<-sf::st_bbox(st_transform(roi,4326))

  timeRange=as.POSIXlt(timeRange,tz="GMT")


  datesToRetrieve<-seq(from=timeRange[2],to=timeRange[1],by="-1 hour") %>%
    data.frame(stringsAsFactors = F) %>%
    set_names("date") %>%
    mutate(date_character=as.character(as.Date(date))) %>%
    mutate(year=format(date,'%Y')) %>%
    mutate(month=format(date,'%m')) %>%
    mutate(day=format(date,"%d")) %>%
    mutate(hour=format(date,"%H"))
  #mutate(hour_era5=as_datetime(c(t*60*60),origin="1900-01-01")) %>%


  res<-datesToRetrieve %>%
    mutate(url=pmap(list(year,month,day,hour),~getQuery(dimensions,..1,..2,..3,..4,roi_bbox))) %>%
    mutate(name=paste0(year,month,day,"_",hour)) %>%
    mutate(destfile=file.path(destFolder,paste0(name,".nc"))) %>%
    dplyr::select(name,url,destfile)


if (download){
  cat("Downloading the data...\n")
  ## Parameters for download of ERA 5 data
  #import python CDS-API
  cdsapi <- reticulate::import('cdsapi')
  #for this step there must exist the file .cdsapirc in the root directory of the computer (e.g. "/home/ptaconet")
  server = cdsapi$Client() #start the connection
  for (i in 1:length(res)){
    for (j in 1:length(res[[i]])){
      for (k in 1:length(res[[i]][[j]]$destfile)){
        if (!file.exists(era5Data_md[[i]][[j]]$destfile[k])){
           server$retrieve("reanalysis-era5-single-levels",
                           res[[i]][[j]]$url[k][[1]],
                           res[[i]][[j]]$destfile[k])
        }
      }
    }
  }

}
  return(res)


  #query the server to get the ncdf for date of catch and date of catch + 1
  #server$retrieve("reanalysis-era5-single-levels",
  #               query_this_date_hlc,
  #              "/home/ptaconet/Documents/react/data_CIV/ERA_WIND/test.nc")


}
