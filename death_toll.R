install.packages("rvest")

### Scrape wiki page for tables
library(rvest)
link <- "https://en.wikipedia.org/wiki/List_of_natural_disasters_by_death_toll"
wiki_page <- read_html(link)
death_toll_tables <- html_elements(wiki_page, "table.sortable")[2:3] %>% html_table()
death_toll_tb <- do.call(rbind, death_toll_tables)

### Convert death toll to numbers
dtoll <- death_toll_tb$`Death toll`
dtoll <- gsub(",", "", dtoll)
dtoll <- gsub("\\(.*\\)", "", dtoll)
dtoll <- gsub("\\[.*\\]", "", dtoll)
# Use bounds
dtoll <- gsub("\\+", "", dtoll)
# Find midpoints of ranges
ranges <- dtoll[grepl("[–-]", dtoll)]
ranges <- unlist(regmatches(ranges, gregexpr("\\d+[–-]\\d+", ranges)))
ranges <- strsplit(ranges, "[–-]")
dtoll[grepl("[–-]", dtoll)] <- sapply(ranges, function(x) {mean(as.integer(x))})
# Convert to numbers
death_toll_tb$`Death toll` <- as.numeric(dtoll)

### Plot
library(ggplot2)
death_toll_tb$Type <- tolower(death_toll_tb$Type)
death_toll_tb$Type <- as.factor(death_toll_tb$Type)
g <- ggplot(death_toll_tb, mapping = aes(Year, `Death toll`, fill = Type)) + geom_bar(stat = "identity")
g
