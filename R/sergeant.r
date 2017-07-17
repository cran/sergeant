s_head <- purrr::safely(httr::HEAD)

#' Setup a Drill connection
#'
#' @param host Drill host (will pick up the value from \code{DRILL_HOST} env var)
#' @param port Drill port (will pick up the value from \code{DRILL_PORT} env var)
#' @param ssl use ssl?
#' @param user,password NOT IMPLEMENTED YET credentials for username/password auth.
#'                      (will pick up the values from \code{DRILL_USER}/\code{DRILL_PASSWORD}
#'                      env vars)
#' @export
#' @examples
#' dc <- drill_connection()
drill_connection <- function(host=Sys.getenv("DRILL_HOST", "localhost"),
                      port=Sys.getenv("DRILL_PORT", 8047),
                      ssl=FALSE,
                      user=Sys.getenv("DRILL_USER", ""),
                      password=Sys.getenv("DRILL_PASSWORD", "")) {
  list(host=host,
       port=port,
       ssl=ssl,
       user=ifelse(user[1]=="", NA, user[1]),
       password=ifelse(password[1]=="", NA, password[1])) -> out

  class(out) <- c("drill_conn", class(out))

  out

}

#' Test whether Drill HTTP REST API server is up
#'
#' This is a very simple test (performs \code{HEAD /} request on the Drill server/cluster)
#'
#' @param drill_con drill server connection object setup by \code{drill_connection()}
#' @export
#' @examples \dontrun{
#' drill_connection() %>% drill_active()
#' }
drill_active <- function(drill_con) {
  drill_server <- make_server(drill_con)
  !is.null(s_head(drill_server, httr::timeout(2))$result)
}

#' Get the status of Drill
#'
#' @note The output of this is in a "viewer" window
#' @param drill_con drill server connection object setup by \code{drill_connection()}
#' @export
#' @examples \dontrun{
#' drill_connection() %>% drill_status()
#' }
drill_status <- function(drill_con) {
  drill_server <- make_server(drill_con)
  res <- httr::GET(sprintf("%s/status", drill_server))
  httr::stop_for_status(res)
  cnt <- httr::content(res, as="text", encoding="UTF-8")
  cnt <- htmltools::HTML(cnt)
  htmltools::browsable(cnt)
}

#' Get the current memory metrics
#'
#' @param drill_con drill server connection object setup by \code{drill_connection()}
#' @export
#' @examples \dontrun{
#' drill_connection() %>% drill_metrics()
#' }
drill_metrics <- function(drill_con) {
  drill_server <- make_server(drill_con)
  res <- httr::GET(sprintf("%s/status/metrics", drill_server))
  httr::stop_for_status(res)
  cnt <- httr::content(res, as="text", encoding="UTF-8")
  jsonlite::fromJSON(cnt, flatten=TRUE)
}

#' Get information about threads
#'
#' @note The output of this is in a "viewer" window
#' @param drill_con drill server connection object setup by \code{drill_connection()}
#' @export
#' @examples \dontrun{
#' drill_connection() %>% drill_threads()
#' }
drill_threads <- function(drill_con) {
  drill_server <- make_server(drill_con)
  res <- httr::GET(sprintf("%s/status/threads", drill_server))
  httr::stop_for_status(res)
  cnt <- httr::content(res, as="text", encoding="UTF-8")
  cnt <- htmltools::HTML(sprintf("<pre>%s</pre>", cnt))
  htmltools::browsable(cnt)
}

#' Get the profiles of running and completed queries
#'
#' @param drill_con drill server connection object setup by \code{drill_connection()}
#' @export
#' @references \href{https://drill.apache.org/docs/}{Drill documentation}
#' @examples \dontrun{
#' drill_connection() %>% drill_profiles()
#' }
drill_profiles <- function(drill_con) {
  drill_server <- make_server(drill_con)
  res <- httr::GET(sprintf("%s/profiles.json", drill_server))
  httr::stop_for_status(res)
  cnt <- httr::content(res, as="text", encoding="UTF-8")
  jsonlite::fromJSON(cnt)
}

