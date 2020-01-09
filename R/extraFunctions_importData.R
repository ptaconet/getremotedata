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


# To open a MODIS dataset that was downloaded via OpenDap
importData_modis_vnp<-function(path_to_nc,var_name){
  grid_nc<-raster::raster(path_to_nc,varname=var_name)
  raster::projection(grid_nc)<-"+proj=sinu +lon_0=0 +x_0=0 +y_0=0 +a=6371007.181 +b=6371007.181 +units=m +no_defs"
  raster::extent(grid_nc)[1:2]<-raster::extent(grid_nc)[1:2]+raster::res(grid_nc)[1]/2
  raster::extent(grid_nc)[3:4]<-raster::extent(grid_nc)[3:4]-raster::res(grid_nc)[1]/2
  return(grid_nc)
}

# To open a GPM dataset that was downloaded via OpenDap
importData_gpm<-function(path_to_nc,var_name){

  rast<-raster::raster(path_to_nc,varname=var_name)
  raster::projection(rast)<-"+init=epsg:4326 +proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0 "
  # The raster has to be flipped. Output was validated with the data from 2017-09-20 (see https://docserver.gesdisc.eosdis.nasa.gov/public/project/GPM/browse/GPM_3IMERGDF.png)
  rast <- raster::t(rast)
  rast <- raster::flip(rast,'y')
  rast <- raster::flip(rast,'x')

  return(rast)

}


importData_era5<-function(path_to_nc){

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


importData_smap<-function(path_to_nc,var_name,minLon,minLat,maxLon,maxLat){

  if(file.info(path_to_nc)$size<2000){
    r <- "no data available"
  } else {
    nc<-ncdf4::nc_open(path_to_nc)
    nc_soilmosture<-ncdf4::ncvar_get(nc, var_name)
    #if(grepl("_AM_",var_name)){
    #  nc_lon<-ncdf4::ncvar_get(nc, "Soil_Moisture_Retrieval_Data_AM_longitude")
    #  nc_lat<-ncdf4::ncvar_get(nc, "Soil_Moisture_Retrieval_Data_AM_latitude")
    #} else if(grepl("_PM_",var_name)){
    #  nc_lon<-ncdf4::ncvar_get(nc, "Soil_Moisture_Retrieval_Data_PM_longitude_pm")
    #  nc_lat<-ncdf4::ncvar_get(nc, "Soil_Moisture_Retrieval_Data_PM_latitude_pm")
    #}

    nc_soilmosture[nc_soilmosture == -9999] <- NA
    #nc_lon[nc_lon == -9999] <- NA
    #nc_lat[nc_lat == -9999] <- NA

    #    ind <- apply(nc_soilmosture, 1, function(x) all(is.na(x)))
    #    nc_soilmosture <- nc_soilmosture[ !ind, ]
    #    nc_lon <- nc_lon[ !ind, ]
    #    nc_lat <- nc_lat[ !ind, ]

    #    if(!(purrr::is_empty(nc_soilmosture))){
    #      xmn=min(nc_lon,na.rm = T)
    #      xmx=max(nc_lon,na.rm = T)
    #  ymn=min(nc_lat,na.rm = T)
    #  ymx=max(nc_lat,na.rm = T)
    #  if(xmn!=xmx && ymn!=ymx){
    #   r <- raster(t(nc_soilmosture), xmn=xmn, xmx=xmx, ymn=ymn, ymx=ymx, crs=CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs+ towgs84=0,0,0"))
    # } else {
    #   r <- "no data available"
    # }
    #} else {
    #  r <- "no data available"
    #}

    r <- raster::raster(t(nc_soilmosture), xmn=minLon, xmx=maxLon, ymn=minLat, ymx=maxLat, crs=sp::CRS("+init=epsg:6933"))


  }
  return(r)

}


importData_tamsat<-function(path_to_nc,roi){

  rast<-raster::raster(path_to_nc)

  # extend a bit the size of the bbox
  bbox_tamsat<-sf::extent(roi)
  bbox_tamsat[1]=bbox_tamsat[1]-0.5
  bbox_tamsat[2]=bbox_tamsat[2]+0.5
  bbox_tamsat[3]=bbox_tamsat[3]-0.5
  bbox_tamsat[4]=bbox_tamsat[4]+0.5

  # Crop to the bbox
  rast<-raster::raster(path_to_nc) %>%
    raster::crop(bbox_tamsat)

  return(rast)

}
