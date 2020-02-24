#' @name .grd_get_url_era5
#' @aliases .grd_get_url_era5
#' @title Download Copernicus ERA-5 time series data
#' @description This function enables to retrieve URLs of ERA-5 products given a ROI, a time frame and a set of variables of interest.
#' @export
#'
#' @author Paul Taconet, IRD \email{paul.taconet@ird.fr}
#'
#'
#' @noRd
#'

.grd_get_url_era5<-function(variables,
                           roi,
                           time_range
){

  # Check : https://dominicroye.github.io/en/2018/access-to-climate-reanalysis-data-from-r/

  # ERA 5 : https://cds.climate.copernicus.eu/cdsapp#!/dataset/reanalysis-era5-single-levels?tab=overview

  # Description of the wind data: https://apps.ecmwf.int/codes/grib/param-db?id=165 and https://apps.ecmwf.int/codes/grib/param-db?id=166

  getQuery<-function(variables,year,month,day,hour,roi_bbox){

    query <- reticulate::r_to_py(list(
      variable= variables,
      product_type= "reanalysis",
      year= year,
      month=month, #formato: "01","01", etc.
      day= day, #stringr::str_pad(1:31,2,"left","0"),
      time= hour, #stringr::str_c(0:23,"00",sep=":")%>%str_pad(5,"left","0"),
      format= "netcdf",
      area = paste0(roi_bbox$ymax,"/",roi_bbox$xmin,"/",roi_bbox$ymin,"/",roi_bbox$xmax) # North, West, South, East
    ))

    return(query)

  }

  roi_bbox<-sf::st_bbox(sf::st_transform(roi,4326))

  time_range=as.POSIXlt(time_range,tz="GMT")

  datesToRetrieve<-seq(from=time_range[2],to=time_range[1],by="-1 hour") %>%
    data.frame(stringsAsFactors = F) %>%
    purrr::set_names("date") %>%
    dplyr::mutate(date_character=as.character(as.Date(date))) %>%
    dplyr::mutate(year=format(date,'%Y')) %>%
    dplyr::mutate(month=format(date,'%m')) %>%
    dplyr::mutate(day=format(date,"%d")) %>%
    dplyr::mutate(hour=format(date,"%H"))
  #mutate(hour_era5=as_datetime(c(t*60*60),origin="1900-01-01")) %>%

  res<-datesToRetrieve %>%
    dplyr::mutate(url=purrr::pmap(list(year,month,day,hour),~getQuery(variables,..1,..2,..3,..4,roi_bbox))) %>%
    dplyr::mutate(name=paste0(year,month,day,"_",hour,".nc")) %>%
    dplyr::select(name,url,date) %>%
    dplyr::rename(time_start=date)


  return(res)

  #if (download){
  #  cat("Downloading the data...\n")
    ## Parameters for download of ERA 5 data
    ##import python CDS-API
  # cdsapi <- reticulate::import('cdsapi')
  ##for this step there must exist the file .cdsapirc in the root directory of the computer (e.g. "/home/ptaconet")
  #  server = cdsapi$Client() #start the connection
  #  for (i in 1:nrow(res)){
  #    server$retrieve("reanalysis-era5-single-levels",
  #                    res$url[[i]],
  #                    res$destfile[[i]])
  #  }

  #}

  #for (i in 1:length(res)){
  #  for (j in 1:length(res[[i]])){
  #    for (k in 1:length(res[[i]][[j]]$destfile)){
  #      if (!file.exists(era5Data_md[[i]][[j]]$destfile[k])){
  #         server$retrieve("reanalysis-era5-single-levels",
  #                         res[[i]][[j]]$url[k][[1]],
  #                         res[[i]][[j]]$destfile[k])
  #      }
  #    }
  #  }
  #}


}




