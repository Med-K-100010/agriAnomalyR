library(testthat)

test_that("detect_anomalies fonctionne avec les différentes méthodes", {
  df <- setup_test_data()
  # Nettoyer d'abord pour standardiser les colonnes
  df_clean <- clean_sensor_data(df, timestamp_col = "Timestamp")

  # Test de la méthode Z-Score
  res_z <- detect_anomalies(df_clean, timestamp_col = "timestamp", method = "zscore", threshold = 1.5)
  expect_true("anomaly" %in% names(res_z))
  expect_true("anomaly_score" %in% names(res_z))
  expect_type(res_z$anomaly, "logical")
  expect_type(res_z$anomaly_score, "double")

  # Test de la méthode IQR
  res_iqr <- detect_anomalies(df_clean, timestamp_col = "timestamp", method = "iqr")
  expect_s3_class(res_iqr, "data.frame")

  # Test Isolation Forest (lightweight heuristic)
  res_iso <- detect_anomalies(df_clean, timestamp_col = "timestamp", method = "isolation_forest")
  expect_equal(nrow(res_iso), nrow(df_clean))
})

test_that("detect_anomalies lève une erreur si aucune colonne numérique n'est présente", {
  df_char <- data.frame(timestamp = as.POSIXct("2026-01-01"), sensor = "ABC")
  expect_error(detect_anomalies(df_char, method = "zscore"), "No numeric sensor columns found.")
})
