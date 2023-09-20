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
dd = d_gateway_results %>%
  group_by(machine) %>%
  summarize(n=n(), num_correct=sum(correct_result)) %>%
  rename(Machine=machine,Tested=n,Working=num_correct)

dd

save_tex_value(sprintf("%d",max(dd$Tested)), "gateways_num_tested")

dd %>% filter(Machine=="CN Client") %>% mutate(tmp=sprintf("%d",Working)) %>% pull(tmp) %>%
  save_tex_value("gateways_num_working_cn_client")

dd %>% filter(Machine=="DE Server") %>% mutate(tmp=sprintf("%d",Working)) %>% pull(tmp) %>%
  save_tex_value("gateways_num_working_de_server")

print(xtable(dd), file="tab/gateways_functionality_by_server.tex")


# Which gateways are functioning for all the machines?
dd = d_gateway_results %>%
  group_by(gateway) %>%
  summarize(num_correct=sum(correct_result)) %>%
  filter(num_correct == num_servers) %>%
  select(gateway)

dd

dd %>%
  rename(Gateway=gateway) %>%
  xtable() %>%
  print(file="tab/gateways_all_functional_gateways.tex")

save_tex_value(sprintf("%d", nrow(dd)), "gateways_num_functional_everywhere")

dd  %>%
  write_csv("csv/functioning_gateways.csv")



