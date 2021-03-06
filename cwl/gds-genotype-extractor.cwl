cwlVersion: v1.1
class: CommandLineTool
label: GDS Genotype Extractor
doc: |-
  This tool extracts genotypes from a GDS file into an RDS file.

  This tool is intended to extract a small number of variants and is not optimized to handle large numbers of variants.
  The user must specify the set of variants to include in the `variant_include_file`.
  This file must be in `.rds` format and contain a vector of integer variant_id values from the GDS file for which to extract genotypes.
  The user can optionally provide a `sample_include` file to indicate a subset of samples for which to extract genotypes. If provided, it must also be in `.rds` format and contain a vector of `sample.id` values in the GDS file.

  The tool produces two RDS files.

  The first file (`variant_info.rds`) contains information about each variant included in the output, with the following columns:
  column | description
  --- | ---
  `variant.id` | variant identifier for this variant
  `chr` | chromosome of this variant
  `pos` | position of this variant
  `ref` | reference allele for this variant
  `alt` | alternate allele for this variant
  `allele.index` | index of this alternate allele in the GDS file (for multiallelic variants, 1=first alternate allele, 2=second alternate allele, etc.)
  `variant` | string identifier for this variant, also used as the column name in the  `genotypes.rds` output file.

  The second file (`genotypes.rds`) contains a tibble with sample identifiers and genotypes for each variant:
  column | description
  --- | ---
  `sample.id` | sample identifier from the GDS file
  `<variant>` | the dosage of the alternate allele for this variant. One column per requested variant.

requirements:
- class: ShellCommandRequirement
- class: DockerRequirement
  dockerPull: uwgac/topmed-master:2.10.0
- class: InlineJavascriptRequirement

inputs:
- id: gds_file
  type: File
  inputBinding:
    position: 0
    shellQuote: false
  label: GDS file
  doc: GDS file
  'sbg:fileTypes': GDS
- id: sample_include_file
  type: File?
  inputBinding:
    prefix: --sample_include_file
    position: 2
    shellQuote: false
  label: Sample include file
  doc: File containing the sample ids to include in the output file.
  'sbg:fileTypes': RDS
- id: variant_include_file
  type: File
  inputBinding:
    prefix: --variant_include_file
    position: 3
    shellQuote: false
  label: Variant include file
  doc: File containing variant ids to include in the output file.
  'sbg:fileTypes': RDS
- id: output_prefix
  type: string
  inputBinding:
    prefix: --out_prefix
    position: 4
    shellQuote: false
  label: Output file prefix.
  doc: Output file prefix. Will be appended to "_genotypes.rds" and "_variant_info.rds".

outputs:
- id: genotype_file
  type: File?
  outputBinding:
    glob: '*genotypes.rds'
- id: variant_info_file
  type: File?
  outputBinding:
    glob: '*variant_info.rds'
stdout: job.out.log

baseCommand:
- wget https://raw.githubusercontent.com/UW-GAC/cwl-gds-genotype-extractor/main/R/extract_genotypes.R
- '&&'
- R -q --vanilla --args
arguments:
- prefix: <
  position: 100
  valueFrom: extract_genotypes.R
  shellQuote: false

hints:
- class: sbg:SaveLogs
  value: '*.log'
