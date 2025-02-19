################################################################################
### DRFEWS Land Use Modeling -- Data Generation
### Conservation Reserve Program
###
### Description: This script loads and cleans the necessary data to create
###              Conservation Reserve Program (CRP) inputs.
###   1) Creates county-level enrollments data, with acres of enrollment and 
###      scheduled retirements
###   2) Creates CRP price series for all counties
################################################################################

if (!require("pacman")) install.packages("pacman")

libraries <- c("tidyverse",
               "data.table",
               "readxl",
               "here")
pacman::p_load(char = libraries)

### Step 0: Checking working directory
here::i_am("Snakefile")

#####
### Step 1: Parsing
#####

parser <- ArgumentParser()
parser$add_argument("--file_in_CRP", action = "store", type="string", metavar = "InputText",
                    help = "Name of input file w/ raw CPIu data")
parser$add_argument("--file_in_infl", action = "store", type="string", metavar = "InflationData",
                    help = "Name of output file w/ base year deflator")
parser$add_argument("--file_out", action = "store", type="string", metavar = "OutputFile",
                    help = "Base year for generating inflation deflator value")
args <- parser$parse_args()

args <- list("file_in_CRP" = "inputs/USDA_FSA_CRP_1986-2022.xlsx")

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
read_excel()

# Executions -- Load Enrollment Data
dt.cons_land <- read_excel(args$file_in_CRP,
                           sheet = "ACRES",
                           skip = 3)

dt.cons_rent <- read_excel(args$file_in_CRP,
                           sheet = "")
# Executions -- Basic Variable Cleaning
dt.cons_land <- dt.cons_land %>%
  as.data.table() %>%
  .[,FIPS_cnty := str_pad(FIPS, width = 5, side = "left", pad = "0")]  %>%
  .[,FIPS_st   := str_sub(FIPS_cnty, end = 2)] %>%
  .[,c("FIPS_cnty", "FIPS_st", as.character(1986:2022))] %>%
  setnames(c("FIPS_cnty", "FIPS_st", str_c("CRP_Acres", 1986:2022))) %>%
  melt(measure = patterns("CRP_Acres"), variable.name = "Year", value.name = "CRP_Acres")


### Build Conservation Enrollment Data
