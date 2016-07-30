bad_images <- read.csv('bad_images.csv', sep = ';', stringsAsFactors = FALSE)
scoring <- read.csv('info_scorings.csv', sep = ';', stringsAsFactors = FALSE)

str(bad_images[,1])

str(scoring$pic)

updated_scoring <- scoring[c(!scoring$pic %in% bad_images[,1]),]

updated_scoring$positive_tumor_cells_new <- vector(length = 480)

updated_scoring$positive_tumor_cells_new[updated_scoring$positive_tumor_cells == '0%'] <- '0%'
updated_scoring$positive_tumor_cells_new[updated_scoring$positive_tumor_cells == '>0% and <1%'] <- '0-5%'
updated_scoring$positive_tumor_cells_new[updated_scoring$positive_tumor_cells == '>0% and <5%'] <- '0-5%'
updated_scoring$positive_tumor_cells_new[updated_scoring$positive_tumor_cells == '1-9%'] <- '5-15%'
updated_scoring$positive_tumor_cells_new[updated_scoring$positive_tumor_cells == '5-15%'] <- '5-15%'
updated_scoring$positive_tumor_cells_new[updated_scoring$positive_tumor_cells == '16-30%'] <- '16-39%'
updated_scoring$positive_tumor_cells_new[updated_scoring$positive_tumor_cells == '10-39%'] <- '16-39%'
updated_scoring$positive_tumor_cells_new[updated_scoring$positive_tumor_cells == '>30%'] <- '40-69%'
updated_scoring$positive_tumor_cells_new[updated_scoring$positive_tumor_cells == '40-69%'] <- '40-69%'
updated_scoring$positive_tumor_cells_new[updated_scoring$positive_tumor_cells == '70-100%'] <- '70-100%'


write.csv(updated_scoring, file = 'updated_scoring2.csv', sep = ';', row.names = F)

?subset

tumor_groups <- updated_scoring$positive_tumor_cells_new

barplot(table(f_tumor_groups))
str(tumor_groups)
f_tumor_groups <- factor(tumor_groups, levels = c('0%', '0-5%', '5-15%', '16-39%', '40-69%', '70-100%'))

