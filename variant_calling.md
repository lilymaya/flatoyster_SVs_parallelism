# Variant calling #

Using GATK and Picard Tools

## Pre-process ##

Following recommendations from: https://gatk.broadinstitute.org/hc/en-us/articles/360035535912-Data-pre-processing-for-variant-discovery

### Step 1: Remove duplicates and prep samples ###

Mark duplicates using Picard Tools v. 2.21.1

```
# Assign array nb to file
NAME=$(cat $DATADIRECTORY/00_scripts/gatk_map.txt | awk "NR==${PBS_ARRAY_INDEX}")

#save array table correspondance
echo -e ${PBS_ARRAY_INDEX}"\t"${NAME} >> $DATADIRECTORY/00_scripts/06_gatk_array_table.txt

$PICARD_TOOLS
cd $DATAINPUT

picard MarkDuplicates TMP_DIR=$SCRATCH I=${NAME}_paired_unique.sorted.bam O=${NAME}_MD.bam M=${NAME}_metrics.txt ASSUME_SORT_ORDER=coordinate VALIDATION_STRINGENCY=SILENT REMOVE_DUPLICATES=TRUE CREATE_INDEX=TRUE
```

Sort into coordinate order

  ```
# Assign array nb to file
NAME=$(cat $DATADIRECTORY/00_scripts/gatk_map.txt | awk "NR==${PBS_ARRAY_INDEX}")

#save array table correspondance
echo -e ${PBS_ARRAY_INDEX}"\t"${NAME} >> $DATADIRECTORY/00_scripts/06_gatk_array_table.txt

$PICARD_TOOLS
cd $DATAINPUT

picard SortSam TMP_DIR=$SCRATCH I=${NAME}_MD.bam O=${NAME}_SS.bam SORT_ORDER=coordinate
```

Now index all the files
  
```
# Assign array nb to file
NAME=$(cat $DATADIRECTORY/00_scripts/gatk_map.txt | awk "NR==${PBS_ARRAY_INDEX}")

#save array table correspondance
echo -e ${PBS_ARRAY_INDEX}"\t"${NAME} >> $DATADIRECTORY/00_scripts/06_gatk_array_table.txt

. /appli/bioinfo/samtools/1.9/env.sh

cd $DATAINPUT
samtools index $DATAINPUT/${NAME}_SS.bam
```

### Step 2: Prepare reference genome ###

Create a sequence dictionary
  
```
picard CreateSequenceDictionary R=Oed.genome.chr.fasta O=Oed.genome.chr.dict
```
  
Create a fasta index using samtools v.1.9

```
samtools faidx Oed.genome.chr.fasta
```

## Calling ##

GATK v.4.4.0.0

### Step 1: Call variants per samples ###

HaplotypeCaller: Call germline SNPs and indels via local re-assembly of haplotypes (runs per sample to generate an intermediate GVCF)

Automatically applied read filters:
- NotSecondaryAlignmentReadFilter- filter out reads representing secondary alignments
- GoodCigarReadFIlte- keep only reads containing good CIGAR string
- NonZeroReferenceLengthAlignmentReadFilter- filter out reads that do not align to the reference
- PassesVendorQualityCheckReadFilter- filter out reads failing platfor/vendor quality checks
- MappedReadFilter- filter out unmapped reads
- MappingQualityAvailableReadFilter- filter out reads without available mapping quality
- NotDuplicateReadFilter- filter out reads marked as duplicate
- MappingQualityReadFilter- keep only reads with mapping qualities within a specified range (min 10)
- WellformedReadFilter- tests whether a read is "well-formed" -- that is, is free of major internal inconsistencies and issues that could lead to errors downstream.
  
Additional filters I applied:
- min-base-quality-score 30  (minimum base quality required to consider a base for calling, default: 10)
- heterozygosity 0.01  (heterozygosity value used to compute prior probabilities for any locus, default: 0.001)

```
# Assign array nb to file
NAME=$(cat $DATADIRECTORY/00_scripts/gatk_map.txt | awk "NR==${PBS_ARRAY_INDEX}")

#save array table correspondance
echo -e ${PBS_ARRAY_INDEX}"\t"${NAME} >> $DATADIRECTORY/00_scripts/06_gatk_array_table.txt

. /appli/bioinfo/gatk/4.4.0.0/env.sh

gatk --java-options "-Djava.io.tmpdir=$SCRATCH $JAVA_OPTS" HaplotypeCaller -R $GENOME -I $DATAINPUT/${NAME}_SS.bam -O $DATAOUTPUT/${NAME}_output.g.vcf.gz --min-base-quality-score 30 --heterozygosity 0.01 -ERC GVCF -G StandardAnnotation -G AS_StandardAnnotation
```

