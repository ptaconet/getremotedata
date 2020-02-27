#' @name grd_list_collections
#' @aliases grd_list_collections
#' @title Get data sources / collections implemented in the package
#' @description This function returns a table of the data sources / collections that can be downloaded and pre-processed using the getremotedata package
#' @export
#'
#' @usage grd_list_collections()
#'
#' @return a data.frame with the data sources / collections dealt by grd_list_collections, along with details on each data collection
#'
#' @export
#' @examples
#'
#' sources<-grd_list_collections()
#' sources
#'
#' @author Paul Taconet, \email{paul.taconet@@ird.fr}
#'


grd_list_collections<-function(){

  return(grdMetadata_internal)

}
