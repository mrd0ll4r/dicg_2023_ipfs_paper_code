

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

server_names = c("DE Server","CN Client","US Client","US Server")

# Load data

d1 = read_csv("csv/experiment_01/file_sizes.csv",col_types = "id") %>%
  filter(server <= 4) %>%
  mutate(server = factor(server,labels=server_names)) %>%
  mutate(experiment=1)

d2 = read_csv("csv/experiment_02/file_sizes.csv",col_types = "id") %>%
  filter(server <= 4) %>%
  mutate(server = factor(server,labels=server_names)) %>%
  mutate(experiment=2)

dd = d1 %>% rbind(d2)

for (experiment in c(1,2)) {
  p=dd %>%
    filter(experiment==experiment) %>%
    ggplot(aes(x = file_size, y = 1-after_stat(ecdf), group=server, color=server)) +
    stat_ecdf(pad=FALSE) +
    scale_x_continuous(
      trans="log2",
      breaks = 2^seq(2,26,2),
      labels = trans_format("log2", math_format(2 ^ .x)),
    )+
    scale_y_log10() +
    xlab("File Size (Log Scale)") +
    ylab("1-ECDF")
  
  p %>%
    print_plot(sprintf("file_sizes_loglog_ecdf_experiment_0%d", experiment))
  
  p = dd %>%
    filter(experiment==experiment) %>%
    ggplot(aes(x = file_size, group=server, color=server)) +
    stat_ecdf(pad=FALSE) +
    scale_x_continuous(
      trans="log2",
      breaks = 2^seq(2,26,2),
      labels = trans_format("log2", math_format(2 ^ .x)),
    )+
    xlab("File Size (Log Scale)") +
    ylab("ECDF")
  
  print_plot(p,sprintf("file_sizes_ecdf_experiment_0%d", experiment))
}

