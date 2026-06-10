library(testthat)

test_that("calculate_sensor_statistics renvoie les bonnes métriques", {
  df_clean <- clean_sensor_data(setup_test_data(), timestamp_col = "Timestamp")
  stats <- calculate_sensor_statistics(df_clean, anomaly_col = "anomaly")

  expect_s3_class(stats, "data.frame")
  expect_true(all(c("sensor", "mean", "min", "max", "missing_rate", "anomaly_rate") %in% names(stats)))
  expect_equal(nrow(stats), 2) # soil_moisture et temperature
})

test_that("compare_sensors évalue la cohérence des capteurs", {
  df_clean <- clean_sensor_data(setup_test_data(), timestamp_col = "Timestamp")
  comp <- compare_sensors(df_clean, timestamp_col = "timestamp")

  expect_type(comp, "list")
  expect_true("correlation_matrix" %in% names(comp))
  expect_true("inconsistent_sensors" %in% names(comp))
  expect_true(is.matrix(comp$correlation_matrix))
})

test_that("generate_alerts crée un tableau d'alertes conforme", {
  df <- setup_test_data()
  df_clean <- clean_sensor_data(df, timestamp_col = "Timestamp")

  alerts <- generate_alerts(df_clean, timestamp_col = "timestamp", anomaly_col = "anomaly")

  expect_s3_class(alerts, "data.frame")
  expect_true(all(c("timestamp", "sensor", "severity", "message") %in% names(alerts)))

  if (nrow(alerts) > 0) {
    expect_true(any(alerts$severity %in% c("medium", "high")))
  }
})
