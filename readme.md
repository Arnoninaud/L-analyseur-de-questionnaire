# 📊 Analyseur de questionnaires à l'échelle départementale (France)

Cette application développée sous **R** permet de **cartographier** et **analyser des questionnaires** à l'échelle départementale en France, à l'aide d'**Analyses des Correspondances Multiples (ACM)** et de **clustering**.  
Elle repose sur une interface **Shiny** interactive et sur des données administratives issues de l'IGN.

---

## 🎯 Fonctionnalités principales

- **Import de questionnaires** au format `.csv` avec encodage UTF-8
- **Analyse statistique avancée** : ACM (Analyse des Correspondances Multiples) avec clustering k-means
- **Cartographie interactive** des résultats par département et régions (via Leaflet)
- **Visualisations dynamiques** : graphiques interactifs (Plotly), tableaux de données (DT)
- **Profils de clusters** : identification des modalités sur-représentées dans chaque cluster
- **Interface web moderne** via **Shiny** avec thème personnalisé (Zephyr)

---

## 📁 Structure attendue du projet

```
analyseur-de-questionnaire/
│
├── analyseur de questionnaire.Rproj
├── app.R                          # Application Shiny principale
├── préparation des données.R       # Script de préparation des géométries
├── exemple.csv                     # Fichier de test
│
├── data_geo/                       # Dossier créé par le script de préparation
│   ├── dept_geometries.rds         # Géométries des départements (format R)
│   └── region_geometries.rds       # Géométries des régions (format R)
│
└── admin_express/                  # Données IGN (à télécharger)
    ├── DEPARTEMENT.shp
    ├── REGION.shp
    └── ... (autres fichiers associés)
```

---

## 📊 Prérequis sur les données

### Format du questionnaire
- Le questionnaire doit être **au format `.csv`** avec encodage **UTF-8**
- Il doit contenir **une colonne indiquant le département** associé à chaque répondant
- Les noms des départements doivent correspondre aux noms officiels (ex: "FINISTÈRE", "PARIS", "CÔTES-D'ARMOR")
- Les colonnes à analyser doivent contenir des **variables qualitatives** (ou être convertibles en facteurs)

### Traitement automatique des données
L'application effectue automatiquement :
- **Normalisation des noms de départements** : conversion en majuscules et suppression des espaces superflus
- **Conversion des variables** : transformation en facteurs pour l'ACM si nécessaire
- **Gestion des valeurs manquantes** : remplacement des NA par 0 dans les comptages géographiques

---

## 🗺️ Données cartographiques

L'application utilise les couches **Admin Express** de l'IGN :
- **Départements** (DEPARTEMENT.shp)
- **Régions** (REGION.shp)

