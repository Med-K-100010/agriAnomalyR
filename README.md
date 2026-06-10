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

## 💻 Exemple d'Utilisation Rapide
## copier dans la console et executer
```r
library(agriAnomalyR) #Fais appellle au differentes fonctionnalites de mon package

data <- import_sensor_data("C:\file.csv") #mettez le chemin de votre fichier ou vous le laissé vide et il prend automatiquement les donnees preexistantes
data_clean <- clean_sensor_data(data) #Standardise le nom des colonnes en minuscules et convertit les dates au bon format temporel. 
data_Anom <- detect_anomalies(data_clean, method = "moving_average") #Repère les comportements anormaux dans les données (via moyenne mobile, quantiles ou k-means)
data_classif <- classify_anomalies(data_Anom)  #Catégorise et qualifie la sévérité ou le type des anomalies qui ont été détectées
head(data_classif) # 2. Visualiser les premières lignes avec les anomalies détectées et classifiées
data_imp_miss_val <- impute_missing_values(data_classif, method = "linear") #Bouche proprement les valeurs manquantes (NA) par interpolation, moyenne mobile ou algorithme KNN
stats <- calculate_sensor_statistics(data_imp_miss_val) #Calcule les résumés statistiques (moyenne, minimum, maximum) par capteur pour analyser les tendances globales de tes données
alerts <- generate_alerts(data_imp_miss_val)  #Déclenche des alertes et génère des rapports de notification dès que les mesures franchissent des seuils critiques de danger
plot_timeseries(data_imp_miss_val) #permet de visualiser notre dataset 
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
```markdown
# agriAnomalyR 🌾

`agriAnomalyR` est un package R professionnel conçu pour l'importation, le nettoyage, l'imputation et la détection d'anomalies dans les données de capteurs IoT agricoles (humidité du sol, température, etc.). Il intègre un pipeline complet allant du fichier brut jusqu'à la génération d'alertes agronomiques.

---

## 🛠️ Description des Fonctions

Le package est articulé autour de briques fonctionnelles modulaires et d'une fonction pipeline "clé en main".

### 📥 1. Acquisition et Préparation des Données

* **`import_sensor_data(files = NULL, ...)`**
  Importe de manière flexible vos fichiers de données de capteurs depuis plusieurs formats (**CSV, JSON, Excel**). Si aucun fichier n'est spécifié, la fonction charge automatiquement un jeu de données d'exemple interne au package pour une prise en main immédiate.
  
* **`clean_sensor_data(data, ...)`**
  Standardise la structure de vos tables de données. Elle convertit tous les noms de colonnes en minuscules pour éviter les erreurs de syntaxe et transforme les chaînes de caractères de dates en objets temporels standardisés (`POSIXct`).

* **`impute_missing_values(data, method = "linear", ...)`**
  Nettoie le jeu de données en remplaçant les valeurs manquantes (`NA`) causées par des pannes de capteurs ou des pertes de signal. Elle propose trois techniques robustes : l'**interpolation linéaire**, la **moyenne mobile** (avec gestion automatique des effets de bord) et une approche par **KNN** (plus proches voisins).

---

### 🔍 2. Analyse et Détection d'Anomalies

* **`detect_anomalies(data, method = "moving_average", ...)`**
  Le cœur algorithmique du package. Analyse les séries temporelles pour y détecter des points anormaux à l'aide de trois méthodes au choix : la **moyenne mobile glissante** (écart à la tendance), les **quantiles** (valeurs extrêmes) ou le clustering **K-means**.
  
* **`classify_anomalies(data, ...)`**
  Prend le relais après la détection pour qualifier et catégoriser la sévérité ou la nature des anomalies trouvées, permettant ainsi de trier efficacement les faux positifs des vrais dysfonctionnements structurels.

---

### 📊 3. Statistiques et Alertes

* **`calculate_sensor_statistics(data, ...)`**
  Génère des résumés statistiques globaux et agrégés (moyenne, minimum, maximum, écart-type) par capteur ou par période, facilitant l'analyse des tendances agronomiques et des indicateurs de santé des cultures à long terme.

* **`generate_alerts(data, ...)`**
  Scrutateur en temps réel qui déclenche des notifications et génère des rapports d'alertes détaillés dès que les mesures des capteurs (humidité critique, pic de chaleur) franchissent des seuils agronomiques de danger prédéfinis.

