library(tidyverse)
library(rvest)
library(polite)

session = polite::bow("https://www.rottentomatoes.com/")


page = polite::scrape(session)

df = tibble(
  title = page |>
    html_elements(".dynamic-text-list__streaming-links+ ul .dynamic-text-list__item-title") |>
    html_text(),
  score = page |>
    html_elements(".dynamic-text-list__streaming-links+ ul rt-text") |>
    html_text2() |>
    str_remove("%$") |>
    as.numeric(),
  certified = page |>
    html_elements(".dynamic-text-list__streaming-links+ ul score-icon-critics") |>
    html_attr("certified") |>
    str_to_upper() |>
    as.logical(),
  sentiment = page |>
    html_elements(".dynamic-text-list__streaming-links+ ul score-icon-critics") |>
    html_attr("sentiment")
) |>
  mutate(
    status = case_when(
      certified & sentiment == "positive" ~ "certified fresh",
      !certified & sentiment == "positive" ~ "fresh",
      sentiment == "negative" ~ "rotten"
    ),
    url = page |>
      html_elements(".dynamic-text-list__streaming-links+ ul a.dynamic-text-list__tomatometer-group") |>
      html_attr("href") |>
      (\(x) paste0("https://rottentomatoes.com/", x))()
  )


get_sub_page = function(url, session) {
  sub_page = polite::nod(session, url) |>
    polite::scrape()
  
  cat("Scraping", url, "\n")
  
  tibble(
    mpaa_rating = sub_page |>
      html_elements("#hero-wrap rt-text:nth-child(7)") |>
      html_text2(),
    
    popcorn_score = sub_page |>
      html_elements("rt-link~ rt-button+ rt-text") |>
      html_text() |>
      str_remove("%") |>
      as.numeric(),
    
    n_critic_scores = sub_page |>
      html_elements(".critics-score-type+ rt-link") |>
      html_text2()
  )
}


get_sub_page("https://www.rottentomatoes.com/m/the_gorge", session)
  
  
r = df |>
  mutate(
    sub_page = map(url, get_sub_page, session=session)
  )

r |> unnest_wider(sub_page)