#' @name .grd_get_url_imcce
#' @aliases .grd_get_url_imcce
#' @title Download IMCCE time series data
#' @description This function enables to retrieve URLs of IMCCE datasets for a given ROI and time frame, and eventually download the data
#' @details
#'
#' Argument \code{time_range} can be provided either as a single date (e.g. \code{as.Date("2017-01-01"))} or time frame provided as two bounding dates ( e.g. \code{as.Date(c("2010-01-01","2010-01-30"))})
#'
#' @author Paul Taconet, IRD \email{paul.taconet@ird.fr}
#'
#' @family get_url
#'
#' @noRd
#'

.grd_get_url_imcce<-function(roi,time_range){

  if(!is(time_range,"Date")){stop("Argument time_range is not of class Date")}
  if(!is(roi,"sf")){stop("roi is not of class sf")}

  url_imcce_webservice<-"http://vo.imcce.fr/webservices/miriade/ephemcc_query.php?"

  if(length(time_range)==1){
    time_range=c(time_range,time_range)
  }

  roi_bbox<-sf::st_bbox(st_transform(roi,4326))

  datesToRetrieve<-seq(from=time_range[2],to=time_range[1],by=-1) %>%
    as.data.frame() %>%
    purrr::set_names("date")

  table_urls<-datesToRetrieve %>%
    dplyr::mutate(url=paste0(url_imcce_webservice,"-name=s:Moon&-type=Satellite&-ep=",date,"T23:30:00&-nbd=1d&-step=1h&-tscale=UTC&-observer=",mean(c(roi_bbox$xmin,roi_bbox$xmax)),"%20",mean(c(roi_bbox$ymin,roi_bbox$ymax)),"%200.0&-theory=INPOP&-teph=1&-tcoor=1&-mime=text/csv&-output=--jd&-extrap=0&-from=MiriadeDoc")) %>%
    dplyr::mutate(name=paste0(gsub("-","",date),".csv"))

  res<-data.frame(time_start=table_urls$date,name=table_urls$name,url=table_urls$url,stringsAsFactors = F)

  return(res)

}



#' @name .grd_get_url_srtm
#' @aliases .grd_get_url_srtm
#' @title Get URLs of SRTM datasets
#' @description This function enables to retrieve URLs of SRTM DEM datasets for a given ROI, and eventually download the data
#' @note
#' \itemize{
#' \item{NB1 :}{The	NASA server where the SRTM data are extracted from is located here : http://e4ftl01.cr.usgs.gov/MEASURES/SRTMGL1.003/2000.02.11/}
#' }
#'
#' @author Paul Taconet, IRD \email{paul.taconet@ird.fr}
#'
#' @family get_url
#'
#' @import sf
#'
#' @noRd

.grd_get_url_srtm<-function(roi){

  url_srtm_server<-"http://e4ftl01.cr.usgs.gov/MEASURES/SRTMGL1.003/2000.02.11/"
  srtm_tiles<-.getSRTMtileNames(roi)
  urls<-paste0(url_srtm_server,srtm_tiles,".SRTMGL1.hgt.zip")

  names<-paste0(srtm_tiles,".SRTMGL1.hgt.zip")

  res<-data.frame(time_start=NA,name=names,url=urls,stringsAsFactors = F)

  return(res)

}


#' @name .get_url_tamsat
#' @aliases get_url_tamsat
#' @title Get URLs of TAMSAT datasets
#' @description This function enables to retrieve URLs of TASMAT products given a variables and a time frame.
#'
#' @details
#'
#'  variables =  "daily_rainfall_estimate" ; "monthly_rainfall_estimate" ; "monthly_anomaly" ; "monthly_climatology"
#'
#'
#' Argument \code{variables} is a list of length 3 :
#' \itemize{
#' \item{*output_time_step*: }{available values : "daily_rainfall_estimate" ; "monthly_rainfall_estimate" ; "monthly_anomaly" ; "monthly_climatology"}
#' \item{*output_product*: }{available values : "rainfall_estimate" ; "anomaly" (only if output_time_step=="monthly") ; "climatology" (only if output_time_step=="monthly") }
#' \item{*output_output*: }{available values : "individual" ; "yearly"}
#'  }
#'
#' Additional information : https://www.tamsat.org.uk/data/archive
#'
#' @author Paul Taconet, IRD \email{paul.taconet@ird.fr}
#'
#' @noRd
#'
#' @examples
#'
#' \dontrun{
#'
#' time_range<-as.Date(c("2017-01-01","2017-01-30"))
#'
#' ### Retrieve the URLs to download TAMSAT products for the whole time frame :
#' df_data_to_dl<-getRemoteData::get_url_tamsat(
#' time_range=time_range,
#' variables=list("daily","rainfall_estimate","individual")
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

