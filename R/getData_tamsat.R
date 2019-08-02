#' @name getData_tamsat
#' @aliases getData_tamsat
#' @title Download TAMSAT time series data
#' @description This function enables to retrieve URLs of TAMSAT datasets for a given time frame, and eventually download the data
#' @export
#'
#' @param timeRange Date(s) of interest. Mandatory. See Details for addition information on how to provide the dates.
#' @param output_time_step
#' @param output_product
#' @param output_output
#' @param download logical. Download data ?
#' @param destFolder string. Mandatory if \code{download} is set to TRUE. The destination folder (i.e. folder where the data will be downloaded)
#'
#' @return a data.frame with 3 columns :
#'  \itemize{
#'  \item{"name": }{Names (unique identifiers) of each dataset }
#'  \item{"url": }{URL to download the dataset}
#'  \item{"destfile": }{Local destination file}
#'  }
#'
#' If \code{download} is set to TRUE, the data are downloaded to \code{destFolder}
#'
#' @details
#'
#' Additional information : https://www.tamsat.org.uk/data/archive
#'
#' @author Paul Taconet, IRD \email{paul.taconet@ird.fr}
#'
#' @family getData
#'
#' @import purrr dplyr
#'
#' @examples
#'
#' timeRange<-c("2017-01-01","2017-01-30") %>% as.Date()
#'
#' \dontrun{
#' getData_tamsat(timeRange=timeRange,
#' output_time_step="daily",
#' output_product="rainfall_estimate",
#' output_output="individual",
#' download=FALSE
#' )
#'}
#'

getData_tamsat<-function(timeRange=as.Date(c("2017-01-01","2017-01-30")), # mandatory. either a time range (e.g. c(date_start,date_end) ) or a single date e.g. ( date_start )
                         output_time_step="daily", # {daily,monthly}
                         output_product="rainfall_estimate", # {rainfall_estimate,anomaly (only if output_time_step==monthly) ,climatology (only if output_time_step==monthly)}
                         output_output="individual", # {individual,yearly}
                         download=FALSE, # TRUE will download the file and return a dataframe with : the URL, the path to the output file, a boolean wether the dataset was properly downloaded or not. FALSE will return a list with the URL only
                         destFolder=getwd(),
                         ...){

  url_tamsat_data<-"https://www.tamsat.org.uk/public_data/TAMSAT3"

  timeRange<-as.Date(timeRange, origin="1970-01-01")

  datesToRetrieve<-seq(timeRange[2],timeRange[1],-1) %>%
    data.frame(stringsAsFactors = F) %>%
    set_names("date") %>%
    mutate(date_character=as.character(as.Date(date))) %>%
    mutate(year=format(date,'%Y')) %>%
    mutate(month=format(date,'%m')) %>%
    mutate(day=format(date,'%d'))

  urls<-datesToRetrieve %>%
    mutate(product_name_daily_rain_individual=paste0("rfe",year,"_",month,"_",day,".v3.nc")) %>%
    mutate(url_product_daily_rain_individual=paste0(url_tamsat_data,"/",year,"/",month,"/",product_name_daily_rain_individual)) %>%
    mutate(product_name_daily_rain_yearly=paste0("TAMSATv3.0_rfe_daily_",year,".zip")) %>%
    mutate(url_product_daily_rain_yearly=paste0(url_tamsat_data,"/zip/",product_name_daily_rain_yearly)) %>%
    mutate(product_name_monthly_rain_individual=paste0("rfe",year,"_",month,".v3.nc")) %>%
    mutate(url_product_monthly_rain_individual=paste0(url_tamsat_data,"/",year,"/",month,"/",product_name_monthly_rain_individual)) %>%
    mutate(product_name_monthly_rain_yearly=paste0("TAMSATv3.0_rfe_monthly_",year,".zip")) %>%
    mutate(url_product_monthly_rain_yearly=paste0(url_tamsat_data,"/zip/",product_name_monthly_rain_yearly)) %>%
    mutate(product_name_monthly_anomaly_individual=paste0("rfe",year,"_",month,"_anom.v3.nc")) %>%
    mutate(url_product_monthly_anomaly_individual=paste0(url_tamsat_data,"/",year,"/",month,"/",product_name_monthly_anomaly_individual)) #%>%
  #mutate(product_name_monthly_climatology_individual=paste0("rfe",year,"-",year,"_",month,"_clim.v3.nc")) %>%
  #mutate(url_product_monthly_climatology_individual=paste0(url_tamsat_data,"/clim","/",month,"/",product_name_monthly_climatology_individual))


  if (output_time_step=="daily" & output_product=="rainfall_estimate" & output_output=="individual"){
    urls <- urls %>% dplyr::select(product_name_daily_rain_individual,url_product_daily_rain_individual)
  } else if (output_time_step=="daily" & output_product=="rainfall_estimate" & output_output=="yearly"){
    urls <- urls %>% dplyr::select(product_name_daily_rain_yearly,url_product_daily_rain_yearly)
  } else if (output_time_step=="monthly" & output_product=="rainfall_estimate" & output_output=="individual"){
    urls <- urls %>% dplyr::select(product_name_monthly_rain_individual,url_product_monthly_rain_individual)
  } else if (output_time_step=="monthly" & output_product=="rainfall_estimate" & output_output=="yearly"){
    urls <- urls %>% dplyr::select(product_name_monthly_rain_yearly,url_product_monthly_rain_yearly)
  } else if (output_time_step=="monthly" & output_product=="anomaly" & output_output=="individual"){
    urls <- urls %>% dplyr::select(product_name_monthly_anomaly_individual,url_product_monthly_anomaly_individual)
  } #else if (output_time_step=="monthly" & output_product=="climatology" & output_output=="individual"){
  #urls <- urls %>% select(product_name_monthly_climatology_individual,url_product_monthly_climatology_individual)
  #}
  urls$destfiles<-file.path(destFolder,urls$product_name_daily_rain_individual)

  res<-data.frame(name=urls[,1],url=urls[,2],destfile=urls[,3],stringsAsFactors = F)

  if (download){
    cat("Downloading the data...\n")
    res<-getRemoteData::downloadData(res, ...)
  }

  return(res)

}
