# -----------------------------------------
# 1) Load packages and data
# -----------------------------------------
library(tidyverse)
library(ineq)     # not necessary for HHI, but leaving for reference
library(readr)

us <- read_csv('output-data/us_names_with_popularity_and_connotations.csv')
uk <- read_csv('output-data/uk_names_with_popularity_and_connotations.csv')

# -----------------------------------------
# 2) Define a helper function for Herfindahl
# -----------------------------------------
calc_herfindahl <- function(df, group_by_sex = TRUE) {
  # group_by_sex allows you to compute HHI separately for male/female or combined
  
  if (group_by_sex) {
    df_hhi <- df %>%
      group_by(year, sex) %>%
      summarize(
        herfindahl = sum((percent_per_year/100)^2, na.rm = TRUE)
      ) %>%
      ungroup()
  } else {
    df_hhi <- df %>%
      group_by(year) %>%
      summarize(
        herfindahl = sum((percent_per_year/100)^2, na.rm = TRUE)
      ) %>%
      ungroup()
  }
  
  return(df_hhi)
}

# -----------------------------------------
# 3) Calculate the Herfindahl index over time
# -----------------------------------------
us_hhi <- calc_herfindahl(us, group_by_sex = TRUE)
uk_hhi <- calc_herfindahl(uk, group_by_sex = TRUE)

# Combine for plotting/analysis
hhi_data <- bind_rows(
  us_hhi %>% mutate(country = "US"),
  uk_hhi %>% mutate(country = "UK")
)

# -----------------------------------------
# 4) Plot the Herfindahl index
# -----------------------------------------
hhi_data %>%
  ggplot(aes(x = year, y = 1-herfindahl, color = country, linetype=sex)) +
  geom_line() +
  labs(
    title = "1-Herfindahl-Hirschman Index (HHI) of Names Over Time",
    x = "Year",
    y = "1-Herfindahl Index"
  ) +
  theme_minimal()

# Minimal
hhi_data %>% filter(year >= 1980, sex == 'F', country == 'US') %>%
  ggplot(aes(x = year, y = 1-herfindahl, color = country, linetype=sex)) +
  geom_line() +
  labs(
    title = "Diversity of names",
    x = "",
    y = ""
  ) +
  theme_minimal()+theme(legend.position = 'none')


# -----------------------------------------
# 5) (Optional) Filter only names that were ever in the top 100
#    and recalculate the HHI for those names.
# -----------------------------------------
filter_top_100 <- function(df) {
  top_100_names <- df %>%
    group_by(year, sex) %>%
    arrange(desc(percent_per_year), .by_group = TRUE) %>%
    slice_head(n = 100) %>%
    pull(lowercase_name) %>%
    unique()  # Ensure unique names
  
  df %>%
    filter(lowercase_name %in% top_100_names)
}

us_top100 <- filter_top_100(us)
uk_top100 <- filter_top_100(uk)

us_hhi_top100 <- calc_herfindahl(us_top100, group_by_sex = TRUE)
uk_hhi_top100 <- calc_herfindahl(uk_top100, group_by_sex = TRUE)

hhi_top100 <- bind_rows(
  us_hhi_top100 %>% mutate(country = "US"),
  uk_hhi_top100 %>% mutate(country = "UK")
)

# -----------------------------------------
# 6) Plot the HHI for top 100 names
# -----------------------------------------
hhi_top100 %>%
  ggplot(aes(x = year, y = 1-herfindahl, color = country, linetype=sex)) +
  geom_line() +
  labs(
    title = "Herfindahl-Hirschman Index (HHI) - Top 100 Names",
    x = "Year",
    y = "Herfindahl Index"
  ) +
  theme_minimal()

