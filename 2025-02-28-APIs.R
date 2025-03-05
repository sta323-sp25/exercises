library(tidyverse)
library(httr2)

## Demo 1 ----

### Get user information

read_file("https://api.github.com/users/rundel")

jsonlite::read_json("https://api.github.com/users/rundel") |>
  View()

### Org repos

jsonlite::read_json("https://api.github.com/orgs/sta323-sp25/repos") |>
  View()

jsonlite::read_json("https://api.github.com/orgs/tidyverse/repos?per_page=100") |>
  View()

jsonlite::read_json("https://api.github.com/orgs/r-lib/repos?per_page=200&page=2") |>
  View()


### Information about myself

jsonlite::read_json("https://api.github.com/user")

## Demo 2 ----


library(httr2)

### Get user info

request("https://api.github.com") |>
  req_url_path("users/rundel") |>
  req_perform()

last_response() |>
  resp_status()

last_response() |>
  resp_body_json() |>
  View()


### Get user information

request("https://api.github.com") |>
  req_url_path("user") |>
  req_auth_bearer_token(gitcreds::gitcreds_get()$password) |>
  req_perform()

last_response() |>
  resp_body_json() |>
  View()

### Get all org repos

request("https://api.github.com") |>
  req_url_path("orgs/sta323-sp25/repos") |>
  req_url_query(per_page=100) |>
  req_auth_bearer_token(gitcreds::gitcreds_get()$password) |>
  req_perform() 

last_response() |>
  resp_body_json() |>
  View()


### Create a gist


z = request("https://api.github.com") |>
  req_url_path("gists") |>
  req_body_json(
    list(
      description = "Testing 1,2,3,...",
      files = list(
        "test.R" = list(
          content = 'print("Hello world!")\n1+1\n'
        ),
        "README.md" = list(
          content = 'This is the readme!\n'
        )
      ),
      public = TRUE
    )
  ) |>
  req_perform()

View(z)
resp_body_json(z)
