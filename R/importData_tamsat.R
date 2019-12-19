#' @name importData_tamsat
#' @aliases importData_tamsat
#' @title Open a TAMSAT product as a \code{raster} object
#' @description This function opens as a \code{raster} object a TAMSAT product that was downloaded via the \code{getData_tamsat} and \code{dowloadData} functions
#' @export
#'
#' @param path_to_raw_tamsat string. Path to the data in .nc4 format
#' @param roi sf POINT or POLYGON. The region of interest in EPSG 4326
#'
#' @return a \code{raster} object (EPSG 4326) crop in the ROI.
#'
#' @author Paul Taconet, IRD \email{paul.taconet@ird.fr}
#'
#' @family prepareData
#'
#'
#' @examples
#'
#' \dontrun{
#' path_to_tamsat<-"path.to.my.tamsat.raster"
#' roi=sf::st_read(system.file("extdata/ROI_example.kml", package = "getRemoteData"),quiet=T)
#' rast_tamsat<-importData_tamsat(path_to_raw_tamsat=path_to_tamsat,
#' roi=roi)
#' #plot(rast_tamsat)
#'}

importData_tamsat<-function(path_to_raw_tamsat,roi=sf::st_read(system.file("extdata/ROI_example.kml", package = "getRemoteData"),quiet=T)){

  rast<-raster::raster(path_to_raw_tamsat)

  # extend a bit the size of the bbox
  bbox_tamsat<-sf::extent(roi)
  bbox_tamsat[1]=bbox_tamsat[1]-0.5
  bbox_tamsat[2]=bbox_tamsat[2]+0.5
  bbox_tamsat[3]=bbox_tamsat[3]-0.5
  bbox_tamsat[4]=bbox_tamsat[4]+0.5

  # Crop to the bbox
  rast<-raster::raster(path_to_raw_tamsat) %>%
    raster::crop(bbox_tamsat)

  return(rast)

}
