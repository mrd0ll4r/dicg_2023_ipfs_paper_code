library(ggplot2)
library(dplyr)
library(readr)
library(tidyr)
library(scales)
library(purrr)
library(forecast)
library(forcats)

source("base_setup.R")
source("plot_setup.R")
source("table_setup.R")
source("tikz_setup.R")
source("constants.R")
source("util.R")

# Load data
d_all_downloads <-
  tibble(
    experiment = c(),
    ts = c(),
    cid = c(),
    expected_sha256 = c(),
    computed_sha256 = c(),
    downloaded_by_server = c()
  )
d_all_files <-
  tibble(
    experiment = c(),
    cid = c(),
    sha256_hash = c(),
    stored_on_server = c()
  )
for (ex in seq(1, 3)) {
  for (i in 1:num_servers) {
    tmp = read_csv(sprintf("../data/experiment_0%d/downloads_server_%d.csv", ex, i),
                   col_types = "Tccc") %>%
      mutate(downloaded_by_server = i) %>%
      mutate(experiment = ex)
    
    d_all_downloads = rbind(d_all_downloads, tmp)
    
    tmp = read_csv(sprintf("../data/experiment_0%d/files_server_%d.csv", ex, i),
                   col_types = "cc") %>%
      mutate(stored_on_server = i) %>%
      mutate(experiment = ex)
    
    d_all_files = rbind(d_all_files, tmp)
  }
}
d_all_downloads = d_all_downloads %>%
  mutate(downloaded_by_server = factor(downloaded_by_server, labels = server_names)) %>%
  filter((
    experiment == 1 &
      timestamp >= experiment_1_begin_ts &
      timestamp < experiment_1_end_ts
  ) |
    (
      experiment == 2 &
        timestamp >= experiment_2_begin_ts &
        timestamp < experiment_2_end_ts
    ) |
    (
      experiment == 3 &
        timestamp >= experiment_3_begin_ts &
        timestamp < experiment_3_end_ts
    )
  )
d_all_files = d_all_files %>%
  mutate(stored_on_server = factor(stored_on_server, labels = server_names))

# Load file size <-> sha256 mappings
d_all_generated_files = read_csv("csv/file_sizes_and_hashes.csv", col_types =
                                   "iidc") %>%
  filter(server <= num_servers) %>%
  mutate(server = factor(server, labels = server_names))

# Join that to all files, so we know how large they are
tmp = d_all_files %>%
  inner_join(d_all_generated_files,
             by = join_by(experiment, sha256_hash, stored_on_server == server))

stopifnot(nrow(tmp) == nrow(d_all_files))

d_downloads = d_all_downloads %>%
  inner_join(tmp, by = join_by(experiment, cid))

stopifnot(nrow(d_downloads) == nrow(d_all_downloads))

###########################################
# General stats

tmp = d_downloads %>% 
  group_by(experiment,downloaded_by_server) %>%
  summarize(n=n()) %>%
  group_by(experiment) %>%
  summarize(n=min(n)) %>%
  pull(n)

save_tex_value(sprintf("%d", tmp[1]), "downloads_experiment_1_num_attempted_downloads_per_machine")
save_tex_value(sprintf("%d", tmp[2]), "downloads_experiment_2_num_attempted_downloads_per_machine")

save_tex_value(sprintf("%d days",difftime(experiment_1_end_ts,experiment_1_begin_ts,units="d")),"downloads_experiment_1_duration")
save_tex_value(sprintf("%s", as.Date(experiment_1_begin_ts)), "downloads_experiment_1_begin_date")
save_tex_value(sprintf("%s", as.Date(experiment_1_end_ts)), "downloads_experiment_1_end_date")

save_tex_value(sprintf("%d days",difftime(experiment_2_end_ts,experiment_2_begin_ts,units="d")),"downloads_experiment_2_duration")
save_tex_value(sprintf("%s", as.Date(experiment_2_begin_ts)), "downloads_experiment_2_begin_date")
save_tex_value(sprintf("%s", as.Date(experiment_2_end_ts)), "downloads_experiment_2_end_date")


############################################
# Download Success Rate

