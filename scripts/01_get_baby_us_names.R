# Generate "us_baby_names" dataset: 
library(tidyverse)

# This reads in the data:
res <- data.frame()
for(i in 1880:2023){
  temp <- read_csv(paste0('source-data/us names by year/yob', i, '.txt'), col_names = F)
  temp$year <- i
  res <- rbind(temp, res)
}

colnames(res) <- c('name', 'sex', 'n', 'year')

res$per_year <- ave(res$n, paste0(res$sex, '_', res$year), FUN = function(x) sum(x))
res$percent_per_year <- 100*res$n/res$per_year
res$nchar <- nchar(res$name)
write_csv(res, 'output-data/us_baby_names.csv')
                  