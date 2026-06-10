#' Clean sensor data
#'
#' Remove duplicates, correct impossible values and optionally regularize time frequency.
#' Only retains numeric columns that match the specified rule patterns.
#'
#' @param data Data frame with sensor time series.
#' @param timestamp_col Timestamp column name.
#' @param sensor_cols Sensor columns to clean.
#' @param frequency Optional frequency string passed to \code{seq.POSIXt} (e.g. "10 min").
#' @param rules Named list of numeric ranges \code{c(min, max)} per column pattern.
#' @return A cleaned data frame containing only the allowed sensors.
#' @export
clean_sensor_data <- function(data,
                              timestamp_col = "timestamp",
                              sensor_cols = NULL,
                              frequency = NULL,
                              rules = list(
                                soil_moisture = c(0, 100),
                                humidity = c(0, 100),
                                air_humidity = c(0, 100),
                                temperature = c(-40, 60),
                                co2 = c(200, 10000),
                                irrigation = c(0, Inf)
                              )) {
  data <- .as_data_frame(data)
  timestamp_col <- .pick_timestamp_col(data, timestamp_col)
  data[[timestamp_col]] <- .parse_timestamp(data[[timestamp_col]])
  names(data) <- .standardize_names(names(data))
  timestamp_col <- .standardize_names(timestamp_col)

  # 1. Identifier toutes les colonnes numériques présentes
  all_numeric_sensors <- .get_sensor_cols(data, sensor_cols, exclude = timestamp_col)

  # 2. SELECTION STRICTE : On ne garde que les colonnes qui correspondent à tes "rules"
  valid_sensors <- character(0)
  for (col in all_numeric_sensors) {
    for (pat in names(rules)) {
      if (grepl(pat, col)) {
        valid_sensors <- c(valid_sensors, col)
        break # On a trouvé un match, on passe au capteur suivant
      }
    }
  }

  # 3. Filtrer le jeu de données pour jeter les colonnes numériques non désirées
  # On garde le timestamp, les colonnes textuelles (comme crop_health) et UNIQUEMENT les capteurs validés
  non_numeric_cols <- names(data)[!vapply(data, is.numeric, logical(1))]
  data <- data[, c(non_numeric_cols, valid_sensors), drop = FALSE]
  sensor_cols <- valid_sensors

  # 4. Suite du traitement classique (Dédoublonnage et Tri)
  data <- data[!duplicated(data[[timestamp_col]]), , drop = FALSE]
  data <- data[order(data[[timestamp_col]]), , drop = FALSE]

  # 5. Nettoyage des valeurs hors-limites pour les capteurs conservés
  for (col in sensor_cols) {
    if (!col %in% names(data)) next
    x <- data[[col]]
    if (!is.numeric(x)) next
    for (pat in names(rules)) {
      if (grepl(pat, col)) {
        lim <- rules[[pat]]
        x[x < lim[1] | x > lim[2]] <- NA_real_
      }
    }
    data[[col]] <- x
  }

  # 6. Régularisation optionnelle de la fréquence
  if (!is.null(frequency) && nrow(data) > 1) {
    full_seq <- seq(min(data[[timestamp_col]], na.rm = TRUE),
                    max(data[[timestamp_col]], na.rm = TRUE),
                    by = frequency)
    idx <- match(full_seq, data[[timestamp_col]])
    data <- data[idx, , drop = FALSE]
    data[[timestamp_col]] <- full_seq
  }

  rownames(data) <- NULL
  data
}
