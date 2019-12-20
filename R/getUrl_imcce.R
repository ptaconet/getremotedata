#' @name getUrl_imcce
#' @aliases getUrl_imcce
#' @title Download IMCCE time series data
#' @description This function enables to retrieve URLs of IMCCE datasets for a given ROI and time frame, and eventually download the data
#' @export
#'
#' @inheritParams getUrl_modis_vnp
#'
#' @inherit getUrl_modis_vnp return
#'
#' @details
#'
#' Argument \code{timeRange} can be provided either as a single date (e.g. \code{as.Date("2017-01-01"))} or time frame provided as two bounding dates ( e.g. \code{as.Date(c("2010-01-01","2010-01-30"))})
#'
#' @author Paul Taconet, IRD \email{paul.taconet@ird.fr}
#'
#' @family getUrl
#'
#' @examples
#'
#' # Read ROI as sf object
#' roi=sf::st_read(system.file("extdata/ROI_example.kml", package = "getRemoteData"),quiet=T)
#' timeRange<-c("2017-01-01","2017-01-30") %>% as.Date()
#'
#' \dontrun{
#' getUrl_imcce(timeRange=timeRange,
#' roi=roi,
#' collection="GPM_3IMERGDF.06",
#' dimensions=c("precipitationCal"),
#' username="my.earthdata.username",
#' password="my.earthdata.pw",
#' download=FALSE
#' )
#'}
#'

getUrl_imcce<-function(timeRange,
                        roi
                        ){

  url_imcce_webservice<-"http://vo.imcce.fr/webservices/miriade/ephemcc_query.php?"

  if(length(timeRange)==1){
    timeRange=c(timeRange,timeRange)
  }

  roi_bbox<-sf::st_bbox(st_transform(roi,4326))

  datesToRetrieve<-seq(from=timeRange[2],to=timeRange[1],by=-1) %>%
    as.data.frame() %>%
    purrr::set_names("date")

  table_urls<-datesToRetrieve %>%
    dplyr::mutate(url=paste0(url_imcce_webservice,"-name=s:Moon&-type=Satellite&-ep=",date,"T23:30:00&-nbd=1d&-step=1h&-tscale=UTC&-observer=",mean(c(roi_bbox$xmin,roi_bbox$xmax)),"%20",mean(c(roi_bbox$ymin,roi_bbox$ymax)),"%200.0&-theory=INPOP&-teph=1&-tcoor=1&-mime=text/csv&-output=--jd&-extrap=0&-from=MiriadeDoc")) %>%
    dplyr::mutate(name=paste0(gsub("-","",date),".csv"))

  res<-data.frame(time_start=table_urls$date,name=table_urls$name,url=table_urls$url,stringsAsFactors = F)

  return(res)

}
