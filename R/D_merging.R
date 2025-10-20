#cleaning extra spaces:
lindkenVar$species <- stringr::str_squish(lindkenVar$species)
iucn$species <- stringr::str_squish(iucn$species)

lindkenVar <- lindkenVar[,c(1, 6, 7)]

#comparing lindken and iucn
sum(lindkenVar$species %in% iucn$species) #1149/1262 : 91%

#to search the iucn synonym database:
toSearch <- lindkenVar$species[which(!lindkenVar$species %in% iucn$species)]

sum(iucn_syn$synonyms %in% toSearch) #68 species

lindken_syn <- iucn_syn[iucn_syn$synonyms %in% toSearch,]


toFix <- lindkenVar[lindkenVar$species %in% lindken_syn$synonyms,]
lindkenVar <- lindkenVar[!lindkenVar$species %in% lindken_syn$synonyms,]

toFix$species_new <- toFix$species
idx <- which(toFix$species_new %in% lindken_syn$synonyms)

for (j in seq_along(idx)) {
  # the position in toFix
  i <- idx[j]
  syn <- toFix$species_new[i]
  
  # find current name(s) in lindken_syn; assume exactly one match
  cur <- lindken_syn$species[lindken_syn$synonyms == syn]
  
  # assign back to the same cell
  toFix$species_new[i] <- cur[1]
}

lindkenVar$species_new <- lindkenVar$species
lindkenVar <- rbind(lindkenVar, toFix)
sum(lindkenVar$species_new %in% iucn$species) #1207/1248: 97%

head(lindkenVar)
lindkenVar$species <- lindkenVar$species_new
lindkenVar <- lindkenVar[,-4]

lindken$iucnData <- NA

lindken$iucnData[!lindken$species %in% iucn$species] <- "no"
lindken$iucnData[lindken$species %in% iucn$species] <- "yes"


lindkenVar <- lindkenVar[ !grepl("^\\S+\\s+\\S+\\s+\\S+$", lindkenVar$species), ] #remove subspecies

lindkenVar <- lindkenVar[which(!duplicated(lindkenVar$species)),] #remove duplicated entries


write.csv(lost_sppA, here::here("data", "processed", "lost_spp.csv"), row.names = FALSE)

head(lost_spp)

sum(lost_spp$species %in% lindkenVar$species)

lost_sppA <- merge(lost_spp, lindkenVar, by = "species")
head(lost_sppA)

write.csv(lost_sppA, here::here("data", "processed", "lost_spp.csv"), row.names = FALSE) #names and data all right.

# DD polygons processing --------------------------------------------------

length(unique(dd_poly$SCI_NAME)) #3099 species
toPoly <- iucn[,c(1:4,9)]

dd_poly <- terra::merge(dd_poly, toPoly, by.x = "ID_NO", by.y = "id")
names(dd_poly)

dd_poly_terrestrial <- dd_poly[dd_poly$systems %in% c("Freshwater (=Inland waters)", "Terrestrial", "Terrestrial|Freshwater (=Inland waters)"),]
table(dd_poly_terrestrial$systems)

dd_poly_terrestrial_dissolved <- terra::aggregate(dd_poly_terrestrial, 
                                                  by = "ID_NO", dissolve = TRUE, 
                                                  cores = 9)

length(unique(dd_poly_terrestrial$ID_NO)) #3067 species; 3552 polygons
length(unique(dd_poly_terrestrial_dissolved$ID_NO)) 

terra::writeVector(dd_poly_terrestrial_dissolved, here::here("data", "processed", "shapefiles", "dd_poly_terrestrial_dissolved.shp"))

#working on dd_poly_terrestrial_dissolved renamed as dd_poly

table(dd_poly$class)
# DD polygons: 866 amphibia, 35 aves, 771 mammals, 1395 reptilia



# matching lost species spatial data --------------------------------------
head(lindken)
head(iucn)

lost <- lindken[lindken$status==0,]
toMerge <- iucn[,c(1, 5)]

lost <- merge(lost, toMerge, by ="species") #adding ID to lost species N = 818
head(lost)

table(lost$class) #amphibia = 284; aves = 51; mammals = 46; reptilia = 437

# filtering polygons ------------------------------------------------------
#amphibia
anura_poly1 <- anura_poly1[,c(1, 2)]
anura_poly2 <- anura_poly2[,c(1, 2)]

anura <- rbind(anura_poly1, anura_poly2)
anura <- terra::aggregate(anura, by="id_no", cores = 9)
lost_anura <- terra::merge(anura, lost, by.y = "id", by.x ="id_no")

names(caudata) <- c("id_no", "sci_name")
names(gymnophiona)

gymnophiona <- gymnophiona[,c(1, 2)]
caudata <- caudata[,c(2, 3)]
cau_gym <- rbind(caudata, gymnophiona)
lost_caugym <- terra::merge(cau_gym, lost, by.y = "id", by.x ="id_no")

