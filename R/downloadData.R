#' @name downloadData
#' @aliases downloadData
#' @title Wrapper to download several datasets
#' @description This function enables to download datasets, enventually parallelizing the download.
#' @export
#'
#' @import parallel dplyr httr

downloadData<-function(df_to_dl,username=NULL,password=NULL,parallelDL=FALSE){

  # check which data is already downloaded
  data_dl<-df_to_dl %>%
    mutate(fileDl=map_lgl(destfile,file.exists)) %>%
    mutate(dlStatus=ifelse(fileDl==TRUE,3,NA))

  # data already downloaded
  data_already_exist<-data_dl %>%
    filter(fileDl==TRUE)

  # data to download
  data_to_download<-data_dl %>%
    filter(fileDl==FALSE)

  if (nrow(data_to_download)>0){
  # Create directories if they do not exist
  unique(dirname(data_to_download$destfile)) %>%
    lapply(dir.create,recursive = TRUE, mode = "0777", showWarnings = FALSE)

  # download data
  #for (i in 1:nrow(data_to_download)){
  #    httr::GET(data_to_download$url[i],httr::authenticate(username,password),write_disk(data_to_download$destfile[i]))
  # }

  if(is.null(username)){
    username<-password<-"no_auth"
  }
  dl_func<-function(url,output,username,password) {httr::GET(url,httr::authenticate(username,password),httr::write_disk(output),httr::progress())}

  if (parallelDL){
    cl <- parallel::makeCluster(detectCores())
    parallel::clusterMap(cl, dl_func, url=data_to_download$url,output=data_to_download$destfile,username=username,password=password,
               .scheduling = 'dynamic')
    parallel::stopCluster(cl)
  } else {
    for (i in 1:nrow(data_to_download)){
      dl_func(url=data_to_download$url[i],output=data_to_download$destfile[i],username=username,password=password)
    }
  }
}
  data_dl<-data_to_download %>%
    mutate(fileDl=map_lgl(destfile,file.exists)) %>%
    mutate(dlStatus=ifelse(fileDl==TRUE,1,2))  %>%
    rbind(data_already_exist)

  # 1 : download ok
  # 2 : download error
  # 3 : data already existing in output folder

  return(data_dl)
}
