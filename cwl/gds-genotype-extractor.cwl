cwlVersion: v1.1
class: CommandLineTool
label: GDS Genotype Extractor
doc: |-
  This tool extracts genotypes from a GDS file into an RDS file.

  The user can specify the set of samples to include and the set of variants to include in the output file.
  This tool is intended to extract a small number of variants and is not optimized to handle large numbers of variants.

  The tool produces an RDS file containing a tibble with variant info and sample genotypes.
  The first five columns give information about each variant and alternate allele:
  column | description
  --- | ---
  `variant.id` | variant identifier for this variant
  `chr` | chromosome of this variant
  `pos` | position of this variant
  `ref` | reference allele for this variant
  `alt` | alternate allele for this variant

  The remaining columns are the sample identifiers, and the contents are the dosage of the alternate allele for that sample.

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
- id: sample_include_file
  type: File?
  inputBinding:
    prefix: --sample_include_file
    position: 2
    shellQuote: false
  label: Sample include file
  doc: File containing the sample ids to include in the output file.
- id: variant_include_file
  type: File
  inputBinding:
    prefix: --variant_include_file
    position: 3
    shellQuote: false
  label: Variant include file
  doc: File containing variant ids to include in the output file.
- id: output_prefix
  type: string
  inputBinding:
    prefix: --out_prefix
    position: 4
    shellQuote: false
  label: Output file prefix.
  doc: Output file prefix. Will be appended to "_genotypes.rds".

outputs:
- id: genotype_file
  type: File?
  outputBinding:
    glob: '*.rds'
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
