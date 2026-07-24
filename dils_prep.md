# Preparing input files for DILS

For these steps I used: vcftools v.0.1.16, bcftools v.1.13, samtools v.1.19.2 and vcf2fasta

### FILTERING ###

VARIANT

Step 1: Filter to keep biallelic SNPs only
```
bcftools view -m2 -M2 -v snps snps_filtered_excluded.vcf.gz -Oz -o all_bi.vcf.gz
```

Step 2: Remove sites marked as deviant by ngsParalog and chrs 6,7,8
```
vcftools --gzvcf all_bi.vcf.gz --exclude-positions deviant_snps.txt --not-chr Chr6 --not-chr Chr7 --not-chr Chr8 --recode --out rmdeviant_no678
```

Step 3: Filter by site depth
First assess depth
```
vcftools --vcf rmdeviant_no678.recode.vcf --site-mean-depth --out sitedepth

R

> sitedepth <- read.table('sitedepth.ldepth.mean', header = TRUE)
> quantile(sitedepth$MEAN_DEPTH)
```

Then polish site depth
```
vcftools --vcf rmdeviant_no678.recode.vcf --min-meanDP 7 --max-meanDP 23 --recode --out depth_rmind_deviant_no678.recode.vcf
```

INVARINT

Step 1: extract invariant sites from the GATK output file for all sites (see variant_calling.md for details)
```
vcftools --gzvcf allsites_vcf.vcf.gz --max-maf 0 --remove-indels --recode --out invariant
```

Step 2: remove chromosomes 6,7,8
```
vcftools --vcf invariant.recode.vcf --not-chr Chr6 --not-chr Chr7 --not-chr Chr8 --recode --out invariant_no678
```

Step 3: Assess site depth
```
vcftools --vcf invariant_no678.recode.vcf --site-mean-depth --out sitedepth

R

> sitedepth <- read.table('sitedepth.ldepth.mean', header = TRUE)
> quantile(sitedepth$MEAN_DEPTH)
```

Step 4: Polish site depth
```
vcftools --vcf invariant_no678.recode.vcf --min-meanDP 6 --max-meanDP 117 --recode --out depth_invariant_no678.recode.vcf
```

COMBINE VARIANT AND INVARIANT

Step 1: Compress and index
```
bgzip depth_rmind_deviant_no678.recode.vcf
tabix depth_rmind_deviant_no678.recode.vcf.gz

bgzip depth_invariant_no678.recode.vcf
tabix depth_invariant_no678.recode.vcf.gz
```

Step 2: Concatenate
```
bcftools concat --allow-overlaps depth_rmind_deviant_no678.recode.vcf.gz depth_invariant_no678.recode.vcf.gz -O z -o demo_input.vcf.gz
```

Then Benjamin Penaud created and ran a magic custom script (completevcf.bash), filling the file with missing data where necessary (an important step to get DILS to run properly).
Output: complete_final_dils_input.vcf.gz


### FILE PREP ###

Split by chromosome, because we dont want to include chrs 6,7,8

e.g.
```
vcftools --gzvcf complete_final_dils_input.vcf.gz --chr Chr1 --recode --out /home1/datawork/lcolston/flatoyster/DILS_filter/chr1_final_dils_input
```

All files must be compressed and indexed for vcf2fasta. Use bcftools 
```
bgzip chr1_final_dils_input.recode.vcf
tabix chr1_final_dils_input.recode.vcf.gz
```

Also have to split gff3 file by chromosome, and the fasta file, e.g.
```
awk -v chr="Chr1" '$1 == chr || $1 ~ /^#/ {print}' Oed.gff3 > chr1.gff3

awk -v chr="Chr10" '/^>/ {p = ($0 == ">" chr)} p' Oed.genome.chr.fasta > Chr1.fasta
```

Then index all of these, e.g.
```
samtools faidx Chr2.fasta
```

### CONVERT TO FASTA ###

We needed to modify the vcf2fasta command for DILS input: see vcf2_fasta_cfraisse_modified.py, created by Christelle Fraïsse.

Run vcf2fasta (modified) for each chromosome, e.g.
```
vcf2_fasta_cfraisse_modified.py --fasta $GENOME --vcf $VCF --gff $GFF --feat gene --out $OUTPUT
```

Then modify the fasta files for input for DILS, using modify_fasta.py, created by Camille Roux.
```
for fastafile in $(ls output_chr1_gene/*.fas); do gene_name=$(basename $fastafile); python3 modify_fasta.py ${fastafile} /home1/datawork/lcolston/flatoyster/demography_final/correspondance_pop_table.txt relabelledFastaFiles1/${gene_name} >> nStopCodons1.txt; done
```

### EDIT GENES INCLUDED ###

We do not want all the inversion genes in the file (linkage disequilibrium)

Put all genes into one directory EXCEPT the inversion genes, and concatenate
```
cat *.fas > dils_input.fas
```

### FILTER ###

DILS struggled with the long genes. Filter only for genes up to 5000bp.
```
from Bio import SeqIO

def filter_fasta_by_length(dils_input.fas, 5K_dils_input.fasta, max_length=5000):
    with open(dils_input.fas, 'r') as input_handle, open(5K_dils_input.fasta, 'w') as output_handle:
        filtered_sequences = (
            record for record in SeqIO.parse(input_handle, "fasta") 
            if len(record.seq) <= max_length
        )
        count = SeqIO.write(filtered_sequences, output_handle, "fasta")

    print("Found {} sequences with length <= {} bp".format(count, max_length))
```

### ADD BACK ISLAND AND INVERSION GENES ###

We wanted to keep one gene from each island and each inversion. So these genes were added back into the final dataset. Most are longer than 5000bp but a few long ones are fine for DILS

OED_005755 7147
OED_006462 55044
OED_001881 54808
OED_003174 15233
OED_014772 7858
OED_016524 35462
OED_018903 24754
OED_011649 8461
OED_026744 16861
OED_026967 22971
OED_032478 9552
OED_019282 21460
OED_009086 27133
OED_028297 44930

```
cat *.fas > dils_input_5K_islands.fas
```
