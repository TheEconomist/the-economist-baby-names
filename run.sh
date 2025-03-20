#! /bin/bash
set -e

# Function to run R scripts and check for failure
run_r_script() {
  Rscript -e "renv::run('$1')"
  if [ $? -ne 0 ]; then
    echo "Error in R script: $1"
    exit 1
  fi
}

Help()
{
  echo "Run this data package"
  echo
  echo "Syntax run.sh [-h]"
  echo "h        Print this help"
  echo
}

while getopts "h" option; do
  case $option in
    h)
      Help
      exit;;
  esac
done

run_r_script "./scripts/run.R"

echo "{\"timestamp\": $(date +%s)}" > output-data/timestamp.json