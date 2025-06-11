#João Paulo dos Santos Vieira de Alencar#
# Preparing shapefiles for prioritization analyses ------------------------

# Loading packages --------------------------------------------------------
library(terra)

# Loading vectors ---------------------------------------------------------
lost_spp <- terra::vect(here::here("data", "processed", "shapefiles", "lost_spp.shp")) #dissolved
dd_poly <- terra::vect(here::here("data", "processed", "shapefiles", "dd_poly_terrestrial_dissolved.shp")) #dissolved

bg <- terra::vect(here::here("data", "processed", "shapefiles", "lostBG.shp"))  # anuraBG shapefile
world <- terra::vect(here::here("data", "raw", "shapefiles", "world.shp"))  # world shapefile

res <- 0.0083333333
raster_base <- terra::rast(terra::ext(world), resolution = res)
terra::crs(raster_base) <- terra::crs(world)


# Parallel for lost -------------------------------------------------------
path_lost <- "/Users/joaosvalencar/Documents/priorityRediscovery/lost_rasters/"

library(terra)
library(future.apply)

# Set up multithreading for terra
terraOptions(threads = 2)  # Each raster function can use up to 2 threads

# Set up parallel plan for the whole loop
future::plan(multisession, workers = 5)  # Use 5 parallel workers

# Define the function to be run in parallel
process_species <- function(i) {
  library(terra)
  terra::terraOptions(threads = 2)  # Each raster function can use up to 4 threads
  lost_spp <- terra::vect(here::here("data", "processed", "shapefiles", "lost_spp.shp")) #dissolved
  bg <- terra::vect(here::here("data", "processed", "shapefiles", "lostBG.shp"))  # anuraBG shapefile
  world <- terra::vect(here::here("data", "raw", "shapefiles", "world.shp"))  # world shapefile
  
  res <- 0.0083333333
  raster_base <- terra::rast(terra::ext(world), resolution = res)
  terra::crs(raster_base) <- terra::crs(world)
  
  poly <- lost_spp[i, ]
  spp_name <- poly$species
  spp_class <- poly$class
  
  file_out <- paste0(path_lost, spp_class, "_", spp_name, ".tif")
  
  # Skip if file exists (checkpointing)
  if (file.exists(file_out)) return(paste("✅ Exists:", spp_name))
  
  tryCatch({
    r <- terra::rasterize(poly, raster_base, field = 1, background = 0, touches = TRUE)
    r_masked <- terra::mask(r, bg)
    
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
path_dd <- "/Users/joaosvalencar/Documents/priorityRediscovery/dd_rasters/"

process_species <- function(i) {
  library(terra)
  terra::terraOptions(threads = 2)  # Each raster function can use up to 4 threads
  dd_poly <- terra::vect(here::here("data", "processed", "shapefiles", "dd_poly_terrestrial_dissolved.shp")) #dissolved
  bg <- terra::vect(here::here("data", "processed", "shapefiles", "lostBG.shp"))  # anuraBG shapefile
  world <- terra::vect(here::here("data", "raw", "shapefiles", "world.shp"))  # world shapefile
  
  res <- 0.0083333333
  raster_base <- terra::rast(terra::ext(world), resolution = res)
  terra::crs(raster_base) <- terra::crs(world)
  
  poly <- dd_poly[i, ]
  spp_name <- poly$species
  spp_class <- poly$class
  
  file_out <- paste0(path_dd, spp_class, "_", spp_name, ".tif")
  
  # Skip if file exists (checkpointing)
  if (file.exists(file_out)) return(paste("✅ Exists:", spp_name))
  
  tryCatch({
    r <- terra::rasterize(poly, raster_base, field = 1, background = 0, touches = TRUE)
    r_masked <- terra::mask(r, bg)
    
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


