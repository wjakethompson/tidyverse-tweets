### Setup ----------------------------------------------------------------------
needed_packages <- c("devtools", "tidyverse", "glue", "lubridate", "stackr",
  "rtweet")
load_packages <- function(x) {
  if (!(x %in% rownames(installed.packages()))) {
    if (x == "stackr") {
      devtools::install_github("dgrtwo/stackr")
    } else {
      install.packages(x, repos = "https://cran.rstudio.com/")
    }
  }
  suppressPackageStartupMessages(require(x, character.only = TRUE))
}
vapply(needed_packages, load_packages, TRUE)


### Query Stackoverflow API ----------------------------------------------------
tidy_so <- stack_questions(pagesize = 100, tagged = "tidyverse") %>%
  select(title, creation_date, link) %>%
  mutate(creation_date = ymd_hms(creation_date)) %>%
  arrange(desc(creation_date)) %>%
  filter(creation_date > ymd_hms(Sys.time()) - dminutes(5)) %>%
  as.list()

pwalk(.l = tidy_so, .f = function(title, creation_date, link) {
  tweet_text <- glue("{title} #tidyverse #rstats {link}")
  post_tweet(tweet_text)
})
