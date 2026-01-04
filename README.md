# L-analyseur-de-questionnaire
Last active 2 weeks ago 

Une application sur R qui permet de cartographié et analyser des questionnaire par analyse de comparaisons multiples.

La seul contrainte et que pour cartographier vos résultats de questionnaires, il faut que votre questionnaire contienne une colonne avec le nom des département associé à chaques répondants.
Il est aussi important d'avoir les couches admin express des département (https://geoservices.ign.fr/adminexpresset des régions de France 
à la suite de leurs téléchargement, il est impératif de les stockés dans un dossier nomé admin_express. 
Il va falloir pour son fonctionnement préparer les données avec le script "prepare_carto_simple.R" 

munissez-vous avant de commencer des packages sur R : 
shiny,leaflet,sf,FactoMineR,dplyr,ggplot2,shinycssloaders,plotly,htmltools,data.table,DT
