fp_out <- "data/s.csv"

# Download the texts
library(dplyr)
library(gutenbergr)
library(stringr)

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


# remove all punctuation and replace spaces in titles
s$title <- gsub("[[:punct:]]", "", s$title)
s$title <- str_replace_all(s$title, " ", "_")
s$title <- str_replace_all(s$title, "\r", "_")
s$title <- str_replace_all(s$title, "\n", "_")

# drop all sentences with no text:
s <- filter(s, text != "")

s <- select(s, -gutenberg_id)
write.csv(s, file = fp_out, row.names = FALSE)
