#' Impute missing values in sensor data
#'
#' Supports linear interpolation, moving-average replacement and a simple KNN-style approach.
#'
#' @param data Data frame with numeric sensor columns.
#' @param timestamp_col Timestamp column name.
#' @param sensor_cols Sensor columns to impute.
#' @param method \code{"linear"}, \code{"moving_average"}, or \code{"knn"}.
#' @param window Window size used for moving averages.
#' @param k Number of neighbors for the KNN-style method.
#' @return A data frame with missing values replaced when possible.
#' @export
impute_missing_values <- function(data,
                                  timestamp_col = "timestamp",
                                  sensor_cols = NULL,
                                  method = c("linear", "moving_average", "knn"),
                                  window = 5,
                                  k = 3) {
  method <- match.arg(method)
  data <- .as_data_frame(data)
  timestamp_col <- .pick_timestamp_col(data, timestamp_col)
  sensor_cols <- .get_sensor_cols(data, sensor_cols, exclude = timestamp_col)
  sensor_cols <- sensor_cols[vapply(data[sensor_cols], is.numeric, logical(1))]
  out <- data

  for (col in sensor_cols) {
    x <- out[[col]]
    if (method == "linear") {
      if (requireNamespace("zoo", quietly = TRUE)) {
        out[[col]] <- as.numeric(zoo::na.approx(x, na.rm = FALSE, rule = 2))
      } else {
        idx <- seq_along(x)
        out[[col]] <- stats::approx(idx[!is.na(x)], x[!is.na(x)], xout = idx, rule = 2)$y
      }
    } else if (method == "moving_average") {
      # 1. Calcul et application de la moyenne mobile classique
      rm <- .rolling_mean(x, k = window)
      x[is.na(x)] <- rm[is.na(x)]

      # === MODIFICATION : SÉCURITÉ POUR LES EFFETS DE BORD ===
      # Si la moyenne mobile a laissé des NA aux extrémités (faute de voisins assez nombreux)
      if (any(is.na(x))) {
        if (requireNamespace("zoo", quietly = TRUE)) {
          # On propage la dernière valeur connue vers l'avant puis vers l'arrière
          x <- zoo::na.locf(x, na.rm = FALSE)
          x <- zoo::na.locf(x, fromLast = TRUE, na.rm = FALSE)
        } else {
          # Alternative sans le package zoo (en utilisant stats::approx avec rule = 2)
          idx <- seq_along(x)
          if (any(!is.na(x))) {
            x <- stats::approx(idx[!is.na(x)], x[!is.na(x)], xout = idx, rule = 2)$y
          }
        }
      }
      # ========================================================

      out[[col]] <- x
    } else if (method == "knn") {
      x2 <- x
      for (i in which(is.na(x2))) {
        available <- which(!is.na(x2))
        if (length(available) == 0) next
        dist <- abs(available - i)
        nn <- available[order(dist)][seq_len(min(k, length(available)))]
        x2[i] <- mean(x2[nn], na.rm = TRUE)
      }
      out[[col]] <- x2
    }
  }
  out
}
