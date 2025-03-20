# Merge in connotations from LLM

# Read in connotations from LLM. These were obtained through separate ChatGPT4 API calls with the query "What are the top five connotations of the name {name}. Give your answer as a list separated by commas." In some cases, multiple requested were needed to get valid replies. Excess punctuation was also removed. All 30075 names with more than 100 entries in the dataset should have five connotations. 
names_with_connotations_clean <- read_csv('output-data/names_and_connotations.csv')

# Merge the connotations data into the raw dataset:
us <- read_csv('output-data/us_baby_names.csv')
us <- us[, setdiff(colnames(us), c('connotation_1', 'connotation_2', 'connotation_3', 'connotation_4', 'connotation_5', 'connotation_raw'))]
us$lowercase_name <- tolower(us$name)
us <- merge(us, names_with_connotations_clean[, c('name', 'connotation_1', 'connotation_2', 'connotation_3', 'connotation_4', 'connotation_5')], by.x='lowercase_name', by.y='name', all.x=T)
write_csv(us, 'output-data/us_names_with_popularity_and_connotations.csv')

uk <- read_csv('output-data/uk_baby_names.csv')
uk <- uk[, setdiff(colnames(uk), c('connotation_1', 'connotation_2', 'connotation_3', 'connotation_4', 'connotation_5'))]
uk$lowercase_name <- tolower(uk$name)
uk <- merge(uk, names_with_connotations_clean[, c('name', 'connotation_1', 'connotation_2', 'connotation_3', 'connotation_4', 'connotation_5')], by.x='lowercase_name', by.y='name', all.x=T)
write_csv(uk, 'output-data/uk_names_with_popularity_and_connotations.csv')