library(rtweet)
library(lubridate)

cur_time <- now()

with_tz(cur_time, tzone = "UTC")
with_tz(cur_time, tzone = "America/Chicago")

create_token(
  app = "tidyverse_tweets",
  consumer_key = Sys.getenv("TWITTER_CONSUMER_API_KEY"),
  consumer_secret = Sys.getenv("TWITTER_CONSUMER_API_SECRET"),
  access_token = Sys.getenv("TWITTER_ACCESS_TOKEN"),
  access_secret = Sys.getenv("TWITTER_ACCESS_TOKEN_SECRET"),
  set_renv = FALSE
)

post_tweet("test tweet")
