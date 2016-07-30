#pixels <- array(dim = c(0,256*256))

updated_scoring <- read.csv('updated_scoring_full.csv')
pic_names <- c()
groups <- c()
rotation_coeff_pixels <- read.csv('rotation_coeff_pixels_bg.csv')
rotation_coeff_pixels <- rotation_coeff_pixels[,-c(1)]
rotation_coeff_pixels <- as.matrix(rotation_coeff_pixels)
i <-  1

pca_data <- array(dim = c(0, 200))

# Integral features
mean_column <- c()
median_column <- c()
min_column <- c()
max_column <- c()
mm_difference_column <- c()


for(pic in updated_scoring$pic)
{
  
  pic_name_b <- 'compressed256/' %+% strsplit(pic, '.jpg') %+% '_compressed_new.png'
  # pic_name_b <- 'compressed256_colored/' %+% strsplit(pic, '.jpg') %+% '_compressed_b.png'
  # pic_name_r <- 'compressed256_colored/' %+% strsplit(pic, '.jpg') %+% '_compressed_r.png'
  if(file.exists(pic_name))
  {
    pic_data_r <- readImage(pic_name)
    # pic_data_r <- readImage(pic_name_r)
    # pic_data_b <- readImage(pic_name_b)
    
    # Предобрадотка изображений
    # pic_data <- (pic_data - 0.1) * 1.5
    
    # img_line <- c(as.vector(pic_data_r@.Data), as.vector(pic_data_b@.Data))
    img_line <- as.vector(pic_data@.Data)
    pca_coefficients <- data.matrix(img_line %*% rotation_coeff_pixels)
    pca_data <- rbind(pca_data, pca_coefficients)
    pic_names <- append(pic_names, pic)
    
    mean_column <- append(mean_column, mean(pic_data@.Data))
    median_column <- append(median_column, median(pic_data@.Data))
    mm_difference_column <- append(mm_difference_column, mean(pic_data@.Data) - median(pic_data@.Data))
    min_column <- append(min_column, min(pic_data@.Data))
    max_column <- append(max_column,  max(pic_data@.Data))
    
  }
  else
  {
    mean_column <- append(mean_column, NA)
    median_column <- append(median_column, NA)
    mm_difference_column <- append(mm_difference_column, NA)
    min_column <- append(min_column, NA)
    max_column <- append(max_column,  NA)
  }
  print(i)
  i <- i+1
}

pca_data <- data.frame(pca_data, row.names = pic_names)
# Integral features appending
pca_data$mean <- mean_column[!is.na(mean_column)]
pca_data$median <- median_column[!is.na(median_column)]
pca_data$min <- min_column[!is.na(min_column)]
pca_data$max <- max_column[!is.na(max_column)]
pca_data$mean_median <- mm_difference_column[!is.na(mm_difference_column)]

pca_data$group <- updated_scoring$positive_tumor_cells_new[updated_scoring$pic %in% rownames(pca_data)]


write.csv(pca_data, 'pics_data_after_pca_with_integral.csv')

head(pca_data)

#pixels_df <- data.frame(pixels, row.names = pic_names)


#PCA (if needed)
# pixels_pca <- prcomp(pixels_df)
# 
# pc1 <- pixels_pca$x[, 1]
# length(pc1)
# 
# 
# imp_pixels <- summary(pixels_pca)$importance
# sum(imp_pixels[2,c(1:32)])
# 
# summary(pixels_pca)
# 
# rotation_coeff_pixels <- pixels_pca$rotation
# 
# barplot(imp_pixels[2,]*100, ylab = "Persentage of variance", xlab = "Principal Components", main = "Variance explained by individual PC", col = "cyan3")
# biplot(sc.pca)

labels <- pca_data$group
levels(labels) <- c(0:6)
pca_data$group <- as.factor(pca_data$group)

# Data separation
set.seed(998)
inTraining <- createDataPartition(pca_data$group, p = .7, list = FALSE)
training <- pca_data[ inTraining,]
testing  <- pca_data[-inTraining,]

# Cross Validation
fitControl <- trainControl(## 7-fold CV
  method = "repeatedcv",
  number = 7,
  repeats = 10,
  classProbs = TRUE,
  summaryFunction = multiClassSummary)

set.seed(825)
training$labels <- as.factor(make.names(training$group))
training <- training[, -c(206)]
summary(training)
rfFit <- train(labels ~ ., data = training,
               method = "rf",
               trControl = fitControl,
               metric = "ROC",
               verbose = TRUE
)
?trainControl
testing_group <- data.frame(testing$group)

testing_group$predict <- predict(rfFit, newdata=testing)
testing_group$pic <- updated_scoring$pic[updated_scoring$pic %in% rownames(testing)]
testing_group$testing.group <- as.factor(make.names(testing_group$testing.group))

confusionMatrix(table(testing_group$predict, testing_group$testing.group))

write.csv(testing_group, 'pixels_integral_pca_prediction_results.csv')