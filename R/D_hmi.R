library(terra)

# Calculating HMI for  each species ---------------------------------------
names(dd_poly)[c(1,2)] <- c("id_no", "species")
names(lost_spp)

lost_proj <- terra::project(lost_spp, hmi) #add Mollweide projection (ESRI:54009) to lost spp polygons
lost_proj <- lost_proj[,c(1,2)]
names(lost_proj)
lost_stats <- extract(hmi, lost_proj, fun = c("mean", "median"), na.rm = TRUE, bind=TRUE)

lost_stats <- data.frame(lost_stats)

dd_proj <- terra::project(dd_poly, hmi) #add Mollweide projection (ESRI:54009) to lost spp polygons
dd_proj <- dd_poly[,c(1,2)]
names(dd_proj)
dd_stats <- extract(hmi, dd_proj, fun = c("mean", "median"), na.rm = TRUE, bind=TRUE)

dd_stats <- data.frame(dd_stats)

dd_stats$source <- "dd_spp"
lost_stats$source <- "lost_spp"

spp_stats <- rbind(lost_stats, dd_stats) #full spp stats

write.csv(spp_stats, here::here("data", "processed", "spp_hmi.csv"), row.names = FALSE)


