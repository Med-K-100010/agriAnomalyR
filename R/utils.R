#' Internal: standardize column names
#' @keywords internal
.standardize_names <- function(x) {
  x <- tolower(x)
  x <- gsub("[^a-z0-9]+", "_", x)
  x <- gsub("^_|_$", "", x)
  x
}

#' Internal: pick timestamp column
#' @keywords internal
.pick_timestamp_col <- function(data, timestamp_col = "timestamp") {
  if (timestamp_col %in% names(data)) return(timestamp_col)
  candidates <- c("timestamp", "datetime", "date_time", "date", "time")
  found <- intersect(candidates, names(data))
  if (length(found) == 0) stop("No timestamp column found.", call. = FALSE)
  found[[1]]
}

#' Internal: parse timestamp
#' @keywords internal
.parse_timestamp <- function(x, tz = "UTC") {
  if (inherits(x, c("POSIXct", "POSIXt"))) return(as.POSIXct(x, tz = tz))
  if (inherits(x, "Date")) return(as.POSIXct(x, tz = tz))
  if (is.numeric(x)) return(as.POSIXct(x, origin = "1970-01-01", tz = tz))
  x <- as.character(x)
  parsed <- suppressWarnings(lubridate::parse_date_time(
    x,
    orders = c("Ymd HMS", "Ymd HM", "Ymd", "dmY HMS", "dmY HM", "dmY",
               "mdY HMS", "mdY HM", "mdY",
               "Y-m-d H:M:S", "Y-m-d H:M", "Y-m-d",
               "d/m/Y H:M:S", "d/m/Y H:M", "d/m/Y"),
    tz = tz
  ))
  if (all(is.na(parsed))) {
    parsed <- as.POSIXct(x, tz = tz)
  }
  parsed
}

#' Internal: identify sensor columns
#' @keywords internal
.get_sensor_cols <- function(data, sensor_cols = NULL, exclude = "timestamp") {
  if (!is.null(sensor_cols)) return(sensor_cols)
  num_cols <- names(data)[vapply(data, is.numeric, logical(1))]
  setdiff(num_cols, exclude)
}

#' Internal: rolling mean with fallback
#' @keywords internal
.rolling_mean <- function(x, k = 5) {
  if (length(x) < 2) return(x)
  if (requireNamespace("zoo", quietly = TRUE)) {
    as.numeric(zoo::rollmean(x, k = k, fill = NA, align = "center"))
  } else {
    stats::filter(x, rep(1 / k, k), sides = 2)
  }
}

#' Internal: rolling sd
#' @keywords internal
.rolling_sd <- function(x, k = 5) {
  if (length(x) < 2) return(rep(NA_real_, length(x)))
  f <- function(v) if (all(is.na(v))) NA_real_ else stats::sd(v, na.rm = TRUE)
  if (requireNamespace("zoo", quietly = TRUE)) {
    as.numeric(zoo::rollapply(x, width = k, FUN = f, fill = NA, align = "center", partial = TRUE))
  } else {
    out <- rep(NA_real_, length(x))
    half <- floor(k / 2)
    for (i in seq_along(x)) {
      idx <- max(1, i - half):min(length(x), i + half)
      out[i] <- f(x[idx])
    }
    out
  }
}

#' Internal: safe tibble/data.frame conversion
#' @keywords internal
.as_data_frame <- function(x) {
  if (inherits(x, "data.frame")) return(x)
  as.data.frame(x, stringsAsFactors = FALSE)
}

#' Internal: simple isolation score for one numeric vector
#' @keywords internal
.simple_iso_score_1d <- function(x, ntrees = 40L) {
  x <- as.numeric(x)
  n <- length(x)
  if (n <= 1) return(rep(0, n))
  scores <- numeric(n)
  finite <- is.finite(x)
  x2 <- x[finite]
  if (length(unique(x2)) < 2) return(rep(0, n))
  c_n <- 2 * (log(length(x2) - 1) + 0.5772156649) - 2 * (length(x2) - 1) / length(x2)
  c_n <- ifelse(is.finite(c_n) && c_n > 0, c_n, 1)
  set.seed(1)
  for (t in seq_len(ntrees)) {
    xmin <- min(x2)
    xmax <- max(x2)
    thr <- stats::runif(1, xmin, xmax)
    depth <- ifelse(x <= thr, 1, 1) # one split heuristic
    scores <- scores + 2^(-depth / c_n)
  }
  scores / ntrees
}

#' Internal: ensure columns exist
#' @keywords internal
.ensure_cols <- function(data, cols) {
  missing <- setdiff(cols, names(data))
  if (length(missing) > 0) stop("Missing columns: ", paste(missing, collapse = ", "), call. = FALSE)
}
