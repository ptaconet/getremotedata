  #' @name prepareData_smap
  #' @aliases prepareData_smap
  #' @title Open a SMAP product as a \code{raster} object
  #' @description This function opens as a \code{raster} object a SMAP product that was downloaded via the \code{getData_smap} and \code{dowloadData} functions
  #' @export
  #'
  #' @param path_to_raw_modis string. Path to the data in .nc4 format
  #' @param var_name string. Dimension name (e.g. "Soil_Moisture_Retrieval_Data_AM_soil_moisture")
  #'
  #' @return a \code{raster} object (EPSG 4326)
  #'
  #' @author Paul Taconet, IRD \email{paul.taconet@ird.fr}
  #'
  #' @family prepareData
  #'
  #' @import raster ncdf4
  #'
  #' @examples
  #'
  #' path_to_gpm<-system.file("extdata/smap_example.nc4", package = "getRemoteData")
  #'
  #' rast_smap<-prepareData_smap(path_to_raw_smap=path_to_smap,
  #' var_name="Soil_Moisture_Retrieval_Data_AM_soil_moisture")
  #' #plot(rast_smap)
  #'

      prepareData_smap<-function(path_to_raw_smap,var_name,minLon,minLat,maxLon,maxLat){

    if(file.info(path_to_raw_smap)$size<2000){
      r <- "no data available"
    } else {
    nc<-ncdf4::nc_open(path_to_raw_smap)
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

     r <- raster(t(nc_soilmosture), xmn=minLon, xmx=maxLon, ymn=minLat, ymx=maxLat, crs=CRS("+init=epsg:6933"))


    }
    return(r)

  }
