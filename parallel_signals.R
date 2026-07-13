### Parallel Signals R script ###

    #prep data
#first read in the allele frequency files that were created in parallel_signals.md

ns <- read.table("NS_AN_AC_AF.txt", header = FALSE)
colnames(ns) <- c("Chr", "Pos", "Ref", "Alt", "Total", "Ref_Count", "ns_Freq")

atl <- read.table("atlantic_AN_AC_AF.txt", header = FALSE)
colnames(atl) <- c("Chr", "Pos", "Ref", "Alt", "Total", "Ref_Count", "atl_Freq")

bs <- read.table("BS_AN_AC_AF.txt", header = FALSE)
colnames(mede) <- c("Chr", "Pos", "Ref", "Alt", "Total", "Ref_Count", "bs_Freq")

medw <- read.table("medw_AN_AC_AF.txt", header = FALSE)
colnames(medw) <- c("Chr", "Pos", "Ref", "Alt", "Total", "Ref_Count", "medw_Freq")

#now make dataframes and calculate allele frequency differential

north <- data.frame(ns$Chr, ns$Pos, ns$ns_Freq, atl$atl_Freq)
north$differential_north <- north$ns.ns_Freq - north$atl.atl_Freq

south <- data.frame(bs$Chr, bs$Pos, bs$bs_Freq, medw$medw_Freq)
south$differential_south <- south$mede.mede_Freq - south$medw.medw_Freq

#caclulcate product of allele frequency differential (Π): [Π = (NS-ATL) x (BS-MED)] 
#note here we refer to this throughout scripts as pafd

pafd <- data.frame(ns$Chr, ns$Pos, north$differential_north, south$differential_south)
pafd$pafd_score <- pafd$north.differential_north * pafd$south.differential_south

#add a category column
library(dplyr)

pafd <- pafd %>%
  mutate(Category = case_when(
   pafd$f4_score  > 0.5 ~ "Parallel",
    pafd$f4_score < -0.5 ~ "Anti-Parallel",
    TRUE ~ "Neutral"
  ))
