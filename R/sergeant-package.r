#' Tools to Transform and Query Data with 'Apache' 'Drill'
#'
#' Drill is an innovative low-latency distributed query engine designed to enable data
#' exploration and analytics on both relational and non-relational datastores, scaling to
#' petabytes of data. Users can query the data using standard SQL and BI tools without
#' having to create and manage schemas. Some of the key features are:
#'
#' \itemize{
#'   \item{Schema-free JSON document model similar to MongoDB and Elasticsearch}
#'   \item{Industry-standard APIs: ANSI SQL, ODBC/JDBC, RESTful APIs}
#'   \item{Extremely user and developer friendly}
#'   \item{Pluggable architecture enables connectivity to multiple datastores}
#' }
#'
#' Drill includes a distributed execution environment, purpose built for large-scale data
#' processing. At the core of Drill is the "Drillbit" service which is responsible for
#' accepting requests from the client, processing the queries, and returning results to
#' the client.
#'
#' You can install and run a Drillbit service on one node or on many nodes to form a
#' distributed cluster environment. When a Drillbit runs on each data node in a cluster,
#' Drill can maximize data locality during query execution without moving data over the
#' network or between nodes. Drill uses ZooKeeper to maintain cluster membership and health
#' check information.
#'
#' Methods are provided to work with Drill via the native JDBC & REST APIs along with R
#' \code{DBI} and \code{dplyr} interfaces.
#'
#' @name sergeant
#' @references \href{https://drill.apache.org/docs/}{Drill documentation}
#' @docType package
#' @author Bob Rudis (bob@@rud.is)
#' @import httr jsonlite htmltools
#' @importFrom purrr map map2 map2_df %>%
#' @importFrom dplyr mutate select left_join bind_cols bind_rows data_frame tbl filter
#' @importFrom dplyr db_desc src db_data_type db_explain sql_translate_env copy_to
#' @importFrom dplyr db_query_fields src_tbls sql_escape_ident
#' @importFrom dbplyr build_sql sql_prefix sql_quote src_sql tbl_sql
#' @import utils
#' @import DBI methods
#' @importFrom scales comma
NULL


#' sergeant exported operators
#'
#' The following functions are imported and then re-exported
#' from the sergeant package to enable use of the magrittr
#' pipe operator with no additional library calls
#'
#' @name sergeant-exports
NULL

#' @name %>%
#' @export
#' @rdname sergeant-exports
NULL
