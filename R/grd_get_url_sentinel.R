#' @name .get_url_sentinel
#' @aliases .get_url_sentinel
#' @title Get URLs of Sentinel datasets
#' @description This function enables to retrieve WMS URLs of Sentinel products given a collection, a ROI, a time frame and a set of bands of interest.
#'
#' @inheritParams get_url_modis_vnp
#'
#' @return a data.frame with one row for each dataset and 3 columns  :
#'  \itemize{
#'  \item{*time_start*: }{Start Date/time for the dataset}
#'  \item{*name*: }{An indicative name for the dataset}
#'  \item{*url*: }{URL of the dataset}
#'  }
#'
#' @details
#'
#' Available collections : S2L2A, S2L1C, S1-AWS-IW-VVVH
#'
#' Available dimensions :
#' \itemize{
#' \item{for collections S2L2A and S2L1C : } {1_TRUE_COLOR, 2_FALSE_COLOR, 3_NDVI, 4_FALSE_COLOR, 5_MOISTURE_INDEX, 6_SWIR, 7-NDWI, 8_NDSI, 9_SCENE_CLASSIFICATION, B01, B02, etc... B12}
#' \item{for collection S1-AWS-IW-VVVH : } {towrite}
#' }
#'
#' @author Paul Taconet, IRD \email{paul.taconet@ird.fr}
#'
#' @note
#'
#' @noRd
#'
#' @examples
#'
#' roi<-sf::st_read(system.file("extdata/roi_example.gpkg", package = "getRemoteData"),quiet=TRUE)
#' time_range<-as.Date(c("2017-01-01","2017-01-30"))
#' collection <- "S2L2A"
#' dimensions <- c("B04","B08","B8A","B11","9_SCENE_CLASSIFICATION")
#' credentials_sentinel_hub <- config::get("sentinel-hub")
#'
#'
#' df_data_to_dl <- get_url_sentinel(time_range = time_range,
#' roi = roi,
#' collection = collection,
#' dimensions = dimensions,
#' instance_id = credentials_sentinel_hub$sentinel2
#' )
#'
#' df_data_to_dl <- get_url_sentinel(time_range = time_range,
#' roi = roi,
#' collection = "S1-AWS-IW-VVVH",
#' dimensions = c("VV","VH"),
#' instance_id = credentials_sentinel_hub$sentinel1
#' )
#'

.get_url_sentinel<-function(time_range, # mandatory. either a time range (e.g. c(date_start,date_end) ) or a single date e.g. ( date_start )
                           roi,
                           collection, # mandatory
                           dimensions, # mandatory #
                           instance_id # mandatory
){

  if(length(time_range)==1){time_range=c(time_range,time_range)}
  #time=paste0(time_range[1],"T00:00:00.000Z/",time_range[2],"T23:59:59.999Z")
  #time=paste0(time_range[1],"/",time_range[2])

 bbox<-sf::st_bbox(roi)
 utm_zone_number<-(floor((bbox$xmin + 180)/6) %% 60) + 1
 if(bbox$ymin>0){ # if latitudes are North
   epsg<-as.numeric(paste0("326",utm_zone_number))
 } else { # if latitude are South
   epsg<-as.numeric(paste0("325",utm_zone_number))
 }

 # We can download 5000 * 5000 pixels image from Sinergize WMS servers. We know that at zoom 19, 1 pixel=0.30m, so 1500 px = 450m. So within each 10km grid we make 400m grids (to be sure that all the area is encompassed)
 roi<-sf::st_transform(roi,epsg) %>% sf::st_zm()
 grid_5000px <- sf::st_make_grid(roi,what="polygons",cellsize = 50000) %>%
   sf::st_crop(roi) %>%
   sf::st_as_text()

 grid_5000px_df <- data.frame(area_wkt=grid_5000px,part_number=seq(1,length(grid_5000px),1),stringsAsFactors = F)

 if(collection %in% c("S2L2A","S2L1C")){
   typenames="DSS2"
 } else if (collection == "S1-AWS-IW-VVVH"){
   typenames="DSS3"
 }

 # get dates of images available through WFS query
 # see https://www.sentinel-hub.com/develop/documentation/faq#t32n443 / https://www.sentinel-hub.com/faq/how-are-values-calculated-within-sentinel-hub-and-how-are-they-returned-output
 wfs <- utils::URLencode(paste0("https://services.sentinel-hub.com/ogc/wfs/",instance_id,"?version=2.0.0&service=WFS&request=GetFeature&SRSNAME=EPSG:",epsg,"&geometry=",sf::st_as_text(roi$geom),"&time=",time_range[1],"/",time_range[2],"/P1D&typenames=",typenames,"&outputformat=application/json"))
 df_data_available <- jsonlite::fromJSON(wfs)$features

 dates_to_retrieve <- unique(df_data_available$properties$date)

 # Build URLs to download data
 res <- expand.grid(dimensions, grid_5000px, dates_to_retrieve) %>%
   dplyr::rename(band=Var1,area_wkt=Var2,time_start=Var3) %>%
   dplyr::mutate(url=paste0("https://services.sentinel-hub.com/ogc/wms/",instance_id,"?version=1.1.1&service=WMS&request=GetMap&format=image/tiff&crs=EPSG:",epsg,"&layers=",band,"&geometry=",area_wkt,"&RESX=10&RESY=10&time=",time_start,"/",time_start,"&showlogo=false&transparent=false&maxcc=100&evalsource=",collection)) %>%
   dplyr::left_join(grid_5000px_df,by="area_wkt") %>%
   dplyr::mutate(name=paste0(collection,"_",gsub("-","",time_start),"_",band,"__p",part_number)) %>%
   dplyr::mutate(destfile=paste0(name,".tif")) %>%
   dplyr::select(name,time_start,destfile,url) %>%
   dplyr::arrange(time_start,name)

 res$url <- purrr::map_chr(res$url,~utils::URLencode(.))

  return(res)

}

