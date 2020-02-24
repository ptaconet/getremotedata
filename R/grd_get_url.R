grd_get_url<-function(collection,
                      variables=NULL,
                      roi,
                      time_range,
                      credentials=NULL,
                      verbose=TRUE){

  if(collection=="SRTMGL1.003"){

    table_urls <- .get_url_srtm(roi)

  } else if(collection=="TAMSAT"){

    table_urls <- .get_url_tamsat(variables,time_range)

  } else if(collection=="ERA5"){

    table_urls <- .grd_get_url_era5(variables,roi,time_range)

  } else if (collection=="MIRIADE"){

    table_urls <- .get_url_tamsat(variables,time_range)

  } else if (collection=="VIIRS_DNB_MONTH"){

    table_urls <- .get_url_viirsDnb(variables,roi,time_range)

  }

  table_urls <- table_urls %>%
    dplyr::mutate(name=stringr::str_replace(name,".*/","")) %>%
    dplyr::arrange(date) %>%
    dplyr::mutate(destfile=file.path(collection,.$name)) %>%
    dplyr::select(date,name,url,destfile) %>%
    dplyr::rename(time_start = date)

  if(verbose){cat("OK\n")}

  return(table_urls)

}
