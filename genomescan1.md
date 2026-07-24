# genomescan1

This dataset contains only variant sites. This dataset was used as input for the local PCA (localpca.R), the gene ontology/annotation (GO.md), and the parallel signals analyses (parallel_signals.md).

Filtering completed using bcftools (v.1.13) and vcftools (v.0.1.16)

First, the GATK output file for variant sites only (see variant_calling.md for details) was filtered to keep biallelic sites only:

```
bcftools view -m2 -M2 -v snps snps_filtered_excluded.vcf.gz -Oz -o all_bi.vcf.gz
```

Then remove sites marked as deviant by ngsParalog (see ngsParalog.md), and sites identified in the high coverage individuals (see XXX)

```
vcftools --vcf all_bi.vcf --exclude-positions deviant_snps.txt --exclude-positions highcov_snps.txt --recode --out excluded
```

Remove missing data and filter MAF

```
vcftools --vcf excluded.recode.vcf --max-missing 1 --maf 0.05 --recode --out genomescan1
```
