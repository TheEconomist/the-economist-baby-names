# -----------------------------------------
# 1) Load packages and data
# -----------------------------------------
library(tidyverse)
library(ineq)     # for Gini()
library(readr)

us <- read_csv('output-data/us_names_with_popularity_and_connotations_cleaned.csv')
uk <- read_csv('output-data/uk_names_with_popularity_and_connotations_cleaned.csv')

# -----------------------------------------
# 2) Define a helper function
# -----------------------------------------
calc_gini_of_changes <- function(df) {
  # 1. Group by sex and name
  # 2. Sort by year (within each group)
  # 3. Compute the absolute change in percent_per_year from the previous year
  # 4. Summarize the Gini of those changes by year AND by sex
  
  df_changes <- df %>%
    group_by(sex, lowercase_name) %>%
    arrange(year, .by_group = TRUE) %>%
    mutate(change = abs(percent_per_year - lag(percent_per_year))) %>%
    ungroup()
  
  # Compute Gini by year AND sex
  df_gini <- df_changes %>%
    group_by(year, sex) %>%
    summarize(gini_of_change = Gini(change, na.rm = TRUE), .groups = "drop")
  
  return(df_gini)
}

# -----------------------------------------
# 3) Calculate the trendiness (Gini) over time
# -----------------------------------------
us_gini <- calc_gini_of_changes(us)
uk_gini <- calc_gini_of_changes(uk)

# Combine into one dataframe with a country column
trendiness <- bind_rows(
  us_gini %>% mutate(country = "US"),
  uk_gini %>% mutate(country = "UK")
)

# -----------------------------------------
# 4) Plot the results (all names) by sex and country
# -----------------------------------------
trendiness %>%
  ggplot(aes(x = year, y = gini_of_change, color = country)) +
  geom_line() +
  facet_wrap(~sex) +
  labs(
    title = "Trendiness index (Gini of annual changes in name share), by Sex",
    x = "Year",
    y = "Gini of changes in percent_of_names"
  ) +
  theme_minimal()

# -----------------------------------------
# 5) (Optional) Filter only names that were ever in the top 100
# -----------------------------------------
filter_top_100 <- function(df) {
  top_100_names <- df %>%
    group_by(year, sex) %>%
    arrange(desc(percent_per_year), .by_group = TRUE) %>%
    slice_head(n = 100) %>%
    pull(lowercase_name) %>%
    unique()  # ensure unique across the entire data
  df %>% filter(lowercase_name %in% top_100_names)
}

us_top100 <- filter_top_100(us)
uk_top100 <- filter_top_100(uk)

# Recalculate Gini for top 100 only
us_gini_top100 <- calc_gini_of_changes(us_top100)
uk_gini_top100 <- calc_gini_of_changes(uk_top100)

trendiness_top100 <- bind_rows(
  us_gini_top100 %>% mutate(country = "US"),
  uk_gini_top100 %>% mutate(country = "UK")
)

# -----------------------------------------
# 6) Plot results for top 100 names only, by sex and country
# -----------------------------------------
trendiness_top100 %>%
  ggplot(aes(x = year, y = gini_of_change, color = country)) +
  geom_line() +
  facet_wrap(~sex) +
  labs(
    title = "Trendiness index (Gini of annual changes in name share), Top 100 - by Sex",
    x = "Year",
    y = "Gini of changes in percent_of_names"
  ) +
  theme_minimal()


# -----------------------------------------
# 7) (Optional) Filter to only top changes in a given year
# -----------------------------------------
filter_top_changes <- function(df) {
  # For each sex and name, compute the annual change in popularity,
  # then for each year & sex, select the 100 names with the largest change.
  df_changes <- df %>%
    group_by(sex, lowercase_name) %>%
    arrange(year, .by_group = TRUE) %>%
    mutate(change = abs(percent_per_year - lag(percent_per_year))) %>%
    ungroup()
  
  df_top_changes <- df_changes %>%
    group_by(year, sex) %>%
    arrange(desc(change), .by_group = TRUE) %>%
    slice_head(n = 100) %>%
    ungroup()
  
  return(df_top_changes)
}

# Apply the new filter to the US and UK data
us_top_changes <- filter_top_changes(us)
uk_top_changes <- filter_top_changes(uk)

# Recalculate Gini for top changes only. Note that calc_gini_of_changes() will recompute
# the "change" variable, but since we are working with a subset already filtered on change,
# this is acceptable.
us_gini_top_changes <- calc_gini_of_changes(us_top_changes)
uk_gini_top_changes <- calc_gini_of_changes(uk_top_changes)

trendiness_top_changes <- bind_rows(
  us_gini_top_changes %>% mutate(country = "US"),
  uk_gini_top_changes %>% mutate(country = "UK")
)

# -----------------------------------------
# 8) Plot results for top 100 changes only, by sex and country
# -----------------------------------------
trendiness_top_changes %>%
  ggplot(aes(x = year, y = gini_of_change, color = country)) +
  geom_line() +
  # geom_smooth() + 
  facet_wrap(~sex) +
  labs(
    title = "Trendiness index (Gini of annual changes in name share), Top 100 Changes per Year - by Sex",
    x = "Year",
    y = "Gini of changes in percent_of_names"
  ) +
  theme_minimal()

