# Scanning for parallel signals across the genome #

To investigate parallel signals across the genome, we used a calculation of the product of the allele frequency differential.
This was completed in R, and the script is available in this repository, parallel_signals.R

This file outlines how to create the input files for that script.

For each population, we created a text file with 7 columns:
- Chromosome Number
- Position
- Reference Allele
- Alternative Allele
- Total number of alleles at position (note that only biallelic sites were retained in the vcf so this number is 2 x number of individuals)
- Reference allele count
- Frequency of the reference allele

Example with the Atlantic population

First run VCFtools (v.0.1.16) to create a vcf file of just the Atlantic individuals from the dataset Genomescan1

```
vcftools --vcf genomescan1.vcf --indv BZH_02 --indv BZH_03 --indv BZH_04 --indv BZH_05 --indv BZH_06 --indv BZH_07 --indv BZH_08 --recode --out atlantic
```

Next, use bcftools (v.1.13) to create tags in the VCF for allele counts and frequency

```
bcftools +fill-tags atlantic.recode.vcf -- -t AN,AC,AF > atlantic_tags.vcf
```

Next, use bcftools (v.1.13) to extract these fields into a text file

```
bcftools query -f '%CHROM\t%POS\t%REF\t%ALT\t%INFO/AN\t%INFO/AC\t%INFO/AF\n' atlantic_tags.vcf  > atlantic_AN_AC_AF.txt
```

Repeat for each of the 4 populations.