---
## 🎯 Sortie attendue cas de data_classif
```r
 # A tibble: 6 × 13
  timestamp           crop_health soil_moisture soil_temperature humidity
  <dttm>              <chr>               <dbl>            <dbl>    <dbl>
1 2024-01-01 00:00:00 Healthy              20.0             16.5     72.1
2 2024-01-01 01:00:00 High_Stress          43.0             16.2     41.2
3 2024-01-01 02:00:00 Healthy              34.3             32.7     86.7
4 2024-01-01 03:00:00 High_Stress          29.0             16.2     69.8
5 2024-01-01 04:00:00 Healthy              11.2             16.8     40.2
6 2024-01-01 05:00:00 High_Stress          11.2             29.0     92.6
# ℹ 8 more variables: air_temperature <dbl>, anomaly_score <dbl>,
#   anomaly <lgl>, anomaly_soil_moisture <lgl>,
#   anomaly_soil_temperature <lgl>, anomaly_humidity <lgl>,
#   anomaly_air_temperature <lgl>, anomaly_type <chr>
```

##⚠️ 
Si vous ne dispose pas des coordonnees (latitude et longitude) dans votre dataset vous ne pourrez pas visualiser la zone, ce qui est le cas dans la dataset exemple fournis dans le package
##⚠️ Pour les programmeurs qui veulent tester l'integrite du package
##⚠️ Si for pc n'a pas rtools installez rtools si rtools est installes et que ca donne des erreurs essayez les commandes ci-dessous et d'obtenir les meme resultats  

> file.exists("C:/rtools44/x86_64-w64-mingw32.static.posix/bin/gcc.exe")
[1] TRUE
> Sys.setenv(
+     PATH = paste(
+         "C:/rtools44/x86_64-w64-mingw32.static.posix/bin",
+         "C:/rtools44/usr/bin",
+         "C:/Program Files/R/R-4.6.0/bin/x64",
+         sep = ";"
+     )
+ )
> Sys.which("gcc")
                                       gcc 
"C:\\rtools44\\X86_64~1.POS\\bin\\gcc.exe" 
> Sys.which("make")
                              make 
"C:\\rtools44\\usr\\bin\\make.exe" 
> pkgbuild::check_build_tools(debug = TRUE)
Trying to compile a simple C file
Running "C:/PROGRA~1/R/R-46~1.0/bin/x64/Rcmd.exe" SHLIB foo.c
using C compiler: 'gcc.exe (GCC) 13.3.0'
gcc  -I"C:/PROGRA~1/R/R-46~1.0/include" -DNDEBUG     -I"c:/rtools45/x86_64-w64-mingw32.static.posix/include"      -O2 -Wall -std=gnu2x  -mfpmath=sse -msse2 -mstackrealign   -c foo.c -o foo.o
gcc -shared -s -static-libgcc -o foo.dll tmp.def foo.o -Lc:/rtools45/x86_64-w64-mingw32.static.posix/lib/x64 -Lc:/rtools45/x86_64-w64-mingw32.static.posix/lib -LC:/PROGRA~1/R/R-46~1.0/bin/x64 -lR
Your system is ready to build packages!
> devtools::check()
══ Building ══════════════════════════════════════════════════════════════════
Setting env vars:
• CFLAGS    : -Wall -pedantic -fdiagnostics-color=always
• CXXFLAGS  : -Wall -pedantic -fdiagnostics-color=always
• CXX11FLAGS: -Wall -pedantic -fdiagnostics-color=always
• CXX14FLAGS: -Wall -pedantic -fdiagnostics-color=always
• CXX17FLAGS: -Wall -pedantic -fdiagnostics-color=always
• CXX20FLAGS: -Wall -pedantic -fdiagnostics-color=always
── R CMD build ───────────────────────────────────────────────────────────────
✔  checking for file 'C:\Users\HP X360\OneDrive\Documents\SDM\agriAnomalyR/DESCRIPTION' (978ms)
─  preparing 'agriAnomalyR': (509ms)
✔  checking DESCRIPTION meta-information ...
─  installing the package (it is needed to build vignettes)
✔  creating vignettes (8.1s)
─  checking for LF line-endings in source and make files and shell scripts (1.3s)
─  checking for empty or unneeded directories
   Omitted 'LazyData' from DESCRIPTION
     NB: this package now depends on R (>= 4.1.0)
     WARNING: Added dependency on R >= 4.1.0 because package code uses the
     pipe |> or function shorthand \(...) syntax added in R 4.1.0.
     File(s) using such syntax:
       'plot_sensor_map.R'
