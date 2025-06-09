#João Paulo dos Santos Vieira de Alencar#
# Preparing shapefiles for prioritization analyses ------------------------

# Loading packages --------------------------------------------------------
library(terra)

# Loading vectors ---------------------------------------------------------

lost_spp <- terra::vect(here::here("data", "processed", "shapefiles", "lost_spp.shp")) #dissolved
bg <- terra::vect(here::here("data", "processed", "shapefiles", "lostBG.shp"))  # anuraBG shapefile
world <- terra::vect(here::here("data", "raw", "shapefiles", "world.shp"))  # world shapefile


# Definir una resolución deseada para el raster (en unidades del sistema de coordenadas)
res <- 0.0083333333
raster_base <- terra::rast(terra::ext(world), resolution = res)
terra::crs(raster_base) <- terra::crs(world)

# rasterize basics --------------------------------------------------------

raster_base <- rast(ext(world), resolution = res) #creates a general background; ext define extension
#crs(raster_base) <- crs(poly) #poly is a vectorial shapefile to be rasterized; crs information are given to general background
raster_poly <- rasterize(lost_spp[1], raster_base, field = 1, background = 0, touches = TRUE)
masked <- mask(raster_poly, bg)
writeRaster(masked, here::here("data", "processed", "rasters", paste("Arthropleptides_dutoiti", ".tif", sep="")), overwrite = TRUE)


library(terra)
path <- "/Users/joaosvalencar/Downloads/dd_rasters/"

for(i in seq_along(dd_poly$SCI_NAME)){
  
  spp_name <- dd_poly$SCI_NAME[i]
  spp_class <- dd_poly$class[i]
  poly <- dd_poly[i]
  
  r <- rasterize(poly, raster_base, field = 1, background = 0, touches = TRUE)
  r_masked <- mask(r, bg)
  
  writeRaster(r_masked,
              paste0(path, spp_class, "_", spp_name, ".tif"),
              overwrite = TRUE)
}

dd_rasters <- dir("/Users/joaosvalencar/Downloads/dd_rasters/")
spp_rasters <- sub("^[^_]+_(.+)\\.tif$", "\\1", dd_rasters)

sum(spp_rasters%in%dd_poly$SCI_NAME)
