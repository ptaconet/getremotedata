#' @name .import_era5
#' @title Import data  source=="ERA5"
#' @noRd


.import_era5 <- function(df_data_to_import,variable,output){

  if(output=="RasterBrick"){

    rasts <- df_data_to_import$destfile %>%
      map(~raster(., varname = variable)) %>%
      brick(.)
    names(rasts) <- df_data_to_import$time_start

  } else if(output=="stars"){
    stop("stars output is not available for this collection")
  }

  return(rasts)

}


#' @name .import_miriade
#' @title Import data  source=="MIRIADE"
#' @noRd


.import_miriade <- function(df_data_to_import){

  rasts <- df_data_to_import$destfile %>%
    map(~read.csv(.,skip=10))

  return(rasts)

}


#' @name .import_srtm
#' @title Import data  collection=="SRTM"
#' @noRd


.import_srtm <- function(df_data_to_import,roi,output){

  if(output=="RasterBrick"){

    rasts <- df_data_to_import$destfile %>%
      map(~unzip(., exdir = dirname(.))) %>%
      map(~raster(.)) %>%
      do.call(merge,.) %>%
      crop(roi)

  } else if(output=="stars"){
    stop("stars output is not possiblet for this collection")
  }

  return(rasts)

}

#' @name .import_tamsat
#' @title Import data  source=="TAMSAT"
#' @noRd


.import_tamsat <- function(df_data_to_import,variable,roi,output){

  df_data_to_import <- df_data_to_import[which(grepl(variable,df_data_to_import$name)),]

  if(output=="RasterBrick"){

    rasts <- df_data_to_import$destfile %>%
      map(~raster(.,varname = variable)) %>%
      map(~crop(.,roi)) %>%
      brick()
    names(rasts) <- df_data_to_import$time_start

  } else if(output=="stars"){
    stop("stars output is not implemented yet for this collection")
  }

  return(rasts)

}

#' @name .import_viirsdnb
#' @title Import data  source=="VIIRS_DNB_MONTH"
#' @noRd


.import_viirsdnb <- function(df_data_to_import,variable,output){

  df_data_to_import <- df_data_to_import[which(grepl(variable,df_data_to_import$name)),]

  if(output=="RasterBrick"){

    rasts <- df_data_to_import$destfile %>%
      map(~raster(.)) %>%
      brick(.)
    names(rasts) <- df_data_to_import$time_start

  } else if(output=="stars"){
    stop("stars output is not available for this collection")
  }

  return(rasts)

}


