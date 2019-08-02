#' @name ancillaryFunctions_general
#' @aliases ancillaryFunctions_general
#' @title A set of ancillary functions
#' @description A set of ancillary functions
#' @export convertMetersToDegrees getUTMepsg getMODIStileNames getSRTMtileNames
#'
#' @param roi sf polygon object. a region of interest
#'
#' @import sf dplyr stringr geojsonsf
#'
#' @author Paul Taconet, \email{paul.taconet@@ird.fr}
#'

convertMetersToDegrees<-function(length_meters,
                                 latitude_4326){

  length_degrees <- length_meters / (111.32 * 1000 * cos(latitude_4326 * ((pi / 180))))

  return(length_degrees)
}

  getUTMepsg<-function(roi){

  bbox<-st_bbox(roi)
  #  cat("Warning: ROIs overlapping more than 1 UTM zone are currently not adapted in this workflow\n")
  utm_zone_number<-(floor((bbox$xmin + 180)/6) %% 60) + 1
  if(bbox$ymin>0){ # if latitudes are North
    epsg<-as.numeric(paste0("326",utm_zone_number))
  } else { # if latitude are South
    epsg<-as.numeric(paste0("325",utm_zone_number))
  }

  return(epsg)
}


getMODIStileNames<-function(roi){

  options(warn=-1)
  modis_tile = read_sf("https://modis.ornl.gov/files/modis_sin.kmz") %>%
    st_intersection(roi) %>%
    as.data.frame() %>%
    dplyr::select(Name) %>%
    as.character()
  options(warn=0)

  if(length(unique(modis_tile))>1){
    stop("Your ROI is overlapping more than 1 MODIS tile. This workflow is currently not adapted for this case\n")
  } else {
    modis_tile<-modis_tile %>%
      unique() %>%
      stringr::str_replace_all(c(" "="",":"=""))
    for (i in 1:9){
      modis_tile<-gsub(paste0("h",i,"v"),paste0("h0",i,"v"),modis_tile)
    }
    if(nchar(modis_tile)!=6){
      modis_tile<-paste0(substr(modis_tile,1,4),"0",substr(modis_tile,5,5))
    }
  }

  return(modis_tile)
}


getSRTMtileNames<-function(roi){

  srtm_tiles <- geojsonsf::geojson_sf("http://dwtkns.com/srtm30m/srtm30m_bounding_boxes.json")  %>%
    sf::st_intersection(roi) %>%
    as.data.frame()

  SRTMtileNames<-substr(srtm_tiles$dataFile,1,7)

  return(SRTMtileNames)
}

