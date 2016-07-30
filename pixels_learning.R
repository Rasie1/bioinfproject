pixels <- array(dim = c(0,256*256))
pic_names <- c()

i <-  1
for(pic in updated_scoring$pic)
{
  pic_name <- 'compressed256/' %+% strsplit(pic, '.jpg') %+% '_compressed_new.png'
  # pic_name_r <- 'compressed256_colored/' %+% strsplit(pic, '.jpg') %+% '_compressed_r.png'
  # pic_name_b <- 'compressed256_colored/' %+% strsplit(pic, '.jpg') %+% '_compressed_b.png'
  if(file.exists(pic_name))
  {
    pic_data <- readImage(pic_name)
    # pic_data <- (pic_data - 0.1) * 1.5
    
    img_line <- as.vector(pic_data@.Data) 
    pixels <- rbind(pixels, img_line)
    
    pic_names <- append(pic_names, pic)
    # print(111111111111111)
    # print(img_line)
    
  }
  else
  {
    print("WAKAKAKAKA")
  }
  print(i)
  i <- i+1
}
pixels_df <- data.frame(pixels, row.names = pic_names)
#PCA


pixels_pca <- prcomp(pixels_df, scale. = T, center = T)

pc1 <- pixels_pca$x[, 1]
length(pc1)


imp_pixels <- summary(pixels_pca)$importance
sum(imp_pixels[2,c(1:200)])

summary(pixels_pca)

rotation_coeff_pixels <- pixels_pca$rotation

barplot(imp_pixels[2,]*100, ylab = "Persentage of variance", xlab = "Principal Components", main = "Variance explained by individual PC", col = "cyan3")
biplot(sc.pca)

write.csv(rotation_coeff_pixels[,1:200], "rotation_coeff_pixels_bg.csv")

# 
# train_pca$pc1 <-  data.matrix(train_pca[, c(2,3,4,5,6)]) %*% rotation_coeff[,"PC1"]
# train_pca$pc2 <-  data.matrix(train_pca[, c(2,3,4,5,6)]) %*% rotation_coeff[,"PC2"]
# train_pca$pc3 <-  data.matrix(train_pca[, c(2,3,4,5,6)]) %*% rotation_coeff[,"PC3"]
# 
# test_pca$pc1 <-  data.matrix(test_pca[, c(2,3,4,5,6)]) %*% rotation_coeff[,"PC1"]
# test_pca$pc2 <-  data.matrix(test_pca[, c(2,3,4,5,6)]) %*% rotation_coeff[,"PC2"]
# test_pca$pc3 <-  data.matrix(test_pca[, c(2,3,4,5,6)]) %*% rotation_coeff[,"PC3"]
