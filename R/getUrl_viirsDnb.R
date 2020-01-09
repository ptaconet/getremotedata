#' @name getUrl_viirsDnb
#' @aliases getUrl_viirsDnb
#' @title Get URLs of VIIRS DNB datasets
#' @description This function enables to retrieve URLs of VIIRS DNB products given a ROI, a time frame and a set of dimensions of interest.
#' @export
#'
#' @inheritParams getUrl_modis_vnp
#'
#' @inherit getUrl_modis_vnp return
#'
#' @details
#'
#' Argument \code{timeRange} can be provided either as a single date (e.g. \code{as.Date("2017-01-01"))} or time frame provided as two bounding dates ( e.g. \code{as.Date(c("2017-01-01","2017-06-01"))})
#'
#' @note
#' \itemize{
#' \item{NB1 :}{The	NOAA server where the VIIRS DNB data are extracted from is located here : https://gis.ngdc.noaa.gov/arcgis/rest/services/NPP_VIIRS_DNB/}
#' }
#'
#' @author Paul Taconet, IRD \email{paul.taconet@ird.fr}
#'
#' @family getUrl
#'
#' @import lubridate
#'
#' @examples
#'
#'\dontrun{
#'require(sf)
#'require(purrr)
#'
#' # Set ROI and time range of interest
#' roi<-sf::st_read(system.file("extdata/roi_example.gpkg", package = "getRemoteData"),quiet=TRUE)
#' timeRange<-as.Date(c("2017-01-01","2017-08-30"))
#'
#' ### Retrieve the URLs to download VIIRS DNB products for the whole time frame :
#' df_data_to_dl<-getRemoteData::getUrl_viirsDnb(
#' timeRange=timeRange,
#' roi=roi,
#' dimensions=c("Monthly_AvgRadiance","Monthly_CloudFreeCoverage")
#' )
#'
#'# Set destination folder
#' df_data_to_dl$destfile<-file.path(getwd(),df_data_to_dl$name)
#'
#'# Download the data
#'res_dl<-getRemoteData::downloadData(df_data_to_dl,parallelDL=TRUE)
#'
#'# Open the Monthly_AvgRadiance bands as a list of rasters
#'rasts_viirsdnb<-purrr::map(res_dl$destfile[which(grepl("Monthly_AvgRadiance",res_dl$destfile))],~raster::raster(.))
#'
#'# plot the first date :
#' raster::plot(rasts_viirsdnb[[1]])
#'
#'}

getUrl_viirsDnb<-function(timeRange, # mandatory. either a time range (e.g. c(date_start,date_end) ) or a single date e.g. ( date_start )
                           roi, # either provide roi (sf point or polygon) or provide roiSpatialIndexBound. if roiSpatialIndexBound is not provided, it will be calculated from roi
                           dimensions # mandatory
                           ){

  if(!is(timeRange,"Date")){stop("Argument timeRange is not of class Date")}

  url_noaa_nighttime_webservice<-"https://gis.ngdc.noaa.gov/arcgis/rest/services/NPP_VIIRS_DNB/"

  available_dim<-c("Monthly_AvgRadiance_StrayLightImpacted","Monthly_AvgRadiance","Monthly_CloudFreeCoverage_StrayLightImpacted","Monthly_CloudFreeCoverage")
  wrong_dim<-setdiff(dimensions,available_dim)

  if(length(wrong_dim)>0){
    stop(paste0("\nDimension ",wrong_dim," do not exist. Check out which dimensions are available at the following URL : ",url_noaa_nighttime_webservice))
  }

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
    dplyr::mutate(dimensions=rep(dimensions,dplyr::n()/2)) %>%
    dplyr::mutate(url=paste0(url_noaa_nighttime_webservice,dimensions,"/ImageServer/exportImage?bbox=",roi_bbox$xmin,",",roi_bbox$ymin,",",roi_bbox$xmax,",",roi_bbox$ymax,"&time=",format(time_start,scientific=FALSE),",",format(time_end,scientific=FALSE),"&format=tiff&f=image")) %>%
    dplyr::mutate(name=paste0(dimensions,"_",year,month,".tif"))
    #dplyr::mutate(destfile=file.path(destFolder,paste0(name,".tif")))

  res<-data.frame(time_start=table_urls$date,name=table_urls$name,url=table_urls$url,stringsAsFactors = F)

  return(res)

}
