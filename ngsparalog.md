# ngsParalog #

Run ngsParalog (Linderoth 2018) on raw data to determine a list of SNPs that are 'deviant' and should be removed for downstream analyses. The program also uses samtools to run. 
See https://github.com/tplinderoth/ngsParalog for more information.

```
samtools mpileup -b $BAM_LIST -l $BED_FILE -q 0 -Q 0 --ff UNMAP,DUP | "$NGSPARALOG_PATH"/ngsParalog calcLR -infile - -outfile $OUTFILE -minQ 20 -minind 30 -mincov 1
```
