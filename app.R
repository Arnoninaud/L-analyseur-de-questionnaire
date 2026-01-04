library(shiny)
library(leaflet)
library(sf)
library(FactoMineR)
library(dplyr)
library(ggplot2)
library(shinycssloaders)
library(plotly)
library(htmltools)
library(data.table)
library(DT)

departements_sf <- readRDS("data_geo/dept_geometries.rds")
regions_sf <- readRDS("data_geo/region_geometries.rds")

ui <- fluidPage(
  theme = bslib::bs_theme(
    base_font = bslib::font_google("Montserrat"),
    bootswatch = "zephyr",
    bg = "#ecf1f5",
    fg ="#000000"
  ),
  
  titlePanel("Analyse de questionnaire comprenant un champs département"),
  
  sidebarLayout(
    sidebarPanel(
      width = 3,
      
      fileInput("file", "Résultat de la campagne (.csv)", accept = ".csv"),
      
      uiOutput("dept_selector"),
      
      hr(),
      
      h5("📊 Analyse ACM"),
      uiOutput("acm_columns_selector"),
      sliderInput("n_clusters", "Nombre de clusters", 2, min = 2, max = 10),
      
      hr(),
      
      actionButton("go", "Lancer l'analyse", class = "btn-primary btn-block"),
      
      br(), br()
    ),
    
    mainPanel(
      width = 9,
      
      tabsetPanel(
        tabPanel("📈 ACM",
                 plotlyOutput("acm_plot", height = "500px") %>% withSpinner(),
                 br(),
                 h4("Top 20 modalités contributives"),
                 DTOutput("modalites_table") %>% withSpinner()
        ),
        
        tabPanel("👥 Profils des clusters",
                 h4("Caractéristiques des clusters"),
                 DTOutput("cluster_profile") %>% withSpinner()
        ),
        
        tabPanel("🗺️ Cartographie",
                 fluidRow(
                   column(6,
                          selectInput("niveau_geo", "Échelle :", 
                                      choices = c("Département" = "departement", 
                                                  "Région" = "region"),
                                      selected = "departement")
                   ),
                   column(7,
                          checkboxInput("show_clusters_map", 
                                        "Afficher les clusters", 
                                        value = FALSE)
                   )
                 ),
                 br(),
                 leafletOutput("map", height = 650) %>% withSpinner(),
                 
        )
      )
    )
  )
)

