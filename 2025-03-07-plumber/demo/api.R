library(tidyverse)
library(plumber)

simpsons = readRDS("data/simpsons.rds")

#* @apiTitle Simpson's Paradox API demo
#* @apiDescription Plumber demo for an API that demonstrates Simpson's Paradox 
#* using data from the `datasaurus` package.

#* @get /data
function() {
  simpsons
}

#* @serializer html
#* @get /data/html
function() {
  knitr::kable(simpsons, format="html")
}

#* @serializer print
#* @get /data/md
function() {
  knitr::kable(simpsons)
}

#* @serializer png
#* @get /data/plot
function(color = "group") {
  g = if (color == "none") {
    ggplot(simpsons, aes(x=x,y=y))
  } else {
    ggplot(simpsons, aes_string(x="x",y="y",color=color))
  }
  
  print(g + geom_point())
}

#* @serializer print
#* @get /model
function(formula = "y~x") {
  lm(as.formula(formula), data=simpsons) |>
    summary()
}

#* @post /data/new
function(req) {
  simpsons <<- bind_rows(
    simpsons, req$body
  )
}

