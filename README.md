# CWL GDS Genotype Extractor

Script and CWL to extract genotypes from a GDS file into an RDS file.

The CWL scripts were developed on the [BioData Catalyst Powered by Seven Bridges](https://platform.sb.biodatacatalyst.nhlbi.nih.gov/) platform, as a collaboration between the UW GAC and Seven Bridges developers. Workflows are composed of tools that wrap R scripts.

Tools require the [uwgac/topmed-master docker image](https://hub.docker.com/r/uwgac/topmed-master).

Interact with workflows on the [BioData Catalyst Powered by Seven
Bridges](https://platform.sb.biodatacatalyst.nhlbi.nih.gov/) platform
using [sbpack](https://github.com/rabix/sbpack).

## Running the R script directly

Example:

```
R --no-save --args \
  testdata/1KG_phase3_subset.gds \
  --variant_include_file testdata/variant_include.rds \
  --sample_include_file testdata/sample_include.rds \
  --out_prefix test \
  < R/extract_genotypes.R
```
