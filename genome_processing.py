import pandas as pd


df = pd.read_csv('sample_files/plink_genome/test_ovine_genome.csv', delimiter=' ',
                 header=None, names=['IID1', 'IID2', 'Z0', 'Z1', 'Z2'])

df['RT'] = 'NA'

df.loc[df['Z2'] >= 0.98, 'RT'] = 'MZT' # monozygous twins
df.loc[df['Z1'] >= 0.82, 'RT'] = 'PO' # parent/offspring
df.loc[(df['Z1'] >= 0.41) & (df['Z2'] >= 0.21), 'RT'] = 'FS' # full siblings

df.drop(['Z0', 'Z1', 'Z2'], axis=1).to_csv('sample_files/relatives/relatives.csv', sep='\t', index=False)