names(lost_anura)
names(lost_caugym)
amphibia <- rbind(lost_anura, lost_caugym)

terra::writeVector(amphibia, here::here("data", "processed", "shapefiles", "lost_amphibia.shp"), filetype = "ESRI Shapefile", overwrite = TRUE)

#mammals
names(mammals)
mammals <- mammals[,c(2, 3)]
names(mammals) <- c("id_no", "sci_names")

lost_mammals <- terra::merge(mammals, lost, by.y = "id", by.x ="id_no")
lost_mammals <- terra::aggregate(lost_mammals, by="id_no", cores = 9)
dim(lost_mammals)

terra::writeVector(lost_mammals, here::here("data", "processed", "shapefiles", "lost_mammals.shp"), filetype = "ESRI Shapefile", overwrite = TRUE)

#reptilia
names(reptiles1)
names(reptiles2)
reptiles1 <- reptiles1[,c(1,2)]
reptiles2 <- reptiles2[,c(1,2)]
reptiles <- rbind(reptiles1, reptiles2)

reptiles <- terra::aggregate(reptiles, by = "id_no", cores = 9)

lost_reptiles <- terra::merge(reptiles, lost, by.y = "id", by.x ="id_no")
dim(lost_reptiles) #410 spp

terra::writeVector(lost_reptiles, here::here("data", "processed", "shapefiles", "lost_reptiles.shp"), filetype = "ESRI Shapefile", overwrite = TRUE)

#birds: non-passeriformes
dim(birdsnp1)
birdsnp1 <- rbind(birdsnp1, birdsnp2)

birdsnp0 <- birdsnp0[,c(2,3)]
birdsnp1 <- birdsnp1[,c(2,3)]
names(birdsnp0) <- c("id_no", "sci_names")
names(birdsnp1) <- c("id_no", "sci_names")

lost_birds0 <- terra::merge(birdsnp0, lost, by.y = "id", by.x ="id_no") #47 entries
lost_birds1 <- terra::merge(birdsnp1, lost, by.y = "id", by.x ="id_no") #zero species
dim(lost_birds0)


#birds: passeriformes
dim(birdsp0)
dim(birdsp1)

birdsp0 <- birdsp0[,c(2,3)]
birdsp1 <- birdsp1[,c(2,3)]

names(birdsp0) <- c("id_no", "sci_names")
names(birdsp1) <- c("id_no", "sci_names")

lost_birdsp0 <- terra::merge(birdsp0, lost, by.y = "id", by.x ="id_no") #27 entries
lost_birdsp1 <- terra::merge(birdsp1, lost, by.y = "id", by.x ="id_no") #0 entries

names(lost_birdsp0)

lost_birds <- rbind(lost_birds0, lost_birdsp0)

lost_birds <- terra::aggregate(lost_birds, by = "id_no", cores = 9)
dim(lost_birds)
names(lost_birds)
lost_birds <- lost_birds[,c(-11)]

terra::writeVector(lost_birds, here::here("data", "processed", "shapefiles", "lost_birds.shp"), filetype = "ESRI Shapefile", overwrite = TRUE)

# merge all spatial data --------------------------------------------------

names(amphibia)
amphibia <- amphibia[,c(1,4,5,6,7,8,9,10)]

names(reptiles)
reptiles <- reptiles[,c(-7,-8)]

names(birds)
birds <- birds[,c(1,4,5,6,7,8,9,10)]

names(mammals)
mammals <- mammals[,c(1,4,5,6,7,8,9,10)]

lost_tetrapoda <- rbind(amphibia, reptiles, birds, mammals)
dim(lost_tetrapoda)
names(lost_tetrapoda)

head(iucn)
toMerge <- iucn[,c(1,6,9,10)]

lost_tetrapoda <- terra::merge(lost_tetrapoda, toMerge, by.x="id_no", by.y="id")
names(lost_tetrapoda)
lost_tetrapoda <- lost_tetrapoda[,c(-2, -8)]

terra::writeVector(lost_tetrapoda, here::here("data", "processed", "shapefiles", "lost_spp.shp"), filetype = "ESRI Shapefile", overwrite = TRUE)
dim(lost_spp) #790
table(lost_spp$class) #amphibia 283; aves 51; mammals 46; reptilia 410


# merging DD and lost spp polygons: background ----------------------------
names(lost_spp)
names(dd_poly)

lost_spp <- lost_spp[,c(1,2,3)]
dd_poly <- dd_poly[,c(1,2,3)]

toBG <- rbind(lost_spp, dd_poly)

lostBG <- terra::aggregate(toBG, by="id_no", cores=9)
dim(lostBG)

lostBG <- terra::aggregate(lostBG, by="dissolve", cores=9)

terra::writeVector(lostBG, here::here("data", "processed", "shapefiles", "lostBG.shp"), filetype = "ESRI Shapefile", overwrite = TRUE)



