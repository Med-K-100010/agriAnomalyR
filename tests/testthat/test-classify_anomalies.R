library(testthat)

test_that("classify_anomalies catégorise correctement via les règles", {
  df <- setup_test_data()
  df_clean <- clean_sensor_data(df, timestamp_col = "Timestamp")

  # On simule un résultat de détection d'anomalie
  df_clean$anomaly <- FALSE
  df_clean$anomaly[c(3, 5, 8)] <- TRUE # 3 était NA (à cause du clean), 5 est NA, 8 est bloqué à 28

  res <- classify_anomalies(df_clean, timestamp_col = "timestamp", window = 3)

  expect_true("anomaly_type" %in% names(res))

  # La valeur manquante (index 5) doit être classée en 'donnee_manquante'
  expect_equal(res$anomaly_type[5], "donnee_manquante")

  # La valeur bloquée en continu (index 8) doit être capturée en 'panne_capteur'
  expect_equal(res$anomaly_type[8], "panne_capteur")
})

test_that("classify_anomalies fonctionne avec l'option kmeans", {
  df <- setup_test_data()
  df_clean <- clean_sensor_data(df, timestamp_col = "Timestamp")
  df_clean$anomaly <- TRUE
  df_clean$anomaly_score <- runif(nrow(df_clean), 1, 5)

  res_km <- classify_anomalies(df_clean, timestamp_col = "timestamp", method = "kmeans")
  expect_s3_class(res_km, "data.frame")
  expect_true(any(res_km$anomaly_type %in% c("bruit_temporaire", "panne_capteur", "derive_lente", "donnee_manquante")))
})
