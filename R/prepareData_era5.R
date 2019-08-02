#' @name prepareData_era5
#' @aliases prepareData_era5
#' @title Open a ERA-5 product as a \code{raster} object
#' @description This function opens as a \code{raster} object a ERA-5 product that was downloaded via the \code{getData_era5} function
#' @export
#'
#' @param path_to_raw_modis string. Path to the data in .nc format
#' @param var_name string. Dimension name (e.g. "LST_Day_1km")
#'
#' @return a \code{raster} object with the MODIS projection (+proj=sinu +lon_0=0 +x_0=0 +y_0=0 +a=6371007.181 +b=6371007.181 +units=m +no_defs)
#'
#' @author Paul Taconet, IRD \email{paul.taconet@ird.fr}
#'
#' @family prepareData
#'
#' @import ncdf4 lubridate
#'
#' @examples
#'
#' path_to_era5<-system.file("extdata/era5_example.nc", package = "getRemoteData")
#'
#' rast_era5<-prepareData_modis(path_to_raw_era5=path_to_era5)
#' #plot(rast_era5)
#'

prepareData_era5<-function(path_to_raw_era5){

  # Open netcdf
  nc <- ncdf4::nc_open(path_to_raw_era5)
  # Get lat and lon
  lat <- ncdf4::ncvar_get(nc,'latitude')
  lon <- ncdf4::ncvar_get(nc,'longitude')
  # Get time
  t <- ncdf4::ncvar_get(nc, "time")
  #time unit: hours since 1900-01-01
  #ncatt_get(nc,'time')
  #convert the hours into date + hour
  #as_datetime() function of the lubridate package needs seconds
  timestamp <- lubridate::as_datetime(c(t*60*60),origin="1900-01-01")

  # Get the variable
  #variable <- ncdf4::ncvar_get(nc,var_name)
  variable <- ncdf4::ncvar_get(nc)

  rast <- raster(t(variable), xmn=min(lon)-0.125, xmx=max(lon)+0.125, ymn=min(lat)-0.125, ymx=max(lat)+0.125, crs="+init=epsg:4326 +proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0")

  return(list(rast,timestamp))
}

