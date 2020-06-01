try_require <- function(package, fun) {
  if (requireNamespace(package, quietly = TRUE)) {
    library(package, character.only = TRUE)
    return(invisible())
  }

  stop("Package `", package, "` required for `", fun , "`.\n", # nocov start
       "Please install and try again.", call. = FALSE) # nocov end
}

# authenticate to drill
# sets up a cookie in the httr handle pool ref for the drill REST API url
auth_drill <- function(ssl, host, port, username, password) {

  httr::set_config(config(ssl_verifypeer = 0L))

  httr::RETRY(
    "POST",
    url = sprintf("%s://%s:%s", ifelse(ssl[1], "https", "http"), host, port),
    path = "/j_security_check",
    encode = "form",
    body = list(
      j_username = username,
      j_password = password
    ),
    terminate_on = c(403, 404)
  ) -> res

  httr::stop_for_status(res)

}

set_names <- function(object = nm, nm) {
  names(object) <- nm
  object
}
