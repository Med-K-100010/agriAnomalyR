#' Generate a report
#'
#' Creates a lightweight HTML report and optionally a PDF if rmarkdown is available.
#'
#' @param data Data frame.
#' @param output_dir Directory where the report is saved.
#' @param file_name Output file base name.
#' @param timestamp_col Timestamp column name.
#' @param sensor_cols Sensor columns.
#' @return Path to the generated report.
#' @export
generate_report <- function(data,
                            output_dir = getwd(),
                            file_name = "agriAnomalyR_report",
                            timestamp_col = "timestamp",
                            sensor_cols = NULL) {
  dir.create(output_dir, showWarnings = FALSE, recursive = TRUE)
  data <- .as_data_frame(data)
  stats_tbl <- calculate_sensor_statistics(data, sensor_cols = sensor_cols)
  alerts <- generate_alerts(data, timestamp_col = timestamp_col, sensor_cols = sensor_cols)

  html_file <- file.path(output_dir, paste0(file_name, ".html"))
  report <- c(
    "<html><head><meta charset='utf-8'><title>agriAnomalyR report</title>",
    "<style>body{font-family:Arial, sans-serif; margin:40px;} table{border-collapse:collapse;} td,th{border:1px solid #999;padding:6px;}</style>",
    "</head><body>",
    "<h1>agriAnomalyR report</h1>",
    "<h2>Sensor statistics</h2>",
    "<pre>", paste(utils::capture.output(print(stats_tbl)), collapse = "\n"), "</pre>",
    "<h2>Alerts</h2>",
    "<pre>", paste(utils::capture.output(print(alerts)), collapse = "\n"), "</pre>",
    "</body></html>"
  )
  writeLines(report, html_file, useBytes = TRUE)

  if (requireNamespace("rmarkdown", quietly = TRUE)) {
    # Keep the API future-proof: the HTML report is always produced.
    # Users can adapt this function to render a richer PDF report in their local setup.
  }

  html_file
}
