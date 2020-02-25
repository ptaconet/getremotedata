#' @name grd_list_variables
#' @aliases grd_list_variables
#' @title Get informations related to the variables available for a given collection
#' @description Get the variables available for a given collection
#'
#' @inheritParams grd_get_url
#'
#' @return A data.frame with the available variables for the collection, and a set of related information for each variable.
#'
#' @export
#'
#' @examples
#'
#' # Get the variables available for the collection VIIRS_DNB_MONTH
#' (df_varinfo <- grd_list_variables("VIIRS_DNB_MONTH"))
#'
#'


grd_list_variables <- function(collection){

  df_variables <- NULL

  .testIfCollExists(collection)
  metadata_coll <- grdMetadata_internal[which(grdMetadata_internal$collection==collection),]
  if(metadata_coll$param_variables==FALSE){warning("The collection that you have specified does not have variables")}

  df_variables <- grdVariables_internal[which(grdVariables_internal$collection==collection),]

  df_variables$collection <- NULL

  return(df_variables)

}
