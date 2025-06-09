# creating zonation archives ----------------------------------------------
#has to add five columns: condition, group, weight, wgrp, filename

zon_ex <- read.table(here::here("data","zonation_example", "feature_list_DD.txt"), header = TRUE)
head(zon_ex)

lost_path <- "/Users/joaosvalencar/Downloads/lost_rasters"
dd_path <- "/Users/joaosvalencar/Downloads/dd_rasters"

# Lost species archive ----------------------------------------------------
lost_filename <- c(dir(lost_path)) #lost filenames

filename <- paste0("../lost_rasters/", lost_filename)

lost_names <- sub("^[^_]+_(.+)\\.tif$", "\\1", lost_filename)
toMerge <- data.frame(lost_names, filename)

lost_stats <- spp_stats[spp_stats$source=="lost_spp",]

feature_list_lost <- merge(lost_stats, toMerge, by.x="species", by.y="lost_names")
feature_list_lost <- feature_list_lost[,-5]

lost_data <- data.frame(lost_spp)
head(lost_data)
lost_data <- lost_data[,c(1,3)]

feature_list_lost <- merge(feature_list_lost, lost_data, by="id_no")



#has to add five columns: condition, group, weight, wgrp, filename
feature_list_lost <- data.frame(condition = rep(NA, times = dim(lost_data)[1]),
                                group = rep(NA, times = dim(lost_data)[1]),
                                weight = rep(NA, times = dim(lost_data)[1]),
                                wgrp = rep(NA, times = dim(lost_data)[1]),
                                filename = rep(NA, times = dim(lost_data)[1]))

head(feature_list_lost)

feature_list_lost$condition <- rep(1, times = dim(lost_data)[1])
feature_list_lost$group <- match(feature_list_DD$class, c("Amphibia", "Reptilia", "Aves", "Mammalia"))
feature_list_lost$weight <- round(feature_list_DD$median_gHM, digits=3) #median
feature_list_lost$wgrp <- match(feature_list_DD$class, c("Amphibia", "Reptilia", "Aves", "Mammalia"))
feature_list_lost$filename <- feature_list_lost$filename

head(feature_list_lost)

write.table(feature_list_lost, here::here("data", "zonation_rediscovery", "feature_list_lost.txt"),
            row.names = FALSE, quote = FALSE)
?write.table
