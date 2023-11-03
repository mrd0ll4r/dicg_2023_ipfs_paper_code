# R Scripts for Data Generation and Evaluation

This directory contains R scripts used to generate data and, later, evaluate results.

## Scripts and Functionalities

### Reproducibility

We use [renv](https://rstudio.github.io/renv/articles/renv.html) to lock dependency versions.
Install `renv` and restart your R session in the current directory for this to work.

### Framework, Utility Functions, Constants

- `util.R` contains utility functions
- `table_setup.R`: utilities and setup to produce `xtable` tables
- `tikz_setup.R`: utilities and setup to produce nice `tikz` figures
- `plot_setup.R`: utilities for producing figures
- `base_setup.R`: utilities for producing value `.tex` files etc.
- `constants.R`: various constants, such as time ranges, peer IDs, etc.

### Data Generation

- `gen_filesizes.R` generates file sizes (in bytes) following a predetermined distribution.
- `gen_download_lists.R` generates a schedule for each node to download content off one other node at a point in time.

### Evaluation

- `file_size_eval.R` evaluates the generated file sizes and produces figures of their distributions.
- `gateway_availability_eval.R` evaluates results of the gateway availability experiment.
- `download_eval.R` evaluates download success rates.
- `peer_eval.R` evaluates peer lists and computes node interconnectivity.

### Input/Output

Input is generally read from `../data/` or `csv/`.
Output is generally produced to `csv/`, `fig/` (for figures), `tab/` (for tables), and `val/` (for values).
