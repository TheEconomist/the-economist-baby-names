# Load packages
library(tidyverse)
library(readr)

# Load data
us <- read_csv('output-data/us_names_with_popularity_and_connotations.csv')
uk <- read_csv('output-data/uk_names_with_popularity_and_connotations.csv')

# Load necessary libraries
library(dplyr)
library(tidyr)
library(ggplot2)

# Define connotation columns
connotation_cols <- c("intelligence", "beauty", "strength", "wealth", "benevolence/love", "joy", "religious")

us <- us %>% rename('benevolence/love' = 'love')
uk <- uk %>% rename('benevolence/love' = 'love')

# Prepare data
us_long <- us %>%
  select(year, n, all_of(connotation_cols)) %>%
  pivot_longer(
    cols = all_of(connotation_cols),
    names_to = "connotation",
    values_to = "flag"
  ) %>%
  mutate(flag = ifelse(is.na(flag), FALSE, flag))

uk_long <- uk %>%
  select(year, n, all_of(connotation_cols)) %>%
  pivot_longer(
    cols = all_of(connotation_cols),
    names_to = "connotation",
    values_to = "flag"
  ) %>%
  mutate(flag = ifelse(is.na(flag), FALSE, flag))

# Calculate percentages
connotation_percent_us <- us_long %>%
  group_by(year, connotation) %>%
  summarize(
    sum_n = sum(n, na.rm = TRUE),
    sum_n_conc = sum(n * flag, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  mutate(
    percent = (sum_n_conc / sum_n) * 100
  )
connotation_percent_uk <- uk_long %>%
  group_by(year, connotation) %>%
  summarize(
    sum_n = sum(n, na.rm = TRUE),
    sum_n_conc = sum(n * flag, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  mutate(
    percent = (sum_n_conc / sum_n) * 100
  )

# Plot 
ggplot(connotation_percent_us, aes(x = year, y = percent, color = connotation)) +
  geom_line() +
  labs(
    title = "Percentage of Names with Specific Connotations Over Time (US)",
    x = "Year",
    y = "Percentage (%)",
    color = "Connotation"
  ) +
  theme_minimal()

# Plot 
ggplot(connotation_percent_uk, aes(x = year, y = percent, color = connotation)) +
  geom_line() +
  labs(
    title = "Percentage of Names with Specific Connotations Over Time (UK)",
    x = "Year",
    y = "Percentage (%)",
    color = "Connotation"
  ) +
  theme_minimal()