─  building 'agriAnomalyR_0.1.0.tar.gz'
   
══ Checking ══════════════════════════════════════════════════════════════════
Setting env vars:
• _R_CHECK_CRAN_INCOMING_REMOTE_               : FALSE
• _R_CHECK_CRAN_INCOMING_                      : FALSE
• _R_CHECK_FORCE_SUGGESTS_                     : FALSE
• _R_CHECK_PACKAGES_USED_IGNORE_UNUSED_IMPORTS_: FALSE
• NOT_CRAN                                     : true
── R CMD check ───────────────────────────────────────────────────────────────
─  using log directory 'C:/Users/HP X360/AppData/Local/Temp/RtmpKOq5nU/file1e9c17093666/agriAnomalyR.Rcheck' (347ms)
─  using R version 4.6.0 (2026-04-24 ucrt)
─  using platform: x86_64-w64-mingw32
─  R was compiled by
       gcc.exe (GCC) 14.3.0
       GNU Fortran (GCC) 14.3.0
─  running under: Windows 11 x64 (build 26200)
─  using session charset: UTF-8
─  current time: 2026-06-10 15:25:26 UTC
─  using options '--no-manual --as-cran'
✔  checking for file 'agriAnomalyR/DESCRIPTION'
─  checking extension type ... Package
─  this is package 'agriAnomalyR' version '0.1.0'
─  package encoding: UTF-8
✔  checking package namespace information
✔  checking package dependencies (7s)
✔  checking if this is a source package ...
✔  checking if there is a namespace
✔  checking for executable files (939ms)
✔  checking for hidden files and directories ... 
✔  checking for portable file names
✔  checking whether package 'agriAnomalyR' can be installed (4.1s)
✔  checking installed package size ... 
✔  checking package directory (342ms)
✔  checking for future file timestamps (1.3s)
✔  checking 'build' directory ...
✔  checking DESCRIPTION meta-information (445ms)
N  checking top-level files ...
   Non-standard file/directory found at top level:
     'data-raw'
✔  checking for left-over files
✔  checking index information (450ms)
✔  checking package subdirectories (1s)
✔  checking code files for non-ASCII characters ... 
✔  checking R files for syntax errors ... 
✔  checking whether the package can be loaded ... 
✔  checking whether the package can be loaded with stated dependencies ... 
✔  checking whether the package can be unloaded cleanly ... 
✔  checking whether the namespace can be loaded with stated dependencies ... 
✔  checking whether the namespace can be unloaded cleanly (339ms)
✔  checking loading without being on the library search path (522ms)
✔  checking dependencies in R code (2s)
✔  checking S3 generic/method consistency (341ms)
✔  checking replacement functions ... 
✔  checking foreign function calls ... 
✔  checking R code for possible problems (4.3s)
✔  checking Rd files (635ms)
✔  checking Rd metadata ... 
✔  checking Rd line widths ... 
✔  checking Rd cross-references (870ms)
✔  checking for missing documentation entries ... 
✔  checking for code/documentation mismatches (689ms)
✔  checking Rd \usage sections (552ms)
✔  checking Rd contents ... 
✔  checking for unstated dependencies in examples ... 
✔  checking installed files from 'inst/doc' (501ms)
✔  checking files in 'vignettes' (488ms)
─  checking examples ... NONE (1.1s)
✔  checking for unstated dependencies in 'tests' ... 
─  checking tests ...
✔  Running 'testthat.R' (3.5s)
✔  checking for unstated dependencies in vignettes (822ms)
✔  checking package vignettes ... 
✔  checking re-building of vignette outputs (5s)
✔  checking for non-standard things in the check directory
✔  checking for detritus in the temp directory ...
   
   See
     'C:/Users/HP X360/AppData/Local/Temp/RtmpKOq5nU/file1e9c17093666/agriAnomalyR.Rcheck/00check.log'
   for details.
   
── R CMD check results ─────────────────────────────── agriAnomalyR 0.1.0 ────
Duration: 48.2s

❯ checking top-level files ... NOTE
  Non-standard file/directory found at top level:
    'data-raw'

0 errors ✔ | 0 warnings ✔ | 1 note 
