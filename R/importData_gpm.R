#' @name importData_gpm
#' @aliases importData_gpm
#' @title Open a GPM product as a \code{raster} object
#' @description This function opens as a \code{raster} object a GPM product that was downloaded via the \code{getData_modis} and \code{dowloadData} functions
#' @export
#'
#' @param path_to_raw_modis string. Path to the data in .nc4 format
#' @param var_name string. Dimension name (e.g. "precipitationCal")
#'
#' @return a \code{raster} object (EPSG 4326)
#'
#' @author Paul Taconet, IRD \email{paul.taconet@ird.fr}
#'
#' @family ImportData
#'
#' @import raster
#'
#' @examples
#'
#' path_to_gpm<-system.file("extdata/gpm_example.nc4", package = "getRemoteData")
#'
#' rast_gpm<-importData_gpm(path_to_raw_gpm=path_to_gpm,
#' var_name="precipitationCal")
#' #plot(rast_modis)
#'


importData_gpm<-function(path_to_raw_gpm,var_name){

  rast<-raster::raster(path_to_raw_gpm,varname=var_name)
  raster::projection(rast)<-"+init=epsg:4326 +proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0 "
  # The raster has to be flipped. Output was validated with the data from 2017-09-20 (see https://docserver.gesdisc.eosdis.nasa.gov/public/project/GPM/browse/GPM_3IMERGDF.png)
  rast <- raster::t(rast)
  rast <- raster::flip(rast,'y')
  rast <- raster::flip(rast,'x')

  return(rast)

}

#  if(resample){
#resample_output_res<-convertMetersToDegrees(resample_output_res,latitude_4326=mean(c(extent(rast)[3],extent(rast)[4])))
#r<-rast
#res(r)<-resample_output_res
#rast<-raster::resample(rast,r,method='bilinear')
#}
