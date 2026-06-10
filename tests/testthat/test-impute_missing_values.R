library(testthat)

test_that("impute_missing_values remplit efficacement les valeurs manquantes", {
  df <- setup_test_data()
  df_clean <- clean_sensor_data(df, timestamp_col = "Timestamp")

  # Vérifier qu'il y a bien des NA avant imputation
  expect_true(any(is.na(df_clean$soil_moisture)))

  # Imputation linéaire
  res_linear <- impute_missing_values(df_clean, timestamp_col = "timestamp", method = "linear")
  expect_false(any(is.na(res_linear$soil_moisture)))

  # Imputation Moyenne Mobile
  res_ma <- impute_missing_values(df_clean, timestamp_col = "timestamp", method = "moving_average", window = 3)
  expect_false(any(is.na(res_ma$soil_moisture)))

  # Imputation KNN
  res_knn <- impute_missing_values(df_clean, timestamp_col = "timestamp", method = "knn", k = 2)
  expect_false(any(is.na(res_knn$soil_moisture)))
})
