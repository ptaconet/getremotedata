#' @name grd_list_collections
#' @aliases grd_list_collections
#' @title Get data sources / collections implemented in the package
#' @description This function returns a table of the data sources / collections that can be downloaded and pre-processed using the getremotedata package
#' @export
#'
#' @usage grd_list_collections()
#'
#' @param detailed Boolean. Return detailed information on each available data collection available ? TRUE by default. FALSE returns a summarized version of the available sources of data.
#' @return a data.frame with the data sources / collections dealt by getData, along with details on each data collection
#'
#' @details The output data.frame columns are:
#' \itemize{
#' \item{"source": }{The source acronym}
#' \item{"collection": }{The collection}
#' }
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
