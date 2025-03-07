library(httr2)
library(tidyverse)

job::empty({
  library(plumber)
  plumb(file='api.R')$run(port=12121)
})

jsonlite::read_json("http://127.0.0.1:12121/data") |>
  bind_rows() |>
  View()

new_data = tibble(
  x = rnorm(10),
  y = rnorm(10),
  group = "9",
  rand = "9"
)


request("http://127.0.0.1:12121") |>
  req_url_path("data/new") |>
  req_method("post") |>
  req_body_json(new_data) |>
  req_perform()

last_response() |>
  resp_status()
last_response() |> resp_body_json()
