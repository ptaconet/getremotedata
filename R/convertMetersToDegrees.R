#' @name convertMetersToDegrees
#' @aliases convertMetersToDegrees
#' @title Convert a length measurement from meters to degrees
#' @description Convert a length measurement from meters to degrees
#'
#' @param length_meters numeric. A length measurement in meters
#' @param latitude_4326  numeric. The latitude of the measurement
#'
#' @return a numeric. length is degrees
#'
#' @examples
#'
#' lenght_in_degrees<-convertMetersToDegrees(length_meters=1000,latitude_4326=-1.5)
#' lenght_in_degrees
#'
#' @author Paul Taconet, \email{paul.taconet@@ird.fr}
#'

convertMetersToDegrees<-function(length_meters,
                                 latitude_4326){

  length_degrees <- length_meters / (111.32 * 1000 * cos(latitude_4326 * ((pi / 180))))

  return(length_degrees)
}