#' Get the profile of the query that has the given queryid
#'
#' @param drill_con drill server connection object setup by \code{drill_connection()}
#' @param query_id UUID of the query in standard UUID format that Drill assigns to each query
#' @references \href{https://drill.apache.org/docs/}{Drill documentation}
#' @export
drill_profile <- function(drill_con, query_id) {
  drill_server <- make_server(drill_con)
  res <- httr::GET(sprintf("%s/profiles/%s.json", drill_server, query_id))
  httr::stop_for_status(res)
  cnt <- httr::content(res, as="text", encoding="UTF-8")
  jsonlite::fromJSON(cnt)
}

#' Cancel the query that has the given queryid
#'
#' @param drill_con drill server connection object setup by \code{drill_connection()}
#' @param query_id the UUID of the query in standard UUID format that Drill assigns to each query.
#' @references \href{https://drill.apache.org/docs/}{Drill documentation}
#' @export
drill_cancel <- function(drill_con, query_id) {
  drill_server <- make_server(drill_con)
  res <- httr::GET(sprintf("%s/profiles/cancel/%s", drill_server, query_id))
  httr::stop_for_status(res)
  message(httr::content(res, as="text", encoding="UTF-8"))
  invisible(TRUE)
}

#' Get the list of storage plugin names and configurations
#'
#' @param drill_con drill server connection object setup by \code{drill_connection()}
#' @param plugin the assigned name in the storage plugin definition.
#' @references \href{https://drill.apache.org/docs/}{Drill documentation}
#' @export
#' @examples \dontrun{
#' drill_connection() %>% drill_storage()
#' }
drill_storage <- function(drill_con, plugin=NULL) {

  drill_server <- make_server(drill_con)

  if (is.null(plugin)) {
    res <- httr::GET(sprintf("%s/storage.json", drill_server))
  } else {
    res <- httr::GET(sprintf("%s/storage/%s.json", drill_server, plugin))
  }

  httr::stop_for_status(res)

  cnt <- httr::content(res, as="text", encoding="UTF-8")
  jsonlite::fromJSON(cnt, flatten=TRUE) %>%
    dplyr::tbl_df()

}

#' List the name, default, and data type of the system and session options
#'
#' @param drill_con drill server connection object setup by \code{drill_connection()}
#' @param pattern pattern to filter results by
#' @export
#' @references \href{https://drill.apache.org/docs/}{Drill documentation}
#' @examples \dontrun{
#' drill_connection() %>% drill_options()
#' }
drill_options <- function(drill_con, pattern=NULL) {
  drill_server <- make_server(drill_con)
  res <- httr::GET(sprintf("%s/options.json", drill_server))
  httr::stop_for_status(res)
  cnt <- httr::content(res, as="text", encoding="UTF-8")
  jsonlite::fromJSON(cnt) %>%
    dplyr::tbl_df() -> out
  if (!is.null(pattern)) out <- dplyr::filter(out, grepl(pattern, name))
  out
}

#' Get Drillbit information, such as ports numbers
#'
#' @param drill_con drill server connection object setup by \code{drill_connection()}
#' @export
#' @references \href{https://drill.apache.org/docs/}{Drill documentation}
#' @examples \dontrun{
#' drill_connection() %>% drill_stats()
#' }
drill_stats <- function(drill_con) {
  drill_server <- make_server(drill_con)
  res <- httr::GET(sprintf("%s/cluster.json", drill_server))
  httr::stop_for_status(res)
  cnt <- httr::content(res, as="text", encoding="UTF-8")
  jsonlite::fromJSON(cnt)
}

#' Identify the version of Drill running
#'
#' @param drill_con drill server connection object setup by \code{drill_connection()}
#' @export
#' @references \href{https://drill.apache.org/docs/}{Drill documentation}
#' @examples \dontrun{
#' drill_connection() %>% drill_version()
#' }
drill_version <- function(drill_con) {
  drill_query(drill_con, "SELECT version FROM sys.version", uplift=FALSE, .progress=FALSE)$rows$version[1]
}
