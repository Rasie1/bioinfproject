source("http://bioconductor.org/biocLite.R")
biocLite()
biocLite("EBImage")

library('EBImage')


Image <- readImage('compressed/16_36_4_3_770_compressed.png')
Image <- readImage('compressed/16_36_4_11_646_compressed.png')
Image <- readImage('compressed/16_36_4_4_751_compressed.png')
Image <- readImage('compressed/32_36_16_9_4236_compressed.png')
display(Image)

#Image1 <- Image + 0.2
#Image2 <- Image - 0.2
#Image3 <- Image * 0.5
#Image4 <- Image * 2
#display(Image3); display(Image4)
#display(Image1); display(Image2)

img_an <- (Image - 0.1) * 1.5
display(img_an)

#fHigh <- matrix(1, nc = 3, nr = 3)
#fHigh[2, 2] <- -6.5
#img_an <- filter2(img_an, fHigh)
#display(img_an)

mean(img_an@.Data)
median(img_an@.Data)
min(img_an@.Data)
max(img_an@.Data)