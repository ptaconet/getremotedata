#' @name ancillaryFunctions_oPeNDAP
#' @aliases ancillaryFunctions_oPeNDAP
#' @title A set of ancillary functions to retrieve data using OpenDAP
#' @description A set of ancillary functions to retrieve data using OpenDAP
#' @export .getOpenDAPvector .getOpenDapURL_dimensions .getOpenDapURL_dimensions2 .getOpenDAPtimeIndex_modis .getOpendapOptArguments_modis_vnp .getOpendapOptArguments_gpm .getOpendapOptArguments_smap
#'
#'
#' @author Paul Taconet, \email{paul.taconet@@ird.fr}
#'

.getOpenDAPvector<-function(OpenDAPUrl,
                           variableName,
                           username,
                           password){
  httr::set_config(authenticate(user=username, password=password, type = "basic"))
  vector_response<-httr::GET(paste0(OpenDAPUrl,".ascii?",variableName))
  vector<-httr::content(vector_response,"text")
  vector<-strsplit(vector,",")
  vector<-vector[[1]]
  vector<-stringr::str_replace(vector,"\\n","")
  vector<-vector[-1]
  vector<-as.numeric(vector)

  return(vector)

}


.getOpenDapURL_dimensions<-function(dimensionsToRetrieve,timeIndex,roiSpatialIndexBound,TimeVectorName,SpatialXVectorName,SpatialYVectorName){
  dim<-dimensionsToRetrieve %>%
    purrr::map(~paste0(.x,"[",timeIndex,"][",roiSpatialIndexBound[1],":",roiSpatialIndexBound[2],"][",roiSpatialIndexBound[3],":",roiSpatialIndexBound[4],"],",TimeVectorName,"[",timeIndex,"],",SpatialYVectorName,"[",roiSpatialIndexBound[1],":",roiSpatialIndexBound[2],"],",SpatialXVectorName,"[",roiSpatialIndexBound[3],":",roiSpatialIndexBound[4],"]")) %>%
    unlist() %>%
    paste(collapse=",")
  return(dim)
}

.getOpenDapURL_dimensions2<-function(dimensionsToRetrieve,timeIndex,roiSpatialIndexBound,TimeVectorName,SpatialXVectorName,SpatialYVectorName){
  dim<-dimensionsToRetrieve %>%
    purrr::map(~paste0(.x,"[",timeIndex[1],":",timeIndex[2],"][",roiSpatialIndexBound[1],":",roiSpatialIndexBound[2],"][",roiSpatialIndexBound[3],":",roiSpatialIndexBound[4],"],",TimeVectorName,"[",timeIndex[1],":",timeIndex[2],"],",SpatialYVectorName,"[",roiSpatialIndexBound[1],":",roiSpatialIndexBound[2],"],",SpatialXVectorName,"[",roiSpatialIndexBound[3],":",roiSpatialIndexBound[4],"]")) %>%
    unlist() %>%
    paste(collapse=",")
  return(dim)
}