for (ex in seq(1, 3)) {
  p = d_downloads %>%
    filter(experiment == ex) %>%
    group_by(experiment, downloaded_by_server, stored_on_server) %>%
    summarize(
      n = n(),
      num_success = sum(!is.na(computed_sha256)),
      success_rate = num_success / n
    ) %>%
    mutate(experiment = sprintf("Experiment %d", experiment)) %>%
    mutate(stored_on_server = fct_rev(stored_on_server)) %>%
    ggplot(aes(x = downloaded_by_server, y = stored_on_server, fill = success_rate)) +
    geom_tile(color = "black") +
    geom_label(
      aes(label = round(success_rate, 2)),
      color = "black",
      fill = "white",
      size = rel(3.5),
      label.r = unit(0, "lines")
    ) +
    coord_fixed() +
    scale_x_discrete(position = "top") +
    xlab("Downloaded By") +
    ylab("Stored On") +
    labs(fill = "Success Rate") +
    scale_fill_continuous(type = "viridis", option = "E", limits=c(0,1)) +
    theme(plot.margin=unit(c(0,0,0,0),"mm")) +
    theme(axis.text = element_text(color = "black"))
  
  print_plot(
    p,
    sprintf("downloads_success_rate_experiment_%02d", ex),
    width = 2.2,
    height = 2.2
  )
}

p = d_downloads %>%
  group_by(experiment, downloaded_by_server, stored_on_server) %>%
  summarize(
    n = n(),
    num_success = sum(!is.na(computed_sha256)),
    success_rate = num_success / n
  ) %>%
  mutate(experiment = sprintf("Experiment %d", experiment)) %>%
  mutate(stored_on_server = fct_rev(stored_on_server)) %>%
  ggplot(aes(x = downloaded_by_server, y = stored_on_server, fill = success_rate)) +
  geom_tile(color = "black") +
  geom_label(
    aes(label = round(success_rate, 2)),
    color = "black",
    fill = "white",
    size = rel(3.5),
    label.r = unit(0, "lines")
  ) +
  coord_fixed() +
  scale_x_discrete(position = "top") +
  xlab("Downloaded By") +
  ylab("Stored On") +
  labs(fill = "Success Rate") +
  facet_wrap( ~ experiment) +
  scale_fill_continuous(type = "viridis", option = "E", limits=c(0,1)) +
  theme(plot.margin=unit(c(0,0,0,0),"mm")) +
  theme(axis.text = element_text(color = "black"))

print_plot(
  p,
  "downloads_success_rate_experiment_faceted",
  width = 3.5,
  height = 2.2
)

# General success rate per experiment
t = d_downloads %>%
  group_by(experiment) %>%
  summarize(
    n=n(),
    num_success = sum(!is.na(computed_sha256)),
    success_rate = num_success/n
  )

a = function(b){b*100}

t %>%
  filter(experiment==1) %>%
  pull(n) %>%
  sprintf("$%d$",.) %>%
  save_tex_value("downloads_experiment_1_num_attempted_downloads_total")

t %>%
  filter(experiment==2) %>%
  pull(n) %>%
  sprintf("$%d$",.) %>%
  save_tex_value("downloads_experiment_2_num_attempted_downloads_total")

t %>%
  filter(experiment==1) %>%
  pull(num_success) %>%
  sprintf("$%d$",.) %>%
  save_tex_value("downloads_experiment_1_num_successful_downloads_total")

t %>%
  filter(experiment==2) %>%
  pull(num_success) %>%
  sprintf("$%d$",.) %>%
  save_tex_value("downloads_experiment_2_num_successful_downloads_total")

t %>%
  filter(experiment==1) %>%
  pull(success_rate) %>%
  a() %>%
  round() %>%
  sprintf("$\\approx %d \\%%$",.) %>%
  save_tex_value("downloads_experiment_1_success_rate_total")

t %>%
  filter(experiment==2) %>%
  pull(success_rate) %>%
  a() %>%
  round() %>%
  sprintf("$\\approx %d \\%%$",.) %>%
  save_tex_value("downloads_experiment_2_success_rate_total")


