#' Classify anomaly types
#'
#' Simple rule-based anomaly classification with an optional k-means helper.
#'
#' @param data Data frame containing anomaly flags.
#' @param timestamp_col Timestamp column name.
#' @param sensor_cols Sensor columns to inspect.
#' @param anomaly_col Name of the anomaly column.
#' @param method \code{"rules"} (default) or \code{"kmeans"}.
#' @param window Rolling window used for drift/stuck detection.
#' @return The original data frame with a \code{anomaly_type} column.
#' @export
classify_anomalies <- function(data,
                               timestamp_col = "timestamp",
                               sensor_cols = NULL,
                               anomaly_col = "anomaly",
                               method = c("rules", "kmeans"),
                               window = 5) {
  method <- match.arg(method)
  data <- .as_data_frame(data)
  timestamp_col <- .pick_timestamp_col(data, timestamp_col)
  if (!anomaly_col %in% names(data)) stop("`anomaly_col` not found.", call. = FALSE)
  sensor_cols <- .get_sensor_cols(data, sensor_cols, exclude = c(timestamp_col, anomaly_col, "anomaly_score"))
  sensor_cols <- sensor_cols[vapply(data[sensor_cols], is.numeric, logical(1))]

  out <- data
  out$anomaly_type <- NA_character_

  if (method == "kmeans") {
    cols <- c("anomaly_score", sensor_cols)
    cols <- intersect(cols, names(out))
    m <- out[, cols, drop = FALSE]
    m <- as.data.frame(lapply(m, function(z) ifelse(is.na(z), stats::median(z, na.rm = TRUE), z)))
    if (ncol(m) >= 2 && nrow(m) >= 4) {
      set.seed(1)
      km <- stats::kmeans(scale(m), centers = min(4, nrow(m)))
      labels <- c("bruit_temporaire", "panne_capteur", "derive_lente", "donnee_manquante")
      out$anomaly_type <- ifelse(out[[anomaly_col]], labels[km$cluster], NA_character_)
      return(out)
    }
  }

  if (length(sensor_cols) == 0) {
    out$anomaly_type[out[[anomaly_col]]] <- "bruit_temporaire"
    return(out)
  }

  primary <- sensor_cols[[1]]
  x <- out[[primary]]
  na_flag <- is.na(x)
  stuck_flag <- c(FALSE, diff(x) == 0)
  streak <- rle(ifelse(is.na(x), "NA", as.character(round(x, 6))))
  max_run <- rep(1, length(x))
  idx <- 1
  for (i in seq_along(streak$lengths)) {
    len <- streak$lengths[i]
    max_run[idx:(idx + len - 1)] <- len
    idx <- idx + len
  }

  local_mean <- .rolling_mean(x, k = window)
  slope <- c(NA, diff(local_mean))
  drift_flag <- abs(slope) > stats::sd(x, na.rm = TRUE) * 0.5

  out$anomaly_type[out[[anomaly_col]] & na_flag] <- "donnee_manquante"
  out$anomaly_type[out[[anomaly_col]] & !na_flag & max_run >= window] <- "panne_capteur"
  out$anomaly_type[out[[anomaly_col]] & !na_flag & !is.na(drift_flag) & drift_flag] <- "derive_lente"
  out$anomaly_type[out[[anomaly_col]] & is.na(out$anomaly_type)] <- "bruit_temporaire"

  out
}
