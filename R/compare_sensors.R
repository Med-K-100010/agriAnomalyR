#' Compare sensors
#'
#' @param data Data frame with sensor columns.
#' @param sensor_cols Sensor columns to compare.
#' @param timestamp_col Timestamp column name.
#' @return A list with a correlation matrix and a simple inconsistency summary.
#' @export
compare_sensors <- function(data,
                            sensor_cols = NULL,
                            timestamp_col = "timestamp") {
  data <- .as_data_frame(data)
  timestamp_col <- .pick_timestamp_col(data, timestamp_col)
  sensor_cols <- .get_sensor_cols(data, sensor_cols, exclude = timestamp_col)
  sensor_cols <- sensor_cols[vapply(data[sensor_cols], is.numeric, logical(1))]
  m <- stats::na.omit(data[, sensor_cols, drop = FALSE])
  corr <- if (ncol(m) >= 2) stats::cor(m, use = "pairwise.complete.obs") else matrix(1, nrow = 1, ncol = 1, dimnames = list(sensor_cols, sensor_cols))
  inconsistent <- stats::setNames(logical(length(sensor_cols)), sensor_cols)
  if (length(sensor_cols) >= 2) {
    for (i in seq_along(sensor_cols)) {
      vv <- corr[i, ]
      inconsistent[i] <- any(abs(vv[-i]) < 0.3, na.rm = TRUE)
    }
  }
  list(
    correlation_matrix = corr,
    inconsistent_sensors = sensor_cols[inconsistent]
  )
}
