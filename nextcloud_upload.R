library(cli)
library(dplyr)
library(purrr)


src_path <- "/mnt/hdd/Music"
nc_path <- "Music"
nc_uri <- "https://example.com"
auth_str <- "<nc_login>:<nc_password>"
src_fld <- src_path

nc_make_folder <- function(fld_path, nc_path, nc_uri = nc_uri, auth_str = auth_str){

  fld_path <- gsub(" ", "\ ", fld_path)

  nc_user <- strsplit(auth_str, ":")[[1]] %>% .[1]
  full_nc_uri <- paste0(nc_uri, "/remote.php/dav/files/", nc_user, "/", nc_path, "/", fld_path)
  full_nc_uri <- paste0("'", full_nc_uri, "'") %>%
    gsub(" ", "%20", .)

  cli::cli_alert_info("Creating folder {full_nc_uri}")

  res_cmd <- system2("curl", args = c("-X", "MKCOL", "-u", auth_str, full_nc_uri))
  if(res_cmd==0){
    cli::cli_alert_success("Created folder {fld_path} at")
    cli::cli_alert_info("{full_nc_uri}")
    return(TRUE)
  } else {
    return(FALSE)
  }

}

nc_upl_file <- function(src_path, nc_path, nc_uri = nc_uri, auth_str = auth_str){

  src_path <- gsub(" ", "\ ", src_path)

  file_name <- basename(src_path)
  file_name <- gsub(" ", "\ ", file_name)
  nc_user <- strsplit(auth_str, ":")[[1]] %>% .[1]
  full_nc_uri <- paste0(nc_uri, "/remote.php/dav/files/", nc_user, "/", nc_path, "/", file_name)

  full_nc_uri <- paste0("'", full_nc_uri, "'") %>%
    gsub(" ", "%20", .)

  src_path <- paste0("'", src_path, "'")

  cli::cli_alert_info("Uploading file {src_path} to {full_nc_uri}")

  res_cmd <- system2("curl", args = c("-X", "PUT", "-u", auth_str, full_nc_uri, "-T", src_path))

  if(res_cmd==0){
    cli::cli_alert_info("Uploaded file {src_path} to {nc_path}")
    return(TRUE)
  } else {
    return(FALSE)
  }
}

#' Upload folder to Nextcloud
#'
#' @param src_fld full path to src folder
#' @param nc_path path to NC
#' @param nc_uri NC URL with https://
#' @param auth_str auth string i.e. "login:password" string
nc_upl_folder <- function(src_fld, nc_path, nc_uri = nc_uri, auth_str = auth_str){
  ndirs <- list.dirs(src_fld, recursive = F, full.names = T)
  upl_files <- list.files(src_fld, all.files = T,
                          full.names = T)
  nfiles <- setdiff(upl_files, ndirs) %>%
    setdiff(., paste0(src_fld, "/", c(".", "..")))

  nc_make_folder(basename(src_fld), nc_path, nc_uri, auth_str)

  new_nc_path <- paste0(nc_path, "/", basename(src_fld))

  purrr::walk(nfiles, nc_upl_file, new_nc_path, nc_uri, auth_str)
  purrr::walk(ndirs, nc_upl_folder, new_nc_path, nc_uri, auth_str)

}

nc_upl_folder(src_path, nc_path, nc_uri, auth_str)
