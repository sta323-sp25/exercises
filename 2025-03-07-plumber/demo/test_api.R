library(httr2)
library(tidyverse)

job::empty({
  library(plumber)
  plumb(file='api.R')$run(port=12121)
})


