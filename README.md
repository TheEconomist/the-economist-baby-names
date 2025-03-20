# What's in a name?

This repository contains R scripts that analyze trends in baby names from America and Britain over the past 143 years. It examines how the popularity, diversity, and meanings (connotations) of names have evolved over time, highlighting cultural shifts through visualizations and statistical metrics.

### Contents:
- **Data Gathering Scripts**: Collect and prepare datasets of baby names from US and UK sources.
- **Connotation Analysis**: Uses AI-generated descriptors to categorize names into groups (e.g., intelligence, beauty, strength).
- **Trend Analysis**: Evaluates the diversity and rate of change in naming practices using metrics such as the Jensen–Shannon distance and Herfindahl-Hirschman Index (HHI).
- **Visualization Scripts**: Generate charts illustrating trends in name popularity, diversity, and associated connotations.

# Details:

## Sources:
- [SSA Baby Names](https://www.ssa.gov/oact/babynames) (US data)
- [ONS Data](https://www.ons.gov.uk) (UK data)
- ChatGPT4 (for connotation analysis)
- Word2Vec (for dimensional mapping of connotations)

## Data Description
### United States

The dataset for American names is stored in the file [`output-data/us_names_with_popularity_and_connotations.csv`](output-data/us_names_with_popularity_and_connotations.csv). It contains detailed information on the prevalence and connotations of common names given in America from 1880–2023. The columns include:

- **`name`**: The given name under analysis.
- **`sex`**: The gender associated with the name (M for Male, F for Female).
- **`n`**: The number of occurrences of the name in a given year.
- **`year`**: The specific year the data was recorded.
- **`per_year`**: The total number of births recorded in that year.
- **`percent_per_year`**: The percentage of occurrences of the name relative to the total births in that year.
- **`nchar`**: The number of characters in the name.
- **`connotation_1` to `connotation_5`**: The top five connotations associated with each name, representing different qualities or attributes. These were acquired by asking ChatGPT4o to give the top five connotations of the name, separated by commas.
- **`flag`**: A boolean flag indicating whether the row is missing data on any of the five connotations listed (FALSE indicates all connotations are present).
- **`connotation_raw`**: The raw text string of connotations associated with the name, as originally provided.
- **`intelligence` to `tradition`**: Boolean columns indicating whether the name is associated with specific broad connotation categories such as intelligence, beauty, strength, wealth, love, joy, religious, and tradition. These were acquired by asking ChatGPT4o for all connotations related to these themes.

### United Kingdom

The dataset for UK names is stored in the file [`output-data/uk_names_with_popularity_and_connotations.csv`](output-data/uk_names_with_popularity_and_connotations.csv). It provides similar information to the US dataset, covering UK names from 1996–2023.

### Example Rows (US)

| name | sex | n  | year | per_year | percent_per_year | nchar | connotation_1 | connotation_2 | connotation_3 | connotation_4 | connotation_5 | flag | connotation_raw | intelligence | beauty | strength | wealth | love | joy | religious | tradition |
|------|-----|----|------|----------|------------------|-------|---------------|---------------|---------------|---------------|---------------|------|-----------------|--------------|--------|----------|--------|------|-----|-----------|-----------|
| Aaban | M  | 14 | 2013 | 1890819  | 0.0007404199      | 5     | dignity       | nobility      | prosperity    | leadership    | strength      | FALSE| 1. Dignity\n2. Nobility\n3. Prosperity\n4. Leadership\n5. Strength | FALSE        | FALSE  | FALSE    | FALSE  | FALSE| FALSE| FALSE     | FALSE     |
| Emma  | F  | 350| 2020 | 1720000  | 0.0203488372      | 4     | beauty        | love          | joy           | kindness      | strength      | FALSE| 1. Beauty\n2. Love\n3. Joy\n4. Kindness\n5. Strength  | FALSE        | TRUE   | FALSE    | FALSE  | TRUE | TRUE | FALSE     | FALSE     |

## Connotations
Connotations were obtained through OpenAI's API using separate calls to ChatGPT4 with the query "What are the top five connotations of the name {name}. Give your answer as a list separated by commas." 
Connotations groups were obtained through a combination of manual and LLM identification of synonyms. Groups were defined manually.  

## Caveats
- Not all baby names enter our dataset. In America, we only have data on names given to five or more in a given year. In England and Wales, only names given to at least three in a given year enter the data.
- Our study tracks the popularity of connotations through the names. However, we only know the current connotations of names. Connotations may have changed over time. For some connotations this is especially important (e.g. "traditional"). Please consider this if using this data to look at such questions, and be careful about going far back in time. We have no reason to believe this affects broad trends in the data for the cannotation groups we identify in our analysis. 

## Contact

For questions or issues, please contact Sondre Solstad at [sondresolstad@economist.com](mailto:sondresolstad@economist.com).

## Suggested citation
The Economist and Solstad, S. (corresponding author), 2025. What's in a name? [online] The Economist. Available at: www.economist.com/interactive/culture/2025/03/20/what-is-in-a-name. First published in the article "The importance of being Earnest", The Economist, March 20th, 2025.