### Step 2: Consolidate GVCFs ###

GenomicsDBImport: Import single-sample GVCFs into GenomicsDB before joint genotyping

Automatically applied read filter:
- WellformedReadFilter- tests whether a read is "well-formed" -- that is, is free of major internal inconsistencies and issues that could lead to errors downstream. If a read passes this filter, the rest of the engine should be able to process it without blowing up.

```
gatk --java-options "-Djava.io.tmpdir=$SCRATCH/gdb $JAVA_OPTS" GenomicsDBImport --genomicsdb-workspace-path $DATAOUTPUT --sample-name-map $SAMPLES -L $INTERVALS
```

### Step 3: Joint genotyping ###
GenotypeGVCFs: Perform joint genotyping on one or more samples pre-called with HaplotypeCaller

Automatically applied read filter: WellformedReadFilter

Additional filters I applied:
- heterozygosity 0.01  heterozygosity value used to compute prior probabilities for any locus, default: 0.001

This step was run with VARIANT sites only:

```
gatk --java-options "-Djava.io.tmpdir=$SCRATCH $JAVA_OPTS" GenotypeGVCFs -R $GENOME -V gendb://$DATAINPUT -O $DATAOUTPUT/genotype.vcf.gz --heterozygosity 0.01
```

### Step 3: Filter variants ###

Useful articles:
https://gatk.broadinstitute.org/hc/en-us/articles/360035531112#2
https://gatk.broadinstitute.org/hc/en-us/articles/360037499012
https://gatk.broadinstitute.org/hc/en-us/articles/360035890471-Hard-filtering-germline-short-variants
https://gatk.broadinstitute.org/hc/en-us/articles/360035891011-JEXL-filtering-expressions
https://gatk.broadinstitute.org/hc/en-us/articles/360035531012--How-to-Filter-on-genotype-using-VariantFiltration


First we want to separate the SNPs from the INDELS, using SelectVariants

SelectVariants https://gatk.broadinstitute.org/hc/en-us/articles/360036362532-SelectVariants

Automatically applied read filter:
- WellformedReadFilter

```
gatk SelectVariants -V $DATAINPUT -select-type SNP -O $DATAOUTPUT
```

Hard filter using the recommended GATK parameters

VariantFiltration https://gatk.broadinstitute.org/hc/en-us/articles/13832750065947-VariantFiltration

Automatically applied read filter: WellformedReadFilter

Additional filters I applied:

QD : QualByDepth, variant confidence (from the QUAL field) divided by the unfiltered depth of non-hom_ref samples. 
FS : FisherStrand, this is the Phred-scaled probability that there is strand bias at the site
SOR : StrandOddsRatio, another way to estimate strand bias using a test similar to the symmetric odds ratio test.
MQ : RMSMappingQuality, the root mean square mapping quality over all the reads at the site.
MQRankSum : Mapping QualityRankSumTest, this is the u-based z-approximation from the Rank Sum Test for mapping qualities
ReadPosRankSum : ReadPosRankSumTest, this is the u-based z-approximation from the Rank Sum Test for site position within reads

```
gatk VariantFiltration \
    -V $DATAINPUT \
    -filter "QD < 2.0" --filter-name "QD2" \
    -filter "QUAL < 30.0" --filter-name "QUAL30" \
    -filter "SOR > 3.0" --filter-name "SOR3" \
    -filter "FS > 60.0" --filter-name "FS60" \
    -filter "MQ < 40.0" --filter-name "MQ40" \
    -filter "MQRankSum < -12.5" --filter-name "MQRankSum-12.5" \
    -filter "ReadPosRankSum < -8.0" --filter-name "ReadPosRankSum-8" \
    -O $DATAOUTPUT
```

Now we want to exclude these filtered sites using SelectVariants

Automatically applied read filter: WellformedReadFilter

Additional filters:
- exclude-filtered		 	-don't include filtered sites (i.e. have anything other than `.` or `PASS` in the FILTER field).
- exclude-non-variants		-don't include non-variant sites (should already be only variant sites but just in case)

```
gatk SelectVariants -V $DATAINPUT --exclude-filtered --exclude-non-variants -O $DATAOUTPUT
```

