# 📊 Analyseur de questionnaires à l’échelle départementale (France)

Cette application développée sous **R** permet de **cartographier** et **analyser des questionnaires** à l’échelle départementale en France, à l’aide d’**analyses de comparaisons multiples**.  
Elle repose sur une interface **Shiny** interactive et sur des données administratives issues de l’IGN.

---

## 🎯 Fonctionnalités

- Import de questionnaires au format `.csv`
- Analyse statistique (comparaisons multiples)
- Cartographie interactive des résultats par département
- Visualisations dynamiques (graphiques, cartes, tableaux)
- Interface web via **Shiny**

---

## 📁 Structure attendue du projet

```
analyseur-de-questionnaire/
│
├── analyseur de questionnaire.Rproj
├── app.R
├── préparation des données.R
├── exemple.csv
│
└── admin_express/
    ├── DEPARTEMENT.shp
    ├── REGION.shp
    └── ...
```

---

## 📊 Prérequis sur les données

- Le questionnaire doit être **au format `.csv`**
- Il doit contenir **une colonne indiquant le département associé à chaque répondant**
- Les noms des départements doivent être cohérents avec ceux des données Admin Express

---

## 🗺️ Données cartographiques

L’application utilise les couches **Admin Express** de l’IGN :

- Départements  
- Régions

📥 Téléchargement :  
https://geoservices.ign.fr/adminexpress

Les fichiers doivent être :
- stockés dans un dossier nommé **`admin_express`**
- placé dans le même répertoire que le fichier **`analyseur de questionnaire.Rproj`**

---

## ⚙️ Installation des dépendances

Avant de lancer l’application, installez les packages R suivants :

```r
install.packages(c(
  "shiny",
  "leaflet",
  "sf",
  "FactoMineR",
  "dplyr",
  "ggplot2",
  "shinycssloaders",
  "plotly",
  "htmltools",
  "data.table",
  "DT"
))
```

⚠️ Une **connexion Internet** est requise pour certaines fonctionnalités (cartographie interactive et thème de l'application).

---

## ▶️ Utilisation

1. **Préparer les données**  
   Exécuter le script :
   ```r
   préparation des données.R
   ```

2. **Lancer l’application Shiny**
   ```r
   shiny::runApp("app.R")
   ```

---

## 🧪 Exemple

Un fichier **`exemple.csv`** est fourni pour tester l’application.  
Lors du paramétrage, sélectionnez la colonne **`Departement`** comme variable contenant les noms des départements.

---

## 🧑‍💻 Auteur

**Arnaud Burel**  
Master 1 – Cartographie et Gestion de l’Environnement  
Université de Nantes



