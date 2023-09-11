# This will read the <cid>,<hash> CSVs from the servers and assign them to the
# other servers to download.

library(readr)
library(dplyr)

num_files_per_server=5000
num_servers=4

# Generate permutations of who downloads from whom
assignments = perms(seq(1,num_servers))
# Remove rows for which a server downloads from itself
for (i in 1:num_servers) {
  assignments = assignments[assignments[,i]!=i,]
}
# Shuffle rows
assignments = assignments[sample(nrow(assignments)),]

# Load data, assign who downloads what
all_cids <- tibble(cid=c(),sha256_hash=c(),stored_on_server=c(),to_download=c(),row_number=c())
for (i in 1:num_servers) {
  # We need to repeat the assignment a few times to get to num_files_per_server
  assignment = rep(assignments[,i],ceil(num_files_per_server/nrow(assignments)))[1:num_files_per_server]
  
  tmp = read_csv(sprintf("../data/files_server_%d.csv",i),col_types = "cc") %>%
    mutate(stored_on_server=i) %>%
    mutate(to_download=assignment) %>%
    mutate(row_number = row_number())
  
  all_cids = rbind(all_cids,tmp)
}

# Reorder
all_cids = all_cids %>%
  arrange(row_number,stored_on_server)

write_csv(all_cids,"csv/file_download_assignments.csv")

# Write per-server lists
for (i in 1:num_servers) {
  all_cids %>%
    filter(to_download==i) %>%
    mutate(stored_on_server=NULL, row_number=NULL, to_download=NULL) %>%
    write_csv(sprintf("csv/file_download_assignments_server_%d.csv",i))
}
