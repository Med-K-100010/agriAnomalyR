library(testthat)

test_that("clean_sensor_data nettoie correctement les données", {
  df <- setup_test_data()

  # Ajouter un doublon de timestamp pour tester la déduplication
  df_dup <- rbind(df, df[1, ])

  res <- clean_sensor_data(df_dup, timestamp_col = "Timestamp")

  # 1. Vérification du format de sortie
  expect_s3_class(res, "data.frame")
  expect_equal(nrow(res), 10) # Le doublon doit être supprimé

  # 2. Vérification de la standardisation du nom de colonne (Timestamp -> timestamp)
  expect_true("timestamp" %in% names(res))
  expect_false("Timestamp" %in% names(res))

  # 3. Vérification de l'application des règles (150 devient NA pour soil_moisture)
  # index 3 dans l'original avait la valeur 150
  expect_true(is.na(res$soil_moisture[3]))
})

test_that("clean_sensor_data gère la régularisation de la fréquence", {
  df <- setup_test_data()
  # Retirer une ligne pour créer un trou dans la fréquence
  df_gap <- df[-5, ]

  res <- clean_sensor_data(df_gap, timestamp_col = "Timestamp", frequency = "10 min")

  expect_equal(nrow(res), 10) # La ligne manquante doit être réintroduite (remplie de NA)
  expect_true(is.na(res$soil_moisture[5]))
})