# Table of success rates per downloading server and experiment
t = d_downloads %>%
  group_by(experiment, downloaded_by_server) %>%
  summarize(
    n = n(),
    num_success = sum(!is.na(computed_sha256)),
    success_rate = num_success / n
  ) %>%
  pivot_wider(
    names_from = experiment,
    values_from = all_of(c("n", "num_success","success_rate")),
    names_vary = "slowest"
  )

addtorow <- list()
addtorow$pos = list(0)
addtorow$command = "& \\multicolumn{3}{c}{Experiment 1} & \\multicolumn{3}{c}{Experiment 2} \\\\
  \\cmidrule(lr){2-4} \\cmidrule(lr){5-7}
  Downloaded By & $n$ & Succ. & Rate & $n$ & Succ. & Rate \\\\"

print(
  xtable(t, digits = 2),
  file = "tab/downloads_n_success_rates_by_downloading_machine.tex",
  add.to.row = addtorow,
  include.colnames = F
)

# Success rate per downloading machine per experiment, 8 values
a = function(b){b*100}
t %>%
  filter(downloaded_by_server == "DE Server") %>%
  pull(success_rate_1) %>%
  a() %>%
  round() %>%
  sprintf("$\\approx %d \\%%$",.) %>%
  save_tex_value("downloads_experiment_1_downloaded_by_de_server_success_rate")

t %>%
  filter(downloaded_by_server == "DE Server") %>%
  pull(success_rate_2) %>%
  a() %>%
  round() %>%
  sprintf("$\\approx %d \\%%$",.) %>%
  save_tex_value("downloads_experiment_2_downloaded_by_de_server_success_rate")

t %>%
  filter(downloaded_by_server == "US Server") %>%
  pull(success_rate_1) %>%
  a() %>%
  round() %>%
  sprintf("$\\approx %d \\%%$",.) %>%
  save_tex_value("downloads_experiment_1_downloaded_by_us_server_success_rate")

t %>%
  filter(downloaded_by_server == "US Server") %>%
  pull(success_rate_2) %>%
  a() %>%
  round() %>%
  sprintf("$\\approx %d \\%%$",.) %>%
  save_tex_value("downloads_experiment_2_downloaded_by_us_server_success_rate")

t %>%
  filter(downloaded_by_server == "US Client") %>%
  pull(success_rate_1) %>%
  a() %>%
  round() %>%
  sprintf("$\\approx %d \\%%$",.) %>%
  save_tex_value("downloads_experiment_1_downloaded_by_us_client_success_rate")

t %>%
  filter(downloaded_by_server == "US Client") %>%
  pull(success_rate_2) %>%
  a() %>%
  round() %>%
  sprintf("$\\approx %d \\%%$",.) %>%
  save_tex_value("downloads_experiment_2_downloaded_by_us_client_success_rate")

t %>%
  filter(downloaded_by_server == "CN Client") %>%
  pull(success_rate_1) %>%
  a() %>%
  round() %>%
  sprintf("$\\approx %d \\%%$",.) %>%
  save_tex_value("downloads_experiment_1_downloaded_by_cn_client_success_rate")

t %>%
  filter(downloaded_by_server == "CN Client") %>%
  pull(success_rate_2) %>%
  a() %>%
  round() %>%
  sprintf("$\\approx %d \\%%$",.) %>%
  save_tex_value("downloads_experiment_2_downloaded_by_cn_client_success_rate")


# Table of success rates per storing server and experiment
t = d_downloads %>%
  group_by(experiment, stored_on_server) %>%
  summarize(
    n = n(),
    num_success = sum(!is.na(computed_sha256)),
    success_rate = num_success / n
  ) %>%
  pivot_wider(
    names_from = experiment,
    values_from = all_of(c("n", "num_success","success_rate")),
    names_vary = "slowest"
  )

addtorow <- list()
addtorow$pos = list(0)
addtorow$command = "& \\multicolumn{3}{c}{Experiment 1} & \\multicolumn{3}{c}{Experiment 2} \\\\
  \\cmidrule(lr){2-4} \\cmidrule(lr){5-7}
  Stored On & $n$ & Succ. & Rate & $n$ & Succ. & Rate \\\\"

