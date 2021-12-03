library(tidyverse)
library(readxl)
library(magrittr)
library(biomaRt)

# Import data
dat_file <- c('Ce-rGC_BlastP.xlsx')

Sr_rGCs <- read_excel(dat_file, sheet = 1) %>%
    as_vector() %>%
    na.omit() %>%
    unique() %>%
    as_tibble_col(column_name = "geneID")

Ss_rGCs <- read_excel(dat_file, sheet = 2) %>%
    as_vector() %>%
    na.omit() %>%
    unique() %>%
    as_tibble_col(column_name = "geneID")

WBPS_homologs <- read_excel(dat_file, sheet = 5) %>%
    na.omit() %>%
    unique() 

merged_homolog_list <- bind_rows(WBPS_homologs, Ss_rGCs, Sr_rGCs) %>%
    unique()

Ss.seq <- getBM(attributes=c('wbps_gene_id', 'wbps_transcript_id', 'peptide'),
                  # grab the peptide sequences for the given genes from WormBase Parasite
                  mart = useMart(biomart="parasite_mart", 
                                 dataset = "wbps_gene", 
                                 host="https://parasite.wormbase.org", 
                                 port = 443),
                  filters = c('species_id_1010', 
                              'wbps_gene_id'),
                  values = list(c('ststerprjeb528'),
                                merged_homolog_list$geneID),
                  useCache = F) %>%
    as_tibble() %>%
    #we need to rename the columns retreived from biomart
    dplyr::rename(geneID = wbps_gene_id, transcriptID = wbps_transcript_id)%>%
    dplyr::mutate(queryID = geneID) # save the query used for indexing

Sr.seq <- getBM(attributes=c('external_gene_id', 'wbps_transcript_id', 'peptide'),
                # grab the peptide sequences for the given genes from WormBase Parasite
                mart = useMart(biomart="parasite_mart", 
                               dataset = "wbps_gene", 
                               host="https://parasite.wormbase.org", 
                               port = 443),
                filters = c('species_id_1010',
                            'gene_name'),
                values = list(c('strattprjeb125'),
                              merged_homolog_list$geneID),
                useCache = F) %>%
    as_tibble() %>%
    #we need to rename the columns retreived from biomart
    dplyr::rename(geneID = external_gene_id, transcriptID = wbps_transcript_id)%>%
    dplyr::mutate(queryID = geneID) # save the query used for indexing

merged_coding_list <- bind_rows(Sr.seq, Ss.seq) %>%
    dplyr::select(transcriptID, peptide) %>%
    dplyr::mutate(Length = nchar(peptide))


write.csv(merged_homolog_list, 'Str_rGCs_unique.csv')

