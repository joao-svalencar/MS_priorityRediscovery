# creating zonation archives ----------------------------------------------
#has to add four columns: group, weight, wgrp, filename

#feature_list_lost <- read.table(here::here("data","zonation", "feature_list_lost.txt"), header = TRUE)
#head(feature_list_lost)

lost_spp <- lost_spp[,c(1,3,7,11)] #species, class, iucn, last_seen
head(lost_spp)

# Get quantile cut points (excluding 0% and 100% to avoid edge issues)
q <- quantile(lost_spp$last_seen, probs = c(0, 0.25, 0.5, 0.75, 1), na.rm = TRUE)

# Create the column with values 1 to 4
# adding weight to species last seen: highest to the longest time no seen
lost_spp$last_seen_idx <- cut(lost_spp$last_seen,
                                breaks = q,
                                labels = 4:1,
                                include.lowest = TRUE,
                                right = TRUE) 

head(lost_spp)

#adding weight to species IUCN classification:
lost_spp$iucn_idx <- with(lost_spp, ifelse(lost_spp$iucn %in% c("LC", "NT"), 1,
                                           ifelse(lost_spp$iucn %in% c("VU", "DD"), 2,
                                           ifelse(lost_spp$iucn == "EN", 3,
                                           ifelse(lost_spp$iucn == "CR", 4,
                                           ifelse(lost_spp$iucn == "EX", 5, NA)))))) 

#weight is the product of last seen and IUCN classification:
lost_spp$weight <- as.numeric(as.character(lost_spp$last_seen_idx)) * as.integer(lost_spp$iucn_idx)

head(lost_spp)

# Lost species archive ----------------------------------------------------

#create path to the raster files:
path_lost <- "/Users/joaosvalencar/Documents/priorityRediscovery/zonation/setup/lost_rasters5_moll/"
lost_filename <- c(dir(path_lost)) #lost species filenames
filename <- paste0("../lost_rasters/", lost_filename) #adding the specific directory to the filename
clean_files <- gsub(".*/[^_]+_([^_]+)_([^\\.]+)\\.tif$", "\\1 \\2", filename) #removing the first part of the filename to spp name match merging

lost_names <- lost_spp$species

matched_idx <- match(lost_names, clean_files) #creates vector of ids where lost_names and clean_files match
matched_files <- filename[matched_idx] #orders filenames according to matching ids

toMerge <- data.frame(lost_names, matched_files) #merge species names with file names


feature_list_lost <- merge(lost_spp, toMerge, by.x="species", by.y="lost_names") #merging weight to species filenames
head(feature_list_lost)

# creating the Zonation feature list input --------------------------------

#has to add four columns: roup, weight, wgrp, filename
feature_list_lost_file <- data.frame(
                                group = rep(NA, times = dim(feature_list_lost)[1]),
                                weight = rep(NA, times = dim(feature_list_lost)[1]),
                                wgrp = rep(NA, times = dim(feature_list_lost)[1]),
                                filename = rep(NA, times = dim(feature_list_lost)[1]))

head(feature_list_lost_file)

feature_list_lost_file$group <- match(feature_list_lost$class, c("Amphibia", "Reptilia", "Aves", "Mammalia"))
feature_list_lost_file$weight <- feature_list_lost$weight
feature_list_lost_file$wgrp <- match(feature_list_lost$class, c("Amphibia", "Reptilia", "Aves", "Mammalia"))
feature_list_lost_file$filename <- feature_list_lost$matched_files

head(feature_list_lost_file)

write.table(feature_list_lost_file, here::here("data", "zonation", "feature_list_lost.txt"),
            row.names = FALSE, quote = FALSE)

# DD species archive ------------------------------------------------------

feature_list_DD <- read.table(here::here("data","zonation", "feature_list_DD.txt"), header = TRUE)
head(feature_list_DD)
feature_list_DD$weight <- 1
write.table(feature_list_DD, here::here("data", "zonation", "feature_list_DD.txt"),
            row.names = FALSE, quote = FALSE)

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
