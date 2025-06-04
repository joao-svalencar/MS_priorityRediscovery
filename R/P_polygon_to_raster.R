#João Paulo dos Santos Vieira de Alencar#
# Preparing shapefiles for prioritization analyses ------------------------

# Loading packages --------------------------------------------------------
library(terra)

# Loading vectors ---------------------------------------------------------

lost_spp <- terra::vect(here::here("data", "processed", "shapefiles", "lost_spp.shp")) #dissolved
bg <- terra::vect(here::here("data", "processed", "shapefile", "lostBG.shp"))  # anuraBG shapefile
world <- terra::vect(here::here("data", "raw", "shapefiles", "world.shp"))  # world shapefile


# Definir una resolución deseada para el raster (en unidades del sistema de coordenadas)
res <- 0.0083  #en grados si está en WGS84
raster_base <- rast(ext(world), resolution = res)
crs(raster_base) <- crs(world)

# rasterize basics --------------------------------------------------------

raster_base <- rast(ext(world), resolution = res) #creates a general background; ext define extension
crs(raster_base) <- crs(poly) #poly is a vectorial shapefile to be rasterized; crs information are given to general background
raster_poly <- rasterize(poly[which(poly$species=="Nectophrynoides asperginis")], raster_base, field = 1, background = 0, touches = TRUE)
masked <- mask(raster_poly, world)
writeRaster(raster_poly, here::here("data", "raw", "sppRasters", paste("Nectophrynoides asperginis", ".tif", sep="")), overwrite = TRUE)


# for iterations ----------------------------------------------------------

for(i in 1:length(spp$species))
  {
  sppRaster <- mask(rasterize(spp[i], raster_base, field = 1, background = 0), world)
  writeRaster(sppRaster, here::here("data", "raw", "sppRasters", paste(spp[i]$species, ".tif", sep="")), overwrite = TRUE)
  }