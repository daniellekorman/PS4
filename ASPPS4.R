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
colnames(elect_table) <- c("#", 
                           "Year", 
                           "Winner", 
                           "Winner Party", 
                           "Popular Vote (%)", 
                           "Margin of Popular Vote (%)",
                           "Popular Vote",
                           "Margin of Popular Vote",
                           "Runner Up",
                           "Runner Up Party",
                           "Turnout (%)")

# Reset rownames to start at 1 after removing 1st two rows
rownames(elect_table) <- NULL

# Fix the data:
# All of the names of winners and runners up are repeated twice
# Both Margin columns (% and total) have repeat/messy numbers
# First, try to separate the Winners' names into Last, First [Middle] and First [Middle] Last
# Looked up how to split strings where a lowercase letter precedes immediately (no space) an
# uppercase, will also apply that to periods where needed for middle initials
strsplit(elect_table$Winner, split="(?<=([a-z]))(?=[A-Z])", perl=TRUE)
# Was not able to figure out how to split between a period and capital letter, or
# deal with William McKinley.  Since we are just plotting the data, I guess all that isn't necessary
# So, I won't actually delete the redundant strings here.  I spent a long time trying

# Now, deal with the redundant and messy Margin columns
# In the Percentage one, I have to remove everything before the "-" or after "%"

# Change "Margin of Popular Vote (%)" column to character
fixthis <- as.character(elect_table$`Margin of Popular Vote (%)`)
# Get rid of everything before negative, and percentages so it can be a numeric
elect_table$`Margin of Popular Vote (%)`[1:4] <- as.numeric(gsub("%|.*−", "", fixthis[1:4]))*-1
#This fixes rows 1-4, for 5-29, remove % and delete everything after the first % to get rid of repeat
elect_table$`Margin of Popular Vote (%)`[5:29] <- as.numeric(gsub("%.*", "", fixthis[5:29]))
# Get rid of % for the rest of the column
elect_table$`Margin of Popular Vote (%)`[30:48] <- as.numeric(gsub("%", "", fixthis[30:48]))

# Also get rid of % for Popular Vote (%) and Turnout
elect_table$`Popular Vote (%)` <- as.numeric(gsub("%", "", as.character(elect_table$`Popular Vote (%)`)))
elect_table$`Turnout (%)` <- as.numeric(gsub("%", "", as.character(elect_table$`Turnout (%)`)))

# The Margin of Popular Vote column is too messy to deal with, so it will not be used

## Visualizing Data ##

# First Plot: Voter Turnout over time, with party
# Sort data by year
byyear <- elect_table[order(elect_table$Year),]
partywinner <- as.factor(byyear$`Winner Party`)
plot1 <- plot(byyear$Year, byyear$`Turnout (%)`, type = "p", 
              pch=19, cex=.5, col=partywinner, 
              xlab = "Year", ylab = "Voter Turnout (%)", 
              xlim=c(min(byyear$Year), max(byyear$Year)),
              ylim=c(min(byyear$`Turnout (%)`), max(byyear$`Turnout (%)`)))
palette(c("purple", "blue", "red", "black"))
title("Winning Party and Voter Turnout Over Time")
text(1855, 30, "Democratic Republican", cex = .6, col = "purple")
text(1840, 52, "Democrat", cex = .75, col = "blue")
text(1925, 45, "Republican", cex = .75, col = "red")
text(1832, 75, "Whig", cex = .75, col = "black")
# Second Plot: Candidate with most of popular vote winning over time

dev.off()  
