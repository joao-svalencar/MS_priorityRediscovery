#João Paulo dos Santos Vieira de Alencar#
# Preparing shapefiles for prioritization analyses ------------------------

# Loading packages --------------------------------------------------------
library(terra)

# Loading vectors ---------------------------------------------------------
lost_spp <- terra::vect(here::here("data", "processed", "shapefiles", "lost_spp.shp"))
#lost_spp$dissolve <- 1
#lostBG <- terra::aggregate(lost_spp, by="dissolve", cores = 9)
lostBG <- terra::vect(here::here("data", "processed", "shapefiles", "lostBG.shp"))
#terra::writeVector(lostBG, here::here("data", "processed", "shapefiles", "lostBG.shp"), filetype = "ESRI Shapefile", overwrite = TRUE)

dd_poly <- terra::vect(here::here("data", "processed", "shapefiles", "dd_poly_terrestrial_dissolved.shp")) #dissolved
#dd_poly$dissolve <- 1
#ddBG <- terra::aggregate(dd_poly, by="dissolve", cores = 9)
ddBG <- terra::vect(here::here("data", "processed", "shapefiles", "ddBG.shp"))
#terra::writeVector(ddBG, here::here("data", "processed", "shapefiles", "ddBG.shp"), filetype = "ESRI Shapefile", overwrite = TRUE)


# Parallel for lost -------------------------------------------------------
path_lost <- "/Users/joaosvalencar/Documents/priorityRediscovery/zonation/rasters/lost_rasters/"

library(terra)
library(future.apply)

# Set up multithreading for terra
terra::terraOptions(threads = 2)  # Each raster function can use up to 2 threads

# Set up parallel plan for the whole loop
future::plan(multisession, workers = 5)  # Use 5 parallel workers

# Define the function to be run in parallel
process_species <- function(i) {
  library(terra)
  terra::terraOptions(threads = 2)  # Each raster function can use up to 4 threads
  lost_spp <- terra::vect(here::here("data", "processed", "shapefiles", "lost_spp.shp")) #dissolved
  lostBG <- terra::vect(here::here("data", "processed", "shapefiles", "lostBG.shp"))  # anuraBG shapefile
  world <- terra::vect(here::here("data", "raw", "shapefiles", "world.shp"))  # world shapefile
  
  res <- 0.0083333333
  raster_base <- terra::rast(terra::ext(world), resolution = res)
  terra::crs(raster_base) <- terra::crs(world)
  
  poly <- lost_spp[i, ]
  spp_name <- poly$species
  spp_name <- gsub(" ", "_", spp_name)
  spp_class <- poly$class
  
  file_out <- paste0(path_lost, spp_class, "_", spp_name, ".tif")
  
  # Skip if file exists (checkpointing)
  if (file.exists(file_out)) return(paste("✅ Exists:", spp_name))
  
  tryCatch({
    r <- terra::rasterize(poly, raster_base, field = 1, background = 0, touches = TRUE)
    r_masked <- terra::mask(r, lostBG)
    
    terra::writeRaster(r_masked,
                file_out,
                datatype = "INT1U",
                gdal = c("COMPRESS=DEFLATE", "ZLEVEL=1"),
                overwrite = TRUE)
    
    paste("✅ Done:", spp_name)
  }, error = function(e) {
    paste("❌ Failed:", spp_name, "-", e$message)
  })
}

# Run the parallel loop
results <- future_lapply(1:nrow(lost_spp), process_species, future.seed = TRUE)


# Parallel for DD ---------------------------------------------------------
path_dd <- "/Users/joaosvalencar/Documents/priorityRediscovery/zonation/rasters/dd_rasters/"

library(terra)
library(future.apply)

# Set up multithreading for terra
terra::terraOptions(threads = 2)  # Each raster function can use up to 2 threads

# Set up parallel plan for the whole loop
future::plan(multisession, workers = 5)  # Use 5 parallel workers

process_species <- function(i) {
  library(terra)
  terra::terraOptions(threads = 2)
  dd_poly <- terra::vect(here::here("data", "processed", "shapefiles", "dd_poly_terrestrial_dissolved.shp")) #dissolved
  ddBG <- terra::vect(here::here("data", "processed", "shapefiles", "ddBG.shp"))
  world <- terra::vect(here::here("data", "raw", "shapefiles", "world.shp"))  # world shapefile
  
  res <- 0.0083333333
  raster_base <- terra::rast(terra::ext(world), resolution = res)
  terra::crs(raster_base) <- terra::crs(world)
  
  poly <- dd_poly[i, ]
  spp_name <- poly$species
  spp_name <- gsub(" ", "_", spp_name)
  spp_class <- poly$class
  
  file_out <- paste0(path_dd, spp_class, "_", spp_name, ".tif")
  
  # Skip if file exists (checkpointing)
  if (file.exists(file_out)) return(paste("✅ Exists:", spp_name))
  
  tryCatch({
    r <- terra::rasterize(poly, raster_base, field = 1, background = 0, touches = TRUE)
    r_masked <- terra::mask(r, ddBG)
    
    terra::writeRaster(r_masked,
                       file_out,
                       datatype = "INT1U",
                       gdal = c("COMPRESS=DEFLATE", "ZLEVEL=1"),
                       overwrite = TRUE)
    
    paste("✅ Done:", spp_name)
  }, error = function(e) {
    paste("❌ Failed:", spp_name, "-", e$message)
  })
}

# Run the parallel loop
results <- future_lapply(1:nrow(dd_poly), process_species, future.seed = TRUE)


# background raster -------------------------------------------------------
terra::terraOptions(threads = 10)

system.time(
r <- terra::rasterize(bg, raster_base, field = 1, background = NA, touches = TRUE)
)

terra::writeRaster(r,
                   here::here("data", "processed", "rasters", "bg.tif"),
                   datatype = "INT1U",
                   gdal = c("COMPRESS=DEFLATE", "ZLEVEL=1"),
                   overwrite = TRUE)