# ------------------ SERVER ------------------
server <- function(input, output, session) {
  #bslib::bs_themer()
  # ─────── Lecture CSV ───────
  data <- reactive({
    req(input$file)
    fread(input$file$datapath, encoding = "UTF-8") %>% as.data.frame()
  })
  
  # ─────── Sélecteur colonne département ───────
  output$dept_selector <- renderUI({
    req(data())
    selectInput("dept_col", "📍 Colonne avec le département", 
                choices = names(data()))
  })
  
  # ─────── Sélecteur colonnes ACM ───────
  output$acm_columns_selector <- renderUI({
    req(data())
    selectInput("acm_cols", "Variables pour l'ACM", 
                choices = names(data()), 
                multiple = TRUE)
  })
  
  # ─────── ACM + Clustering ───────
  acm_res <- eventReactive(input$go, {
    req(data(), input$acm_cols)
    
    withProgress(message = "Analyse en cours...", {
      
      df <- data()[, input$acm_cols, drop = FALSE]
      df[] <- lapply(df, function(x) if (!is.factor(x)) as.factor(x) else x)
      
      incProgress(0.3, detail = "ACM...")
      acm <- MCA(df, ncp = 2, graph = FALSE)
      
      incProgress(0.7, detail = "Clustering...")
      cluster <- kmeans(acm$ind$coord[, 1:2], centers = input$n_clusters, nstart = 25)
      
      incProgress(1)
      list(acm = acm, cluster = cluster, data_acm = df)
    })
  })
  clusters_with_data <- reactive({
    req(acm_res(), data(), input$dept_col)
    
    df <- data()
    
    # Ajout du cluster aux données originales
    df$cluster <- as.factor(acm_res()$cluster$cluster)
    
    df
  })
  
  # ─────── Plot ACM ───────
  output$acm_plot <- renderPlotly({
    req(acm_res())
    
    df_plot <- data.frame(
      Dim1 = acm_res()$acm$ind$coord[, 1],
      Dim2 = acm_res()$acm$ind$coord[, 2],
      Cluster = as.factor(acm_res()$cluster$cluster)
    )
    
    p <- ggplot(df_plot, aes(x = Dim1, y = Dim2, color = Cluster)) +
      geom_point(alpha = 0.6, size = 2) +
      theme_minimal() +
      labs(
        title = "ACM - Dimensions 1 & 2",
        x = paste0("Dim 1 (", round(acm_res()$acm$eig[1, 2], 1), "%)"),
        y = paste0("Dim 2 (", round(acm_res()$acm$eig[2, 2], 1), "%)")
      )
    
    ggplotly(p, tooltip = c("Cluster", "x", "y"))
  })
  
  # ─────── Tableau modalités ───────
  output$modalites_table <- renderDT({
    req(acm_res())
    
    contrib <- as.data.frame(acm_res()$acm$var$contrib)
    
    modalites_df <- data.frame(
      Modalite_complete = rownames(contrib),
      Contrib_Dim1 = round(contrib$`Dim 1`, 2),
      Contrib_Dim2 = round(contrib$`Dim 2`, 2)
    ) %>%
      mutate(
        Variable = sub("_.*", "", Modalite_complete),
        Modalite = sub(".*_", "", Modalite_complete),
        Contrib_Moyenne = round((Contrib_Dim1 + Contrib_Dim2) / 2, 2)
      ) %>%
      arrange(desc(Contrib_Moyenne)) %>%
      select(Variable, Modalite, Contrib_Dim1, Contrib_Dim2, Contrib_Moyenne) %>%
      head(10)
    
    datatable(modalites_df, 
              options = list(pageLength = 10, dom = 't'),
              rownames = FALSE) %>%
      formatStyle('Contrib_Moyenne', 
                  background = styleColorBar(range(modalites_df$Contrib_Moyenne), 'lightblue'),
                  backgroundSize = '100% 90%',
                  backgroundRepeat = 'no-repeat',
                  backgroundPosition = 'center')
  })
  
  # ─────── Profil des clusters ───────
  output$cluster_profile <- renderDT({
    req(acm_res())
    
    df <- acm_res()$data_acm
    df$Cluster <- acm_res()$cluster$cluster
    
    profiles <- lapply(1:input$n_clusters, function(k) {
      cluster_data <- df[df$Cluster == k, ]
      n_cluster <- nrow(cluster_data)
      
      if (n_cluster == 0) return(NULL)
      
      var_summaries <- lapply(names(df)[names(df) != "Cluster"], function(var) {
        tab_cluster <- table(cluster_data[[var]])
        tab_global <- table(df[[var]])
        
        ratios <- (tab_cluster / n_cluster) / (tab_global / nrow(df))
        
        if (length(ratios) > 0 && max(ratios) > 0) {
          top_mod <- names(which.max(ratios))
          data.frame(
            Variable = var,
            Modalite = top_mod,
            Pct_Cluster = round(100 * tab_cluster[top_mod] / n_cluster, 1),
            Ratio = round(ratios[top_mod], 2),
            stringsAsFactors = FALSE
          )
        } else {
          NULL
        }
      })
      
      var_summaries <- var_summaries[!sapply(var_summaries, is.null)]
      if (length(var_summaries) == 0) return(NULL)
      
      result <- do.call(rbind, var_summaries) %>%
        filter(Ratio > 1.2) %>%
        arrange(desc(Ratio)) %>%
        head(5)
      
      if (nrow(result) == 0) return(NULL)
      
      result$Cluster <- k
      result$Effectif <- n_cluster
      result
    })
    
    profiles <- profiles[!sapply(profiles, is.null)]
    
    if (length(profiles) == 0) {
      return(data.frame(Message = "Aucune sur-représentation détectée"))
    }
    
    profiles_df <- do.call(rbind, profiles) %>%
      select(Cluster, Effectif, Variable, Modalite, Pct_Cluster, Ratio) %>%
      arrange(Cluster, desc(Ratio))
    
    datatable(profiles_df, 
              options = list(pageLength = 15),
              rownames = FALSE) %>%
      formatStyle('Ratio',
                  background = styleColorBar(range(profiles_df$Ratio), 'lightgreen'),
                  backgroundSize = '100% 90%',
                  backgroundRepeat = 'no-repeat',
                  backgroundPosition = 'center')
  })
  
  # ═════════════════════════════════════════════════════════════════
  # CARTOGRAPHIE SIMPLIFIÉE
  # ═════════════════════════════════════════════════════════════════
  
  # ─────── Agrégation par département/région ───────
  map_data <- reactive({
    req(data(), input$dept_col, input$niveau_geo)
    
    df <- data()
    
    # Normaliser les noms de départements
    df$dept_clean <- toupper(trimws(as.character(df[[input$dept_col]])))
    
    # Ajouter les clusters si disponibles
    if (!is.null(acm_res())) {
      df$cluster <- as.factor(acm_res()$cluster$cluster)
    }
    
    # Choisir la couche géographique
    if (input$niveau_geo == "departement") {
      geo_sf <- departements_sf
      id_col <- "code_dept"
      nom_col <- "nom_dept"
    } else {
      geo_sf <- regions_sf
      id_col <- "code_reg"
      nom_col <- "nom_region"
    }
    
    # Compter les répondants par territoire
    if (input$niveau_geo == "departement") {
      # Jointure directe pour départements
      counts <- df %>%
        group_by(dept_clean) %>%
        summarise(n_repondants = n(), .groups = "drop")
      
      # Si on veut les clusters
      if (input$show_clusters_map && "cluster" %in% names(df)) {
        counts_cluster <- df %>%
          group_by(dept_clean, cluster) %>%
          summarise(n = n(), .groups = "drop") %>%
          tidyr::pivot_wider(
            names_from = cluster,
            values_from = n,
            values_fill = 0,
            names_prefix = "cluster_"
          )
        counts <- counts %>% left_join(counts_cluster, by = "dept_clean")
      }
      
      # Joindre avec les géométries
      map_sf <- geo_sf %>%
        left_join(counts, by = c("nom_dept" = "dept_clean"))
      
    } else {
      # Pour les régions : passer par les départements
      dept_to_region <- departements_sf %>%
        st_drop_geometry() %>%
        select(nom_dept, code_reg)
      
      df_with_region <- df %>%
        left_join(dept_to_region, by = c("dept_clean" = "nom_dept"))
      
      counts <- df_with_region %>%
        filter(!is.na(code_reg)) %>%
        group_by(code_reg) %>%
        summarise(n_repondants = n(), .groups = "drop")
      
      # Si on veut les clusters
      if (input$show_clusters_map && "cluster" %in% names(df)) {
        counts_cluster <- df_with_region %>%
          filter(!is.na(code_reg)) %>%
          group_by(code_reg, cluster) %>%
          summarise(n = n(), .groups = "drop") %>%
          tidyr::pivot_wider(
            names_from = cluster,
            values_from = n,
            values_fill = 0,
            names_prefix = "cluster_"
          )
        counts <- counts %>% left_join(counts_cluster, by = "code_reg")
      }
      
      # Joindre avec les géométries
      map_sf <- geo_sf %>%
        left_join(counts, by = "code_reg")
    }
    
    # Remplacer les NA par 0
    map_sf <- map_sf %>%
      mutate(n_repondants = ifelse(is.na(n_repondants), 0, n_repondants))
    
    # Filtrer seulement les territoires avec répondants
    map_sf_filtered <- map_sf %>% filter(n_repondants > 0)
    
    list(
      map_sf = map_sf_filtered,
      nom_col = nom_col,
      n_total = nrow(df),
      n_matched = sum(map_sf_filtered$n_repondants, na.rm = TRUE)
    )
  })
  
  # ─────── Carte Leaflet ───────
  output$map <- renderLeaflet({
    req(map_data())
    
    map_sf <- map_data()$map_sf
    nom_col <- map_data()$nom_col
    
    if (nrow(map_sf) == 0) {
      showNotification("Aucun répondant localisé", type = "warning")
      return(leaflet() %>% addTiles())
    }
    
    # Palette de couleurs
    pal <- colorNumeric(
      palette = "YlOrRd",
      domain = map_sf$n_repondants
    )
    
    # Labelsa
    if (input$show_clusters_map && "cluster_1" %in% names(map_sf)) {
      cluster_cols <- grep("^cluster_", names(map_sf), value = TRUE)
      
      # Générer les labels ligne par ligne pour chaque territoire
      labels <- lapply(1:nrow(map_sf), function(i) {
        cluster_lines <- sapply(cluster_cols, function(col) {
          paste0(gsub("cluster_", "Cluster ", col), " : ", map_sf[[col]][i])
        })
        
        htmltools::HTML(paste0(
          "<strong>", map_sf[[nom_col]][i], "</strong><br/>",
          "Total : ", map_sf$n_repondants[i], "<br/>",
          "<hr style='margin:3px 0;'/>",
          paste(cluster_lines, collapse = "<br/>")
        ))
      })
    } else {
      labels <- paste0(
        "<strong>", map_sf[[nom_col]], "</strong><br/>",
        "Répondants : ", map_sf$n_repondants
      ) %>% lapply(htmltools::HTML)
    }
    
    # Carte
    leaflet(map_sf) %>%
      addProviderTiles(providers$CartoDB.Positron) %>%
      addPolygons(
        fillColor = ~pal(n_repondants),
        fillOpacity = 0.7,
        color = "white",
        weight = 2,
        opacity = 1,
        highlightOptions = highlightOptions(
          opacity = 1, 
          weight = 3,
          color = "#666",
          fillOpacity = 0.9,
          bringToFront = TRUE
        ),
        label = labels,
        labelOptions = labelOptions(
          style = list("font-weight" = "normal", padding = "3px 8px"),
          textsize = "13px",
          direction = "auto"
        )
      ) %>%
      addLegend(
        position = "bottomright",
        pal = pal,
        values = ~n_repondants,
        title = "Nombre de<br/>répondants",
        opacity = 0.8
      )
  })
}


shinyApp(ui, server)
