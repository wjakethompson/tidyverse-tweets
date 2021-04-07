library(rtweet)
library(lubridate)
library(glue)
library(tibble)

cur_time <- now()

with_tz(cur_time, tzone = "UTC")
with_tz(cur_time, tzone = "America/Chicago")

bot_token <- create_token(
  app = "tidyverse_tweets",
  consumer_key = Sys.getenv("TWITTER_CONSUMER_API_KEY"),
  consumer_secret = Sys.getenv("TWITTER_CONSUMER_API_SECRET"),
  access_token = Sys.getenv("TWITTER_ACCESS_TOKEN"),
  access_secret = Sys.getenv("TWITTER_ACCESS_TOKEN_SECRET"),
  set_renv = FALSE
)

test_num <- tibble(num = 2)

pwalk(test_num,
      .f = function(num, token) {
        status <- glue("test tweet{num}")
        post_tweet(status, token = token)
      },
      token = bot_token)
