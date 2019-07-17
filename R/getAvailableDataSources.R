#' @name getAvailableDataSources
#' @aliases getAvailableDataSources
#' @title Get data sources / collections implemented in the package
#' @description This function returns a table of the data sources / collections that can be downloaded and pre-processed using the getData package
#' @export
#'
#' @usage getAvailableDataSources()
#'
#' @return a data.frame with the data sources / collections dealt by getData, along with details on each data collection
#'
#' @details The output data.frame columns are:
#' \itemize{
#' \item{"source": }{The source acronym}
#' \item{"collection": }{The collection}
#' \item{"...": }{...TODO : finish description}
#' }
#'
#'
#' @family
#'
#'
#' @examples
#'
#' sources<-getAvailableDataSources()
#' sources
#'
#' @author Paul Taconet, \email{paul.taconet@@ird.fr}
#'


getAvailableDataSources<-function(){
  df_AvailableDataSources<-read.csv(system.file("extdata/data_collections.csv", package = "getData"))
  return(df_AvailableDataSources)
}
