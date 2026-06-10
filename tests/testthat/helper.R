setup_test_data <- function() {
  data.frame(
    Timestamp = seq(as.POSIXct("2026-01-01 00:00:00", tz = "UTC"), by = "10 min", length.out = 10),
    soil_moisture = c(25, 26, 150, 27, NA, 28, 28, 28, 28, 29), # 150 hors limites, NA, blocage à 28
    temperature = c(15, 16, 15, 14, 16, 17, 18, 19, 20, 21),
    anomaly = c(FALSE, FALSE, TRUE, FALSE, TRUE, FALSE, FALSE, FALSE, FALSE, FALSE),
    stringsAsFactors = FALSE
  )
}
