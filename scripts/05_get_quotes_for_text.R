##### ----------------------------------------------------------------
##### ----------------------------------------------------------------
# Quotes in text:

# Load packages
library(tidyverse)
library(readr)

# Load data
us <- read_csv('output-data/us_names_with_popularity_and_connotations.csv')
uk <- read_csv('output-data/uk_names_with_popularity_and_connotations.csv')
connotations <- read_csv('output-data/names_and_connotations.csv')

# Prepping connotation-group percentages for easier reference:

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
##### ----------------------------------------------------------------
##### ----------------------------------------------------------------


# Lines with calculations:

# In America Donald is a less popular choice than it was in 2010, given to just 414 children in 2023.
us$n[us$name == 'Donald' & us$year == 2023 & us$sex == "M"] < us$n[us$name == 'Donald' & us$year == 2010 & us$sex == "M"]

us$n[us$name == 'Donald' & us$year == 2023 & us$sex == "M"]

# As Taylor Swift has climbed the music charts, her first name has slid down the rankings, perhaps because parents fear their children will feel bested by the star.
ggplot(us[us$name == 'Taylor' & us$year > 2010, ], aes(x=year, y=percent_per_year, col=sex))+geom_line()+theme_minimal()+xlab('')+ylab('')+ggtitle('% per year named Taylor, by sex')

# The Economist analysed the first names of almost 400m people born in America and Britain in the past 143 years.
sum(us$n) + sum(uk$n)

# Our prompts—more than 30,000 of them—produced 7,439 unique descriptors, including “purity”, “warrior” and “socially awkward”.
length(unique(unlist(c(unique(connotations$connotation_1), 
                       unique(connotations$connotation_2), 
                       unique(connotations$connotation_3), 
                       unique(connotations$connotation_4), 
                       unique(connotations$connotation_5)))))

# Ironically the most popular description was “unique”, tied to 12,124 different names.
nrow(na.omit(connotations[connotations$connotation_1 == 'unique' | 
                  connotations$connotation_2 == 'unique' |
                  connotations$connotation_3 == 'unique' |
                  connotations$connotation_4 == 'unique' |
                  connotations$connotation_5 == 'unique' ,]))

# But the LLM shows that now, thanks to the world’s biggest pop star, people associate that name with versatility, professionalism and creativity.
unlist(connotations[connotations$name == 'taylor', ])

# Names associated with cleverness—such as Raynard—are down six percentage points from 2000.
round(connotation_percent_us$percent[connotation_percent_us$year == 2000 & connotation_percent_us$connotation == 'intelligence']-
connotation_percent_us$percent[connotation_percent_us$year == 2023 & connotation_percent_us$connotation == 'intelligence'])

# Names associated with beauty became more popular in recent decades. Almost 30% of names in England and Wales bear that connotation, up 2.5 per-centage points from 2000; over 30% of names in America do, too.
connotation_percent_uk$percent[connotation_percent_uk$year == 2023 & connotation_percent_uk$connotation == 'beauty']

connotation_percent_uk$percent[connotation_percent_uk$year == 2000 & connotation_percent_uk$connotation == 'beauty']-connotation_percent_uk$percent[connotation_percent_uk$year == 2023 & connotation_percent_uk$connotation == 'beauty']

connotation_percent_us$percent[connotation_percent_us$year == 2000 & connotation_percent_us$connotation == 'beauty']-connotation_percent_us$percent[connotation_percent_us$year == 2023 & connotation_percent_us$connotation == 'beauty']

# Every girl’s name in the top ten—including the top three (Olivia, Emma and Charlotte in America and Olivia, Amelia, Isla in Britain)—connotes “elegance” or some variation thereof. Of the top 100 boys’ names in America, only one, Beau, carries associations of handsomeness.
top_10_girls_us <- us[us$sex == 'F' & us$year == 2023, ]
top_10_girls_us <- top_10_girls_us[order(top_10_girls_us$n, decreasing = T), ][1:10, ]
top_100_boys_us <- us[us$sex == 'M' & us$year == 2023, ]
top_100_boys_us <- top_100_boys_us[order(top_100_boys_us$n, decreasing = T), ][1:100, ]
top_10_girls_uk <- uk[uk$sex == 'F' & uk$year == 2023, ]
top_10_girls_uk <- top_10_girls_uk[order(top_10_girls_uk$n, decreasing = T), ][1:10,]

(sum(top_10_girls_us$beauty) == 10) & (sum(top_10_girls_uk$beauty) == 10)
top_10_girls_us[, paste0('connotation_', 1:5)]
top_10_girls_uk[, paste0('connotation_', 1:5)]

top_100_boys_us[top_100_boys_us$beauty, ]

# If beauty is desired in girls, brawn has muscled into male names: 70% of boys in America, and 55% of boys in Britain, have a name that evokes powerfulness. 
us_2023 <- us[us$year == 2023, ]
sum(us_2023$n[us_2023$strength & us_2023$sex == 'M'])/sum(us_2023$n[us_2023$sex == 'M'], na.rm = T)

uk_2023 <- uk[uk$year == 2023, ]
sum(uk_2023$n[uk_2023$strength & uk_2023$sex == 'M'])/sum(uk_2023$n[uk_2023$sex == 'M'], na.rm = T)

# Even still, names with an overt religiosity remain popular, tied to roughly 15% of names in America.
sum(us$n[us$religious & us$year == 2023])/sum(us$n[us$year == 2023])

# In 2023 Muhammad was the most popular name for boys in England and Wales, given to more than 4,600 infants, or 1.7% of boys.
data.frame(uk_2023[uk_2023$sex == 'M', ][1, ])

# At that point [1965], there were 10,841 names in America.
length(unique(us$name[us$year == 1965]))

# By 2023, the last year in our data set, there were 28,945 unique ones given to five or more people, compared with 22,680 in 1990, despite fewer children being born.
length(unique(us$name[us$year == 2023]))
length(unique(us$name[us$year == 1990]))

# In America names linked to Spanish, such as Jose and Diego, have surged in popularity, as have names linked to Arabic in Britain—Eesa and Sami, for example.
ggplot(us[us$name %in% c('Jose', 'Diego') & us$sex == 'M', ], aes(x=year, y=percent_per_year, col=name))+geom_line()+theme_minimal()+xlab('')

ggplot(uk[uk$lowercase_name %in% c('eesa', 'sami') & uk$sex == 'M', ], aes(x=year, y=n, col=name))+geom_line()+theme_minimal()+ylab('')

# In 1948 nearly a third of American children received one of the 20 most popular names; today parents may prefer to pick something more individualistic than conventional.
in_1948 <- us[us$year == 1948, ]
sum(in_1948$n[order(in_1948$n, decreasing = T)][1:20])/sum(in_1948$n)

# As we studied which names were chosen from year to year, we found that the speed at which trendy names come and go is much faster today than it was even half a century ago. The jumps and dives in popular names are more evenly spread, too.
# See scripts/chart_speed_of_name_change_over_time.R
# and scripts/chart_gini_of_name_change_over_time.R 

# The name [Linda] was given to nearly 100,000 girls—or 5.6%, up from 3.4% the preceding year. The Linda spike is remarkable for another reason: in percentage terms, no names are nearly as popular now as Linda was then.
us$percent_per_year[us$name == 'Linda' & us$sex == 'F' & us$year == 1947] # in 1946
us$percent_per_year[us$name == 'Linda' & us$sex == 'F' & us$year == 1946] # in 1947
max(us$percent_per_year[us$year == 2023]) < us$percent_per_year[us$name == 'Linda' & us$sex == 'F' & us$year == 1947]