print(
  xtable(t, digits = 2),
  file = "tab/downloads_n_success_rates_by_storing_machine.tex",
  add.to.row = addtorow,
  include.colnames = F
)

# Success rate per storing machine per experiment, 8 values
a = function(b){b*100}
t %>%
  filter(stored_on_server == "DE Server") %>%
  pull(success_rate_1) %>%
  a() %>%
  round() %>%
  sprintf("$\\approx %d \\%%$",.) %>%
  save_tex_value("downloads_experiment_1_stored_on_de_server_success_rate")

t %>%
  filter(stored_on_server == "DE Server") %>%
  pull(success_rate_2) %>%
  a() %>%
  round() %>%
  sprintf("$\\approx %d \\%%$",.) %>%
  save_tex_value("downloads_experiment_2_stored_on_de_server_success_rate")

t %>%
  filter(stored_on_server == "US Server") %>%
  pull(success_rate_1) %>%
  a() %>%
  round() %>%
  sprintf("$\\approx %d \\%%$",.) %>%
  save_tex_value("downloads_experiment_1_stored_on_us_server_success_rate")

t %>%
  filter(stored_on_server == "US Server") %>%
  pull(success_rate_2) %>%
  a() %>%
  round() %>%
  sprintf("$\\approx %d \\%%$",.) %>%
  save_tex_value("downloads_experiment_2_stored_on_us_server_success_rate")

t %>%
  filter(stored_on_server == "US Client") %>%
  pull(success_rate_1) %>%
  a() %>%
  round() %>%
  sprintf("$\\approx %d \\%%$",.) %>%
  save_tex_value("downloads_experiment_1_stored_on_us_client_success_rate")

t %>%
  filter(stored_on_server == "US Client") %>%
  pull(success_rate_2) %>%
  a() %>%
  round() %>%
  sprintf("$\\approx %d \\%%$",.) %>%
  save_tex_value("downloads_experiment_2_stored_on_us_client_success_rate")

t %>%
  filter(stored_on_server == "CN Client") %>%
  pull(success_rate_1) %>%
  a() %>%
  round() %>%
  sprintf("$\\approx %d \\%%$",.) %>%
  save_tex_value("downloads_experiment_1_stored_on_cn_client_success_rate")

t %>%
  filter(stored_on_server == "CN Client") %>%
  pull(success_rate_2) %>%
  a() %>%
  round() %>%
  sprintf("$\\approx %d \\%%$",.) %>%
  save_tex_value("downloads_experiment_2_stored_on_cn_client_success_rate")


########################################
# Download Success Rate Over Time

d_downloads %>%
  group_by(experiment) %>%
  filter(downloaded_by_server == "CN Client") %>%
  mutate(successful_download = !is.na(computed_sha256)) %>%
  mutate(
    cid = NULL,
    expected_sha256 = NULL,
    computed_sha256 = NULL,
    sha256_hash = NULL
  ) %>%
  mutate(slice = cut(timestamp, breaks = "4 hour")) %>%
  group_by(experiment, slice, stored_on_server) %>%
  summarize(
    n = n(),
    num_success = sum(successful_download),
    success_rate = num_success / n
  ) %>%
  mutate(slice = as.POSIXlt(slice)) %>%
  ggplot(aes(
    x = slice,
    y = success_rate,
    group = stored_on_server,
    color = stored_on_server
  )) +
  geom_line() +
  #geom_smooth() +
  scale_x_datetime(date_breaks = "1 day") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  ggtitle("Success Rate of Downloads Performed by CN Client") +
  xlab("Date") +
  ylab("Success Rate") +
  facet_wrap( ~ experiment, scales = "free_x")

