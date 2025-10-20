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
#ddBG <- terra::aggregate(dd_poly, by="dissolve")
ddBG <- terra::vect(here::here("data", "processed", "shapefiles", "ddBG.shp"))
#terra::writeVector(ddBG, here::here("data", "processed", "shapefiles", "ddBG.shp"), filetype = "ESRI Shapefile", overwrite = TRUE)

# Parallel for lost -------------------------------------------------------
path_lost <- "/Users/joaosvalencar/Documents/priorityRediscovery/zonation/setup/lost_rasters/"
path_lost <- "/Users/joaosvalencar/Documents/priorityRediscovery/zonation/setup/lost_rasters5_moll/"

library(terra)
library(future.apply)

# Set up multithreading for terra
terra::terraOptions(threads = 10)  # Each raster function can use up to 2 threads

# Set up parallel plan for the whole loop
future::plan(multisession, workers = 5)  # Use 5 parallel workers

# Define the function to be run in parallel
process_lostSpecies <- function(i) {
  library(terra)
  terra::terraOptions(threads = 2)  # Each raster function can use up to 4 threads
  lost_spp <- terra::vect(here::here("data", "processed", "shapefiles", "lost_spp.shp")) #dissolved
  
  spp_name <- lost_spp$species[i]
  spp_name <- gsub(" ", "_", spp_name)
  spp_class <- lost_spp$class[i]
  
  file_out <- paste0(path_lost, spp_class, "_", spp_name, ".tif")
  
  # Skip if file exists (checkpointing)
  if (file.exists(file_out)){
    return(paste("✅ Exists:", spp_name))
    }else{
      poly <- lost_spp[i, ]
      lostBG <- terra::vect(here::here("data", "processed", "shapefiles", "lostBG.shp"))  # lostBG shapefile
      world <- terra::vect(here::here("data", "raw", "shapefiles", "world.shp"))  # world shapefile
      
      #res <- 0.0083333333 #1km
      res <- 0.0083333333 *5 #5km
      raster_base <- terra::rast(terra::ext(world), resolution = res)
      terra::crs(raster_base) <- terra::crs(world)
      
      tryCatch({
        r <- terra::rasterize(poly, raster_base, field = 1, background = 0, touches = TRUE)
        r_masked <- terra::mask(r, lostBG)
        
        terra::writeRaster(r_masked,
                    file_out,
                    datatype = "INT1U",
                    gdal = c("COMPRESS=DEFLATE", "ZLEVEL=5"),
                    overwrite = TRUE)
        
        paste("✅ Done:", spp_name)
      }, error = function(e) {
        paste("❌ Failed:", spp_name, "-", e$message)
      })
    }
}
# Run the parallel loop
results <- future_lapply(1:nrow(lost_spp), process_lostSpecies, future.seed = TRUE)


# Parallel for DD ---------------------------------------------------------
path_dd <- "/Users/joaosvalencar/Documents/priorityRediscovery/zonation/setup/dd_rasters/"
path_dd <- "/Users/joaosvalencar/Documents/priorityRediscovery/zonation/setup/dd_rasters5/"
library(terra)
library(future.apply)

# Set up multithreading for terra
terra::terraOptions(threads = 2)  # Each raster function can use up to 2 threads

# Set up parallel plan for the whole loop
future::plan(multisession, workers = 5)  # Use 5 parallel workers

process_ddSpecies <- function(i) {
  library(terra)
  terra::terraOptions(threads = 2)
  dd_poly <- terra::vect(here::here("data", "processed", "shapefiles", "dd_poly_terrestrial_dissolved.shp")) #dissolved
  
  spp_name <- dd_poly$species[i]
  spp_name <- gsub(" ", "_", spp_name)
  spp_class <- dd_poly$class[i]
  
  file_out <- paste0(path_dd, spp_class, "_", spp_name, ".tif")
  
  # Skip if file exists (checkpointing)
  if (file.exists(file_out)){
    return(paste("✅ Exists:", spp_name))
    }else{
      poly <- dd_poly[i, ]
      ddBG <- terra::vect(here::here("data", "processed", "shapefiles", "ddBG.shp"))
      world <- terra::vect(here::here("data", "raw", "shapefiles", "world.shp"))  # world shapefile
      
      #res <- 0.0083333333 #1km
      res <- 0.0083333333 *5 #5km 
      raster_base <- terra::rast(terra::ext(world), resolution = res)
      terra::crs(raster_base) <- terra::crs(world)

      tryCatch({
        r <- terra::rasterize(poly, raster_base, field = 1, background = 0, touches = TRUE)
        r_masked <- terra::mask(r, ddBG)
        
        terra::writeRaster(r_masked,
                           file_out,
                           datatype = "INT1U",
                           gdal = c("COMPRESS=DEFLATE", "ZLEVEL=5"),
                           overwrite = TRUE)
        
        paste("✅ Done:", spp_name)
      }, error = function(e) {
        paste("❌ Failed:", spp_name, "-", e$message)
      })
    }
}

