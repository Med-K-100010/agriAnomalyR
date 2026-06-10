library(testthat)

test_that("plot_timeseries génère un objet ggplot", {
  df_clean <- clean_sensor_data(setup_test_data(), timestamp_col = "Timestamp")
  p <- plot_timeseries(df_clean, timestamp_col = "timestamp", sensor_cols = "temperature")

  expect_s3_class(p, "ggplot")
})

test_that("plot_sensor_map génère un widget leaflet", {
  df_gps <- data.frame(latitude = c(48.8566, 45.7640), longitude = c(2.3522, 4.8357), anomaly = c(FALSE, TRUE))
  map <- plot_sensor_map(df_gps)

  expect_s3_class(map, "leaflet")
})

test_that("generate_report génère un fichier HTML sur le disque", {
  df_clean <- clean_sensor_data(setup_test_data(), timestamp_col = "Timestamp")
  tmp_dir <- tempdir()

  report_path <- generate_report(df_clean, output_dir = tmp_dir, file_name = "test_report", timestamp_col = "timestamp")

  expect_true(file.exists(report_path))
  expect_equal(tools::file_ext(report_path), "html")

  # Nettoyage après test
  unlink(report_path)
})
