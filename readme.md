# 📊 Analyseur de questionnaires à l’échelle départementale (France)

Cette application développée sous **R** permet de **cartographier** et **analyser des questionnaires** à l’échelle départementale en France, à l’aide d’**analyses de comparaisons multiples**.  
Elle repose sur une interface **Shiny** interactive et sur des données administratives issues de l’IGN.

---

## 🎯 Fonctionnalités

- Import de questionnaires au format `.csv`
- Analyse statistique (comparaisons multiples)
- Cartographie interactive des résultats par département et régions
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
Ce script est assez long et est à ne faire fonctionner qu'une seul fois

2. **Lancer l’application Shiny**
   ```r
   shiny::runApp("app.R")
   ```
3. **Ajouter votre questionnaire dans l'espace dédié**

4. **Indiquer la collone de votre questionnaire qui contient les noms des départements**

5. **Choisir les collones pour faire votre ACM**

6. **Choisir le nombre de cluster voulus**

7. **Cliquer sur "Lancer l'analyse"**
---

## 🧪 Exemple

Un fichier **`exemple.csv`** est fourni pour tester l’application.  
Lors du paramétrage, sélectionnez la colonne **`Departement`** comme variable contenant les noms des départements.

## 💻 Interface

A la suite de toute les préparation, vous aurez accès à 3 onglets:

1. **ACM** qui va vous donné un graphique de la répartition des clusters selon les deux dimensions les plus explicatives. En dessous, vous trouverer les 20 variables les plus explicatives ainsi que leurs contributions respectives à la dimension 1 et 2.

2. **Profils des clusters** ici il y a un tableau représentatant les informations sur les clusters avec par modalité, sont cluster, l'effectif de répondants au sein de celui-ci, le pourcentage de personne dans le cluster aillant choisi cette modalité de réponses et leurs ratio. Une barre de recherche permet de chercher une modalité particulière.

3. **Cartographie**, ce dernière onglet donne accès à une carte leaflet représentant le nombre de personnes par, en fonction de l'échelles choisi, région ou départements. si **afficher les clusters** n'est pas coché , en passant la souris sur les polygones vous aurez l'information du nombre de répondant, mais si il est coché , vous aurez l'information du nombre de répondants par clusters dans les zones désignés.



