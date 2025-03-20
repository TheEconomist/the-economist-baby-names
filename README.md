# Template for data analysis projects

This is a basic repo for structuring a data project for the Economist. It's set up around using [R][Rlang], but is equally useable with [Python][Python] scripts, if you prefer.

[Rlang]: https://www.r-project.org/
[Python]: https://python.org/


## How to use it

The project structure is set up with four (self-explanatory) directories:

- `source-data` - The data files your script depends on to run. (This may not be _all_ the data you need--pulling information direct from the internet is also fine!)
- `scripts` - Your processing scripts (in R or Python)
- `plots` - Any charts you want to output
- `output-data` - The data files your script produces

There is also a `run.sh`. This is a [shell script][shell script] in bash. If at all practical, this script should run all of your code (either use `Rscript scripts/MY_SCRIPT.R` or `python3 scripts/MY_SCRIPT.py`). This means anyone coming fresh to your script will know how to run it and generate your output files. A shell script is more or less the same as running commands on the command line, so you can run several scripts in order, or even mix and match R and python scripts if you feel the need. This also means you _don't_ need to use `setwd` in R. (`setwd` makes it more difficult for other people to use your script.)

[shell script]: https://en.wikipedia.org/wiki/Shell_script


## Best practices

_You should be using dependency management_. If you're using R, use [renv][renv] (this is decidedly better than [pacman][pacman]; please _don't_ use pacman). If you're using Python, use [poetry][poetry] (you could also use [pipenv][pipenv]--both are fine; either is better than just providing `requirements.txt`, though that's better than nothing). This will help make sure other people are able to run your code easily. If you're not sure how to use these tools, [renv][renv how to] and [poetry][poetry how to] both have relatively inscrutable introductions, but they're hopefully helpful.

[renv]: https://rstudio.github.io/renv/index.html
[renv how to]: https://rstudio.github.io/renv/reference/init.html
[pacman]: https://cran.r-project.org/web/packages/pacman/index.html
[pipenv]: https://pipenv.pypa.io/en/latest/
[poetry]: https://python-poetry.org/
[poetry how to]: https://python-poetry.org/docs/basic-usage/

_Dates should always be in ISO format_. That's `YYYY-MM-DD`, like `2024-01-12`. This is for three reasons. First, there's no risk of anyone confusing this date format for another (unlike American/European date formats). Second, most programming languages will parse an ISO date correctly with no other formatting. And third, dates written like this will always sort in chronological order, even if sorted alphabetically.
