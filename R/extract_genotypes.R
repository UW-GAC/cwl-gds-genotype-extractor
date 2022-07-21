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

if (!is.na(argv$sample_include_file)) {
  sample_include <- readRDS(argv$sample_include_file)
} else {
  sample_include <- NULL
}
variant_include <- readRDS(argv$variant_include_file)

gds <- seqOpen(argv$gds)

seqSetFilter(gds, sample.id = sample_include, variant.id = variant_include)

var_info <- variantInfo(gds, expanded = TRUE)

geno <- expandedAltDosage(gds)

seqClose(gds)

var_info <- var_info %>%
  mutate(variant = sprintf("chr%s:%d_%s_%s", chr, pos, ref, alt))

colnames(geno) <- var_info$variant

geno <- geno %>%
  as_tibble(rownames = "sample.id")

outfile <- "genotypes.rds"
if (nchar(argv$out_prefix) > 0) {
  outfile <- paste(argv$out_prefix, outfile, sep = "_")
}
saveRDS(geno, outfile)

outfile <- "variant_info.rds"
if (nchar(argv$out_prefix) > 0) {
  outfile <- paste(argv$out_prefix, outfile, sep = "_")
}
saveRDS(var_info, outfile)
