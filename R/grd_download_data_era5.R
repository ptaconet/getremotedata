#' @name grd_download_data_era5
#' @aliases grd_download_data_era5
#' @title Download ERA5 data
#' @description Download ERA5 data after querying with the function \link{grd_get_url}
#'
#' @param output_grd_get_url_era5 output of \link{grd_get_url} with collection="ERA5"
#'
#' @return NULL
#'
#' @note
#'
#' There must exist the file .cdsapirc in the root directory of the computer (e.g. "/home/ptaconet"). See \url{https://dominicroye.github.io/en/2018/access-to-climate-reanalysis-data-from-r/} for additional details
#'
#' @export
#'
#' @import reticulate
#' @importFrom magrittr %>%
#'
#' @examples
#' \dontrun{
#' require(sf)
#'
#' roi = st_as_sf(data.frame(
#' geom = "POLYGON ((-5.82 9.54, -5.42 9.55, -5.41 8.84, -5.81 8.84, -5.82 9.54))"),
#' wkt = "geom",crs = 4326)
#'
#' time_range = as.Date(c("2017-01-01","2017-01-30"))
#'
#' # query to get ERA5 url
#' era5_urls <- grd_get_url(collection = "ERA5", variables = c("10m_u_component_of_wind","10m_v_component_of_wind"), roi = roi, time_range = time_range)
#'
#' # now download data
#' grd_download_data_era5(era5_urls)
#'}


grd_download_data_era5 <- function(output_grd_get_url_era5){

  unique(dirname(output_grd_get_url_era5$destfile)) %>% lapply(dir.create,recursive = TRUE, showWarnings = FALSE)

  cat("Downloading the data...\n")
  ##import python CDS-API
   cdsapi <- reticulate::import('cdsapi')
  ##for this step there must exist the file .cdsapirc in the root directory of the computer (e.g. "/home/ptaconet")
    server = cdsapi$Client() #start the connection
    for (i in 1:nrow(output_grd_get_url_era5)){
      cat("Downloading data n° ",i," over ",nrow(output_grd_get_url_era5),"\n")
      server$retrieve("reanalysis-era5-single-levels",
                      output_grd_get_url_era5$url[[i]],
                      output_grd_get_url_era5$destfile[[i]])
    }

    return(NULL)
}
