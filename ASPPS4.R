# Problem set 4
# Danielle Korman
# 3/3/16

rm(list=ls())
setwd("/Users/drk/Desktop/R!/PS4")
library(rvest)  
wikiURL <- 'https://en.wikipedia.org/wiki/List_of_United_States_presidential_elections_by_popular_vote_margin'

## Grab the tables from the page and use the html_table function to extract the tables.
## You need to subset temp to find the data you're interested in (HINT: html_table())

temp <- wikiURL %>% 
  html() %>%
  html_nodes("table")

# Extract second table from webpage, since this contains the data of interest
elect_table <- html_table(temp[[2]], header=TRUE, fill=TRUE, trim=TRUE)
# Remove first 2 rows, which do not line up well with data in this format
elect_table <- elect_table[-(1:2),]
# Set column names