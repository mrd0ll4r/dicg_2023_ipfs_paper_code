# Generates file sizes in bytes based on file size distributions as described in
# Barford, Crovella: Generating Representative Web Workloads for Network and
# Server Performance Evaluation
# https://dl.acm.org/doi/pdf/10.1145/277851.277897
#
# We configure an expected available bandwidth for downloads and uploads,
# and the interval at which files will be downloaded.
# This results in a maximum file size which is transferable within the time slot.

library(stats)
library(distributionsrd)
library(ggplot2)
library(dplyr)
library(readr)
library(tidyr)
library(scales)
library(purrr)

source("base_setup.R")
source("plot_setup.R")
source("table_setup.R")
source("tikz_setup.R")

dir.create("csv", showWarnings = FALSE, recursive = TRUE, mode = "0777")

num_entries = 2000
lnorm_cutoff = 133*1024
max_filesize = floor(1000*1000/8 * 5*60) # 1mbps in 5 minutes, in bytes

generate_file_sizes <- function(n=num_entries, cutoff=lnorm_cutoff, max_fs=max_filesize) {
  d = rlnorm(n, meanlog=9.357, sdlog=1.318)
  d = d[d < cutoff]
  d = d[1:(n*0.93)]
  d = append(d, rpareto(n, k=1.1, xmin=cutoff))
  d = floor(d)
  d = d[d <= max_fs]
  d = d[1:n]
  return(sample(d))
}

dd <- tibble( server=as.factor(c(
                      rep(1,num_entries),
                      rep(2,num_entries),
                      rep(3,num_entries),
                      rep(4,num_entries)
                    )),
              file_size=list_c(lapply(rep(num_entries, 4),generate_file_sizes))
)

dd %>%
  group_by(server) %>%
  summarize(n=n(),mean=mean(file_size), min=min(file_size), max=max(file_size), sum=sum(file_size))


write_csv(dd,file="csv/file_sizes.csv")

