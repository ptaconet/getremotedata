#' @name getUrl_viirsDnb
#' @aliases getUrl_viirsDnb
#' @title Download VIIRS DNB time series data
#' @description This function enables to retrieve URLs of VIIRS DNB datasets for a given ROI and time frame, and eventually download the data
#' @export
#'
#' @inheritParams getUrl_modis_vnp
#'
#' @inherit getUrl_modis_vnp return
#'
#' @details
#'
#' Argument \code{timeRange} can be provided either as a single date (e.g. \code{as.Date("2017-01-01"))} or time frame provided as two bounding dates ( e.g. \code{as.Date(c("2010-01-01","2010-01-30"))})
#'
#' @author Paul Taconet, IRD \email{paul.taconet@ird.fr}
#'
#' @family getUrl
#'
#' @import lubridate
#'
#' @examples
#'
#' # Read ROI as sf object
#' roi=sf::st_read(system.file("extdata/ROI_example.kml", package = "getRemoteData"),quiet=TRUE)
#' timeRange<-c("2017-01-01","2017-01-30") %>% as.Date()
#'
#' getUrl_viirsDnb(timeRange=timeRange,
#' roi=roi,
#' dimensions=c("Monthly_AvgRadiance","Monthly_CloudFreeCoverage"),
#' download=FALSE
#' )
#'
#'


getUrl_viirsDnb<-function(timeRange, # mandatory. either a time range (e.g. c(date_start,date_end) ) or a single date e.g. ( date_start )
                           roi, # either provide roi (sf point or polygon) or provide roiSpatialIndexBound. if roiSpatialIndexBound is not provided, it will be calculated from roi
                           dimensions # mandatory
                           ){

  url_noaa_nighttime_webservice<-"https://gis.ngdc.noaa.gov/arcgis/rest/services/NPP_VIIRS_DNB/"

  roi_bbox<-sf::st_bbox(st_transform(roi,4326))

  timeRange=as.Date(timeRange,origin="1970-01-01")

  if(length(timeRange)==1){
    timeRange=c(timeRange,timeRange %m+% lubridate::days(1))
  }

  datesToRetrieve<-seq(from=timeRange[2],to=timeRange[1],by="-1 month") %>%
    data.frame(stringsAsFactors = F) %>%
    purrr::set_names("date") %>%
    dplyr::mutate(date_character=as.character(as.Date(date))) %>%
    dplyr::mutate(year=format(date,'%Y')) %>%
    dplyr::mutate(month=format(date,'%m')) %>%
    dplyr::mutate(date_start=as.Date(paste(year,month,"01",sep="-"))) %>%
    dplyr::mutate(date_end=date_start %m+% months(1))  %>%
    dplyr::mutate(time_start=as.integer(difftime(date_start ,"1970-01-01" , units = c("secs")))*1000) %>%
    dplyr::mutate(time_end=as.integer(difftime(date_end ,"1970-01-01" , units = c("secs")))*1000)

  table_urls<-datesToRetrieve %>%
    dplyr::select(year,month,time_start,time_end) %>%
    dplyr::slice(rep(1:dplyr::n(), each = length(dimensions))) %>%
    dplyr::mutate(date=as.character(paste(year,month,"01",sep="-"))) %>%
    dplyr::mutate(dimensions=rep(dimensions,n()/2)) %>%
    dplyr::mutate(url=paste0(url_noaa_nighttime_webservice,dimensions,"/ImageServer/exportImage?bbox=",roi_bbox$xmin,",",roi_bbox$ymin,",",roi_bbox$xmax,",",roi_bbox$ymax,"&time=",format(time_start,scientific=FALSE),",",format(time_end,scientific=FALSE),"&format=tiff&f=image")) #%>%
    #dplyr::mutate(product_name=paste0(dimensions,"_",year,month)) %>%
    #dplyr::mutate(destfile=file.path(destFolder,paste0(product_name,".tif")))


  res<-data.frame(time_start=table_urls$date,url=table_urls$url,stringsAsFactors = F)

  return(res)

}
