#' @name grd_get_url
#' @aliases grd_get_url
#' @title Build the URL(s) of the data to download
#' @description This is the main function of the package. It enables to build the URL(s) of the spatiotemporal datacube to download, given a collection, variables, region and time range of interest.
#'
#' @param collection string. mandatory. Collection of interest (see details).
#' @param variables string vector. optional. Variables to retrieve for the collection of interest. If not specified (default) all available variables will be extracted (see details).
#' @param roi object of class \code{sf} or \code{sfc}. mandatory. Region of interest. Must be POLYGON-type geometry composed of one single feature.
#' @param time_range date(s) / POSIXlt of interest . mandatory. Single date/datetime or time frame : vector with start and end dates/times (see details).
#' @param credentials vector string of length 2 with username and password. optional.
#' @param verbose boolean. optional. Verbose (default TRUE)
#'
#' @return a data.frame with one row for each dataset to download and 4 columns  :
#'  \describe{
#'  \item{time_start}{Start Date/time for the dataset}
#'  \item{name}{Indicative name for the dataset}
#'  \item{url}{http URL of the dataset}
#'  \item{destfile}{Indicative destination file for the dataset}
#'  }
#'
#' @details
#'
#' Argument \code{collection} : Collections available can be retrieved with the function \link{grd_list_collections}
#'
#' Argument \code{variables} : For each collection, variables available can be retrieved with the function \link{grd_list_variables}
#'
#' Argument \code{time_range} : Can be provided either as i) a single date (e.g. \code{as.Date("2017-01-01"))} or ii) a time frame provided as two bounding dates (starting and ending time) ( e.g. \code{as.Date(c("2010-01-01","2010-01-30"))}) or iii) a POSIXlt single time (e.g. \code{as.POSIXlt("2010-01-01 18:00:00")}) or iv) a POSIXlt time range (e.g. \code{as.POSIXlt(c("2010-01-01 18:00:00","2010-01-02 09:00:00"))}) for the half-hourly collection (GPM_3IMERGHH.06). If POSIXlt, times must be in UTC.
#'
#' @export
#'
#' @importFrom stringr str_replace
#' @import dplyr
#'
#' @example
#'
#' require(sf)
#' roi = st_as_sf(data.frame(
#' geom="POLYGON ((-5.82 9.54, -5.42 9.55, -5.41 8.84, -5.81 8.84, -5.82 9.54))"),
#' wkt="geom",crs = 4326)
#'
#' time_range = as.Date(c("2017-01-01","2017-01-30"))
#'
#' # SRTM
#' strm_urls <- grd_get_url(collection="SRTMGL1.003",roi=roi)
#'
#' # TAMSAT
#' tamsat_urls <- grd_get_url(collection="TAMSAT",variables = c("daily_rainfall_estimate","monthly_rainfall_estimate","monthly_anomaly"), time_range=time_range)
#'
#' # VIIRS_DNB_MONTH
#' viirsdnb_urls <- grd_get_url(collection="VIIRS_DNB_MONTH",variables = c("Monthly_AvgRadiance","Monthly_CloudFreeCoverage"), roi=roi, time_range=time_range)
#'
#' # MIRIADE
#' imcce_urls <- grd_get_url(collection="MIRIADE",roi=roi,time_range=time_range)
#'
#' # ERA5
#' era5_urls <- grd_get_url(collection="ERA5",variables = c("10m_u_component_of_wind","10m_v_component_of_wind"), roi=roi, time_range=time_range)
#'



grd_get_url<-function(collection,
                      variables=NULL,
                      roi=NULL,
                      time_range=NULL,
                      credentials=NULL,
                      verbose=TRUE){

  # tests
  .testIfCollExists(collection)
  .testInternetConnection()

  if(!inherits(verbose,"logical")){stop("verbose argument must be boolean\n")}

  metadata_coll <- grdMetadata_internal[which(grdMetadata_internal$collection==collection),]
  if(is.null(variables) && metadata_coll$param_variables==TRUE){stop("The collection that you have specified needs a 'variables' parameter")}
  if(is.null(roi) && metadata_coll$param_roi==TRUE){stop("The collection that you have specified needs a 'roi' parameter")}
  if(is.null(time_range) && metadata_coll$param_time_range==TRUE){stop("The collection that you have specified needs a 'time_range' parameter")}
  #if(is.null(credentials) && metadata_coll$param_credentials==TRUE){stop("The collection that you have specified needs a 'credentials' parameter")}

  if(!is.null(roi)){.testRoi(roi)}
  if(!is.null(time_range)){.testTimeRange(time_range)}

  if(metadata_coll$param_variables==TRUE){
    available_dim<-grd_list_variables(collection)$name
    .testIfVarExists(variables,available_dim)
  }


  if(collection=="SRTMGL1.003"){

    table_urls <- .grd_get_url_srtm(roi)

  } else if(collection=="TAMSAT"){

    table_urls <- .grd_get_url_tamsat(variables,time_range)

  } else if(collection=="ERA5"){

    table_urls <- .grd_get_url_era5(variables,roi,time_range)

  } else if (collection=="MIRIADE"){

    table_urls <- .grd_get_url_imcce(roi,time_range)

  } else if (collection=="VIIRS_DNB_MONTH"){

    table_urls <- .grd_get_url_viirsDnb(variables,roi,time_range)

  }

  table_urls <- table_urls %>%
    dplyr::mutate(name=stringr::str_replace(name,".*/","")) %>%
    dplyr::mutate(destfile=file.path(collection,.$name)) %>%
    dplyr::select(time_start,name,url,destfile)

  if(verbose){cat("OK\n")}

  return(table_urls)

}
