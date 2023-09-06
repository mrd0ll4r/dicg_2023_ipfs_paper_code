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

generate_file_sizes <- function(n=num_entries, cutoff=lnorm_cutoff) {
  d = rlnorm(n, meanlog=9.357, sdlog=1.318)
  d = d[d < cutoff]
  d = d[1:(n*0.93)]
  d = append(d, rpareto(n-length(d), k=1.1, xmin=cutoff))
  d = floor(d)
  return(sample(d))
}

dd <- tibble(server=as.factor(c(rep(1,num_entries),rep(2,num_entries),rep(3,num_entries))),
             file_size=list_c(lapply(rep(num_entries,3),generate_file_sizes))
             )

write_csv(dd,file="csv/file_sizes.csv")

dd %>%
  group_by(server) %>%
  summarize(mean=mean(file_size), min=min(file_size), max=max(file_size), sum=sum(file_size))

p = ggplot(dd, aes(x = file_size, y = 1-after_stat(ecdf), group=server, color=server)) +
  stat_ecdf(pad=FALSE) +
  scale_x_continuous(
    trans="log2",
    breaks = 2^seq(2,26,2),
    labels = trans_format("log2", math_format(2 ^ .x)),
  )+
  scale_y_log10() +
  xlab("File Size (Log Scale)") +
  ylab("1-ECDF")

print_plot(p,"file_sizes_loglog_ecdf")

p = ggplot(dd, aes(x = file_size, group=server, color=server)) +
  stat_ecdf(pad=FALSE) +
  scale_x_continuous(
    trans="log2",
    breaks = 2^seq(2,26,2),
    labels = trans_format("log2", math_format(2 ^ .x)),
  )+
  xlab("File Size (Log Scale)") +
  ylab("ECDF")

print_plot(p,"file_sizes_ecdf")


