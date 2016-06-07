fp_out <- "data/s.csv"
gutenberg <- FALSE

# Download the texts
library(dplyr)
library(stringr)

if(gutenberg){
  library(gutenbergr)
  s <- gutenberg_works() %>% filter(str_detect(author, "Shakespeare")) %>% 
    # same results w or w/out next line
    # select(gutenberg_id) %>% unlist() %>% as.numeric() %>%
    gutenberg_download(meta_fields = "title")
  
  # check it out in Rstudio
  count(s, title) %>% View()
  
  # these seem to be full collections of multiple works, so drop:
  s <- filter(s, !str_detect(title, "Cambridge Edition"))
  s <- filter(s, !str_detect(title, "Explanatory Notes"))
  # Theres two romeo and juliets:
  s <- filter(s, !str_detect(title, "Shakespeare's Tragedy of Romeo and Juliet"))
  s <- filter(s, !str_detect(title, "Arranged for Representation"))
  
  count(s, title) %>% data.frame() %>% pander::pander()
  
  # remove all punctuation and replace spaces in titles
  s$title <- gsub("[[:punct:]]", "", s$title)
  s$title <- str_replace_all(s$title, " ", "_")
  s$title <- str_replace_all(s$title, "\r", "_")
  s$title <- str_replace_all(s$title, "\n", "_")
  
  # drop all sentences with no text:
  s <- filter(s, text != "")
  
  s <- select(s, -gutenberg_id)
  write.csv(s, file = fp_out, row.names = FALSE)
} else {
  library(rvest)
  text_links <- read_html("http://www.folgerdigitaltexts.org/download/") %>%
    html_nodes(".txt") %>% html_attr("href")
  text_names <- read_html("http://www.folgerdigitaltexts.org/download/") %>%
    html_nodes(".file") %>% html_text()
  # drop first bc thats all of them
  text_links <- text_links[2:length(text_links)]
  text_names <- text_names[2:length(text_names)]
  
  # remove all punctuation and replace spaces in titles
  text_names <- gsub("[[:punct:]]", "", text_names)
  text_names <- str_replace_all(text_names, " ", "_")
  text_names <- str_replace_all(text_names, "\r", "_")
  text_names <- str_replace_all(text_names, "\n", "_")
  
  for(i in seq(length(text_links))){
    download.file(url = paste0("http://www.folgerdigitaltexts.org/download/", text_links[i]), 
                  destfile = paste0("data/", text_names[i], ".txt"))
    print(text_names[i])
  }
  
  out <- data.frame(do.call(rbind, lapply(text_names, function (tname){
    fileName <- paste0("data/", tname, ".txt")
    cv <- readChar(fileName, file.info(fileName)$size) 
    # before Act 1 is the meta data
    # cv <- str_split(cv, "ACT 1")[[1]][2]
    print(tname)
    c(cv, tname)
  })), stringsAsFactors = FALSE)
  write.csv(out, file = fp_out, row.names = FALSE)
  
}

