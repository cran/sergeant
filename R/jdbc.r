#' Connect to Drill using JDBC
#'
#' The DRILL JDBC driver fully-qualified path must be placed in the
#' \code{DRILL_JDBC_JAR} environment variable. This is best done via \code{~/.Renviron}
#' for interactive work. e.g. \code{DRILL_JDBC_JAR=/usr/local/drill/jars/jdbc-driver/drill-jdbc-all-1.10.0.jar}
#'
#' @param nodes character vector of nodes. If more than one node, you can either have
#'              a single string with the comma-separated node:port pairs pre-made or
#'              pass in a character vector with multiple node:port strings and the
#'              function will make a comma-separated node string for you.
#' @param cluster_id the cluster id from \code{drill-override.conf}
#' @param schema an optional schema name to append to the JDBC connection string
#' @param use_zk are you connecting to a ZooKeeper instance (default: \code{TRUE}) or
#'               connecting to an individual DrillBit.
#' @return a JDBC connection object
#' @references \url{https://drill.apache.org/docs/using-the-jdbc-driver/#using-the-jdbc-url-for-a-random-drillbit-connection}
#' @export
#' @examples \dontrun{
#' con <- drill_jdbc("localhost:2181", "main")
#' drill_query(con, "SELECT * FROM cp.`employee.json`")
#'
#' # you can also use the connection with RJDBC calls:
#' dbGetQuery(con, "SELECT * FROM cp.`employee.json`")
#'
#' # for local/embedded mode with default configuration info
#' con <- drill_jdbc("localhost:31010", use_zk=FALSE)
#' }
drill_jdbc <- function(nodes="localhost:2181", cluster_id=NULL, schema=NULL, use_zk=TRUE) {

  try_require("rJava")
  try_require("RJDBC")

  jar_path <- Sys.getenv("DRILL_JDBC_JAR")
  if (!file.exists(jar_path)) {
    stop(sprintf("Cannot locate DRILL JDBC JAR [%s]", jar_path))
  }

  drill_jdbc_drv <- RJDBC::JDBC(driverClass="org.apache.drill.jdbc.Driver",
                                classPath=jar_path, identifier.quote='`')

  conn_type <- "drillbit"
  if (use_zk) conn_type <- "zk"

  if (length(nodes) > 1) nodes <- paste0(nodes, collapse=",")

  conn_str <- sprintf("jdbc:drill:%s=%s", conn_type, nodes)

  if (!is.null(cluster_id)) conn_str <- sprintf("%s%s", conn_str, sprintf("/drill/%s", cluster_id))

  if (!is.null(schema)) conn_str <- sprintf("%s;%s", schema)

  message(sprintf("Using [%s]...", conn_str))

  RJDBC::dbConnect(drill_jdbc_drv, conn_str)

}
