# Process raw data #

### FastQC ###

use FastQC (https://github.com/s-andrews/fastqc, Andrews 2010) to assess quality
fastqc v. 0.11.9

```
fastqc $DATAINPUT/${NAME}.fastq.gz -o $DATAOUTPUT 2> $LOG/fastqc_raw_${NAME}.log
```

### fastp ###

use fastp (https://github.com/opengene/fastp, Chen et al. 2018) to assess quality to trim, filter for an average quality of 28, and removing polyG tails and Illumina adapter sequencing. 
fastp v. 0.20.0

```
fastp -i ${NAME}_R1_001.fastq.gz -I ${NAME}_R2_001.fastq.gz -o $DATAOUTPUT/${NAME}_paired_1.fastq.gz  -O $DATAOUTPUT/${NAME}_paired_2.fastq.gz --adapter_fasta $ADAPTERFILE --trim_poly_g --average_qual 28 --length_required 50 --thread 28 &> $LOG/fastp_${NAME}.log

```

Re-run fastqc to confirm that fastp has improved the quality of the raw reads

### Map to reference genome using BWA-MEM ###

Using bwa-mem v. 0.7.17 (Li and Durbin 2009) and sambamba v. 0.8.0 (Tarasov et al. 2015)


Index genome
```
bwa index $GENOME
```

Map
```
bwa mem -t 15 -M $GENOME -R '@RG\tID:'${NAME}'\tSM:'${NAME}'\tPL:illumina\tLB:lib1\tPU:unit1' ${NAME}_paired_1.fastq.gz ${NAME}_paired_2.fastq.gz > $DATAOUTPUT/${NAME}.sam
```

Filter output files and convert to bam format using SAMBAMBA
```
sambamba view -t 15 -S -f bam ${NAME}.sam > ${NAME}.bam
rm ${NAME}.sam
sambamba view -f bam -F "proper_pair and not (unmapped or secondary_alignment) and not ([XA] != null or [SA] != null)" ${NAME}.bam > ${NAME}_paired_unique.bam
rm ${NAME}.bam
sambamba sort ${NAME}_paired_unique.bam
rm ${NAME}_paired_unique.bam
sambamba index -t 15 ${NAME}_paired_unique.sorted.bam
