#' Plot sensor time series
#'
#' @param data Data frame with a timestamp column.
#' @param timestamp_col Timestamp column name.
#' @param sensor_cols Sensor columns to plot.
#' @param anomaly_col Optional anomaly column name.
#' @param corrected_data Optional corrected data frame to compare before/after.
#' @return A ggplot object.
#' @export
plot_timeseries <- function(data,
                            timestamp_col = "timestamp",
                            sensor_cols = NULL,
                            anomaly_col = "anomaly",
                            corrected_data = NULL) {
  data <- .as_data_frame(data)
  timestamp_col <- .pick_timestamp_col(data, timestamp_col)
  sensor_cols <- .get_sensor_cols(data, sensor_cols, exclude = c(timestamp_col, anomaly_col))
  sensor_cols <- sensor_cols[vapply(data[sensor_cols], is.numeric, logical(1))]
  long <- tidyr::pivot_longer(data, cols = tidyselect::all_of(sensor_cols), names_to = "sensor", values_to = "value")
  p <- ggplot2::ggplot(long, ggplot2::aes(x = .data[[timestamp_col]], y = value)) +
    ggplot2::geom_line(linewidth = 0.4) +
    ggplot2::facet_wrap(~sensor, scales = "free_y", ncol = 1) +
    ggplot2::theme_minimal() +
    ggplot2::labs(x = "Time", y = "Value")

  if (anomaly_col %in% names(data)) {
    a <- data[data[[anomaly_col]] %in% TRUE, , drop = FALSE]
    if (nrow(a) > 0) {
      a_long <- tidyr::pivot_longer(a, cols = tidyselect::all_of(sensor_cols), names_to = "sensor", values_to = "value")
      p <- p + ggplot2::geom_point(data = a_long, ggplot2::aes(x = .data[[timestamp_col]], y = value),
                                   color = "red", size = 1.8)
    }
  }

  if (!is.null(corrected_data)) {
    corrected_data <- .as_data_frame(corrected_data)
    corrected_data[[timestamp_col]] <- .parse_timestamp(corrected_data[[timestamp_col]])
    cd <- tidyr::pivot_longer(corrected_data, cols = tidyselect::all_of(sensor_cols), names_to = "sensor", values_to = "value")
    p <- p + ggplot2::geom_line(data = cd, ggplot2::aes(x = .data[[timestamp_col]], y = value),
                                linetype = "dashed", alpha = 0.6)
  }

  p
}
