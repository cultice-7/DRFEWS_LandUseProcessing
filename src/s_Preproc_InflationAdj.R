################################################################################
### DRFEWS Land Use Modeling -- Data Generation
### Price Generation
###
### Description: This script uses CPIu data from the Bureau of Labor Statistics
###   to create a price deflator table that can generate prices in dollars in
###   terms of the input year.
###
### This script is designed to run with snakemake
################################################################################

if (!require("pacman")) install.packages("pacman")

libraries <- c("tidyverse",
               "data.table",
               "here")
pacman::p_load(char = libraries)

### Step 0: Checking working directory
here::i_am("Snakefile")

#####
### Step 1: Parsing
#####

# debug
file_in <- "inputs/BLS_CPIu_Annual_1990-2024.txt"
base_year <- 2016
file_out <- paste0("outputs/CPIu_Base", base_year, ".csv")
infl <- 0.02

# file_in <- snakemake@input[["file_in"]]
# file_out <- snakemake@output[["file_out"]]
# base_year <- snakemake@params[["base_year"]]
# infl <- snakemake@params[["infl"]]

#####
### Step 2: Executions
#####

# Load inflation data and create a deflator based on base year
cpi <- fread(file_in)
cpi_base <- cpi[Year == base_year]$Annual
cpi <- cpi %>%
  .[, Deflator := round(Annual / cpi_base, 2)] %>%
  .[, c("Year", "Deflator")]

# Extend series out to 2050
start_year <- max(dt.cpi$Year) + 1
end_year <- 2050

for (year in start_year:end_year){
  new_val <- round((cpi[Year == year - 1]$Deflator) * (1 + infl), 2)
  new_row <- list(Year = year, Deflator = new_val)
  cpi <- rbind(cpi, new_row)
}

# Write inflation to file
fwrite(cpi, file_out)