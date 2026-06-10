#' Import sensor data from files
#'
#' Import agricultural IoT sensor data from CSV, JSON or Excel files.
#' If no files are provided, it automatically loads the package's internal example file.
#'
#' @param files Character vector of file paths. If NULL, loads the internal example file.
#' @param timestamp_col Name of the timestamp column.
#' @param sensor_cols Optional vector of sensor columns to keep.
#' @param tz Time zone used to parse timestamps.
#' @param unit_conversion Named list of functions applied to columns after import.
#' @param na_strings Strings treated as missing values.
#' @return A cleaned data frame with a parsed timestamp column.
#' @export
import_sensor_data <- function(files = NULL, # <-- MODIFICATION 1 : On ajoute = NULL par défaut
                               timestamp_col = "timestamp",
                               sensor_cols = NULL,
                               tz = "UTC",
                               unit_conversion = list(),
                               na_strings = c("", "NA", "NaN", "NULL")) {

  # <-- MODIFICATION 2 : BLOC MAGIQUE AJOUTÉ ICI
  # Si l'utilisateur n'a fourni aucun fichier, on bascule sur le fichier d'exemple interne
  if (is.null(files)) {
    files <- system.file("extdata", "agriculture_dataset_with_target.csv", package = "agriAnomalyR")
    if (files == "") {
      stop("Le fichier d'exemple interne 'sensor_example.csv' est introuvable.", call. = FALSE)
    }
  }

  # Sécurité d'origine
  if (length(files) == 0) stop("`files` cannot be empty.", call. = FALSE)

  # Fonction interne de lecture (inchangée, elle fonctionne parfaitement !)
  read_one <- function(path) {
    ext <- tolower(tools::file_ext(path))
    obj <- switch(
      ext,
      csv = readr::read_csv(path, show_col_types = FALSE, na = na_strings),
      json = {
        x <- jsonlite::fromJSON(path, flatten = TRUE)
        .as_data_frame(x)
      },
      xlsx = readxl::read_excel(path, na = na_strings),
      xls = readxl::read_excel(path, na = na_strings),
      stop("Unsupported file type: ", ext, call. = FALSE)
    )
    obj <- .as_data_frame(obj)
    names(obj) <- .standardize_names(names(obj))
    ts_col <- .pick_timestamp_col(obj, .standardize_names(timestamp_col))
    obj[[ts_col]] <- .parse_timestamp(obj[[ts_col]], tz = tz)

    if (!is.null(sensor_cols)) {
      keep <- unique(c(ts_col, .standardize_names(sensor_cols), intersect(c("sensor_id","latitude","longitude"), names(obj))))
      keep <- intersect(keep, names(obj))
      obj <- obj[, keep, drop = FALSE]
    }

    for (nm in names(unit_conversion)) {
      nm2 <- .standardize_names(nm)
      if (nm2 %in% names(obj)) {
        obj[[nm2]] <- unit_conversion[[nm]](obj[[nm2]])
      }
    }

    obj
  }

  # Application à tous les fichiers et fusion (inchangé)
  out <- lapply(files, read_one)
  out <- dplyr::bind_rows(out)
  names(out) <- .standardize_names(names(out))
  ts_col <- .pick_timestamp_col(out, .standardize_names(timestamp_col))
  out <- out[order(out[[ts_col]]), , drop = FALSE]
  rownames(out) <- NULL
  out
}
