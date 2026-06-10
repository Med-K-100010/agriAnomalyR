library(testthat)
library(agriAnomalyR)

# ==============================================================================
# Préparation des données communes (Mutualisation)
# ==============================================================================
path <- system.file("extdata", "agriculture_dataset_with_target.csv", package = "agriAnomalyR")

# Si le fichier de test existe, on prépare les objets pour tous les tests
if (nzchar(path)) {
  raw_data     <- import_sensor_data(path)
  cleaned_data <- clean_sensor_data(raw_data)
}

# ==============================================================================
# Blocs de Tests
# ==============================================================================

test_that("import_sensor_data reads csv correctly", {
  skip_if_not(nzchar(path), message = "Fichier d'exemple introuvable")

  expect_true(nrow(raw_data) > 0)
  expect_true(ncol(raw_data) > 0)
  # On ne teste pas "timestamp" ici car le fichier brut peut avoir des majuscules
})

test_that("clean_sensor_data standardizes and cleans data", {
  skip_if_not(nzchar(path))

  expect_true(nrow(cleaned_data) <= nrow(raw_data))
  # Ici c'est sûr, clean_sensor_data a converti le nom en minuscules :
  expect_true("timestamp" %in% names(cleaned_data))
})

test_that("detect and classify anomalies work in sequence", {
  skip_if_not(nzchar(path))

  # On utilise cleaned_data
  anom_data <- detect_anomalies(cleaned_data, method = "moving_average")
  expect_true("anomaly" %in% names(anom_data))

  classified_data <- classify_anomalies(anom_data)
  expect_true("anomaly_type" %in% names(classified_data))
})

test_that("statistics and alerts handle cleaned data", {
  skip_if_not(nzchar(path))

  # Crucial : On passe 'cleaned_data' et non 'raw_data' !
  stats  <- calculate_sensor_statistics(cleaned_data)
  alerts <- generate_alerts(cleaned_data)

  expect_true(nrow(stats) > 0)
  expect_true(is.data.frame(alerts))
})