# Run the parallel loop
results <- future_lapply(1:nrow(dd_poly), process_ddSpecies, future.seed = TRUE)


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


# PARALLEL WITH MOLLWEID PROJECTION ---------------------------------------
path_lost <- "/Users/joaosvalencar/Documents/priorityRediscovery/zonation/setup/lost_rasters5_moll/"

library(terra)
library(future)
library(future.apply)

process_lostSpecies <- function(i) {
  library(terra)
  terra::terraOptions(threads = 2)
  
  # Set CRS to Mollweide
  moll_crs <- "ESRI:54009"
  
  # Load and project shapefiles
  lost_spp <- terra::vect(here::here("data", "processed", "shapefiles", "lost_spp.shp"))
  lost_spp <- terra::project(lost_spp, moll_crs)
  
  lostBG <- terra::vect(here::here("data", "processed", "shapefiles", "lostBG.shp"))
  lostBG <- terra::project(lostBG, moll_crs)
  
  world <- terra::vect(here::here("data", "raw", "shapefiles", "world.shp"))
  world <- terra::project(world, moll_crs)
  
  # Base raster: 5km (5000 meters) resolution
  raster_base <- terra::rast(terra::ext(world), resolution = 5000)
  terra::crs(raster_base) <- moll_crs
  
  spp_name <- lost_spp$species[i]
  spp_name <- gsub(" ", "_", spp_name)
  spp_class <- lost_spp$class[i]
  
  file_out <- paste0(path_lost, spp_class, "_", spp_name, ".tif")
  
  if (file.exists(file_out)) {
    return(paste("✅ Exists:", spp_name))
  } else {
    poly <- lost_spp[i, ]
    
    tryCatch({
      cat("Rasterizing:", spp_name, "\n")
      r <- terra::rasterize(poly, raster_base, field = 1, background = 0, touches = TRUE)
      
      cat("Masking:", spp_name, "\n")
      r_masked <- terra::mask(r, lostBG)
      
      cat("Writing:", spp_name, "\n")
      terra::writeRaster(
        r_masked,
        file_out,
        datatype = "INT1U",
        gdal = c("COMPRESS=DEFLATE", "ZLEVEL=5"),
        overwrite = TRUE
      )
      
      paste("✅ Done:", spp_name)
    }, error = function(e) {
      paste("❌ Failed:", spp_name, "-", e$message)
    })
  }
}

future::plan(multisession, workers = 5)  # Use 5 parallel workers
results <- future_lapply(1:nrow(lost_spp), process_lostSpecies, future.seed = TRUE)


# MOLLWEID DD -------------------------------------------------------------
path_dd <- "/Users/joaosvalencar/Documents/priorityRediscovery/zonation/setup/dd_rasters5_moll/"

library(terra)
library(future)
library(future.apply)

process_ddSpecies <- function(i) {
  library(terra)
  terra::terraOptions(threads = 2)
  
  # Set CRS to Mollweide
  moll_crs <- "ESRI:54009"
  
  # Load and project shapefiles
  dd_poly <- terra::vect(here::here("data", "processed", "shapefiles", "dd_poly_terrestrial_dissolved.shp")) #dissolved
  dd_poly <- terra::project(dd_poly, moll_crs)
  
  ddBG <- terra::vect(here::here("data", "processed", "shapefiles", "ddBG.shp"))
  ddBG <- terra::project(ddBG, moll_crs)
  
  world <- terra::vect(here::here("data", "raw", "shapefiles", "world.shp"))
  world <- terra::project(world, moll_crs)
  
  # Base raster: 5km (5000 meters) resolution
  raster_base <- terra::rast(terra::ext(world), resolution = 5000)
  terra::crs(raster_base) <- moll_crs
  
  spp_name <- dd_poly$species[i]
  spp_name <- gsub(" ", "_", spp_name)
  spp_class <- dd_poly$class[i]
  
  file_out <- paste0(path_dd, spp_class, "_", spp_name, ".tif")
  
  if (file.exists(file_out)) {
    return(paste("✅ Exists:", spp_name))
  } else {
    poly <- dd_poly[i, ]
    
    tryCatch({
      r <- terra::rasterize(poly, raster_base, field = 1, background = 0, touches = TRUE)
      r_masked <- terra::mask(r, ddBG)
      
      terra::writeRaster(
        r_masked,
        file_out,
        datatype = "INT1U",
        gdal = c("COMPRESS=DEFLATE", "ZLEVEL=5"),
        overwrite = TRUE
      )
      
      paste("✅ Done:", spp_name)
    }, error = function(e) {
      paste("❌ Failed:", spp_name, "-", e$message)
    })
  }
}

future::plan(multisession, workers = 5)  # Use 5 parallel workers
results <- future_lapply(1:nrow(dd_poly), process_ddSpecies, future.seed = TRUE)


