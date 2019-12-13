#' @name getData_modis_vnp
#' @aliases getData_modis_vnp
#' @title Open a MODIS product as a \code{raster} object
#' @description This function opens as a \code{raster} object a MODIS product that was downloaded via the \code{getData_modis} and \code{dowloadData} functions
#' @export
#'
#' @param path_to_raw_modis string. Path to the data in .nc4 format
#' @param var_name string. Dimension name (e.g. "LST_Day_1km")
#'
#' @return a \code{raster} object with the MODIS projection (+proj=sinu +lon_0=0 +x_0=0 +y_0=0 +a=6371007.181 +b=6371007.181 +units=m +no_defs)
#'
#' @author Paul Taconet, IRD \email{paul.taconet@ird.fr}
#'
#' @family prepareData
#'
#' @import raster
#'
#' @examples
#'
#' path_to_modis<-system.file("extdata/modis_example.nc4", package = "getRemoteData")
#'
#' rast_modis<-getData_modis_vnp(path_to_raw_modis=path_to_modis,
#' var_name="LST_Day_1km")
#' #plot(rast_modis)
#'

# To open a MODIS dataset that was downloaded via OpenDap
getData_modis_vnp<-function(path_to_raw_modis,var_name){
  grid_nc<-raster(path_to_raw_modis,varname=var_name)
  projection(grid_nc)<-"+proj=sinu +lon_0=0 +x_0=0 +y_0=0 +a=6371007.181 +b=6371007.181 +units=m +no_defs"
  extent(grid_nc)[1:2]<-extent(grid_nc)[1:2]+res(grid_nc)[1]/2
  extent(grid_nc)[3:4]<-extent(grid_nc)[3:4]-res(grid_nc)[1]/2
  return(grid_nc)
}
