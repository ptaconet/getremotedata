#' @name ancillaryFunctions_oPeNDAP
#' @aliases ancillaryFunctions_oPeNDAP
#' @title A set of ancillary functions to retrieve data using OpenDAP
#' @description A set of ancillary functions to retrieve data using OpenDAP
#' @export .getOpenDAPvector .getOpenDapURL_dimensions .getOpenDapURL_dimensions2 .getOpenDAPtimeIndex_modis .getOpendapOptArguments_modis_vnp .getOpendapOptArguments_gpm .getOpendapOptArguments_smap .getOpendapAvailableDimensions .testDimVal
#'
#' @author Paul Taconet, \email{paul.taconet@@ird.fr}
#'

.getOpenDAPvector<-function(OpenDAPUrl,
                           variableName,
                           username=NULL,
                           password=NULL){

  if(!is.null(username) || is.null(getOption("earthdata_login"))){
    login<-getRemoteData::login_earthdata(username,password)
  }

  httr::set_config(httr::authenticate(user=getOption("earthdata_user"), password=getOption("earthdata_pass"), type = "basic"))
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



.getOpendapOptArguments_modis_vnp<-function(roi,collection,username=NULL,password=NULL,modisTile=NULL){

  if(!is(roi,"sf")){stop("roi is not of class sf")}

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

  availableDimensions<-getRemoteData::.getOpendapAvailableDimensions(paste0(OpendapURL,".html"),username,password)

  return(list(OpenDAPtimeVector=OpenDAPtimeVector,roiSpatialIndexBound=roiSpatialIndexBound,availableDimensions=availableDimensions))
}


.getOpendapOptArguments_gpm<-function(roi,collection,username=NULL,password=NULL){

  if(!is(roi,"sf")){stop("roi is not of class sf")}

  SpatialOpenDAPXVectorName="lon"
  SpatialOpenDAPYVectorName="lat"

  if (collection=="GPM_3IMERGHH.06"){
   OpendapURL="https://gpm1.gesdisc.eosdis.nasa.gov/opendap/GPM_L3/GPM_3IMERGHH.06/2016/001/3B-HHR.MS.MRG.3IMERG.20160101-S000000-E002959.0000.V06B.HDF5"
  } else if (collection %in% c("GPM_3IMERGDF.06","GPM_3IMERGDL.06")){
    OpendapURL="https://gpm1.gesdisc.eosdis.nasa.gov/opendap/GPM_L3/GPM_3IMERGDF.06/2017/01/3B-DAY.MS.MRG.3IMERG.20170101-S000000-E235959.V06.nc4"
  } else if (collection=="GPM_3IMERGM.06"){
    OpendapURL="https://gpm1.gesdisc.eosdis.nasa.gov/opendap/GPM_L3/GPM_3IMERGM.06/2019/3B-MO.MS.MRG.3IMERG.20190101-S000000-E235959.01.V06B.HDF5"
  }

  roi_bbox<-sf::st_bbox(sf::st_transform(roi,4326))

  OpenDAPXVector<-getRemoteData::.getOpenDAPvector(OpendapURL,SpatialOpenDAPXVectorName,username,password)
  OpenDAPYVector<-getRemoteData::.getOpenDAPvector(OpendapURL,SpatialOpenDAPYVectorName,username,password)

  Opendap_minLon<-which.min(abs(OpenDAPXVector-roi_bbox$xmin))-4
  Opendap_maxLon<-which.min(abs(OpenDAPXVector-roi_bbox$xmax))+4
  Opendap_minLat<-which.min(abs(OpenDAPYVector-roi_bbox$ymin))-4
  Opendap_maxLat<-which.min(abs(OpenDAPYVector-roi_bbox$ymax))+4
  roiSpatialIndexBound<-c(Opendap_minLat,Opendap_maxLat,Opendap_minLon,Opendap_maxLon)

  availableDimensions<-getRemoteData::.getOpendapAvailableDimensions(paste0(OpendapURL,".html"),username,password)

  return(list(roiSpatialIndexBound=roiSpatialIndexBound,availableDimensions=availableDimensions))
}


.getOpendapOptArguments_smap<-function(roi,collection,username=NULL,password=NULL){

  if(!is(roi,"sf")){stop("roi is not of class sf")}

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

  minLon<-OpenDAPXVector[Opendap_minLon]
  maxLon<-OpenDAPXVector[Opendap_maxLon]
  minLat<-OpenDAPYVector[Opendap_minLat]
  maxLat<-OpenDAPYVector[Opendap_maxLat]

  roiSpatialIndexBound<-c(Opendap_minLat,Opendap_maxLat,Opendap_minLon,Opendap_maxLon)
  roiSpatialBound<-c(minLat,maxLat,minLon,maxLon)

  if (collection=="SPL3SMP_E.003"){
    OpendapURL="https://n5eil02u.ecs.nsidc.org/opendap/SMAP/SPL3SMP_E.003/2017.01.30/SMAP_L3_SM_P_E_20170130_R16510_001.h5"
  }

  availableDimensions<-getRemoteData::.getOpendapAvailableDimensions(paste0(OpendapURL,".html"),username,password)

  return(list(roiSpatialIndexBound=roiSpatialIndexBound,availableDimensions=availableDimensions,roiSpatialBound=roiSpatialBound))
}


.getOpendapAvailableDimensions<-function(OpenDAPUrl,username=NULL,password=NULL){

  if(!is.null(username) || is.null(getOption("earthdata_login"))){
    login<-getRemoteData::login_earthdata(username,password)
  }

  httr::set_config(httr::authenticate(user=getOption("earthdata_user"), password=getOption("earthdata_pass"), type = "basic"))

  vector_response<-httr::GET(gsub("html","dds",OpenDAPUrl))

  vector<-httr::content(vector_response,"text")
  vector<-strsplit(vector,"\n")
  vector<-vector[[1]][-length(vector[[1]])]
  vector<-vector[-1]
  vector<-gsub("    ","",vector)
  vector<-gsub("\\["," \\[",vector)

  dimensions_available<-purrr::map_chr(vector,~stringr::word(., 2))

  return(dimensions_available)
}

# Check is the dimensions specified exist
.testDimVal<-function(available_dim,dimensions){

 wrong_dim<-setdiff(dimensions,available_dim)

 if(length(wrong_dim)>0){
    stop(paste0("\nDimension ",paste(wrong_dim,collapse=",")," do(es) not exist."))
 }

}
