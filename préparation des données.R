# prepare_carto_simple.R
# ══════════════════════════════════════════════════════════════════
# Préparation SIMPLIFIÉE des couches Admin Express
# Seulement : Départements et Régions
# ══════════════════════════════════════════════════════════════════

library(sf)
library(dplyr)

# --- Paramètres ---
in_dir <- "admin_express"
out_dir <- "data_geo"
dir.create(out_dir, showWarnings = FALSE)

# Simplification des géométries (pour alléger)
simp_dept <- 200
simp_reg  <- 500

# --- Lecture des couches ---
cat("📂 Lecture des couches Admin Express...\n")

dept_raw <- st_read(file.path(in_dir, "departements.gpkg"), quiet = TRUE)
reg_raw  <- st_read(file.path(in_dir, "regions.gpkg"), quiet = TRUE)

# --- Transformation en WGS84 (pour Leaflet) ---
dept_raw <- st_transform(dept_raw, 4326)
reg_raw  <- st_transform(reg_raw, 4326)

# --- Fonction de nettoyage des noms ---
clean_name <- function(x) {
  x <- toupper(trimws(as.character(x)))
  x <- stringr::str_squish(x)
  x[x == ""] <- NA_character_
  x
}

# --- Départements ---
cat("🗺️ Préparation des départements...\n")

dept_sf <- dept_raw %>%
  mutate(
    code_dept = as.character(code_insee),
    nom_dept = clean_name(nom_officiel),
    code_reg = as.character(code_insee_de_la_region)
  ) %>%
  select(code_dept, nom_dept, code_reg, geom) %>%
  mutate(geometry = st_make_valid(geom)) %>%
  st_simplify(dTolerance = simp_dept, preserveTopology = TRUE)

saveRDS(dept_sf, file.path(out_dir, "dept_geometries.rds"))
cat("✔ Départements enregistrés (", nrow(dept_sf), "polygones)\n")

# --- Régions ---
cat("🌍 Préparation des régions...\n")

region_sf <- reg_raw %>%
  mutate(
    code_reg = as.character(code_insee),
    nom_region = clean_name(nom_officiel)
  ) %>%
  select(code_reg, nom_region, geom) %>%
  mutate(geometry = st_make_valid(geom)) %>%
  st_simplify(dTolerance = simp_reg, preserveTopology = TRUE)

saveRDS(region_sf, file.path(out_dir, "region_geometries.rds"))
cat("✔ Régions enregistrées (", nrow(region_sf), "polygones)\n")

# --- Résumé ---
cat("\n✅ Préparation terminée !\n")
cat("📁 Fichiers dans", out_dir, ":\n")
cat("   - dept_geometries.rds (", nrow(dept_sf), "départements)\n")
cat("   - region_geometries.rds (", nrow(region_sf), "régions)\n")