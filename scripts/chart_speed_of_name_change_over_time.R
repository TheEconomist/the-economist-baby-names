# -----------------------------------------
# 1) Load packages and data
# -----------------------------------------
library(tidyverse)
library(readr)

us <- read_csv('output-data/us_names_with_popularity_and_connotations.csv')
uk <- read_csv('output-data/uk_names_with_popularity_and_connotations.csv')

# -----------------------------------------
# 2) Define a helper function to compute JS distance
# -----------------------------------------
# Jensen–Shannon distance is the sqrt of the JS divergence
# JS divergence for discrete distributions P and Q is:
#   JS(P, Q) = 0.5 * KL(P || M) + 0.5 * KL(Q || M),
# where M = 0.5 * (P + Q),
# and KL() is the Kullback–Leibler divergence.
compute_js_distance <- function(p, q) {
  # Make sure p, q sum to 1 (turn them into probabilities if they're not already)
  p <- p / sum(p)
  q <- q / sum(q)
  m <- 0.5 * (p + q)
  
  # Kullback–Leibler divergence, handling zeros safely
  kl_div <- function(x, y) {
    # Only compute x * log(x/y) over the indices where x>0 and y>0
    valid <- (x > 0 & y > 0)
    sum(x[valid] * log(x[valid] / y[valid]))
  }
  
  js_divergence <- 0.5 * kl_div(p, m) + 0.5 * kl_div(q, m)
  return(sqrt(js_divergence))  # JS distance = sqrt(JS divergence)
}

# -----------------------------------------
# 3) Create a function to calculate the year-to-year JS distance
# -----------------------------------------
calc_js_distance <- function(df, group_by_sex = TRUE) {
  # 1) If necessary, split by sex, or treat as one group if group_by_sex=FALSE
  # 2) For each group, create a wide matrix of name frequencies by year
  # 3) Compute the distribution distance between consecutive years
  
  # A small helper to pivot to year-by-name matrix
  # This yields rows=years, columns=names, values=percent_per_year
  df$percent_per_year <- df$percent_per_year / 100
  pivot_to_name_matrix <- function(d) {
    # Convert to numeric proportion if needed; assume percent_per_year is already fraction 0-1
    # If it's actually in percentages 0-100, you'd do something like: p = percent_per_year / 100
    d %>%
      select(year, lowercase_name, percent_per_year) %>%
      pivot_wider(
        names_from  = lowercase_name,
        values_from = percent_per_year,
        values_fill = 0
      ) %>%
      arrange(year)
  }
  
  # We can now split the data by sex if desired and apply the pivot
  if (group_by_sex) {
    split_data <- df %>% group_split(sex)  
  } else {
    # Put all data in one chunk with a dummy sex=NA
    df <- df %>% mutate(sex = NA)
    split_data <- list(df)
  }
  
  # We'll loop over each piece (male/female or entire dataset) and compute year-to-year JS distances
  results_list <- lapply(split_data, function(sub_df) {
    current_sex <- unique(sub_df$sex)  # might be NA if group_by_sex=FALSE
    
    # Make a wide matrix: row=year, columns=names, each cell=percent_per_year
    wide_mat <- pivot_to_name_matrix(sub_df)
    
    # wide_mat$year is the first column; the rest are name columns
    # We'll compute consecutive JS distances row by row
    mat_years <- wide_mat$year
    mat_distributions <- as.matrix(wide_mat[ , -1])  # everything except the year column
    
    # We'll create a data frame with year and year-to-next-year JS distance
    # The last year won't have a next-year distance, so it will be NA
    js_df <- tibble(
      sex     = current_sex,
      year    = mat_years,
      js_dist = NA_real_
    )
    
    if (nrow(mat_distributions) > 1) {
      for (i in seq_len(nrow(mat_distributions) - 1)) {
        p <- mat_distributions[i, ]
        q <- mat_distributions[i + 1, ]
        js_df$js_dist[i] <- compute_js_distance(p, q)
      }
    }
    return(js_df)
  })
  
  # Combine results for each sex (or single group if group_by_sex=FALSE)
  final_result <- bind_rows(results_list)
  
  return(final_result)
}

# -----------------------------------------
# 4) Calculate year-to-year Jensen–Shannon distances
# -----------------------------------------
us_js_dist <- calc_js_distance(us, group_by_sex = TRUE)
uk_js_dist <- calc_js_distance(uk, group_by_sex = TRUE)

# Combine for convenience
js_data <- bind_rows(
  us_js_dist %>% mutate(country = "US"),
  uk_js_dist %>% mutate(country = "UK")
)

# -----------------------------------------
# 5) Plot the JS distances
# -----------------------------------------
js_data %>%
  ggplot(aes(x = year, y = js_dist, color = country, linetype = sex)) +
  geom_line() +
  labs(
    title = "Year-to-Year Jensen–Shannon Distance of Baby Name Distributions",
    x = "Year",
    y = "JS Distance (consecutive years)"
  ) +
  theme_minimal()
