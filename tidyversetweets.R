### Setup ----------------------------------------------------------------------
library(tidyverse)
library(glue)
library(lubridate)
library(stackr)
library(rtweet)


### Query Stackoverflow API ----------------------------------------------------
safe_query <- safely(stack_questions)
query_tag <- function(tag) {
  query <- safe_query(pagesize = 100, tagged = tag)
}

tidyverse <- c("tidyverse", "ggplot2", "dplyr", "tidyr", "readr", "purrr",
  "tibble", "readxl", "haven", "jsonlite", "xml2", "httr", "rvest", "DBI",
  "stringr", "lubridate", "forcats", "hms", "blob;r", "rlang", "magrittr",
  "glue", "recipes", "rsample", "modelr")

Sys.setenv(TZ = "America/Chicago")
cur_time <- ymd_hms(Sys.time(), tz = Sys.timezone())

tidy_so <- map(tidyverse, query_tag) %>%
  map_dfr(~(.$result %>% as.tibble())) %>%
  select(title, creation_date, link) %>%
  distinct() %>%
  mutate(creation_date = ymd_hms(creation_date)) %>%
  arrange(desc(creation_date)) %>%
  filter(creation_date > cur_time - dminutes(5)) %>%
  as.list()

pwalk(.l = tidy_so, .f = function(title, creation_date, link) {
  if (nchar(title) > 250) {
    trunc_points <- str_locate_all(title, " ") %>%
      .[[1]] %>%
      .[,1]
    trunc <- max(trunc_points[which(trunc_points < 247)]) - 1
    title <- paste0(str_sub(title, start = 1, end = trunc), "...")
  }
  
  tweet_text <- glue("{title} #tidyverse #rstats {link}")
  post_tweet(tweet_text)
})