.getOpenDAPtimeIndex_modis<-function(date,timeVector){
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



.getOpendapOptArguments_modis_vnp<-function(roi,collection,username,password,modisTile=NULL){

  SpatialOpenDAPXVectorName="XDim"
  SpatialOpenDAPYVectorName="YDim"

  OpenDAPServerUrl="https://opendap.cr.usgs.gov/opendap/hyrax"
  modisCrs<-"+proj=sinu +lon_0=0 +x_0=0 +y_0=0 +a=6371007.181 +b=6371007.181 +units=m +no_defs"

  roi_bbox<-sf::st_bbox(sf::st_transform(roi,modisCrs))

  if(is.null(modisTile)){
    modisTile<-getRemoteData::getMODIStileNames(roi)
  }

  OpendapURL<-paste0(OpenDAPServerUrl,"/",collection,"/",modisTile,".ncml")

  OpenDAPtimeVector<-getRemoteData::.getOpenDAPvector(OpendapURL,variableName="time",username,password)
  OpenDAPXVector<-getRemoteData::.getOpenDAPvector(OpendapURL,SpatialOpenDAPXVectorName,username,password)
  OpenDAPYVector<-getRemoteData::.getOpenDAPvector(OpendapURL,SpatialOpenDAPYVectorName,username,password)
  #OpenDAPXVector :numeric vector. The OPeNDAP longitude (X) dimension vector
  #OpenDAPYVector: numeric vector. The OPeNDAP latitude (Y) dimension vector

  Opendap_minLon<-which.min(abs(OpenDAPXVector-roi_bbox$xmin))-1
  Opendap_maxLon<-which.min(abs(OpenDAPXVector-roi_bbox$xmax))-1
  Opendap_maxLat<-which.min(abs(OpenDAPYVector-roi_bbox$ymin))-1
  Opendap_minLat<-which.min(abs(OpenDAPYVector-roi_bbox$ymax))-1
  roiSpatialIndexBound<-c(Opendap_minLat,Opendap_maxLat,Opendap_minLon,Opendap_maxLon)

  return(list(OpenDAPtimeVector=OpenDAPtimeVector,roiSpatialIndexBound=roiSpatialIndexBound))
}


.getOpendapOptArguments_gpm<-function(roi,username,password){

  SpatialOpenDAPXVectorName="lon"
  SpatialOpenDAPYVectorName="lat"

  OpendapURL="https://gpm1.gesdisc.eosdis.nasa.gov/opendap/GPM_L3/GPM_3IMERGHH.06/2016/001/3B-HHR.MS.MRG.3IMERG.20160101-S000000-E002959.0000.V06B.HDF5"

  roi_bbox<-sf::st_bbox(st_transform(roi,4326))

  OpenDAPXVector<-getRemoteData::.getOpenDAPvector(OpendapURL,SpatialOpenDAPXVectorName,username,password)
  OpenDAPYVector<-getRemoteData::.getOpenDAPvector(OpendapURL,SpatialOpenDAPYVectorName,username,password)

  Opendap_minLon<-which.min(abs(OpenDAPXVector-roi_bbox$xmin))-4
  Opendap_maxLon<-which.min(abs(OpenDAPXVector-roi_bbox$xmax))+4
  Opendap_minLat<-which.min(abs(OpenDAPYVector-roi_bbox$ymin))-4
  Opendap_maxLat<-which.min(abs(OpenDAPYVector-roi_bbox$ymax))+4
  roiSpatialIndexBound<-c(Opendap_minLat,Opendap_maxLat,Opendap_minLon,Opendap_maxLon)

  return(list(roiSpatialIndexBound=roiSpatialIndexBound))
}


.getOpendapOptArguments_smap<-function(roi,username,password){

  SpatialOpenDAPXVectorName="x"
  SpatialOpenDAPYVectorName="y"

  OpendapURL="https://n5eil02u.ecs.nsidc.org/opendap/hyrax/SMAP/SPL4CMDL.004/2016.01.06/SMAP_L4_C_mdl_20160106T000000_Vv4040_001.h5"

  roi_bbox<-sf::st_bbox(st_transform(roi,6933))

  OpenDAPXVector<-getRemoteData::.getOpenDAPvector(OpendapURL,SpatialOpenDAPXVectorName,username,password)
  OpenDAPYVector<-getRemoteData::.getOpenDAPvector(OpendapURL,SpatialOpenDAPYVectorName,username,password)

  Opendap_minLon<-which.min(abs(OpenDAPXVector-roi_bbox$xmin))-2
  Opendap_maxLon<-which.min(abs(OpenDAPXVector-roi_bbox$xmax))+2
  Opendap_minLat<-which.min(abs(OpenDAPYVector-roi_bbox$ymin))+2
  Opendap_maxLat<-which.min(abs(OpenDAPYVector-roi_bbox$ymax))-2
  roiSpatialIndexBound<-c(Opendap_minLat,Opendap_maxLat,Opendap_minLon,Opendap_maxLon)

  return(list(roiSpatialIndexBound=roiSpatialIndexBound))
}