.grd_get_url_tamsat<-function(variables,
                              time_range # mandatory. either a time range (e.g. c(date_start,date_end) ) or a single date e.g. ( date_start )
){

  url_tamsat_data<-"https://www.tamsat.org.uk/public_data/TAMSAT3"

  time_range<-as.Date(time_range, origin="1970-01-01")

  datesToRetrieve<-seq(time_range[2],time_range[1],-1) %>%
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

  urls_final<-NULL
  if("daily_rainfall_estimate" %in% variables){
    urls1 <- urls %>% dplyr::select(product_name_daily_rain_individual,url_product_daily_rain_individual,date)
    colnames(urls1) <- c("prod","url","date")
    urls_final <- rbind(urls_final,urls1)
  #} else if (output_time_step=="daily" & output_product=="rainfall_estimate" & output_output=="yearly"){
    #urls <- urls %>% dplyr::select(product_name_daily_rain_yearly,url_product_daily_rain_yearly,date)
  }
  if("monthly_rainfall_estimate" %in% variables){
    urls2 <- urls %>% dplyr::select(product_name_monthly_rain_individual,url_product_monthly_rain_individual,date) %>% dplyr::distinct(product_name_monthly_rain_individual,url_product_monthly_rain_individual,.keep_all=TRUE)
    colnames(urls2) <- c("prod","url","date")
    urls_final <- rbind(urls_final,urls2)
    #} else if (output_time_step=="monthly" & output_product=="rainfall_estimate" & output_output=="yearly"){
  #  urls <- urls %>% dplyr::select(product_name_monthly_rain_yearly,url_product_monthly_rain_yearly,date)
  }
  if("monthly_anomaly" %in% variables){
    urls3 <- urls %>% dplyr::select(product_name_monthly_anomaly_individual,url_product_monthly_anomaly_individual,date) %>% dplyr::distinct(product_name_monthly_anomaly_individual,url_product_monthly_anomaly_individual,.keep_all=TRUE)
    colnames(urls3) <- c("prod","url","date")
    urls_final <- rbind(urls_final,urls3)
  } #else if (output_time_step=="monthly" & output_product=="climatology" & output_output=="individual"){
  #urls <- urls %>% select(product_name_monthly_climatology_individual,url_product_monthly_climatology_individual)
  #}

  colnames(urls_final)<-c("name","url","time_start")

  return(urls_final)

}



