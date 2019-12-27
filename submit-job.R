# cron job
# */5 * * * * cd tidyverse-tweets && chmod +x submit-job.sh && submit-job.sh

library(readr)
library(glue)

active_jobs <- read_delim(system2("squeue", "-u w449t405", stdout = TRUE),
                          delim = " ", trim_ws = TRUE)

if (!("tidytwee" %in% active_jobs$NAME)) {
  system2("sbatch", "tweet-job.sh")
}
