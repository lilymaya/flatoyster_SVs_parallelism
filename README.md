# flatoyster_SVs_parallelism

Code used for project **Parallel islands of differentiation at chromosomal inversions and other genomic regions in the European flat oyster (*Ostrea edulis*)** (Colston-Nepali, Doniol-Valcroze, Penaud, Reisser, Cornette, Roux, Fraïsse, Bierne, and Lapègue, 2026)

### Steps: ###
First we process our raw data: [*data_processing_and_mapping.md*](https://github.com/lilymaya/flatoyster_SVs_parallelism/blob/main/data_processing_and_mapping.md)

Then we call variants using GATK: [*variant_calling.md*](https://github.com/lilymaya/flatoyster_SVs_parallelism/blob/main/variant_calling.md)

Then we filter and create two different vcf files for downstream analyses: [*genomescan1.md*](https://github.com/lilymaya/flatoyster_SVs_parallelism/blob/main/genomescan1.md), [*genomescan2.md*](https://github.com/lilymaya/flatoyster_SVs_parallelism/blob/main/genomescan2.md), using results from [*ngsparalog.md*](https://github.com/lilymaya/flatoyster_SVs_parallelism/blob/main/ngsparalog.md)

To create the input file for the DILS analysis we do the following: [*dils_prep.md*](https://github.com/lilymaya/flatoyster_SVs_parallelism/blob/main/dils_prep.md) and use these custom scripts: [*complete_vcf.bash*](https://github.com/lilymaya/flatoyster_SVs_parallelism/blob/main/complete_vcf.bash), [*vcf2_fasta_cfraisse_modified.py*](https://github.com/lilymaya/flatoyster_SVs_parallelism/blob/main/vcf2_fasta_cfraisse_modified.py), [*modify_fasta.py*](https://github.com/lilymaya/flatoyster_SVs_parallelism/blob/main/modify_fasta.py)

We run a local PCA: [*local_pca.R*](https://github.com/lilymaya/flatoyster_SVs_parallelism/blob/main/local_pca.R)

We calculate pi, fst and dxy across the genome: [*pi-fst-dxy.md*](https://github.com/lilymaya/flatoyster_SVs_parallelism/blob/main/pi-fst-dxy.md)

We scan for parallel signals across the genome using: [*parallel_signals.md*](https://github.com/lilymaya/flatoyster_SVs_parallelism/blob/main/parallel_signals.md) and [*parallel_signals.R*](https://github.com/lilymaya/flatoyster_SVs_parallelism/blob/main/parallel_signals.R)

We use SnpEff to annotate vcfs, and examine GO enrichment: [*snpeff.md*](https://github.com/lilymaya/flatoyster_SVs_parallelism/blob/main/snpeff.md)

We assemble and annotate mitogenomes: [*mitogenome.md*](https://github.com/lilymaya/flatoyster_SVs_parallelism/blob/main/mitogenome.md)
