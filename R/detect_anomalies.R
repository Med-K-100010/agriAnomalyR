#' Detect anomalies in sensor data
#'
#' Implements simple z-score, IQR, moving average and a lightweight isolation-score heuristic.
#'
#' @param data Data frame with numeric sensor columns.
#' @param timestamp_col Timestamp column name.
#' @param sensor_cols Sensor columns to analyse.
#' @param method Detection method: \code{"zscore"}, \code{"iqr"}, \code{"moving_average"}, or \code{"isolation_forest"}.
#' @param threshold Threshold controlling sensitivity.
#' @param window Window size for moving statistics.
#' @param contamination Expected anomaly rate used for the final cutoff.
#' @return A data frame with \code{anomaly} and \code{anomaly_score}.
#' @export
detect_anomalies <- function(data,
                             timestamp_col = "timestamp",
                             sensor_cols = NULL,
                             method = c("zscore", "iqr", "moving_average", "isolation_forest"),
                             threshold = 3,
                             window = 7,
                             contamination = 0.05) {
  method <- match.arg(method)
  data <- .as_data_frame(data)
  timestamp_col <- .pick_timestamp_col(data, timestamp_col)
  sensor_cols <- .get_sensor_cols(data, sensor_cols, exclude = timestamp_col)
  sensor_cols <- sensor_cols[vapply(data[sensor_cols], is.numeric, logical(1))]
  if (length(sensor_cols) == 0) stop("No numeric sensor columns found.", call. = FALSE)

  scores <- rep(0, nrow(data))
  per_col_flag <- vector("list", length(sensor_cols))
  names(per_col_flag) <- sensor_cols

  for (col in sensor_cols) {
    x <- data[[col]]
    sc <- rep(0, length(x))
    if (method == "zscore") {
      s <- stats::sd(x, na.rm = TRUE)
      m <- mean(x, na.rm = TRUE)
      sc <- ifelse(is.na(x) | is.na(s) | s == 0, 0, abs((x - m) / s))
      per_col_flag[[col]] <- sc > threshold
    } else if (method == "iqr") {
      qs <- stats::quantile(x, probs = c(0.25, 0.75), na.rm = TRUE)
      iqr <- as.numeric(qs[2] - qs[1])
      lower <- qs[1] - threshold * iqr
      upper <- qs[2] + threshold * iqr
      sc <- ifelse(is.na(x), 0, pmax(lower - x, 0) + pmax(x - upper, 0))
      per_col_flag[[col]] <- x < lower | x > upper
    } else if (method == "moving_average") {
      mu <- .rolling_mean(x, k = window)
      sdw <- .rolling_sd(x, k = window)
      sc <- ifelse(is.na(x) | is.na(mu) | is.na(sdw) | sdw == 0, 0, abs((x - mu) / sdw))
      per_col_flag[[col]] <- sc > threshold
    } else if (method == "isolation_forest") {
      sc <- .simple_iso_score_1d(x, ntrees = 40L)
      cutoff <- stats::quantile(sc, probs = 1 - contamination, na.rm = TRUE)
      per_col_flag[[col]] <- sc >= cutoff
    }
    scores <- pmax(scores, sc, na.rm = TRUE)
  }

  finite_scores <- scores[is.finite(scores)]
  if (length(unique(finite_scores)) <= 1) {
    anomaly <- rep(FALSE, length(scores))
  } else {
    cutoff_all <- stats::quantile(scores, probs = 1 - contamination, na.rm = TRUE)
    anomaly <- scores > cutoff_all
  }
  anomaly[is.na(anomaly)] <- FALSE

  out <- data
  out$anomaly_score <- as.numeric(scores)
  out$anomaly <- as.logical(anomaly)

  for (col in sensor_cols) {
    out[[paste0("anomaly_", col)]] <- as.logical(per_col_flag[[col]])
  }

  out
}
