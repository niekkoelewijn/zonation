# REG-32806
# Tutorial
# Week 3
# Thursday
# Niek Koelewijn

# install required packages
if(!"raster" %in% rownames(installed.packages())){install.packages("raster")}
if(!"rgdal" %in% rownames(installed.packages())){install.packages("rgdal")}
if(!"ncdf4" %in% rownames(installed.packages())){install.packages("ncdf4")}
if(!"spThin" %in% rownames(installed.packages())){install.packages("spThin")}

# Load required packages
library(raster)
library(rgdal)
library(ncdf4)
library(spThin)

# import the raster
bio1 <- raster("data/input variables/bio1.asc")

# The code below creates a matrix that specifies in the first two columns the range the values in the a raster can take. Inf stands for infinity. In the third column the value that should be assigned to all values defined by the range you specified is stated (1). This matrix is then used to reclassify a raster.
m <- c(-Inf, Inf, 1)
rclmat <- matrix(m, ncol=3, byrow=TRUE)
bio <- reclassify(bio1, rclmat)

#The code below plots the new raster and checks the frequency of the values in the raster, which should be only ones and NAs.
plot(bio)
freq(bio)

# first we import the population raster, then multiplies all the values with -1, crop and resample the raster to match the bio raster and plots the new raster.
population <- raster("data/NLD_pop/nld_pop.gri")
population <- population * -1
population <- crop(population, bio)
population <- resample(population, bio)
plot(population)

#The following lines in the code tell R where to find the shapefile and to import it.
water <- readOGR("data/NLD_wat", "NLD_water_areas_dcw")

#The following code turns the shapefile into a raster, using bio as a mask (the new raster will get the same shape as the bio raster). It then tells R to reclassify the values using the same matrix as earlier so you will get a raster with only ones and NAs. 
water <- rasterize(water, bio1, fun='last', background=NA, mask=TRUE, update=FALSE)
water <- reclassify(water, rclmat)

#The following lines in the code tell R to check the frequency (only ones and NA) and to plot your new raster so you can check how it looks like.
freq(water)
plot(water, col = "blue")

#it is correct that you only see a few dots, but this is not what we want. We also want the north sea to show.
# The following code will substitute the NA values for the value 0 and then simply add the bio raster. It then checks the plot and the frequency of the values again and you can see that we need to reclassify again so that waterbodies have a lower value than land. 
water[is.na(water)] <- 0
water <- water + bio
plot(water)
freq(water)

#the following code creates a matrix called rclmat2 and reclassifies the water raster using the new matrix. It then plots the last water raster and checks the frequency.
m2 <- c(-Inf,1.5,1, 1.5,Inf,0)
rclmat2 <- matrix(m2, ncol=3, byrow=TRUE)
water <- reclassify(water, rclmat2)
plot(water)
freq(water)

# Check resolution and extent
res(bio)
res(water)
res(population)
extent(bio)
extent(water)
extent(population)

# Write raster
writeRaster(population, "data/input variables/population.asc", format = "ascii", overwrite = T)
writeRaster(water, "data/input variables/water.asc", format = "ascii", overwrite = T)
