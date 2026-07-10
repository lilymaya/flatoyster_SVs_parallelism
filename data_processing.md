# Process raw data #

### FastQC ###

use FastQC (https://github.com/s-andrews/fastqc, Andrews 2010) to assess quality
fastqc v. 0.11.9

```
fastqc $DATAINPUT/${NAME}.fastq.gz -o $DATAOUTPUT 2> $LOG/fastqc_raw_${NAME}.log
```

### fastp ###

use fastp (Chen et al. 2018, https://github.com/opengene/fastp) to assess quality to trim, filter for an average quality of 28, and removing polyG tails and Illumina adapter sequencing. 
fastp v. 0.20.0

```
fastp -i ${NAME}_R1_001.fastq.gz -I ${NAME}_R2_001.fastq.gz -o $DATAOUTPUT/${NAME}_paired_1.fastq.gz  -O $DATAOUTPUT/${NAME}_paired_2.fastq.gz --adapter_fasta $ADAPTERFILE --trim_poly_g --average_qual 28 --length_required 50 --thread 28 &> $LOG/fastp_${NAME}.log

```

Re-run fastqc to confirm that fastp has improved the quality of the raw reads
