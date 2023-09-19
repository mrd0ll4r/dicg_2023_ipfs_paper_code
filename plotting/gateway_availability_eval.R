library(ggplot2)
library(dplyr)
library(readr)
library(tidyr)
library(scales)
library(purrr)
library(forecast)

source("base_setup.R")
source("plot_setup.R")
source("table_setup.R")
source("tikz_setup.R")

num_servers = 4
server_names = c("DE Server","CN Client","US Client","US Server")

# The expected SHA256 hash.
# a48161fca5edd15f4649bb928c10769216fccdf317265fc75d747c1e6892f53c is for the README.
# cffe75db76b4aa6463b49e330a70aaba8a8fb2830b0818a5473e899807197c1d is for the small text file.
#correct_sha256="a48161fca5edd15f4649bb928c10769216fccdf317265fc75d747c1e6892f53c"
correct_sha256="cffe75db76b4aa6463b49e330a70aaba8a8fb2830b0818a5473e899807197c1d"

# Load data
d_gateway_results <- tibble(ts=c(), gateway=c(), gateway_base64=c(), url=c(), response_code=c(), effective_url=c(), computed_sha256=c(), error=c(), machine=c())
for (i in 1:num_servers) {
  tmp = read_csv(sprintf("../data/gateways/results_server_%d.csv",i),col_types = "Tcccicc") %>%
    mutate(machine=i)
  
  d_gateway_results = rbind(d_gateway_results, tmp)
}

d_gateway_results = d_gateway_results %>%
  mutate(machine = factor(machine, labels=server_names)) %>%
  mutate(correct_result=(computed_sha256==correct_sha256))


# For reference: On 2023-09-18, the public gateway checker identified 15 gateways as working from my machine (DE).

# How many gateways are functioning for the machines?
d_gateway_results %>%
  group_by(machine) %>%
  summarize(n=n(), num_correct=sum(correct_result))

# Which gateways are functioning for all the machines?
d_gateway_results %>%
  group_by(gateway) %>%
  summarize(num_correct=sum(correct_result)) %>%
  filter(num_correct == num_servers) %>%
  select(gateway) %>%
  write_csv("csv/functioning_gateways.csv")
  