📥 **Téléchargement** :  
[https://geoservices.ign.fr/adminexpress](https://geoservices.ign.fr/adminexpress)

### Installation des données géographiques
1. Téléchargez le fichier Admin Express de l'IGN
2. Décompressez-le dans un dossier nommé **`admin_express`**
3. Placez ce dossier dans le même répertoire que **`analyseur de questionnaire.Rproj`**

---

## ⚙️ Installation des dépendances

Avant de lancer l'application, installez les packages R suivants :

```r
install.packages(c(
  "shiny",           # Interface web interactive
  "bslib",           # Thème moderne pour Shiny
  "leaflet",         # Cartographie interactive
  "sf",              # Manipulation de données spatiales
  "FactoMineR",      # Analyses multivariées (ACM)
  "dplyr",           # Manipulation de données
  "tidyr",           # Restructuration de données
  "ggplot2",         # Graphiques statiques
  "shinycssloaders", # Indicateurs de chargement
  "plotly",          # Graphiques interactifs
  "htmltools",       # Génération de HTML
  "data.table",      # Lecture rapide de fichiers CSV
  "DT"               # Tableaux interactifs
))
```

⚠️ Une **connexion Internet** est requise pour :
- Le chargement des tuiles cartographiques (CartoDB Positron)
- Le thème Google Font (Montserrat)

---

## ▶️ Utilisation

### 1️⃣ Préparation des données géographiques

**⚠️ Cette étape n'est à exécuter qu'une seule fois**

Exécutez le script de préparation :
```r
source("préparation des données.R")
```

Ce script :
- Charge les fichiers `.shp` d'Admin Express
- Transforme les géométries en projection Lambert 93 (EPSG:2154)
- Sauvegarde les données au format `.rds` dans le dossier `data_geo/`
- **Durée estimée** : quelques minutes selon votre machine

### 2️⃣ Lancement de l'application

```r
shiny::runApp("app.R")
```

Ou ouvrez le fichier `app.R` dans RStudio et cliquez sur **"Run App"**.

### 3️⃣ Configuration de l'analyse

Une fois l'application lancée :

1. **📁 Import du fichier CSV**  
   Cliquez sur "Résultat de la campagne (.csv)" et sélectionnez votre fichier de questionnaire

2. **📍 Sélection de la colonne département**  
   Dans la liste déroulante "Colonne avec le département", choisissez la variable contenant les noms des départements

3. **📊 Configuration de l'ACM**  
   - Sélectionnez les **variables à analyser** (variables qualitatives de votre questionnaire)
   - Choisissez le **nombre de clusters** souhaité (entre 2 et 10)
   - Valeur par défaut : 2 clusters

4. **▶️ Lancement**  
   Cliquez sur le bouton **"Lancer l'analyse"**

L'application effectue alors :
- Une **Analyse des Correspondances Multiples (ACM)** sur les 2 premières dimensions
- Un **clustering k-means** avec 25 initialisations aléatoires pour garantir la stabilité
- Le calcul des **contributions des modalités** aux dimensions
- L'agrégation des données par territoire géographique

---

## 💻 Interface et fonctionnalités détaillées

### 🎨 Design de l'interface
- **Thème** : Zephyr (Bootstrap) avec police Montserrat
- **Couleurs** : fond clair (#ecf1f5) pour une meilleure lisibilité
- **Indicateurs de chargement** : spinners animés pendant les calculs

---

### 📑 Onglet 1 : ACM

#### 📈 Graphique de l'ACM
- **Visualisation interactive** (Plotly) des individus dans le plan factoriel (Dim 1 × Dim 2)
- **Coloration par cluster** : chaque cluster a une couleur distincte
- **Pourcentage d'inertie** affiché sur les axes (contribution de chaque dimension)
- **Interactivité** : 
  - Zoom, déplacement, sélection de zones
  - Info-bulles au survol affichant le numéro de cluster et les coordonnées

#### 📊 Tableau des modalités contributives
- **Top 10 des modalités** les plus contributives (trié par contribution moyenne)
- **Colonnes** :
  - `Variable` : nom de la variable d'origine
  - `Modalite` : valeur de la modalité
  - `Contrib_Dim1` : contribution à la dimension 1
  - `Contrib_Dim2` : contribution à la dimension 2
  - `Contrib_Moyenne` : moyenne des deux contributions
- **Mise en forme** : barres de couleur proportionnelles (bleu clair) pour visualiser rapidement les contributions
- **Filtrage automatique** : seules les 10 modalités les plus importantes sont affichées

**💡 Interprétation** : Les modalités avec une forte contribution moyenne sont celles qui structurent le plus les différences entre les répondants.

---

### 👥 Onglet 2 : Profils des clusters

#### 🔍 Tableau des caractéristiques des clusters
- **Identification des modalités sur-représentées** dans chaque cluster
- **Colonnes** :
  - `Cluster` : numéro du cluster
  - `Effectif` : nombre de répondants dans ce cluster
  - `Variable` : nom de la variable
  - `Modalite` : valeur de la modalité sur-représentée
  - `Pct_Cluster` : pourcentage de répondants du cluster ayant choisi cette modalité
  - `Ratio` : ratio de sur-représentation (> 1 signifie sur-représentation)
- **Filtres appliqués** :
  - Seules les modalités avec un **ratio > 1.2** sont affichées (sur-représentation d'au moins 20%)
  - **Top 5 des modalités** les plus sur-représentées par cluster
- **Tri** : par cluster puis par ratio décroissant
- **Barre de recherche** intégrée pour filtrer par nom de variable ou modalité
- **Mise en forme** : barres vertes proportionnelles au ratio de sur-représentation

**💡 Utilisation** : Ce tableau permet d'identifier rapidement les profils types de chaque cluster (ex: "Cluster 1 = personnes âgées + zone rurale + faible revenu").

---

### 🗺️ Onglet 3 : Cartographie

#### ⚙️ Paramètres de la carte

**1. Échelle géographique**
- **Département** (par défaut) : carte à l'échelle départementale
- **Région** : agrégation automatique des départements par région
  - Utilise une table de correspondance entre départements et régions
  - Calcul automatique du code région pour chaque répondant

**2. Affichage des clusters**
- **Case à cocher "Afficher les clusters"** :
  - ❌ **Non cochée** : affiche uniquement le nombre total de répondants par territoire
  - ✅ **Cochée** : affiche la répartition des répondants par cluster dans chaque territoire

#### 🗺️ Carte interactive Leaflet

**Fonctionnalités** :
- **Tuiles de fond** : CartoDB Positron (fond clair et épuré)
- **Coloration des territoires** : échelle de couleur jaune-orange-rouge (palette YlOrRd) proportionnelle au nombre de répondants
- **Contours** : bordures blanches pour délimiter les territoires
- **Effet de survol** :
  - Mise en valeur du territoire (opacité augmentée, bordure grise)
  - Affichage d'une info-bulle avec :
    - **Nom du territoire** (département ou région)
    - **Nombre total de répondants**
    - **Si clusters affichés** : détail du nombre de répondants par cluster
- **Légende** : échelle de couleur avec le nombre de répondants (position : bas-droite)

#### 🔧 Traitement des données cartographiques

L'application effectue automatiquement :
1. **Normalisation des noms** : conversion en majuscules et suppression des espaces
2. **Jointure spatiale** :
   - Pour les **départements** : jointure directe avec `nom_dept`
   - Pour les **régions** : jointure en deux étapes (département → code région → région)
3. **Agrégation des comptages** :
   - Calcul du nombre de répondants par territoire
   - Si clusters activés : calcul du nombre de répondants par cluster **et** par territoire (pivot avec `tidyr`)
4. **Filtrage** : seuls les territoires avec au moins 1 répondant sont affichés
5. **Gestion des NA** : remplacement automatique par 0

**💡 Statistiques affichées** :
- En cas de non-correspondance entre les noms de départements du fichier et les données IGN, l'application affiche une notification d'avertissement

---

## 🧪 Exemple de test

Un fichier **`exemple.csv`** est fourni pour tester l'application.

### Configuration suggérée :
- **Colonne département** : `Departement`
- **Variables à analyser** : sélectionnez toutes les colonnes sauf `Departement`
- **Nombre de clusters** : 3

Cet exemple permet de vérifier :
- Le bon fonctionnement de l'import CSV
- La génération des graphiques et tableaux
- L'affichage de la carte avec des données réalistes

---

## 🛠️ Fonctionnalités techniques avancées

### 📊 Analyse des Correspondances Multiples (ACM)
- **Algorithme** : `FactoMineR::MCA()`
- **Dimensions conservées** : 2 premières dimensions (les plus explicatives)
- **Conversion automatique** : toutes les variables sélectionnées sont converties en facteurs si nécessaire
- **Graphe désactivé** : calcul uniquement des résultats numériques (pas de graphique automatique)

### 🎯 Clustering k-means
- **Nombre d'initialisations** : 25 (paramètre `nstart = 25`)
- **Espace de clustering** : coordonnées des individus sur les 2 premières dimensions de l'ACM
- **Stabilité** : les multiples initialisations garantissent un résultat optimal

### 🗺️ Géométries spatiales
- **Format** : Shapefiles IGN transformés en objets `sf` (Simple Features)
- **Projection** : Lambert 93 (EPSG:2154) – projection officielle française
- **Stockage** : fichiers `.rds` pour un chargement rapide au démarrage de l'application

### 📈 Tableaux interactifs (DT)
- **Pagination** : 10 à 15 lignes par page selon les onglets
- **Tri** : clic sur les en-têtes de colonnes
- **Recherche** : barre de recherche globale intégrée
- **Export** : possibilité d'exporter les données (fonctionnalité DT native)

---

## ⚠️ Limitations et recommandations

### Limitations
- **Taille des données** : l'ACM peut être lente avec plus de 10 000 répondants (temps de calcul ~30 secondes)
- **Variables continues** : l'ACM est conçue pour des variables qualitatives ; discrétisez les variables continues si nécessaire
- **Noms de départements** : doivent correspondre exactement aux noms officiels IGN (avec accents, traits d'union, etc.)

### Recommandations
- **Encodage** : assurez-vous que votre fichier CSV est en **UTF-8** pour éviter les problèmes d'accents
- **Nombre de clusters** : 
  - Trop peu (2-3) : risque de regroupements trop larges
  - Trop nombreux (8-10) : risque de sur-segmentation et clusters peu interprétables
  - **Recommandation** : 3 à 5 clusters pour la plupart des questionnaires
- **Variables à analyser** : ne sélectionnez que les variables pertinentes pour votre analyse (évitez les identifiants, dates non catégorisées, etc.)

---

## 🐛 Dépannage

### L'application ne se lance pas
- Vérifiez que tous les packages sont installés
- Vérifiez que le dossier `data_geo/` contient bien les fichiers `.rds`
- Relancez le script `préparation des données.R` si nécessaire

### La carte est vide
- Vérifiez que la colonne département sélectionnée contient bien des noms de départements
- Vérifiez que les noms sont cohérents avec les données IGN (majuscules, accents, traits d'union)
- Consultez les notifications d'avertissement de l'application

### Les clusters ne s'affichent pas sur la carte
- Assurez-vous d'avoir cliqué sur **"Lancer l'analyse"** avant de cocher "Afficher les clusters"
- Les clusters ne sont disponibles qu'après l'exécution de l'ACM

---

## 📝 Licence et contributions

Cette application est fournie à titre d'exemple éducatif.  
Les données géographiques appartiennent à l'IGN et sont soumises à leur licence respective.

---

## 📧 Contact et support

Pour toute question ou suggestion d'amélioration, n'hésitez pas à ouvrir une issue sur le dépôt du projet.
