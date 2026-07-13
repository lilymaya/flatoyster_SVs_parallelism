# Gene ontology enrichment analyses

SnpEff v. 5.0

See https://pcingola.github.io/SnpEff/snpeff/introduction/ for more information

### First build a database ###

Database built following instructions here: https://pcingola.github.io/SnpEff/snpeff/build_db/

Followed step 2, option 3 with my reference genome (Li et al. 2022)

```
java -jar snpEff.jar build -gff3 -v Oed
```
### Create input files with VCFtools
Use VCFtools v.0.1.16 to create input vcf files for regions of interest, i.e. inversion on chromosome 9

```
vcftools --vcf genomescan1.recode.vcf --positions inversion9_snps.txt --recode --recode-INFO-all --out inversion9
```

### Then run the annotation on each file

```
java -Xmx8g -jar snpEff.jar -v Oed inversion9.recode.vcf > inversion9.ann.vcf
```

### GO enrichment analysis

Look at snpEff_genes.txt output file. Manually create a text file with list of genes (TranscriptId column).
Next use seqtk (see https://github.com/lh3/seqtk for more details) to extract fastq sequences for these genes.
```
seqtk subseq Oed.longest.gene.pep.fq genelist_inversion9.txt > inv9.fq
```
Convert back to fasta
```
seqtk seq -a inv9.fq > inv6.fasta
```
Use these fasta files for input for KOBAS: http://bioinfo.org/kobas/genelist/
