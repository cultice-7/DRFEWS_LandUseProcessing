infl_base_year = 2016

rule inflation_data:
    input: 
        file_in = "inputs/BLS_CPIu_Annual_1990-2024.txt"
    output: 
        file_out = "outputs/CPIu_Base{infl_base_year}.csv"
    params:
        base_year = infl_base_year
    shell:
        r"""
        /src/s_Preproc_InflationAdj.R --file_in {input.file_in} --file_out {output.file_out} --base_year {params.base_year}
        """

rule conservation_data:
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