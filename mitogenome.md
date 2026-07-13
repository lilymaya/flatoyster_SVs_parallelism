# Assemble and annotate mitogenomes

MitoZ v.3.6 (Meng et al. 2019)

See [https://pcingola.github.io/SnpEff/snpeff/introduction/](https://github.com/linzhi2013/MitoZ) for more information

Assemble and annotate the 27 samples + outgroup sample

```
SAMPLE=$(sed -n "${PBS_ARRAY_INDEX}p" $WORKDIR/samples.txt)

OUTDIR=${WORKDIR}/${SAMPLE}
mkdir -p "${OUTDIR}"

cd "${OUTDIR}"

mitoz all \
    --outprefix "${SAMPLE}" \
    --genetic_code 2 \
    --species_name "Ostrea edulis" \
    --fq1 ${DATA}/${SAMPLE}_R1_paired.fastq.gz \
    --fq2 ${DATA}/${SAMPLE}_R2_paired.fastq.gz \
    --fastq_read_length 150 \
    --data_size_for_mt_assembly 3,0 \
    --assembler megahit \
    --kmers_megahit 39 59 79 99 119 141 \
    --memory 50 \
    --clade Mollusca \
    --requiring_taxa Mollusca \
    --min_abundance 0
```
