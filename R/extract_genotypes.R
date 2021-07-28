library(argparser)
library(dplyr)
library(tidyr)
library(readr)
library(SeqVarTools)

sessionInfo()

argp <- arg_parser("Extract genotypes") %>%
  add_argument("gds", help = "path to the GDS file") %>%
  add_argument("--sample_include_file", help = "path to a file containing the set of sample identifiers to extract") %>%
  add_argument("--variant_include_file", help = "path to a file containing the set of variant ids to extract") %>%
  add_argument("--out_prefix", help = "output file prefix")

argv <- parse_args(argp)
print(argv)

sample_include <- readRDS(argv$sample_include_file)
variant_include <- readRDS(argv$variant_include_file)

gds <- seqOpen(argv$gds)

seqSetFilter(gds, sample.id = sample_include, variant.id = variant_include)

var_info <- variantInfo(gds, expanded = TRUE)

geno <- expandedAltDosage(gds)

seqClose(gds)

geno <- geno %>%
  t() %>%
  as_tibble(rownames = "variant.id") %>%
  mutate(variant.id = as.integer(variant.id)) %>%
  group_by(variant.id) %>%
  # Add an allele index for getting chr/pos/ref/alt info.
  mutate(allele_index = 1:n()) %>%
  ungroup() %>%
  left_join(var_info, by = c("variant.id", allele_index = "allele.index")) %>%
  # Order columns as desired.
  select(-allele_index) %>%
  select(variant.id, chr, pos, ref, alt, everything())

outfile <- "genotypes.rds"
if (nchar(argv$out_prefix) > 0) {
  outfile <- paste(argv$out_prefix, outfile, sep = "_")
}
saveRDS(geno, outfile)
