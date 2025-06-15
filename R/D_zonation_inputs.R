# creating zonation archives ----------------------------------------------
#has to add five columns: condition, group, weight, wgrp, filename

zon_ex <- read.table(here::here("data","zonation_example", "feature_list_DD.txt"), header = TRUE)
head(zon_ex)

path_lost <- "/Users/joaosvalencar/Documents/priorityRediscovery/zonation/rasters/lost_rasters/"

# Lost species archive ----------------------------------------------------
lost_filename <- c(dir(lost_path)) #lost filenames
filename <- paste0("../lost_rasters/", lost_filename)
clean_files <- gsub(".*/[^_]+_([^_]+)_([^\\.]+)\\.tif$", "\\1 \\2", filename)

lost_names <- lost_spp$species

matched_idx <- match(lost_names, clean_files) #creates vector of ids where lost_names and clean_files match
matched_files <- filename[matched_idx] #orders filename according to matching ids

toMerge <- data.frame(lost_names, matched_files) #merge species names with file names

lost_stats <- spp_stats[spp_stats$source=="lost_spp",]

feature_list_lost <- merge(lost_stats, toMerge, by.x="species", by.y="lost_names")
feature_list_lost <- feature_list_lost[,-5]

lost_data <- data.frame(lost_spp)
head(lost_data)
lost_data <- lost_data[,c(1,3)]

feature_list_lost <- merge(feature_list_lost, lost_data, by="id_no")
head(feature_list_lost)


#has to add five columns: condition, group, weight, wgrp, filename
feature_list_lost_file <- data.frame(
                                group = rep(NA, times = dim(lost_data)[1]),
                                weight = rep(NA, times = dim(lost_data)[1]),
                                wgrp = rep(NA, times = dim(lost_data)[1]),
                                filename = rep(NA, times = dim(lost_data)[1]))

head(feature_list_lost_file)

feature_list_lost_file$group <- match(feature_list_lost$class, c("Amphibia", "Reptilia", "Aves", "Mammalia"))
feature_list_lost_file$weight <- round(feature_list_lost$median_gHM, digits=3) #median
feature_list_lost_file$wgrp <- match(feature_list_lost$class, c("Amphibia", "Reptilia", "Aves", "Mammalia"))
feature_list_lost_file$filename <- feature_list_lost$matched_files

head(feature_list_lost_file)

write.table(feature_list_lost, here::here("data", "zonation", "feature_list_lost.txt"),
            row.names = FALSE, quote = FALSE)

# DD species archive ------------------------------------------------------
path_dd <- "/Users/joaosvalencar/Documents/priorityRediscovery/zonation/rasters/dd_rasters/"

DD_filename <- c(dir(path_dd)) #DD filenames

filename <- paste0("../dd_rasters/", DD_filename)

clean_files <- gsub(".*/[^_]+_([^_]+)_([^\\.]+)\\.tif$", "\\1 \\2", filename)

dd_names <- dd_poly$species

matched_idx <- match(dd_names, clean_files) #creates vector of ids where lost_names and clean_files match
matched_files <- filename[matched_idx] #orders filename according to matching ids

toMergeDD <- data.frame(dd_names, matched_files) #merge species names with file names
head(toMerge)

dd_stats <- spp_stats[spp_stats$source=="dd_spp",]

feature_list_DD <- merge(dd_stats, toMergeDD, by.x="species", by.y="dd_names")
feature_list_DD <- feature_list_DD[,-5]
head(feature_list_DD)

dd_data <- data.frame(dd_poly)
head(dd_data)
dd_data <- dd_data[,c(1,3)]

feature_list_DD <- merge(feature_list_DD, dd_data, by="id_no")
head(feature_list_DD)


feature_list_DD_file <- data.frame(
                                group = rep(NA, times = dim(dd_data)[1]),
                                weight = rep(NA, times = dim(dd_data)[1]),
                                wgrp = rep(NA, times = dim(dd_data)[1]),
                                filename = rep(NA, times = dim(dd_data)[1]))

head(feature_list_DD_file)

feature_list_DD_file$group <- match(feature_list_DD$class, c("Amphibia", "Reptilia", "Aves", "Mammalia"))
feature_list_DD_file$weight <- round(feature_list_DD$median_gHM, digits=3) #median
feature_list_DD_file$wgrp <- match(feature_list_DD$class, c("Amphibia", "Reptilia", "Aves", "Mammalia"))
feature_list_DD_file$filename <- feature_list_DD$matched_files

head(feature_list_DD_file)

write.table(feature_list_DD_file, here::here("data", "zonation", "feature_list_DD.txt"),
            row.names = FALSE, quote = FALSE)
