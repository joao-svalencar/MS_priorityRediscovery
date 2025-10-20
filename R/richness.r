#richness map
library(terra)

# 1. List all your binary raster files
files <- list.files("/Users/joaosvalencar/Documents/priorityRediscovery/zonation/setup/lost_rasters5_moll", pattern = "\\.tif$", full.names = TRUE) #all species

lost <- rast(files) # automatically stacks them into a multilayer SpatRaster

# 3. Sum across layers to get richness
richness <- sum(lost, na.rm = TRUE)

freq_table <- terra::freq(richness)

# 4. Save richness raster
writeRaster(richness, here::here("outputs", "rasters", "lost_richness.tif"), 
            overwrite = TRUE,
            datatype = "INT2U",   # safe for richness values
            gdal = c("COMPRESS=DEFLATE", "ZLEVEL=5"))



# Files starting with "Amphibia_"
amphibia <- list.files("/Users/joaosvalencar/Documents/priorityRediscovery/zonation/setup/lost_rasters5_moll", pattern = "^Amphibia_.*\\.tif$", full.names = TRUE)

reptiles <- list.files("/Users/joaosvalencar/Documents/priorityRediscovery/zonation/setup/lost_rasters5_moll", pattern = "^Reptilia_.*\\.tif$", full.names = TRUE)

birds <- list.files("/Users/joaosvalencar/Documents/priorityRediscovery/zonation/setup/lost_rasters5_moll", pattern = "^Aves_.*\\.tif$", full.names = TRUE)

mammals <- list.files("/Users/joaosvalencar/Documents/priorityRediscovery/zonation/setup/lost_rasters5_moll", pattern = "^Mammalia_.*\\.tif$", full.names = TRUE)
