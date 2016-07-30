source("http://bioconductor.org/biocLite.R")
biocLite()
biocLite("EBImage")

library('EBImage')
library(ggplot2)
library(randomForest)

# String concatenation
"%+%" <- function(...){
  paste0(...)
}


mean_column <- c()
median_column <- c()
min_column <- c()
max_column <- c()
mm_difference_column <- c()

#mean_column <- append(mean_column, 1)
#pixels <- array(dim = c(1,512*512))

i <-  1

# Extract data from pics
for(pic in updated_scoring$pic)
{
  pic_name <- 'compressed/' %+% strsplit(pic, '.jpg') %+% '_compressed.png'
  if(file.exists(pic_name))
  {
    pic_data <- readImage(pic_name)
  
    pic_data <- (pic_data - 0.1) * 1.5
  
    #fHigh <- matrix(1, nc = 3, nr = 3)
    #fHigh[2, 2] <- -6.5
    #img_an <- filter2(img_an, fHigh)
    #display(img_an)
    mean_column <- append(mean_column, mean(pic_data@.Data))
    median_column <- append(median_column, median(pic_data@.Data))
    mm_difference_column <- append(mm_difference_column, mean(pic_data@.Data) - median(pic_data@.Data))
    min_column <- append(min_column, min(pic_data@.Data))
    max_column <- append(max_column,  max(pic_data@.Data))
    
    #img_line <- as.vector(pic_data@.Data)
    #pixels <- rbind(pixels, img_line)
    
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
#pixels[1,]
#pixels <- pixels[-1,]
#pixels_data <- data.frame(pixels, row.names = c(1:480))
#pixels_data <- merge(updated_scoring$positive_tumor_cells_new, pixels_data)

#write.csv(pixels_data, 'pixels_data.csv', sep = ';')

#str(pixels)
#head(pixels)

updated_scoring$mean_brightness <- mean_column
updated_scoring$median_brightness <- median_column
updated_scoring$min_brightness <- min_column
updated_scoring$max_brightness <- mean_column
updated_scoring$mm_difference_brightness <- mm_difference_column

write.csv(updated_scoring, "updated_scoring_with_values.csv")

# DF for train and test
scoring_train <- updated_scoring[sample(nrow(updated_scoring), 350)]
scoring_test <- updated_scoring[!row.names(updated_scoring) %in% row.names(scoring_train),]


# Compose tables for learning
extractFeatures <- function(data) {
  features <- c("mean_brightness",
                "median_brightness",
                "min_brightness",
                "max_brightness",
                "mm_difference_brightness")
  fea <- data[,features]
  return(fea)
}

rf <- randomForest(extractFeatures(scoring_train), as.factor(scoring_train$positive_tumor_cells_new), ntree=100, importance=TRUE)

submission <- data.frame(pic = scoring_test$pic)
submission$estimated_tumor_cells <- predict(rf, extractFeatures(scoring_test))


imp <- importance(rf, type=1)
featureImportance <- data.frame(Feature=row.names(imp), Importance=imp[,1])

p <- ggplot(featureImportance, aes(x=reorder(Feature, Importance), y=Importance)) +
  geom_bar(stat="identity", fill="#53cfff") +
  coord_flip() + 
  theme_light(base_size=20) +
  xlab("") +
  ylab("Importance") + 
  ggtitle("Random Forest Feature Importance\n") +
  theme(plot.title=element_text(size=18))

#PCA

pca_scoring <- subset(updated_scoring, select = c(positive_tumor_cells_new, 
                                                  mean_brightness,
                                                  median_brightness,
                                                  min_brightness,
                                                  max_brightness,
                                                  mm_difference_brightness))

#rownames(pca_scoring) <- pca_scoring$positive_tumor_cells_new

head(pca_scoring)
print(cor(pca_scoring[, -1]), digits = 2)

sc.pca <- prcomp(pca_scoring[, -1], scale. = T)

pc1 <- sc.pca$x[, 1]
length(pc1)

plot(pca_scoring$positive_tumor_cells_new, pc1)
plot(sc.pca)
imp <- summary(sc.pca)$importance

summary(pca_scoring)

rotation_coeff <- sc.pca$rotation

barplot(imp[2,]*100, ylab = "Persentage of variance", xlab = "Principal Components", main = "Variance explained by individual PC", col = "cyan3")
biplot(sc.pca)

train_pca <- subset(scoring_train, select = c(positive_tumor_cells_new, 
                                                mean_brightness,
                                                median_brightness,
                                                min_brightness,
                                                max_brightness,
                                                mm_difference_brightness))
test_pca <- subset(scoring_test, select = c(positive_tumor_cells_new, 
                                               mean_brightness,
                                               median_brightness,
                                               min_brightness,
                                               max_brightness,
                                               mm_difference_brightness))


rotation_coeff[,"PC1"]
colnames(rotation_coeff)
str((data.matrix(train_pca[, -c(1)]) %*% rotation_coeff[,"PC1"]))
train_pca$pc1 <-  data.matrix(train_pca[, c(2,3,4,5,6)]) %*% rotation_coeff[,"PC1"]
train_pca$pc2 <-  data.matrix(train_pca[, c(2,3,4,5,6)]) %*% rotation_coeff[,"PC2"]
train_pca$pc3 <-  data.matrix(train_pca[, c(2,3,4,5,6)]) %*% rotation_coeff[,"PC3"]

test_pca$pc1 <-  data.matrix(test_pca[, c(2,3,4,5,6)]) %*% rotation_coeff[,"PC1"]
test_pca$pc2 <-  data.matrix(test_pca[, c(2,3,4,5,6)]) %*% rotation_coeff[,"PC2"]
test_pca$pc3 <-  data.matrix(test_pca[, c(2,3,4,5,6)]) %*% rotation_coeff[,"PC3"]


# PCA train and test

rf <- randomForest(train_pca[, c(7,8,9)], as.factor(train_pca$positive_tumor_cells_new), ntree=100, importance=TRUE)

submission <- data.frame(id = rownames(test_pca))
submission$estimated_tumor_cells <- predict(rf, test_pca[, c(7,8,9)])


imp <- importance(rf, type=1)
featureImportance <- data.frame(Feature=row.names(imp), Importance=imp[,1])

p <- ggplot(featureImportance, aes(x=reorder(Feature, Importance), y=Importance)) +
  geom_bar(stat="identity", fill="#53cfff") +
  coord_flip() + 
  theme_light(base_size=20) +
  xlab("") +
  ylab("Importance") + 
  ggtitle("Random Forest Feature Importance\n") +
  theme(plot.title=element_text(size=18))

#Compare results

row.names(submission) <- submission$id
submission <- subset(submission, select = estimated_tumor_cells)
ideal <- subset(scoring_test, select = c(pic, positive_tumor_cells_new))
submission$id <- rownames(submission)
ideal$id <- rownames(ideal)

compare_table <- merge(ideal, submission, by = 'id')

write.csv(compare_table, 'learning_results.csv', sep = ';')


count <- 0

compare_table_ok <- (compare_table[compare_table$positive_tumor_cells_new == compare_table$estimated_tumor_cells, ])

for (result in compare_table) 
{
  if (compare_table$estimated_tumor_cells[result] == result$positive_tumor_cells_new) {
    count <- count + 1
  }
}

