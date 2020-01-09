#' @name ancillaryFunctions_general
#' @aliases ancillaryFunctions_general
#' @title A set of ancillary functions
#' @description A set of ancillary functions
#' @export getMODIStileNames getSRTMtileNames .testCollVal login_earthdata
#'
#' @param roi sf polygon object. a region of interest
#'
#'
#' @author Paul Taconet, \email{paul.taconet@@ird.fr}
#'

getMODIStileNames<-function(roi){

  if(!is(roi,"sf")){stop("roi is not of class sf")}
  roi<-sf::st_transform(roi,4326)
  options(warn=-1)
  modis_tile = sf::read_sf("https://modis.ornl.gov/files/modis_sin.kmz") %>%
    sf::st_intersection(roi) %>%
    as.data.frame() %>%
    dplyr::select(Name) %>%
    as.character()
  options(warn=0)

  if(length(unique(modis_tile))>1){
    stop("Your ROI is overlapping more than 1 MODIS tile. The package currently does not support multiple MODIS tiles\n")
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

  if(!is(roi,"sf")){stop("roi is not of class sf")}
  roi<-sf::st_transform(roi,4326)

  srtm_tiles <- geojsonsf::geojson_sf("http://dwtkns.com/srtm30m/srtm30m_bounding_boxes.json")  %>%
    sf::st_intersection(roi) %>%
    as.data.frame()

  SRTMtileNames<-substr(srtm_tiles$dataFile,1,7)

  return(SRTMtileNames)
}

# Check if the collection has been tested and validated
.testCollVal<-function(source_,collection_){
  collections_validated<-getRemoteData::getAvailableDataSources() %>%
    dplyr::filter(source %in% source_ & collection==collection_)

  if(nrow(collections_validated)==0){
    stop("The collection specified is not valid or has not been validated.\n Check out which collections are available with the function getAvailableDataSources()")
  }

}

# login to earthdata products
login_earthdata<-function(username,password){
  x <- httr::POST(url = 'https://earthexplorer.usgs.gov/inventory/json/v/1.4.0/login',
                  body = URLencode(paste0('jsonRequest={"username":"', username, '","password":"', password, '","authType":"EROS","catalogId":"EE"}')),
                  httr::content_type("application/x-www-form-urlencoded; charset=UTF-8"))
  httr::stop_for_status(x, "connect to server.")
  httr::warn_for_status(x)
  v <- httr::content(x)$data
  if(is.null(v)){
    stop("Login to EarthData failed. Check out username and password")
  } else {
    options(earthdata_user=username)
    options(earthdata_pass=password)
    options(earthdata_login=TRUE)
    cat("\nSuccessfull login to EarthData")
  }
}
