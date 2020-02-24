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
#' # Get the variables available for the collection MOD11A1.006
#' (df_varinfo <- odr_list_variables("VIIRS_DNB_MONTH"))
#'}
#'


grd_list_variables <- function(collection){

  df_variables <- NULL

  df_variables <- grdVariables_internal[which(grdMetadata_internal$collection==collection),]
  df_variables$collection <- NULL

  return(df_variables)

}