#' @name .get_url_viirsDnb
#' @aliases .get_url_viirsDnb
#' @title Get URLs of VIIRS DNB datasets
#' @description This function enables to retrieve URLs of VIIRS DNB products given a ROI, a time frame and a set of variables of interest.
#' @details
#'
#' Argument \code{time_range} can be provided either as a single date (e.g. \code{as.Date("2017-01-01"))} or time frame provided as two bounding dates ( e.g. \code{as.Date(c("2017-01-01","2017-06-01"))})
#'
#' @note
#' \itemize{
#' \item{NB1 :}{The	NOAA server where the VIIRS DNB data are extracted from is located here : https://gis.ngdc.noaa.gov/arcgis/rest/services/NPP_VIIRS_DNB/}
#' }
#'
#' @author Paul Taconet, IRD \email{paul.taconet@ird.fr}
#'
#' @noRd
#'
#' @import lubridate
#'
#' @examples
#'
#'\dontrun{
#'require(sf)
#'require(purrr)
#'
#' # Set ROI and time range of interest
#' roi<-sf::st_read(system.file("extdata/roi_example.gpkg", package = "getRemoteData"),quiet=TRUE)
#' time_range<-as.Date(c("2017-01-01","2017-08-30"))
#'
#' ### Retrieve the URLs to download VIIRS DNB products for the whole time frame :
#' df_data_to_dl<-getRemoteData::get_url_viirsDnb(
#' time_range=time_range,
#' roi=roi,
#' variables=c("Monthly_AvgRadiance","Monthly_CloudFreeCoverage")
#' )
#'
#'# Set destination folder
#' df_data_to_dl$destfile<-file.path(getwd(),df_data_to_dl$name)
#'
#'# Download the data
#'res_dl<-getRemoteData::downloadData(df_data_to_dl,parallelDL=TRUE)
#'
#'# Open the Monthly_AvgRadiance bands as a list of rasters
#'rasts_viirsdnb<-purrr::map(res_dl$destfile[which(grepl("Monthly_AvgRadiance",res_dl$destfile))],~raster::raster(.))
#'
#'# plot the first date :
#' raster::plot(rasts_viirsdnb[[1]])
#'
#'}

.grd_get_url_viirsDnb<-function(
  variables, # mandatory
  roi, # either provide roi (sf point or polygon) or provide roiSpatialIndexBound. if roiSpatialIndexBound is not provided, it will be calculated from roi
  time_range # mandatory. either a time range (e.g. c(date_start,date_end) ) or a single date e.g. ( date_start )
){

  if(!is(time_range,"Date")){stop("Argument time_range is not of class Date")}

  url_noaa_nighttime_webservice<-"https://gis.ngdc.noaa.gov/arcgis/rest/services/NPP_VIIRS_DNB/"

  roi_bbox<-sf::st_bbox(st_transform(roi,4326))

  time_range=as.Date(time_range,origin="1970-01-01")

  if(length(time_range)==1){
    time_range=c(time_range,time_range %m+% lubridate::days(1))
  }

  datesToRetrieve<-seq(from=time_range[2],to=time_range[1],by="-1 month") %>%
    data.frame(stringsAsFactors = F) %>%
    purrr::set_names("date") %>%
    dplyr::mutate(date_character=as.character(as.Date(date))) %>%
    dplyr::mutate(year=format(date,'%Y')) %>%
    dplyr::mutate(month=format(date,'%m')) %>%
    dplyr::mutate(date_start=as.Date(paste(year,month,"01",sep="-"))) %>%
    dplyr::mutate(date_end=date_start %m+% months(1))  %>%
    dplyr::mutate(time_start=as.integer(difftime(date_start ,"1970-01-01" , units = c("secs")))*1000) %>%
    dplyr::mutate(time_end=as.integer(difftime(date_end ,"1970-01-01" , units = c("secs")))*1000)

  table_urls<-datesToRetrieve %>%
    dplyr::select(year,month,time_start,time_end) %>%
    dplyr::slice(rep(1:dplyr::n(), each = length(variables))) %>%
    dplyr::mutate(date=as.character(paste(year,month,"01",sep="-"))) %>%
    dplyr::mutate(variables=rep(variables,dplyr::n()/2)) %>%
    dplyr::mutate(url=paste0(url_noaa_nighttime_webservice,variables,"/ImageServer/exportImage?bbox=",roi_bbox$xmin,",",roi_bbox$ymin,",",roi_bbox$xmax,",",roi_bbox$ymax,"&time=",format(time_start,scientific=FALSE),",",format(time_end,scientific=FALSE),"&format=tiff&f=image")) %>%
    dplyr::mutate(name=paste0(variables,"_",year,month,".tif"))
  #dplyr::mutate(destfile=file.path(dest_folder,paste0(name,".tif")))

  res<-data.frame(time_start=table_urls$date,name=table_urls$name,url=table_urls$url,stringsAsFactors = F)

  return(res)

}
