library(ggplot2)
library(dplyr)
library(readr)
library(tidyr)
library(scales)
library(purrr)
library(forcats)
library(ggpattern)

source("base_setup.R")
source("plot_setup.R")
source("table_setup.R")
source("tikz_setup.R")
source("constants.R")
source("util.R")


# Load data
d_peers = tibble(peers = c(),
                 timestamp = c(),
                 server = c())
for (server in seq(1, num_servers)) {
  timestamps = Sys.glob(sprintf("../data/peer_lists/server_%d/*.peers", server)) %>%
    sort() %>%
    substr(start = 29, stop = 38)
  
  all_peers = tibble(remote = c(), timestamp = c())
  
  for (ts in timestamps) {
    peers = read_csv(
      sprintf("../data/peer_lists/server_%d/%s.peers", server, ts),
      col_names = c("remote"),
      col_types = "c"
    )
    pretty_ts = read_csv(
      sprintf("../data/peer_lists/server_%d/%s.ts", server, ts),
      col_names = c("timestamp"),
      col_types = "T"
    )
    
    peers = peers %>%
      mutate(timestamp = pretty_ts %>% pull(timestamp))
    
    all_peers = all_peers %>% rbind(peers)
  }
  
  all_peers = all_peers %>%
    mutate(server = server)
  
  d_peers = d_peers %>% rbind(all_peers)
}

d_peers = d_peers %>%
  mutate(server = factor(server, labels = server_names)) %>%
  mutate(experiment = case_when(
    timestamp >= experiment_1_begin_ts &
      timestamp < experiment_1_end_ts ~ 1,
    timestamp >= experiment_2_begin_ts &
      timestamp < experiment_2_end_ts ~ 2,
    timestamp >= experiment_3_begin_ts &
      timestamp < experiment_3_end_ts ~ 3
  )) %>%
  filter(!is.na(experiment))

#########################################
# Number of connections over time

# Compute axis ticks and breaks, taking into account the two horizontal lines.
breaks = sort(c(c(32, 96), with(
  d_peers %>% group_by(server, timestamp) %>%
    summarize(n = n())
  ,
  pretty(range(n))
)))
minor_breaks = with(d_peers %>% group_by(server, timestamp) %>%
                      summarize(n = n())
                    ,
                    pretty(range(n)))
minor_breaks = minor_breaks - (minor_breaks[2] - minor_breaks[1]) / 2

p = d_peers %>%
  group_by(server, timestamp, experiment) %>%
  summarize(n = n()) %>%
  ggplot(aes(
    x = timestamp,
    y = n,
    color = server,
    linetype = server
  )) +
  geom_line() +
  geom_hline(yintercept = 32, show.legend = FALSE) +
  geom_hline(yintercept = 96, show.legend = FALSE) +
  facet_wrap(~experiment) +
  ylab("Peers") +
  xlab("Date (UTC)") +
  scale_x_datetime(date_breaks = "1 day") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  scale_y_continuous(breaks = breaks,
                     #limits=range(breaks),
                     minor_breaks = minor_breaks) +
  labs(group = NULL,
       color = NULL,
       linetype = NULL)

print_plot(p, "peers_num_peers_over_time")


######################################
# Mean number of connections

dd = d_peers %>%
  filter(experiment == 2) %>%
  group_by(server, timestamp) %>%
  summarize(n = n()) %>%
  summarize(mean = mean(n), stddev = std(n))

dd %>%
  rename(Server = server, Mean = mean, SD = stddev) %>%
  mutate(SD = sprintf("±%.1f", SD)) %>%
  mutate(Mean = sprintf("%.1f", Mean)) %>%
  xtable() %>%
  print(file = "tab/peers_num_peers_by_server.tex")

dd %>%
  filter(server == "DE Server") %>%
  mutate(mean = sprintf("$%d$", round(mean))) %>%
  pull(mean) %>%
  save_tex_value("peers_num_peers_de_server_mean")

dd %>%
  filter(server == "US Server") %>%
  mutate(mean = sprintf("$%d$", round(mean))) %>%
  pull(mean) %>%
  save_tex_value("peers_num_peers_us_server_mean")

dd %>%
  filter(server == "US Client") %>%
  mutate(mean = sprintf("$%d$", round(mean))) %>%
  pull(mean) %>%
  save_tex_value("peers_num_peers_us_client_mean")

dd %>%
  filter(server == "CN Client") %>%
  mutate(mean = sprintf("$%d$", round(mean))) %>%
  pull(mean) %>%
  save_tex_value("peers_num_peers_cn_client_mean")

######################################
# Share of protocols

dd = d_peers %>%
  filter(experiment == 2) %>%
  mutate(
    quic_v1 = grepl("quic-v1", remote, fixed = TRUE),
    quic = grepl("quic", remote, fixed = TRUE),
    tcp = grepl("tcp", remote, fixed = TRUE)
  ) %>%
  mutate(protocol = ifelse(quic, "QUIC", "TCP")) %>%
  group_by(server, timestamp, protocol) %>%
  summarize(n = n()) %>%
  group_by(server, protocol) %>%
  summarize(mean = mean(n), stddev = std(n)) %>%
  mean_to_share()

