### Setup ----------------------------------------------------------------------
library(glue)
library(lubridate)
library(stackr)
library(feedeR)
library(rtweet)
library(purrr)
library(tibble)
library(dplyr)
library(stringr)


### Functions ------------------------------------------------------------------
fix_special <- function(x) {
  ints <- utf8ToInt(x)
  
  # remove arrows
  arrow <- which(ints == 10132L)
  for (i in seq_along(arrow)) {
    ints <- c(ints[1:(arrow[i] - 1)], 45L, 62L,
              ints[(arrow[i] + 1):length(ints)])
  }
  
  intToUtf8(ints)
}


### Query Stackoverflow API ----------------------------------------------------
safe_query <- safely(stack_questions)
query_tag <- function(tag) {
  query <- safe_query(pagesize = 100, tagged = tag)
  return(query)
}

Sys.setenv(STACK_EXCHANGE_KEY = "OX0Slpm1*EXldYd5wMEH8g((")

tidyverse <- c("tidyverse", "ggplot2", "dplyr", "tidyr", "readr", "purrr",
               "tibble", "readxl", "haven", "jsonlite", "xml2", "httr", "rvest",
               "DBI;r", "stringr", "lubridate", "forcats", "hms;r", "blob;r",
               "rlang", "magrittr", "glue", "recipes", "rsample", "modelr",
               "r-markdown", "bookdown", "blogdown", "xaringan")

tidy_so <- map(tidyverse, query_tag) %>%
  map_dfr(~(.$result %>% as_tibble())) %>%
  select(title, creation_date, link) %>%
  mutate(
    title = str_replace_all(title, "&#39;", "'"),
    title = str_replace_all(title, "&quot;", '"'),
    title = str_replace_all(title, "&amp;&#160;", "& "),
    title = str_replace_all(title, "&gt;", ">"),
    title = str_replace_all(title, "&lt;", "<"),
    title = str_replace_all(title, "&amp;", "&"),
    title = str_replace_all(title, "&#180;", "`"),
    title = str_replace_all(title, "&#181;", "\u03bc"),
    title = str_replace_all(title, "&#231;", "\u00e7"),
    title = str_replace_all(title, "&#250;", "\u00fa"),
    title = str_replace_all(title, "&#233;", "\u00e9")
  ) %>%
  distinct() %>%
  mutate(creation_date = with_tz(creation_date, tzone = "UTC")) %>%
  arrange(creation_date)


### Query RStudio Community ----------------------------------------------------
query_community <- function(category) {
  query <- feed.extract(glue("https://community.rstudio.com/c/{category}.rss"))
  return(query)
}

rstudio <- c("tidyverse", "teaching", "general", "R-Markdown", "shiny",
             "package-development", "ml")

tidy_rc <- map(rstudio, query_community) %>%
  map_dfr(~(.$items %>% as_tibble())) %>%
  select(title, creation_date = date, link) %>%
  mutate(
    title = str_replace_all(title, "\u2018|\u2019", "'"),
    title = map_chr(title, fix_special)
  ) %>%
  mutate(creation_date = with_tz(creation_date, tzone = "UTC")) %>%
  group_by(title) %>%
  slice_min(order_by = creation_date, n = 1) %>%
  arrange(creation_date)


### Tweet ----------------------------------------------------------------------
bot_token <- create_token(
  app = "tidyverse_tweets",
  consumer_key = Sys.getenv("TWITTER_CONSUMER_API_KEY"),
  consumer_secret = Sys.getenv("TWITTER_CONSUMER_API_SECRET"),
  access_token = Sys.getenv("TWITTER_ACCESS_TOKEN"),
  access_secret = Sys.getenv("TWITTER_ACCESS_TOKEN_SECRET"),
  set_renv = FALSE
)

last_tweet <- get_timeline("tidyversetweets", n = 100) %>%
  slice_max(order_by = created_at, n = 1) %>%
  pull(created_at) %>%
  with_tz(tzone = "UTC")

all_update <- bind_rows(tidy_so, tidy_rc) %>%
  arrange(creation_date) %>%
  filter(creation_date > last_tweet)

pwalk(all_update, .f = function(title, creation_date, link) {
  if (nchar(title) > 250) {
    trunc_points <- str_locate_all(title, " ") %>%
      .[[1]] %>%
      .[,1]
    trunc <- max(trunc_points[which(trunc_points < 247)]) - 1
    title <- paste0(str_sub(title, start = 1, end = trunc), "...")
  }
  
  tweet_text <- glue("{title} #tidyverse #rstats {link}")
  post_tweet(tweet_text, token = bot_token)
})
