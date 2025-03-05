library(rvest)
library(tidyverse)
library(httr2)

## Scraping LQ locations page

state.abb
state.name

## Fixing LQ page encoding

read_file("https://www.wyndhamhotels.com/laquinta/durham-north-carolina/la-quinta-raleigh-durham-southpoint/overview") |>
  read_html()

## Scrapiong LQ hotel pages

page = read_html("https://www.wyndhamhotels.com/laquinta/durham-north-carolina/la-quinta-raleigh-durham-southpoint/overview")

page |>
  html_elements("#static-map")

page |>
  html_elements("div.mob-prop-details > div:nth-child(2) > a") |>
  html_attr("href")

page |>
  html_elements("div.mob-prop-details > div.address-info > a") |>
  html_attr("href")

page |>
  html_elements("div.mob-prop-details > div.address-info > a:not(.property-phone-mobile)") |>
  html_attr("href")



## Denny's Location API

build_url = function(lat=35.779556, long=-78.638145, radius=15, limit=20) {
  paste0(
    "https://www.dennys.com/restaurants/near",
    "?lat=", lat, "&long=",long,
    "&radius=",radius,"&limit=",limit,
    "&nomnom=calendars&nomnom_calendars_from=20250304&nomnom_calendars_to=20250312&nomnom_exclude_extref=999"
  )
}

build_url(radius=1000, limit=100) |> jsonlite::read_json() |> View()


##


