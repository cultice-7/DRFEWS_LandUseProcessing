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
               "here",
               "argparse")
pacman::p_load(char = libraries)

### Step 0: Checking working directory
here::i_am("Snakefile")

#####
### Step 1: Parsing
#####

parser <- ArgumentParser()
parser$add_argument("--raw_text", action = "store", type="string", metavar = "InputText",
                    help = "Name of input file w/ raw CPIu data")
parser$add_argument("--out_name", action = "store", type="string", metavar = "OutputName",
                    help = "Name of output file w/ base year deflator")
parser$add_argument("--base_year", action = "store", type="integer", 
                    metavar = "Infl Base Year", default = 2016,
                    help = "Base year for generating inflation deflator value")
args <- parser$parse_args()

# PARSING -- create full file extensions from filename args
f.make_fullname <- function(args){
  
  for (key in names(args)){
    if (str_detect(key, "file")){
      args[[key]] = str_c(getwd(), "/", args[[key]])
    }
  }
  # make_fullname -- Loop through keys
  return(args)
}
args = f.make_fullname(args)

#####
### Step 2: Executions
#####

dt.cpi <- fread(args$file_in)
cpi_base <- dt.cpi[Year == args$base_year]$Annual

dt.cpi <- dt.cpi %>%
  .[,Deflator := round(Annual/cpi_base, 2)] %>%
  .[,c("Year", "Deflator")] %>%
fwrite(dt.cpi, args$file_out)


