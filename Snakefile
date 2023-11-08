configfile: "config.yaml"
conda: "conda.yaml"

import pandas as pd

rule all:
    input:
        expand("results/{data}/{data}_first_order_relatives.csv", data = config["DATA"])
        
        
rule get_genome_file:
    input:
        expand("samples/{data}/{data}.bed", data = config["DATA"]),
        expand("samples/{data}/{data}.bim", data = config["DATA"]),
        expand("samples/{data}/{data}.fam", data = config["DATA"])
    output:
        expand("results/{data}/{data}.genome", data = config["DATA"]),
        expand("results/{data}/{data}.log", data = config["DATA"]),
        expand("results/{data}/{data}.nosex", data = config["DATA"])
    params:
        sam = expand("samples/{data}/{data}", data = config["DATA"]),
        res = expand("results/{data}/{data}", data = config["DATA"])
    shell:
        "plink --bfile {params.sam} --genome --min 0.45 --out {params.res} --chr-set 29 --allow-extra-chr"
        

rule extract_z_columns:
    input:
        expand("results/{data}/{data}.genome", data = config["DATA"])
    output:
        expand("results/{data}/{data}_zcols.csv", data = config["DATA"])
    params:
        sam = expand("results/{data}/{data}.genome", data = config["DATA"]),
        res = expand("results/{data}/{data}_zcols.csv", data = config["DATA"])
    shell:
        "cut -f4,7,14,16,18 --delimiter=' ' {params.sam} | tail -n +2 > {params.res}"


rule find_first_order_relatives:
    input:
        expand("results/{data}/{data}_zcols.csv", data = config["DATA"])
    output:
        expand("results/{data}/{data}_first_order_relatives.csv", data = config["DATA"])
    run:
        df = pd.read_csv(f'{input}', delimiter=' ', header=None, names=['IID1', 'IID2', 'Z0', 'Z1', 'Z2'])

        df['RT'] = 'NA'

	df.loc[df['Z2'] >= 0.98, 'RT'] = 'MZT' # monozygous twins
	df.loc[df['Z1'] >= 0.82, 'RT'] = 'PO' # parent/offspring
	df.loc[(df['Z1'] >= 0.41) & (df['Z2'] >= 0.21), 'RT'] = 'FS' # full siblings

	df.drop(['Z0', 'Z1', 'Z2'], axis=1).to_csv(f'{output}', sep='\t', index=False)
	    
    



