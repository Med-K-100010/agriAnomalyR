# agriAnomalyR

`agriAnomalyR` est un package R pour importer, nettoyer, détecter, classer et visualiser des anomalies dans des données de capteurs agricoles.

## Fonctionnalités

- `import_sensor_data()` : import CSV, JSON, Excel
- `clean_sensor_data()` : suppression des doublons, correction des valeurs impossibles, harmonisation temporelle
- `detect_anomalies()` : z-score, IQR, moyenne mobile, score d'isolement léger
- `classify_anomalies()` : bruit temporaire, panne capteur, dérive lente, donnée manquante
- `impute_missing_values()` : interpolation linéaire, moyenne mobile, KNN simple
- `calculate_sensor_statistics()` : résumé statistique
- `compare_sensors()` : corrélation et incohérences
- `plot_timeseries()` : visualisation temporelle
- `plot_sensor_map()` : carte Leaflet
- `generate_alerts()` : tableau d'alertes
- `generate_report()` : rapport HTML

## Jeu de données

Une source réelle ouverte a été identifiée pour servir de référence :
https://www.kaggle.com/datasets/colabsss/edge-assisted-agricultural-sensor-dataset

## Exemple rapide
## copier dans la console et executer
```r
library(agriAnomalyR)

data <- import_sensor_data("C:\file.csv") #mettez le chemin de votre fichier ou vous le laissé vide et il prend automatiquement les donnees preexistantes
data_clean <- clean_sensor_data(data)
data_Anom <- detect_anomalies(data_clean, method = "moving_average")
data_classif <- classify_anomalies(data_Anom)
data_imp_miss_val <- impute_missing_values(data_classif, method = "linear")
stats <- calculate_sensor_statistics(data_imp_miss_val)
alerts <- generate_alerts(data_imp_miss_val)
plot_timeseries(data_imp_miss_val)
```



## Structure du projet

```text
agriAnomalyR/
├── DESCRIPTION
├── NAMESPACE
├── R/
├── inst/
├── vignettes/
├── tests/
├── data-raw/
└── README.md
```
