#' @name getData_viirsDnb
#' @aliases getData_viirsDnb
#' @title Download VIIRS DNB time series data
#' @description This function enables to retrieve URLs of VIIRS DNB datasets for a given ROI and time frame, and eventually download the data
#' @export
#'
#' @param timeRange Date(s) of interest. Mandatory. See Details for addition information on how to provide the dates.
#' @param roi sf POINT or POLYGON. The region of interest in EPSG 4326
#' @param dimensions TODO
#' @param download logical. Download data ?
#' @param destFolder string. Mandatory if \code{download} is set to TRUE. The destination folder (i.e. folder where the data will be downloaded)
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
#' Useful links :
#'
#'
#' Argument \code{timeRange} can be provided either as a single date (e.g. \code{as.Date("2017-01-01"))} or time frame provided as two bounding dates ( e.g. \code{as.Date(c("2010-01-01","2010-01-30"))})
#'
#' @author Paul Taconet, IRD \email{paul.taconet@ird.fr}
#'
#' @family getData
#'
#' @import sf tidyverse lubridate
#'
#' @examples
#'
#' # Read ROI as sf object
#' roi=sf::st_read(system.file("extdata/ROI_example.kml", package = "getRemoteData"),quiet=T)
#' timeRange<-c("2017-01-01","2017-01-30") %>% as.Date()
#'
#' getData_viirsDnb(timeRange=timeRange,
#' roi=roi,
#' dimensions=c("Monthly_AvgRadiance","Monthly_CloudFreeCoverage"),
#' download=FALSE
#' )
#'
#'


getData_viirsDnb<-function(timeRange=as.Date(c("2017-01-01","2017-01-30")), # mandatory. either a time range (e.g. c(date_start,date_end) ) or a single date e.g. ( date_start )
                           roi=st_read(system.file("extdata/ROI_example.kml", package = "getRemoteData"),quiet=T), # either provide roi (sf point or polygon) or provide roiSpatialIndexBound. if roiSpatialIndexBound is not provided, it will be calculated from roi
                           dimensions=c("Monthly_AvgRadiance","Monthly_CloudFreeCoverage"), # mandatory
                           download=FALSE, # TRUE will download the file and return a dataframe with : the URL, the path to the output file, a boolean wether the dataset was properly downloaded or not. FALSE will return a list with the URL only
                           destFolder=getwd(),
                           ...){

  url_noaa_nighttime_webservice<-"https://gis.ngdc.noaa.gov/arcgis/rest/services/NPP_VIIRS_DNB/"

  roi_bbox<-sf::st_bbox(st_transform(roi,4326))

  timeRange=as.Date(timeRange,origin="1970-01-01")

  if(length(timeRange)==1){
    timeRange=c(timeRange,timeRange %m+% days(1))
  }

  datesToRetrieve<-seq(from=timeRange[2],to=timeRange[1],by="-1 month") %>%
    data.frame(stringsAsFactors = F) %>%
    set_names("date") %>%
    mutate(date_character=as.character(as.Date(date))) %>%
    mutate(year=format(date,'%Y')) %>%
    mutate(month=format(date,'%m')) %>%
    mutate(date_start=as.Date(paste(year,month,"01",sep="-"))) %>%
    mutate(date_end=date_start %m+% months(1))  %>%
    mutate(time_start=as.integer(difftime(date_start ,"1970-01-01" , units = c("secs")))*1000) %>%
    mutate(time_end=as.integer(difftime(date_end ,"1970-01-01" , units = c("secs")))*1000)

  table_urls<-datesToRetrieve %>%
    dplyr::select(year,month,time_start,time_end) %>%
    slice(rep(1:n(), each = length(dimensions))) %>%
    mutate(dimensions=rep(dimensions,n()/2)) %>%
    mutate(url=paste0(url_noaa_nighttime_webservice,dimensions,"/ImageServer/exportImage?bbox=",roi_bbox$xmin,",",roi_bbox$ymin,",",roi_bbox$xmax,",",roi_bbox$ymax,"&time=",format(time_start,scientific=FALSE),",",format(time_end,scientific=FALSE),"&format=tiff&f=image")) %>%
    mutate(product_name=paste0(dimensions,"_",year,month)) %>%
    mutate(destfile=file.path(destFolder,paste0(product_name,".tif")))


  res<-data.frame(name=table_urls$product_name,url=table_urls$url,destfile=table_urls$destfile,stringsAsFactors = F)

  if (download){
    cat("Downloading the data...\n")
    res<-getRemoteData::downloadData(res, ...)
  }

  return(res)

}
