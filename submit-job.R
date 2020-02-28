# cron job
# */5 * * * * cd tidyverse-tweets && chmod +x submit-job.sh && bash submit-job.sh

library(readr)
library(purrr)
library(glue)

safe_read_delim <- safely(read_delim)

active_jobs <- safe_read_delim(system2("squeue", "-u w449t405", stdout = TRUE),
                               delim = " ", trim_ws = TRUE)

if (is.null(active_jobs$result)) {
  system2("sbatch", "tweet-job.sh")
} else {
  if (!("tidytwee" %in% active_jobs$NAME)) {
    system2("sbatch", "tweet-job.sh")
  }
}
