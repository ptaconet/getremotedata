#' @name ancillaryFunctions_getDataFromOpenDAP
#' @aliases ancillaryFunctions_getDataFromOpenDAP
#' @title A set of ancillary functions to retrieve data using OpenDAP
#' @description A set of ancillary functions to retrieve data using OpenDAP
#' @export convertMetersToDegrees getOpenDAPvector getOpenDapURL_dimensions getOpenDAPtimeIndex_modis
#'
#'
#' @author Paul Taconet, \email{paul.taconet@@ird.fr}
#'

getOpenDAPvector<-function(OpenDAPUrl,
                           variableName){
  vector_response<-httr::GET(paste0(OpenDAPUrl,".ascii?",variableName))
  vector<-content(vector_response,"text")
  vector<-strsplit(vector,",")
  vector<-vector[[1]]
  vector<-str_replace(vector,"\\n","")
  vector<-vector[-1]
  vector<-as.numeric(vector)

  return(vector)

}


getOpenDapURL_dimensions<-function(dimensionsToRetrieve,timeIndex,roiSpatialIndexBound,TimeVectorName,SpatialXVectorName,SpatialYVectorName){
  dim<-dimensionsToRetrieve %>%
    map(~paste0(.x,"[",timeIndex,"][",roiSpatialIndexBound[1],":",roiSpatialIndexBound[2],"][",roiSpatialIndexBound[3],":",roiSpatialIndexBound[4],"],",TimeVectorName,"[",timeIndex,"],",SpatialYVectorName,"[",roiSpatialIndexBound[1],":",roiSpatialIndexBound[2],"],",SpatialXVectorName,"[",roiSpatialIndexBound[3],":",roiSpatialIndexBound[4],"]")) %>%
    unlist() %>%
    paste(collapse=",")
  return(dim)
}



getOpenDAPtimeIndex_modis<-function(date,timeVector){
  date_julian<-as.integer(difftime(date ,"2000-01-01" , units = c("days")))
  index_opendap_closest_to_date<-which.min(abs(timeVector-date_julian))
  days_sep_from_date<-timeVector[index_opendap_closest_to_date]-date_julian
  if(days_sep_from_date<=0){
    index_opendap_closest_to_date<-index_opendap_closest_to_date-1
  } else {
    index_opendap_closest_to_date<-index_opendap_closest_to_date-2
  }

  date_closest_to_date<-as.Date("2000-01-01")+timeVector[index_opendap_closest_to_date+1]
  days_sep_from_date<--as.integer(difftime(date ,date_closest_to_date , units = c("days")))

  return(list(date,date_closest_to_date,days_sep_from_date,index_opendap_closest_to_date))
}

