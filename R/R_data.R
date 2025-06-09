lindken <- read.csv(here::here("data", "processed", "lindken_fixed.csv")) #lindken database

iucn <- read.csv(here::here("data", "processed", "iucn_simple.csv")) #IUCN simple_summary + assessments systems and realms

iucn_syn <- read.csv(here::here("data", "processed", "iucn_synonyms.csv")) #IUCN synonyms

#dd_poly <- terra::vect(here::here("data", "raw", "shapefiles", "data_deficient_polygons", "data_0.shp")) #raw
dd_poly <- terra::vect(here::here("data", "processed", "shapefiles", "dd_poly_terrestrial_dissolved.shp")) #dissolved

lost_spp <- terra::vect(here::here("data", "processed", "shapefiles", "lost_spp.shp")) #dissolved

hmi <- terra::rast("/Users/joaosvalencar/Downloads/gHM/gHM.tif")

spp_stats <- read.csv(here::here("data", "processed", "spp_hmi.csv"))

# polygons to process -----------------------------------------------------
#amphibia
anura_poly1 <- terra::vect(here::here("data", "raw", "shapefiles", "anura", "ANURA_PART1.shp")) #dissolved
anura_poly2 <- terra::vect(here::here("data", "raw", "shapefiles", "anura", "ANURA_PART2.shp")) #dissolved
caudata <- terra::vect(here::here("data", "raw", "shapefiles", "caudata", "data_0.shp")) #dissolved
gymnophiona <- terra::vect(here::here("data", "raw", "shapefiles", "gymnophiona", "GYMNOPHIONA.shp")) #dissolved
amphibia <- terra::vect(here::here("data", "processed", "shapefiles", "lost_amphibia.shp")) #dissolved
#mammals
mammals <- terra::vect(here::here("data", "raw", "shapefiles", "mammals", "data_0.shp")) #dissolved
#reptiles
reptiles1 <- terra::vect(here::here("data", "raw", "shapefiles", "reptiles", "REPTILES_PART1.shp")) #dissolved
reptiles2 <- terra::vect(here::here("data", "raw", "shapefiles", "reptiles", "REPTILES_PART2.shp")) #dissolved
#birds
birdsnp0 <- terra::vect(here::here("data", "raw", "shapefiles", "birdsnp", "data_0.shp")) #dissolved
birdsnp1 <- terra::vect(here::here("data", "raw", "shapefiles", "birdsnp", "data_1.shp")) #dissolved
birdsnp2 <- terra::vect(here::here("data", "raw", "shapefiles", "birdsnp", "data_2.shp")) #dissolved
birdsp0 <- terra::vect(here::here("data", "raw", "shapefiles", "birdsp", "data_0.shp")) #dissolved
birdsp1 <- terra::vect(here::here("data", "raw", "shapefiles", "birdsp", "data_1.shp")) #dissolved

# processed polygons to merge ---------------------------------------------

amphibia <- terra::vect(here::here("data", "processed", "shapefiles", "lost_amphibia.shp")) #dissolved
reptiles <- terra::vect(here::here("data", "processed", "shapefiles", "lost_reptiles.shp")) #dissolved
birds <- terra::vect(here::here("data", "processed", "shapefiles", "lost_birds.shp")) #dissolved
mammals <- terra::vect(here::here("data", "processed", "shapefiles", "lost_mammals.shp")) #dissolved