d_downloads %>%
  group_by(experiment) %>%
  filter(stored_on_server == "CN Client") %>%
  mutate(successful_download = !is.na(computed_sha256)) %>%
  mutate(
    cid = NULL,
    expected_sha256 = NULL,
    computed_sha256 = NULL,
    sha256_hash = NULL
  ) %>%
  mutate(slice = cut(timestamp, breaks = "4 hour")) %>%
  group_by(experiment, slice, downloaded_by_server) %>%
  summarize(
    n = n(),
    num_success = sum(successful_download),
    success_rate = num_success / n
  ) %>%
  mutate(slice = as.POSIXlt(slice)) %>%
  ggplot(
    aes(
      x = slice,
      y = success_rate,
      group = downloaded_by_server,
      color = downloaded_by_server
    )
  ) +
  geom_line() +
  #geom_smooth() +
  scale_x_datetime(date_breaks = "1 day") +
  theme(axis.text.x = element_text( angle = 45, hjust = 1)) +
  ggtitle("Success Rate of Downloads of Files Stored on CN Client") +
  facet_wrap( ~ experiment, scale = "free_x")


##################################
# File Size Analysis

for (ex in seq(1, 2)) {
  dd = d_downloads %>%
    filter(experiment == ex) %>%
    mutate(successful = !is.na(computed_sha256)) %>%
    mutate(timestamp = NULL,
           cid = NULL,
           sha256_hash = NULL)
  
  dd2 = dd %>%
    filter(successful) %>%
    mutate(status = "success")
  
  dd2 = dd2 %>% rbind(dd %>% mutate(status = "all"))
  
  p = dd2 %>%
    ggplot(aes(
      x = file_size,
      group = status,
      linetype = status
    )) +
    stat_ecdf(pad = FALSE) +
    scale_x_continuous(
      trans = "log2",
      breaks = 2 ^ seq(2, 26, 2),
      labels = trans_format("log2", math_format(2 ^ .x)),
    ) +
    xlab("File Size (Log Scale)") +
    ylab("ECDF") +
    facet_wrap( ~ downloaded_by_server)
  
  p %>%
    print_plot(
      sprintf(
        "downloads_file_sizes_ecdf_by_status_server_faceted_experiment_0%d",
        ex
      )
    )
  
  p = dd2 %>%
    ggplot(aes(
      x = file_size,
      y = 1 - after_stat(ecdf),
      group = status,
      linetype = status
    )) +
    stat_ecdf(pad = FALSE) +
    scale_x_continuous(
      trans = "log2",
      breaks = 2 ^ seq(2, 26, 2),
      labels = trans_format("log2", math_format(2 ^ .x)),
    ) +
    scale_y_log10() +
    xlab("File Size (Log Scale)") +
    ylab("1-ECDF") +
    facet_wrap( ~ downloaded_by_server)
  
  p %>%
    print_plot(
      sprintf(
        "downloads_file_sizes_loglog_ecdf_by_status_server_faceted_experiment_0%d",
        ex
      )
    )
}



################################
# Time series analysis
d_downloads %>%
  filter(stored_on_server == "CN Client") %>%
  mutate(successful_download = !is.na(computed_sha256)) %>%
  mutate(
    cid = NULL,
    expected_sha256 = NULL,
    computed_sha256 = NULL,
    sha256_hash = NULL
  ) %>%
  mutate(slice = cut(timestamp, breaks = "hour")) %>%
  group_by(slice, downloaded_by_server) %>%
  summarize(
    n = n(),
    num_success = sum(successful_download),
    success_rate = num_success / n
  ) %>%
  mutate(slice = as.POSIXlt(slice)) %>%
  filter(downloaded_by_server == "DE Server") %>%
  pull(success_rate) %>%
  findfrequency()

# nope :(

d_downloads %>%
  filter(downloaded_by_server == "CN Client") %>%
  mutate(successful_download = !is.na(computed_sha256)) %>%
  mutate(
    cid = NULL,
    expected_sha256 = NULL,
    computed_sha256 = NULL,
    sha256_hash = NULL
  ) %>%
  mutate(slice = cut(timestamp, breaks = "hour")) %>%
  group_by(slice, stored_on_server) %>%
  summarize(
    n = n(),
    num_success = sum(successful_download),
    success_rate = num_success / n
  ) %>%
  mutate(slice = as.POSIXlt(slice)) %>%
  filter(stored_on_server == "US Client") %>%
  pull(success_rate) %>%
  findfrequency()

# nope :(
