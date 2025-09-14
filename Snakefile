infl_base_year = 2016
infl_future = 0.02
#configfile: "config.yml"

rule load_inflation_data:
    input: 
        file_in = "inputs/BLS_CPIu_Annual_1990-2024.txt"
    output: 
        file_out = "outputs/CPIu_Base{infl_base_year}.csv"
    params:
        base_year = infl_base_year,
        infl = infl_future
    script:
        src/s_Preproc_InflationAdj.R

rule load_conservation_data:
    input:
        file_in_CRP = "inputs/USDA_FSA_CRP_1986-2022.xlsx"
        file_in_infl = "outputs/CPIu_Base{infl_base_year}.csv"
    output:
        file_out = "outputs/CRP_County_1986-2022.csv"
    params:
    shell:
        r"""
        /src/s_Preproc_CRP.R --file_in_CRP {input.file_in_CRP} --file_in_infl {input.file_in_CRP} --file_out {output.file_out}
        """


rule impute_ag_land_data