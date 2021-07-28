---
title: Generate test data
author: "Adrienne Stilp"
date:  "28 July, 2021"
output:
  html_document:
    toc: true
    toc_depth: 3
    keep_md: true
---



Download GDS from [TOPMed analysis_pipeline repository](https://github.com/UW-GAC/analysis_pipeline/tree/master/testdata).



# Sample include file


```r
set.seed(123)
sample_include <- sample(seqGetData(gds, "sample.id"), 1000)
saveRDS(sample_include, file = "sample_include.rds")
```

# Variant include

Choose some variants that are mono-morphic and some that are not.


```r
seqSetFilter(gds, sample.id=sample_include)
```

```
## # of selected samples: 1,000
```

```r
variant_info <- variantInfo(gds) %>%
  # Add some more info
  mutate(n_alleles = nAlleles(gds),
  af = alleleFrequency(gds),
  maf = pmin(af, 1 - af)
)
```


```r
variant_include <- c()
```

## One monomorphic variant


```r
set.seed(123)
tmp <- variant_info %>%
  filter(maf == 0, n_alleles == 2) %>%
  sample_n(1)
tmp
```

```
##   variant.id chr      pos ref alt n_alleles af maf
## 1       8090   8 23154260   A   T         2  0   0
```

```r
variant_include <- c(variant_include, tmp$variant.id)
```

## 10 polymorphic variants


```r
set.seed(123)
tmp <- variant_info %>%
  filter(maf > 0.2, n_alleles == 2) %>%
  sample_n(10)
tmp
```

```
##    variant.id chr       pos   ref alt n_alleles        af       maf
## 1        5836   6  33023946     A   G         2 0.4155000 0.4155000
## 2        6514   6 140644762     T   A         2 0.6345000 0.3655000
## 3        2644   3  69709112     C   T         2 0.4580000 0.4580000
## 4        7449   7 108341216 ATAAG   A         2 0.4710000 0.4710000
## 5        2903   3 116823483     A   G         2 0.2580000 0.2580000
## 6       12551  12  30042048     A   G         2 0.4885000 0.4885000
## 7       24689   X   4300981     C   T         2 0.7654076 0.2345924
## 8       15074  14  57245199     T   C         2 0.4710000 0.4710000
## 9       17638  16  76770939     G   C         2 0.7230000 0.2770000
## 10      16615  15  90267568     A   C         2 0.6090000 0.3910000
```

```r
variant_include <- c(variant_include, tmp$variant.id)
```

## One variant with multiple alleles


```r
set.seed(123)
tmp <- variant_info %>%
  filter(n_alleles > 2) %>%
  sample_n(1)
tmp
```

```
##   variant.id chr      pos ref          alt n_alleles    af   maf
## 1      20595  19 22124376  CT CTTT,CTTTT,C         4 0.784 0.216
```

```r
variant_include <- c(variant_include, tmp$variant.id)
```

## Combine and save


```r
variant_include <- sort(variant_include)
variant_include
```

```
##  [1]  2644  2903  5836  6514  7449  8090 12551 15074 16615 17638 20595 24689
```

```r
saveRDS(variant_include, "variant_include.rds")
```

# Clean up


```r
seqClose(gds)
```
