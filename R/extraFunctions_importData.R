#' @name extraFunctions_importData
#' @aliases extraFunctions_importData
#' @title A set of functions to import as raster data downloaded through the \code{getURL} functions
#' @description set of functions to import as raster data downloaded through the \code{getURL} functions
#' @export importData_modis_vnp importData_gpm importData_era5 importData_smap importData_tamsat
#'
#' @param path_to_nc string. Path to the data in .nc4 format
#' @param var_name string. Dimension name
#' @param roi sf POLYGON. The region of interest in EPSG 4326
#'
#' @author Paul Taconet, \email{paul.taconet@@ird.fr}
#'



import_data_era5<-function(path_to_nc){

  # Open netcdf
  nc <- ncdf4::nc_open(path_to_nc)
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

  rast <- raster::raster(t(variable), xmn=min(lon)-0.125, xmx=max(lon)+0.125, ymn=min(lat)-0.125, ymx=max(lat)+0.125, crs="+init=epsg:4326 +proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0")

  return(list(rast,timestamp))
}
