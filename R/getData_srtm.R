#' @name getData_srtm
#' @aliases getData_srtm
#' @title Download SRTM DEM
#' @description This function enables to retrieve URLs of SRTM DEM datasets for a given ROI, and eventually download the data
#' @export
#'
#' @param roi sf POINT or POLYGON. The region of interest in EPSG 4326
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
#' Additionally, if \code{download} is set to TRUE the data are downloaded to \code{destFolder}
#'
#'
#' @author Paul Taconet, IRD \email{paul.taconet@ird.fr}
#'
#' @family getData
#'
#' @import sf
#'
#' @examples
#'
#' # Read ROI as sf object
#' roi=sf::st_read(system.file("extdata/ROI_example.kml", package = "getRemoteData"),quiet=T)
#'
#' \dontrun{
#' getData_srtm(roi=roi,
#' download=FALSE
#' )
#'}



getData_srtm<-function(roi=st_read(system.file("extdata/ROI_example.kml", package = "getRemoteData"),quiet=T),
                       download=FALSE,
                       destFolder=getwd(),
                       ... ){

  url_srtm_server<-"http://e4ftl01.cr.usgs.gov/MEASURES/SRTMGL1.003/2000.02.11/"
  srtm_tiles<-getRemoteData::getSRTMtileNames(roi)
  urls<-paste0(url_srtm_server,srtm_tiles,".SRTMGL1.hgt.zip")

  destfiles<-file.path(destFolder,paste0(srtm_tiles,".SRTMGL1.hgt.zip"))

  names<-srtm_tiles

  res<-data.frame(name=names,url=urls,destfile=destfiles,stringsAsFactors = F)

  if (download){
    cat("Downloading the data...\n")
    res<-getRemoteData::downloadData(res, ...)
  }

  return(res)

}
