#' @name getData_imcce
#' @aliases getData_imcce
#' @title Download IMCCE time series data
#' @description This function enables to retrieve URLs of IMCCE datasets for a given ROI and time frame, and eventually download the data
#' @export
#'
#' @param timeRange Date(s) of interest. Mandatory. See Details for addition information on how to provide the dates.
#' @param roi sf POINT or POLYGON. The region of interest in EPSG 4326
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
#' Argument \code{timeRange} can be provided either as a single date (e.g. \code{as.Date("2017-01-01"))} or time frame provided as two bounding dates ( e.g. \code{as.Date(c("2010-01-01","2010-01-30"))})
#'
#' @author Paul Taconet, IRD \email{paul.taconet@ird.fr}
#'
#' @family getData
#'
#' @import  sf dplyr
#'
#' @examples
#'
#' # Read ROI as sf object
#' roi=sf::st_read(system.file("extdata/ROI_example.kml", package = "getRemoteData"),quiet=T)
#' timeRange<-c("2017-01-01","2017-01-30") %>% as.Date()
#'
#' \dontrun{
#' getData_imcce(timeRange=timeRange,
#' roi=roi,
#' collection="GPM_3IMERGDF.06",
#' dimensions=c("precipitationCal"),
#' username="my.earthdata.username",
#' password="my.earthdata.pw",
#' download=FALSE
#' )
#'}
#'

getData_imcce<-function(timeRange=as.Date(c("2010-01-01","2010-01-30")),
                        roi=st_read(system.file("extdata/ROI_example.kml", package = "getRemoteData"),quiet=T),
                        download=FALSE,
                        destFolder=getwd(),
                        ...){

  url_imcce_webservice<-"http://vo.imcce.fr/webservices/miriade/ephemcc_query.php?"

  if(length(timeRange)==1){
    timeRange=c(timeRange,timeRange)
  }

  roi_bbox<-sf::st_bbox(st_transform(roi,4326))

  datesToRetrieve<-seq(from=timeRange[2],to=timeRange[1],by=-1) %>%
    as.data.frame() %>%
    set_names("date")

  table_urls<-datesToRetrieve %>%
    mutate(url=paste0(url_imcce_webservice,"-name=s:Moon&-type=Satellite&-ep=",date,"T23:30:00&-nbd=1d&-step=1h&-tscale=UTC&-observer=",mean(c(roi_bbox$xmin,roi_bbox$xmax)),"%20",mean(c(roi_bbox$ymin,roi_bbox$ymax)),"%200.0&-theory=INPOP&-teph=1&-tcoor=1&-mime=text/csv&-output=--jd&-extrap=0&-from=MiriadeDoc")) %>%
    mutate(product_name=gsub("-","",date)) %>%
    mutate(destfile=file.path(destFolder,paste0(product_name,".csv")))

  urls<-table_urls$url

  destfiles<-table_urls$destfile

  names<-table_urls$product_name

  res<-data.frame(name=names,url=urls,destfile=destfiles,stringsAsFactors = F)

  if (download){
    cat("Downloading the data...\n")
    res<-getRemoteData::downloadData(res, ...)
  }

  return(res)

}
