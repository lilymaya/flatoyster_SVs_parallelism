# pi, fst, and dxy across the genome

The program pixy (v. 1.0.0) was used to calculate pi, fst, and dxy across the genome

See [https://pcingola.github.io/SnpEff/snpeff/introduction/](https://pixy.readthedocs.io/en/latest/) for more information

### First create input files with VCFtools
pixy calculates pairwise fst and dxy, and population level pi across the genome.
First, input files with the populations of interest need to be generated.

Use VCFtools v.0.1.16 to create input vcf files for populations (and regions) of interest, i.e. the inversion on chromsome 9.

Here, we select only the individuals that are homozygous for an inversion allele. Each group (homozygous for allele 1, or homozygous for allele 2) will be an input 'population', outlined in a text file, i.e. chr9_inv.txt

*Note that pixy uses invariant sites, so the vcf used must contain the invariant sites.*
```
vcftools --cf genomescan2.vcf --chr Chr9 --indv BZH_05 --indv BZH_07 --indv NET_01 --indv NET_02 --indv NET_03 --indv NET_04 --indv NET_05 --indv NET_06 --indv DEN_01 --indv COR_03 --indv COR_07 --indv S_9_07 --indv S_9_12 --indv S_11_01 --indv S_11_22 --indv D_9_08 --indv D_9_20 --recode --out chr9_pixyinput
```

### Run pixy

```
pixy --stats pi fst dxy \
--vcf chr9_pixyinput.recode.vcf \
--populations chr9_inv.txt \
--window_size 10000 \
--n_cores 4 \
--output_folder chr9 \
--output_prefix chr9_inv
```
