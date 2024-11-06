# nextcloud_uploader

Upload folders recursively to Nextcloud using R and curl 

## Usage

### Ensure deps are installed

`install.packages(c("dplyr", "cli", "purrr"))`

### Configure vars in script

```
src_path <- "/mnt/hdd/Music"
nc_path <- "Music"
nc_uri <- "https://example.com"
auth_str <- "<nc_login>:<nc_password>"
```

Params:

* `src_path` -- source folder
* `nc_path` -- Nextcloud destination folder
* `nc_uri` -- Nextcloud URI
* `auth_str` -- login:password string, i.e. "myuser:mypassword"

### Run

`Rscript nextcloud_uploader.R`