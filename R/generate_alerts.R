#' Generate alerts
#'
#' @param data Data frame with anomaly and sensor columns.
#' @param timestamp_col Timestamp column name.
#' @param sensor_cols Sensor columns.
#' @param anomaly_col Name of anomaly column.
#' @param export_csv Optional path where the alert table is saved.
#' @return A data frame of alerts.
#' @export
generate_alerts <- function(data,
                            timestamp_col = "timestamp",
                            sensor_cols = NULL,
                            anomaly_col = "anomaly",
                            export_csv = NULL) {
  data <- .as_data_frame(data)
  timestamp_col <- .pick_timestamp_col(data, timestamp_col)
  sensor_cols <- .get_sensor_cols(data, sensor_cols, exclude = c(timestamp_col, anomaly_col))
  sensor_cols <- sensor_cols[vapply(data[sensor_cols], is.numeric, logical(1))]
  alerts <- data.frame(
    timestamp = as.POSIXct(character(0)),
    sensor = character(0),
    severity = character(0),
    message = character(0),
    stringsAsFactors = FALSE
  )

  rows <- list()
  for (col in sensor_cols) {
    x <- data[[col]]
    if (any(is.na(x))) {
      rows[[length(rows) + 1]] <- data.frame(
        timestamp = data[[timestamp_col]][is.na(x)],
        sensor = col,
        severity = "medium",
        message = "Valeur manquante detectee",
        stringsAsFactors = FALSE
      )
    }
    if (anomaly_col %in% names(data) && any(data[[anomaly_col]] %in% TRUE)) {
      idx <- which(data[[anomaly_col]] %in% TRUE)
      rows[[length(rows) + 1]] <- data.frame(
        timestamp = data[[timestamp_col]][idx],
        sensor = col,
        severity = "high",
        message = "Anomalie detectee",
        stringsAsFactors = FALSE
      )
    }
    if (max(rle(round(x, 4))$lengths, na.rm = TRUE) >= 5) {
      rows[[length(rows) + 1]] <- data.frame(
        timestamp = data[[timestamp_col]][which.max(rle(round(x, 4))$lengths)],
        sensor = col,
        severity = "high",
        message = "Capteur possiblement bloque",
        stringsAsFactors = FALSE
      )
    }
  }

  if (length(rows) > 0) {
    alerts <- do.call(rbind, rows)
    rownames(alerts) <- NULL
  } else {
    alerts <- data.frame(timestamp = as.POSIXct(character(0)), sensor = character(0), severity = character(0), message = character(0), stringsAsFactors = FALSE)
  }

  if (!is.null(export_csv)) {
    utils::write.csv(alerts, export_csv, row.names = FALSE)
  }

  alerts
}
