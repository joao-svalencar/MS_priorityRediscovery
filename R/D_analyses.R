dd <- data.frame(dd_poly)
lost <- data.frame(lost_spp)

dd$source <- "dd_spp"
lost$source <- "lost_spp"

names(dd)
names(lost)

lost <- lost[,c(-6, -7, -9)]
dd_noLost <- dd[which(!dd$species %in% lost$species),] #remove from DD species already in Lost spp data

data <- rbind(dd_noLost, lost) #merge lost and dd with no duplicate entries

sum(duplicated(data$species)) #confirms there is no duplicated entries
sum(duplicated(data$id_no)) #confirms there is no duplicated entries

data$source <- factor(data$source, levels = c("lost_spp", "dd_spp"))
# normality test: ---------------------------------------------------------
by(log(data$area), data$source, shapiro.test) # not normal: run Mann-Whitney U test

# testing range-size ------------------------------------------------------

wilcox <- wilcox.test(log(area) ~ source, data = data, alternative = "less") #Mann_Whitney U test: lost range smaller than dd spp range?

# priority rediscovery areas cover by PAs ---------------------------------

lost_priority <- terra::vect(here::here("outputs", "rasters", "lost_priority.shp"))
dd_priority <- terra::vect(here::here("outputs", "rasters", "dd_priority.shp"))

pas <- terra::vect(here::here("data", "raw", "shapefiles", "pas.shp"))

#lost_moll <- project(lost_spp, "ESRI:54009")
lost_moll <- project(lost_spp, "+proj=moll +datum=WGS84")
lost_area <- expanse(lost_moll, unit="km")

lost_spp$mollareakm
#options(scipen = 0)
summary(round(lost_spp$mollareakm, 6))

lost_spp[which(lost_spp$mollareakm==min(lost_spp$mollareakm)),]


# IUCN exploratory --------------------------------------------------------
head(iucn)

iucn$yearLastSeen[iucn$yearLastSeen==""] <- NA

sum(!is.na(iucn$yearLastSeen)) #644 info

644/35545 # 1.81%
327/644 # extinct = 49.22%
10/644
305/644 # critically endangered = 47.36%

table(iucn$iucn[!is.na(iucn$yearLastSeen)])


