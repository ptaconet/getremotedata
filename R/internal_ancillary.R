#' @name .getSRTMtileNames
#' @title A set of ancillary functions
#' @noRd
#' @importFrom geojsonsf geojson_sf
#' @importFrom sf st_transform st_intersection

.getSRTMtileNames<-function(roi){

  srtm_tiles <- NULL
  SRTMtileNames <- NULL
  roi<-sf::st_transform(roi,4326)

  srtm_tiles <- geojsonsf::geojson_sf("http://dwtkns.com/srtm30m/srtm30m_bounding_boxes.json")  %>%
    sf::st_intersection(roi) %>%
    as.data.frame()

  SRTMtileNames<-substr(srtm_tiles$dataFile,1,7)

  return(SRTMtileNames)
}
