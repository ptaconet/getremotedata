#' @name getUrl_srtm
#' @aliases getUrl_srtm
#' @title Download SRTM DEM
#' @description This function enables to retrieve URLs of SRTM DEM datasets for a given ROI, and eventually download the data
#' @export
#'
#' @inheritParams getUrl_modis_vnp
#'
#' @inherit getUrl_modis_vnp return
#'
#'
#' @author Paul Taconet, IRD \email{paul.taconet@ird.fr}
#'
#' @family getUrl
#'
#' @import sf
#'
#' @examples
#'
#' # Read ROI as sf object
#' roi=sf::st_read(system.file("extdata/ROI_example.kml", package = "getRemoteData"),quiet=TRUE)
#'
#' \dontrun{
#' getUrl_srtm(roi=roi,
#' download=FALSE
#' )
#'}



getUrl_srtm<-function(roi){

  url_srtm_server<-"http://e4ftl01.cr.usgs.gov/MEASURES/SRTMGL1.003/2000.02.11/"
  srtm_tiles<-getRemoteData::getSRTMtileNames(roi)
  urls<-paste0(url_srtm_server,srtm_tiles,".SRTMGL1.hgt.zip")

  #destfiles<-file.path(destFolder,paste0(srtm_tiles,".SRTMGL1.hgt.zip"))

  names<-paste0(srtm_tiles,".SRTMGL1.hgt.zip")

  res<-data.frame(time_start=NA,name=names,surl=urls,stringsAsFactors = F)

  return(res)

}
