library(lubridate)

num_servers = 4
server_names = c("DE Server","CN Client","US Client","US Server")

server_1_id = "12D3KooWQrWPQWYUJ6rLErE6HnYaeJEF5fQr3u847B7SHtqmVgK9"
server_2_id = "12D3KooWRWTPHV9cttnkSvxuYnVsarRxjgr3sAay1A1VAJKzeurM"
server_3_id = "12D3KooWBwqvPtRXoH3vsM6iq1Qy8QRNW5dKjmTc5yNYA8e97pWG"
server_4_id = "12D3KooWPXWnBsE223jex46XAPd7qjS5LFPfW3QDXc8AejynHTPA"

experiment_1_begin_ts = as.POSIXct("2023-09-09 08:38:01",tz="UTC")
experiment_1_end_ts = experiment_1_begin_ts + days(7)

experiment_2_begin_ts = as.POSIXct("2023-09-18 20:48:01", tz="UTC")
experiment_2_end_ts = experiment_2_begin_ts + days(7)

experiment_3_begin_ts = as.POSIXct("2023-09-27 16:43:01", tz="UTC")
experiment_3_end_ts = experiment_3_begin_ts + days(7)
