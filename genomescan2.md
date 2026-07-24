# genomescan2

This dataset contains all of the variant sites from Genomescan1 PLUS invariant sites. This dataset was used as input for pixy (pi-fst-dxy.md).

Filtering completed using bcftools (v.1.13) and vcftools (v.0.1.16)

First extract invariant sites from the GATK output file for all sites (see variant_calling.md for details)

```
vcftools --gzvcf allsites_vcf.vcf.gz --max-maf 0 --remove-indels --recode --out invariant
```

Combine this dataset with genomescan1

First both files were compressed and indexed, i.e.:

```
bgzip invariant.recode.vcf
tabix invariant.recode.vcf.gz
```

Then concatenate

```
bcftools concat --allow-overlaps invariant.recode.vcf.gz genomescan1.recode.vcf.gz -O z -o genomescan2.vcf.gz

tabix genomescan2.vcf.gz
```
