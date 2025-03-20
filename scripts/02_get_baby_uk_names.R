# Function to get UK name data:
library(readxl)

historical_1996_2016_boys <- read_xls('source-data/uk names by year/adhocallbabynames1996to2016.xls', sheet = 4)
historical_1996_2016_girls <- read_xls('source-data/uk names by year/adhocallbabynames1996to2016.xls', sheet = 5)

# Define function to get to name-year-count:
tidy_historical <- function(df) {
  library(dplyr)
  library(tidyr)
  library(zoo)
  
  # 1. Remove the top 4 rows (the "junk" rows)
  df_data <- df[-(1:4), ]
  
  # Row 4: partially holds the Year info (with NA in between)
  years_raw <- unlist(df[4, ], use.names = FALSE)
  
  # Row 5: has "Name", "Rank", "Count", "Rank", "Count", ...
  types_raw <- unlist(df[5, ], use.names = FALSE)
  
  # 2. Build proper column names
  #    - For columns 2..n, fill the NA year cells down so each "Rank"/"Count" pair has the correct year.
  years_filled <- c('name', na.locf(years_raw))    # fill NAs downward
  col_names <- paste0(years_filled, "_", types_raw)
  col_names[1] <- "name"  # The first column is "Name"
  
  # Apply these column names to the data portion
  names(df_data) <- col_names
  
  # 3. Pivot from wide to long, then keep only the "Count" columns
  df_long <- df_data %>%
    pivot_longer(
      cols = -name,
      names_to = c("Year", "VarType"),
      names_sep = "_",
      values_to = "Value"
    ) %>%
    filter(VarType == "Count") %>%
    select(name, Year, Count = Value) %>%
    # Convert to numeric if desired, and remove any rows with NA in Count
    mutate(year = as.numeric(Year),
           count = as.numeric(Count),
           name = tolower(name)) %>%
    drop_na(Count)
  
  # Return the tidy data
  return(df_long[, c('name', 'count', 'year')])
}

boys_tidy  <- tidy_historical(historical_1996_2016_boys)
girls_tidy <- tidy_historical(historical_1996_2016_girls)

boys_tidy$sex <- "boys"
girls_tidy$sex <- "girls"

# Next load more recent data:
get_names_by_year <- function(year, sex = 'boys'){
  print(paste('--------------------------------------------'))
  print(paste('--------------------------------------------'))
  print(paste('--------------------------------------------'))
  print(paste('----------', year, ' --- ', sex))
  if(year == 2021 & sex == 'boys'){
    df <- read_xlsx(paste0('source-data/uk names by year/', year, sex, 'names.xlsx'), sheet = 10, skip = 6)[, 2:3]
  } else if(year < 2019){
    df <- read_xls(paste0('source-data/uk names by year/', year, sex, 'names.xls'), sheet = 9, skip = 5)[, 2:3]
  } else {
    df <- read_xlsx(paste0('source-data/uk names by year/', year, sex, 'names.xlsx'), sheet = 9, skip = 5)[, 2:3]
  }
  if(year == 2022){
    df <- read_xlsx(paste0('source-data/uk names by year/', year, sex, 'names.xlsx'), sheet = 9, skip = 4)[, 2:3]
  }
  if(year == 2023){
    df <- read_xlsx(paste0('source-data/uk names by year/', year, sex, 'names.xlsx'), sheet = 9, skip = 4)[, 2:3]
  }
  print(colnames(df))
  colnames(df) <- c("name", 'count')
  df <- df[df$count != 'Count', ]
  df$name <- tolower(df$name)
  df$count <- as.numeric(df$count)
  df$year <- year
  df$sex <- sex
  return(df)
}

boys_2017_2023 <- data.frame()
girls_2017_2023 <- data.frame()
for(i in 2017:2023){

  boys_2017_2023 <- rbind(boys_2017_2023, get_names_by_year(year = i, sex = "boys"))
  girls_2017_2023 <- rbind(girls_2017_2023, get_names_by_year(year = i, sex = "girls"))
}

# Merge it all together
uk_boys <- rbind(boys_tidy, boys_2017_2023[, colnames(boys_tidy)])
uk_girls <- rbind(girls_tidy, girls_2017_2023[, colnames(girls_tidy)])

library(ggplot2)
ggplot(uk_girls[uk_girls$name %in% sample(uk_girls$name, 100), ], aes(x=year, y=count, col=name, group=name))+geom_line()+geom_vline(aes(xintercept = 2016))+geom_point()+theme(legend.position='none')+scale_y_continuous(trans='log10')

uk_names <- rbind(uk_girls, uk_boys)
uk_names <- uk_names[uk_names$name != 'name', ]
uk_names <- uk_names[order(uk_names$name), ]

uk_names$n <- uk_names$count
uk_names <- uk_names[!is.na(uk_names$n), ]
uk_names$count <- NULL
uk_names$nchar <- nchar(uk_names$name)
uk_names$per_year <- ave(uk_names$n, paste0(uk_names$year, '_', uk_names$sex), FUN=sum)
uk_names$percent_per_year <- 100*uk_names$n/uk_names$per_year
uk_names$sex[uk_names$sex == 'boys'] <- "M"
uk_names$sex[uk_names$sex == 'girls'] <- "F"

library(readr)
write_csv(uk_names, 'output-data/uk_baby_names.csv')