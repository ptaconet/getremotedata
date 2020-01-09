#' @name getUrl_tamsat
#' @aliases getUrl_tamsat
#' @title Get URLs of TAMSAT datasets
#' @description This function enables to retrieve URLs of TASMAT products given a collection and a time frame.
#' @export
#'
#' @inheritParams getUrl_modis_vnp
#'
#' @inherit getUrl_modis_vnp return
#'
#' @details
#'
#' Argument \code{collection} is a list of length 3 :
#' \itemize{
#' \item{*output_time_step*: }{available values : "daily" ; "monthly"}
#' \item{*output_product*: }{available values : "rainfall_estimate" ; "anomaly" (only if output_time_step=="monthly") ; "climatology" (only if output_time_step=="monthly") }
#' \item{*output_output*: }{available values : "individual" ; "yearly"}
#'  }
#'
#' Additional information : https://www.tamsat.org.uk/data/archive
#'
#' @author Paul Taconet, IRD \email{paul.taconet@ird.fr}
#'
#' @family getUrl
#'
#' @examples
#'
#' \dontrun{
#'
#' timeRange<-as.Date(c("2017-01-01","2017-01-30"))
#'
#' ### Retrieve the URLs to download TAMSAT products for the whole time frame :
#' df_data_to_dl<-getRemoteData::getUrl_tamsat(
#' timeRange=timeRange,
#' collection=list("daily","rainfall_estimate","individual")
#' )
#'
#'# Set destination folder
#' df_data_to_dl$destfile<-file.path(getwd(),df_data_to_dl$name)
#'
#'# Download the data
#'res_dl<-getRemoteData::downloadData(df_data_to_dl,parallelDL=TRUE)
#'
#'# Open the data as a list of rasters
#'rasts_tamsat<-purrr::map(res_dl$destfile,~raster::raster(.))
#'
#'# plot the first date :
#' raster::plot(rasts_tamsat[[1]])
#'
#'}
#'

getUrl_tamsat<-function(timeRange, # mandatory. either a time range (e.g. c(date_start,date_end) ) or a single date e.g. ( date_start )
                        collection
                        ){

  if(!is(timeRange,"Date")){stop("Argument timeRange is not of class Date")}

  output_time_step<-collection[[1]]
  output_product<-collection[[2]]
  output_output<-collection[[3]]
  if(!(output_time_step %in% c("daily","monthly"))){stop("Wrong value in argument output_time_step")}
  if(!(output_product %in% c("rainfall_estimate","anomaly"))){stop("Wrong value in argument output_product")}
  if(!(output_output %in% c("individual","yearly"))){stop("Wrong value in argument output_output")}

  url_tamsat_data<-"https://www.tamsat.org.uk/public_data/TAMSAT3"

  timeRange<-as.Date(timeRange, origin="1970-01-01")

  datesToRetrieve<-seq(timeRange[2],timeRange[1],-1) %>%
    data.frame(stringsAsFactors = F) %>%
    purrr::set_names("date") %>%
    dplyr::mutate(date_character=as.character(as.Date(date))) %>%
    dplyr::mutate(year=format(date,'%Y')) %>%
    dplyr::mutate(month=format(date,'%m')) %>%
    dplyr::mutate(day=format(date,'%d'))

  urls<-datesToRetrieve %>%
    dplyr::mutate(product_name_daily_rain_individual=paste0("rfe",year,"_",month,"_",day,".v3.nc")) %>%
    dplyr::mutate(url_product_daily_rain_individual=paste0(url_tamsat_data,"/",year,"/",month,"/",product_name_daily_rain_individual)) %>%
    dplyr::mutate(product_name_daily_rain_yearly=paste0("TAMSATv3.0_rfe_daily_",year,".zip")) %>%
    dplyr::mutate(url_product_daily_rain_yearly=paste0(url_tamsat_data,"/zip/",product_name_daily_rain_yearly)) %>%
    dplyr::mutate(product_name_monthly_rain_individual=paste0("rfe",year,"_",month,".v3.nc")) %>%
    dplyr::mutate(url_product_monthly_rain_individual=paste0(url_tamsat_data,"/",year,"/",month,"/",product_name_monthly_rain_individual)) %>%
    dplyr::mutate(product_name_monthly_rain_yearly=paste0("TAMSATv3.0_rfe_monthly_",year,".zip")) %>%
    dplyr::mutate(url_product_monthly_rain_yearly=paste0(url_tamsat_data,"/zip/",product_name_monthly_rain_yearly)) %>%
    dplyr::mutate(product_name_monthly_anomaly_individual=paste0("rfe",year,"_",month,"_anom.v3.nc")) %>%
    dplyr::mutate(url_product_monthly_anomaly_individual=paste0(url_tamsat_data,"/",year,"/",month,"/",product_name_monthly_anomaly_individual)) #%>%
  #mutate(product_name_monthly_climatology_individual=paste0("rfe",year,"-",year,"_",month,"_clim.v3.nc")) %>%
  #mutate(url_product_monthly_climatology_individual=paste0(url_tamsat_data,"/clim","/",month,"/",product_name_monthly_climatology_individual))


  if (output_time_step=="daily" & output_product=="rainfall_estimate" & output_output=="individual"){
    urls <- urls %>% dplyr::select(product_name_daily_rain_individual,url_product_daily_rain_individual,date)
  } else if (output_time_step=="daily" & output_product=="rainfall_estimate" & output_output=="yearly"){
    urls <- urls %>% dplyr::select(product_name_daily_rain_yearly,url_product_daily_rain_yearly,date)
  } else if (output_time_step=="monthly" & output_product=="rainfall_estimate" & output_output=="individual"){
    urls <- urls %>% dplyr::select(product_name_monthly_rain_individual,url_product_monthly_rain_individual,date)
  } else if (output_time_step=="monthly" & output_product=="rainfall_estimate" & output_output=="yearly"){
    urls <- urls %>% dplyr::select(product_name_monthly_rain_yearly,url_product_monthly_rain_yearly,date)
  } else if (output_time_step=="monthly" & output_product=="anomaly" & output_output=="individual"){
    urls <- urls %>% dplyr::select(product_name_monthly_anomaly_individual,url_product_monthly_anomaly_individual,date)
  } #else if (output_time_step=="monthly" & output_product=="climatology" & output_output=="individual"){
  #urls <- urls %>% select(product_name_monthly_climatology_individual,url_product_monthly_climatology_individual)
  #}

  #urls$destfiles<-file.path(destFolder,urls$product_name_daily_rain_individual)

  #res<-data.frame(name=urls[,1],url=urls[,2],destfile=urls[,3],stringsAsFactors = F)

  res<-data.frame(time_start=urls[,3],name=urls$product_name_daily_rain_individual,url=urls[,2],stringsAsFactors = F)

  return(res)

}
