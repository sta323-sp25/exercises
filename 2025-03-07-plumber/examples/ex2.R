# plumber.R

#* @get /req
function(req, arg="") {
  if (arg == "")
    ls(envir=req)
  else
    req[[arg]]
}


#* @get /res
function(res, arg="") {
  if (arg == "")
    ls(envir=res)
  else
    res[[arg]]
}



#* @get /error
#* @serializer html
function() {
  stop("This is an error")
}


#* @get /forbidden
#* @serializer text
function(res) {
  res$status = 403
  res$body = "You are forbidden from accessing this resource"
}