p = dd %>%
  mutate(protocol = fct_rev(protocol)) %>%
  ggplot(aes(y = server, x = share, pattern = protocol)) +
  geom_bar_pattern(
    #aes(
    #  pattern = class,
    #  pattern_angle = class
    #),
    fill            = 'white',
    colour          = 'black',
    #pattern_density = 0.02,
    pattern_fill    = 'white',
    pattern_colour  = 'black',
    stat = "identity",
    #position="dodge2"
  ) +
  #scale_pattern_spacing_discrete(range = c(0.04, 0.08)) +
  #scale_pattern_angle_discrete(range = c(0,500)) +
  ylab(NULL) +
  xlab("Share") +
  labs(pattern = "Protocol")

print_plot(p, "peers_protocol_share_by_server", width = 3.5, height=1.2)

##################################
# Connections between servers

d =   d_peers %>%
  filter(experiment == 2) %>%
  mutate(
    remote_is_server_1 = grepl(server_1_id, remote, fixed = TRUE),
    remote_is_server_2 = grepl(server_2_id, remote, fixed = TRUE),
    remote_is_server_3 = grepl(server_3_id, remote, fixed = TRUE),
    remote_is_server_4 = grepl(server_4_id, remote, fixed = TRUE),
  ) %>%
  group_by(timestamp, server) %>%
  summarize(
    n = n(),
    connected_to_server_1 = any(remote_is_server_1),
    connected_to_server_2 = any(remote_is_server_2),
    connected_to_server_3 = any(remote_is_server_3),
    connected_to_server_4 = any(remote_is_server_4),
  ) %>%
  pivot_longer(
    cols = starts_with("connected_to_server"),
    names_to = "connected_to",
    values_to = "connection"
  ) %>%
  mutate(connected_to = substr(connected_to, 21, 22)) %>%
  mutate(connected_to = factor(connected_to, labels = server_names)) %>%
  group_by(server, connected_to) %>%
  summarize(n = n(), num_connections = sum(connection)) %>%
  mutate(share = num_connections / n) %>%
  arrange(server) %>%
  group_by(server) %>%
  filter(row_number() >= which(server == connected_to)) %>%
  filter(server != connected_to)

p = d %>%
  ggplot(aes(x=server, y=connected_to, fill=share)) +
  geom_tile(color = "black") +
  geom_label(
    aes(label = round(share, 2)),
    color = "black",
    fill = "white",
    label.r = unit(0, "lines"),
    size = rel(2.5),
    label.padding = unit(0.125, "lines")
  ) +
  coord_fixed() +
  scale_x_discrete(position = "top") +
  xlab(NULL) +
  ylab(NULL) +
  labs(fill = "Connectivity") +
  scale_fill_continuous(type = "viridis", option = "E", limits=c(0,1)) +
  theme_bw(9) +
  theme(plot.margin=unit(c(0,0,0,0),"mm")) +
  theme(axis.text.x = element_text(angle=-30, hjust=1)) +
  theme(axis.text = element_text(color = "black")) +
  theme(legend.position = "right") +
  theme(legend.key.width = unit(0.3, 'cm'),
        legend.key.height = unit(0.4, "cm"))

print_plot(p,"peers_connectivity_between_servers", width=3, height=1.5)

# TODO join this with the download assignments to see if a pair was connected before attempting a download.
# 
# d_peers %>%
#   mutate(
#     remote_is_server_1 = grepl(server_1_id, remote, fixed = TRUE),
#     remote_is_server_2 = grepl(server_2_id, remote, fixed = TRUE),
#     remote_is_server_3 = grepl(server_3_id, remote, fixed = TRUE),
#     remote_is_server_4 = grepl(server_4_id, remote, fixed = TRUE),
#   ) %>%
#   group_by(timestamp, server) %>%
#   summarize(
#     n = n(),
#     connected_to_server_1 = any(remote_is_server_1),
#     connected_to_server_2 = any(remote_is_server_2),
#     connected_to_server_3 = any(remote_is_server_3),
#     connected_to_server_4 = any(remote_is_server_4),
#   ) %>%
#   group_by(timestamp, server) %>%
#   summarize(
#     n=min(n),
#     connected_to_any = any(connected_to_server_1, connected_to_server_2, connected_to_server_3),
#     connected_to_all = all(connected_to_server_1, connected_to_server_2, connected_to_server_3)
#     ) %>%
#   ungroup() %>%
#   #group_by(server) %>%
#   summarize(
#     n=n(),
#     connected_to_any_share = sum(connected_to_any)/n(),
#     connected_to_all_share = sum(connected_to_all)/n()
#     )


