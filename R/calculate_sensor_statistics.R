#' Calculate sensor statistics
#'
#' @param data Data frame with sensor columns.
#' @param sensor_cols Sensor columns to summarize.
#' @param anomaly_col Optional anomaly column name.
#' @return A summary table.
#' @export
calculate_sensor_statistics <- function(data,
                                        sensor_cols = NULL,
                                        anomaly_col = "anomaly") {
  data <- .as_data_frame(data)
  sensor_cols <- .get_sensor_cols(data, sensor_cols, exclude = anomaly_col)
  sensor_cols <- sensor_cols[vapply(data[sensor_cols], is.numeric, logical(1))]

  res <- lapply(sensor_cols, function(col) {
    x <- data[[col]]
    data.frame(
      sensor = col,
      mean = mean(x, na.rm = TRUE),
      min = min(x, na.rm = TRUE),
      max = max(x, na.rm = TRUE),
      variance = stats::var(x, na.rm = TRUE),
      missing_rate = mean(is.na(x)),
      anomaly_rate = if (anomaly_col %in% names(data)) mean(as.logical(data[[anomaly_col]]), na.rm = TRUE) else NA_real_,
      row.names = NULL,
      stringsAsFactors = FALSE
    )
  })
  do.call(rbind, res)
}
