# 1. Task

The task is to find first-degree relatives for the given ovine dataset of plink files in *.bed, *.bim and *.fam binary formats.

The dataset is provided in the `samples` directory.

The result file should contain animal pairs with the relation type (RT) specified:

- parent/offspring (PO),
- full siblings (FS),
- monozygous twins (MZT).

All the results are presented in `results` directory.

# 2. Solution

Solution is presented as a Snakemake pipeline using plink v. 1.9 and pandas. 

To obtain the result you need to have Snakemake installed, proceed to the Snakefile directory and run command:

```
snakemake --cores 2 --use-conda
```

You can choose other number of cores, but as the sample dataset is small, `cores==2` is chosen.

# 3. Snakefile logic

Here is the logic of the Snakefile by steps:

1. Rule `get_genome_file` allows to receive the plink *.genome file from the binary bed-bim-fam dataset with the coefficient of relationship `PI_HAT >= 0.45` to exclude non-related organisms. This shell command is used in the DAG:
   
   ```
   plink --bfile <dataset> --genome --min 0.45 --out <dataset> --chr-set 29 --allow-extra-chr
   ```

2. Rule `extract_z_columns` allows to extract `Z0`, `Z1` and `Z2` from the *.genome file.

   There is no data about parents in the initial dataset there for, therefore the `RT` column of the *.genome file cannot be used for further analysis.
   
   We will need three columns `Z0`, `Z1` and `Z2`. For convenience let's remove the unneeded columns using the command within the rule:

   ```
   cut -f4,7,14,16,18 --delimiter=' ' <dataset>.genome | tail -n +2 > <dataset>_zcols.csv
   ```

3. Rule `find_first_order_relatives` allows to analyse the `Z0`/`Z1`/`Z2` columns ratio and write down the relation type for each animal pair:

   - PO - 0/1/0,
   - FS - 0.25/0.5/.25,
   - MZT - 0/0/1.

   In real life these proportions may differ, so less strict ones are taken.
   
   A small piece of pandas code makes it and then the final result can be seen at `/results/samples/samples_first_order_relatives.csv'.
