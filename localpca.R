########## LOCAL PCA ##########################################################

#library(devtools)
#install.packages("data.table")
#devtools::install_github("petrelharp/local_pca/lostruct")
library(lostruct)

#get data into the right format
snps <- read_vcf("genomescan_dataset_chrX.vcf")

#calculate pcs
pcs <- eigen_windows(snps, win= 500, type="snp", k=1)

#select PC1

PC1 <- subset(pcs, select= -c(total, lam_1))

#transform into a dataset
library(dplyr)

dataframe_pcs <- as.data.frame(PC1)

#rename columns

chr <- df %>% 
  rename(
    BZH_02 = PC_1_2,
    BZH_03 = PC_1_3,
    BZH_04 = PC_1_4,
    BZH_05 = PC_1_5,
    BZH_06 = PC_1_6,
    BZH_07 = PC_1_7,
    BZH_08 = PC_1_8,
    COR_01 = PC_1_9,
    COR_02 = PC_1_10,
    COR_03 = PC_1_11,
    COR_04 = PC_1_12,
    COR_05 = PC_1_13,
    COR_06 = PC_1_14,
    COR_07 = PC_1_15,
    DEN_01 = PC_1_16,
    D_9_08 = PC_1_17,
    D_9_20 = PC_1_18,
    NET_01 = PC_1_19,
    NET_02 = PC_1_20,
    NET_03 = PC_1_21,
    NET_04 = PC_1_22,
    NET_05 = PC_1_23,
    NET_06 = PC_1_24,
    S_11_01 = PC_1_25,
    S_11_22 = PC_1_26,
    S_9_07 = PC_1_27,
    S_9_12 = PC_1_28
  )

### PLOTTING ###

# Load necessary libraries
library(ggplot2)
library(tidyr) # For data reshaping

# define populations for individuals

populations <- c(    
  BZH_02 = "Atlantic",
  BZH_03 = "Atlantic",
  BZH_04 = "Atlantic",
  BZH_05 = "Atlantic",
  BZH_06 = "Atlantic",
  BZH_07 = "Atlantic",
  BZH_08 = "Atlantic",
  COR_01 = "Med. West",
  COR_02 = "Med. West",
  COR_03 = "Med. West",
  COR_04 = "Med. West",
  COR_05 = "Med. West",
  COR_06 = "Med. West",
  COR_07 = "Med. West",
  DEN_01 = "North Sea",
  D_9_08 = "Black Sea",
  D_9_20 = "Black Sea",
  NET_01 = "North Sea",
  NET_02 = "North Sea",
  NET_03 = "North Sea",
  NET_04 = "North Sea",
  NET_05 = "North Sea",
  NET_06 = "North Sea",
  S_11_01 = "Black Sea",
  S_11_22 = "Black Sea",
  S_9_07 = "Black Sea",
  S_9_12 = "Black Sea"
  
)

# reshape data
# add index column
chr <- cbind(Index = 1:nrow(chr), chr)

# put into long format
chr_long <- gather(chr, key = "Individual", value = "Value", -Index)

chr_long <- chr_long %>%
  mutate(Group = populations[Individual])

# plot
# define colours
custom_colours <- c("Atlantic" = "#6ea3a0ff","Black Sea" = "#ca7a7aff","Med. West" = "#84aa78ff","North Sea" = "#937ea3ff")

# theme
lilastheme <- theme_linedraw() +
  theme(axis.title = element_text(size = rel(0.9)),
        axis.text.x = element_text(size = 10),
        axis.text.y = element_text(size= 10),
        text = element_text(size = 15),
        panel.grid.major = element_line(colour = NA,size = 0), 
        panel.grid.minor = element_line(colour = NA,size = 0)
  )

# make the plot
myplot <- ggplot(chr_long, aes(x = Index, y = Value, color = Group, group = Individual)) +
  geom_line() +
  labs(x = "SNP Window", y = "Principal Component 1", color = "Population") +
  scale_color_manual(values = custom_colours) +
  lilastheme

