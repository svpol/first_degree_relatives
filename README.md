# Task

The task is to find first-degree relatives for the given ovine dataset of plink files in *.bed, *.bim and *.fam binary formats.

The dataset is provided in the `sample_files/sample` directory.

The result file should contain animal pairs with relation type specified:

- parent/offspring (PO),
- full siblings (FS),
- monozygous twins (MZT).

# Solution

1. Receive plink *.genome file from the binary bed-bim-fam dataset with the coefficient of relationship `PI_HAT >= 0.45`:
   
   ```
   plink --bfile test_ovine --genome --min 0.45 --out test_ovine --chr-set 29 --allow-extra-chr
   ```
   
   The result of this command is provided at `sample_files/plink_genome/test_ovine.genome`.

2. There is no data about parents in the initial dataset there for, therefore the `RT` column of the `test_ovine.genome` cannot be used for further analysis.
   
   We will need three columns `Z0`, `Z1` and `Z2`. For convenience let's remove the unneeded columns:

   ```
   cut -f4,7,14,16,18 --delimiter=' ' test_ovine.genome | tail -n +2 > test_ovine_genome.csv
   ```
   
   The result of this command is provided at `sample_files/plink_genome/test_ovine_genome.csv`.

3. Analysis of the `Z0`/`Z1`/`Z2` columns ratio.
 
   For different types of first-degree relationship, the ratio of `Z0`/`Z1`/`Z2` columns should tend to:

   - PO - 0/1/0,
   - FS - 0.25/0.5/.25,
   - MZT - 0/0/1.

   In real life these proportions may differ, so let's make them less strict.
4. Using `genome_processing.py` filter the data in `test_ovine_genome.csv` and write the answer to `sample_files/relatives/relatives.csv`.