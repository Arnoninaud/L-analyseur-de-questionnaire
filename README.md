# L'analyseur de questionnaire à échelle départemental

Une application sur R qui permet de cartographié et analyser des questionnaire par analyse de comparaisons multiples.

La seul contrainte pour votre questionnaireet que pour cartographier vos résultats de questionnaires, il faut que votre questionnaire contienne une colonne avec le nom des département associé à chaques répondants.

Il est aussi important d'avoir les couches admin express (https://geoservices.ign.fr/adminexpress) des département  et des régions de France soit  
téléchargé et stockés dans un dossier nomé admin_express lui même dans un dossier où se trouve le fichier "analyseur de questionnaire.Rproj". 

Il va falloir pour son fonctionnement préparer les données avec le script "préparation des données.R" avant de lancer les script "app.R"

Munissez-vous avant de commencer des packages sur R : 
shiny,leaflet,sf,FactoMineR,dplyr,ggplot2,shinycssloaders,plotly,htmltools,data.table,DT

Il vous faudra de plus un accès à internet
