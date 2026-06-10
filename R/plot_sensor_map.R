#' Plot sensor map
#'
#' @param data Data frame containing latitude and longitude columns.
#' @param lat_col Latitude column name.
#' @param lon_col Longitude column name.
#' @param value_col Optional value column used for popup text.
#' @param anomaly_col Optional anomaly column name.
#' @return A leaflet map.
#' @export
plot_sensor_map <- function(data,
                            lat_col = "latitude",
                            lon_col = "longitude",
                            value_col = NULL,
                            anomaly_col = "anomaly") {
  data <- .as_data_frame(data)
  .ensure_cols(data, c(lat_col, lon_col))
  cols <- rep("blue", nrow(data))
  if (anomaly_col %in% names(data)) cols[data[[anomaly_col]] %in% TRUE] <- "red"
  popup <- if (!is.null(value_col) && value_col %in% names(data)) {
    paste0(value_col, ": ", data[[value_col]])
  } else {
    NULL
  }

  leaflet::leaflet(data) |>
    leaflet::addTiles() |>
    leaflet::addCircleMarkers(
      lng = data[[lon_col]],
      lat = data[[lat_col]],
      radius = 6,
      color = cols,
      popup = popup
    )
}
