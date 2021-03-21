library(future)
library(purrr)
library(ambiorix)
plan(multisession)
import("views")
dict <- readLines("top_terms")
# bingo logic
score_sheet <- list()
game_no <- 1
setup_mode <- TRUE
app <- Ambiorix$new()
# 404 page
app$not_found <- render_404
# serve static files
app$static("assets", "static")
# homepage
app$get("/", render_home)
# about
app$get("/about", render_about)
app$get("/join", render_join)
app$get("/hit", render_update)
app$get("/reset", render_reset)
app$get("/sheet", render_sheet)
app$get("/bingo", render_bingo)
app$get("/change", render_change)
app$start()
