#' @name getUrl_srtm
#' @aliases getUrl_srtm
#' @title Get URLs of SRTM datasets
#' @description This function enables to retrieve URLs of SRTM DEM datasets for a given ROI, and eventually download the data
#' @export
#'
#' @inheritParams getUrl_modis_vnp
#'
#' @inherit getUrl_modis_vnp return
#'
#' @note
#' \itemize{
#' \item{NB1 :}{The	NASA server where the SRTM data are extracted from is located here : http://e4ftl01.cr.usgs.gov/MEASURES/SRTMGL1.003/2000.02.11/}
#' }
#'
#' @author Paul Taconet, IRD \email{paul.taconet@ird.fr}
#'
#' @family getUrl
#'
#' @import sf
#'
#' @examples
#'
#' \dontrun{
#'
#' require(sf)
#'
#' # Set ROI as a sf object
#' roi<-sf::st_read(system.file("extdata/roi_example.gpkg", package = "getRemoteData"),quiet=TRUE)
#'
#' # Connect to EarthData servers
#' my.earthdata.username<-"username"
#' my.earthdata.pw<-"password"
#'
#' getRemoteData::login_earthdata(my.earthdata.username,my.earthdata.pw)
#'
#' ### Retrieve the URLs to download SRTM DEM :
#' df_data_to_dl<-getRemoteData::getUrl_srtm(roi = roi)
#'
#' # Set destination folder
#' df_data_to_dl$destfile<-file.path(getwd(),df_data_to_dl$name)
#'
#'# Download the data
#'res_dl<-getRemoteData::downloadData(df_data_to_dl,parallelDL=TRUE,data_source="earthdata")
#'
#'# Open the DEM(s) as a list of rasters
#'rasts_srtm<-purrr::map(res_dl$destfile,~unzip(.)) %>%
#'purrr::map(.,~raster::raster(.))
#'
#'# plot the first date :
#' raster::plot(rasts_srtm[[1]])
#'
#'}



getUrl_srtm<-function(roi){

  if(!is(roi,"sf")){stop("roi is not of class sf")}

  url_srtm_server<-"http://e4ftl01.cr.usgs.gov/MEASURES/SRTMGL1.003/2000.02.11/"
  srtm_tiles<-getRemoteData::.getSRTMtileNames(roi)
  urls<-paste0(url_srtm_server,srtm_tiles,".SRTMGL1.hgt.zip")

  names<-paste0(srtm_tiles,".SRTMGL1.hgt.zip")

  res<-data.frame(time_start=NA,name=names,url=urls,stringsAsFactors = F)

  return(res)

}
