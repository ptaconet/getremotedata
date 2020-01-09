#' @name getAvailableDataSources
#' @aliases getAvailableDataSources
#' @title Get data sources / collections implemented in the package
#' @description This function returns a table of the data sources / collections that can be downloaded and pre-processed using the getData package
#' @export
#'
#' @usage getAvailableDataSources()
#'
#' @param detailed Boolean. Return detailed information on each available data collection available ? TRUE by default. FALSE returns a summarized version of the available sources of data.
#' @return a data.frame with the data sources / collections dealt by getData, along with details on each data collection
#'
#' @details The output data.frame columns are:
#' \itemize{
#' \item{"source": }{The source acronym}
#' \item{"collection": }{The collection}
#' \item{"...": }{...TODO : finish description}
#' }
#'
#' @examples
#'
#' sources<-getAvailableDataSources()
#' sources
#'
#' @author Paul Taconet, \email{paul.taconet@@ird.fr}
#'


getAvailableDataSources<-function(detailed=TRUE){
  if (detailed==TRUE){
    df_AvailableDataSources<-utils::read.csv(system.file("extdata/data_collections.csv", package = "getRemoteData"),stringsAsFactors=F)
  } else {
    df_AvailableDataSources<-utils::read.csv(system.file("extdata/data_collections_simple.csv", package = "getRemoteData"),stringsAsFactors=F)
  }
  return(df_AvailableDataSources)
}
