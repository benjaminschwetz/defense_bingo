# render homepage
render_home <- function(req, res){
  if(is.null(req$query$name)){
    sub = "Enter your name to play:"
  } else {
    msg <- glue::glue("The name {req$query$name} is already taken. Choose another:")
    sub <- glue::glue("<p style=\"background-color:#FFFF00\">{msg}</p>")
  }
  res$render("home", list(title = "Defense Bingo", subtitle = sub))
}

# render about
render_about <- function(req, res){
  res$render("about", list(title = "About",
                           game = game_no,
                           mode = setup_mode)
             )
}

# 404: not found
render_404 <- function(req, res){
  res$send_file("404", status = 404L)
}

render_change <- function(req, res){
  setup_mode <<- !setup_mode
  res$redirect("/about", status=302L)
}

render_join <- function(req, res){
  new_player <-     list(
    player = req$query$player,
    words = sample(dict,25),
    clicked = rep(FALSE, 25),
    bingo = FALSE
  )
  if(req$query$player %in% 
     unlist(transpose(score_sheet)$player)) {
    res$redirect(glue::glue("/?error=name&name={req$query$player}"), 302L)
  } else{
    score_sheet <<- rlist::list.append(
      score_sheet,
      new_player
    )
    res$redirect(glue::glue("/sheet?player={req$query$player}"),
                 status=302L
    ) 
  }
}

render_sheet <- function(req, res){
  if(any(unlist(transpose(score_sheet)$bingo))){
    res$redirect("/bingo?{game=game_no}", status=302L)
  } else{
    if(setup_mode){
      res$render("sheet",
                 list(player = req$query$player,
                      table= html_card(req$query$player),
                      standings = html_board(),
                      timeout = 10,
                      text = setup_text)
      )  
    } else {
      res$render("sheet",
                 list(player = req$query$player,
                      table= html_card(req$query$player),
                      standings = html_board(),
                      timeout = 3,
                      text = play_text)
      )
    }
    
  }
}
render_update <- function(req, res) {
  if(!setup_mode){
    player <- req$query$player
    word <- req$query$word
    stats <- keep(score_sheet,
                  ~.x$player == player)[[1]]
    stats$clicked[stats$words==word] <- TRUE
    stats$bingo <- check_bingo(stats$clicked)
    score_sheet <<- modify_if(score_sheet,
                              ~.x$player==player,
                              ~stats
    ) 
  }
  res$redirect(glue::glue("/sheet?player={req$query$player}"),
               status=302L
  )
}
render_bingo <- function(req,res){
  ts <- transpose(score_sheet)
  res$render("bingo", 
             list(player = ts$player[unlist(ts$bingo)][[1]],
                  game = game_no)
  )
}
render_reset <- function(req, res){
  if(req$query$game == game_no){
    score_sheet <<- list()
    game_no <<- game_no + 1
  }
  res$redirect("/", status = 302L)
}


# bingo stuff
html_card <- function(player){
  # browser()
  stats <- keep(score_sheet,
        ~.x$player == player)[[1]]
  cells <- glue::glue("<a style={mark(stats$clicked)} href=/hit?player={player}&word={stats$words}>{stats$words}</a>")
  w_mat <- matrix(cells, 5, 5)
  colnames(w_mat) <- c("B", "I", "N", "G", "O")
  tab <- knitr::kable(w_mat,
                      format = "html",
                      escape=FALSE,
                      align = "ccccc",
                      table.attr = "class=\"bingo\"")
  return(tab)
}

html_board <- function(){
  standings <- transpose(score_sheet) %>% 
    pmap_df(~data.frame(Player=..1, Score=sum(..3)))
  tab <- knitr::kable(standings, format = "html", escape=FALSE,
                      align = "lr",
                      table.attr = "class=\"score\""
                      )
  return(tab)
}
# word <- letters[1:25]
# clicked <- c(TRUE, rep(FALSE,24))
mark <- function(clicked){
  ifelse(
    clicked,
    "background-color:#FFFF00",
    "background-color: #000000"
  )
}

rotate <- function(x) t(apply(x, 2, rev))
check_bingo <- function(click_vec){
  m <- matrix(click_vec, 5)
  any(
    rowSums(m) == 5,
    sum(diag(m)) == 5,
    sum(diag(rotate(m))) == 5
  )
}

setup_text <- "This is your bingo sheet. The game has not started yet. Bookmark this page and come back once it starts!"
play_text <- "This is your Bingo sheet. Mark the words you hear in the defense. If you connect a row or a diagonal of 5 you score a BINGO. Below, you can see the other players. Who ever gets their first BINGO wins!."
