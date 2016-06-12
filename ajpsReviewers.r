### -----------------------------
### ajps reviewers
### simon munzert
### -----------------------------

## goals ------------------------

  # fetch list of AJPS reviewers from PDFs
  # locate them on a map


## tasks ------------------------

  # downloading PDF files
  # importing them into R (as plain text)
  # extract information via regex
  # geocoding


## packages ---------------------

library(stringr) # string processing
library(rvest) # scraping suite
library(pdftools) # get text out of PDFs
library(ggmap) # geocoding


## directory ---------------------

wd <- ("./ajpsReviewers")
dir.create(wd)
setwd(wd)


## code ---------------------

## step 1: inspect page
url <- "http://ajps.org/list-of-reviewers/"
browseURL(url)


## step 2: retrieve pdfs
# get page
content <- read_html(url)
# get anchor (<a href=...>) nodes via xpath
anchors <- html_nodes(content, xpath = "//a")
# get value of anchors' href attribute
hrefs <- html_attr(anchors, "href")

# filter links to pdfs
pdfs <- hrefs[ str_detect(hrefs, "reviewer.*pdf") ]
pdfs <- pdfs[!is.na(pdfs)]
pdfs

# define names for pdfs on disk
pdf_names <- str_extract(pdfs, "\\d{4}.pdf")
pdf_names
pdf_names[1] <- "2015.pdf"

# download pdfs
for(i in seq_along(pdfs)) {
  download.file(pdfs[i], pdf_names[i], mode="wb")
}


## step 3: convert pdfs to raw txt
for (i in seq_along(pdf_names)) {
  pdftext <- pdf_text(pdf_names[i])
  write(pdftext, file = paste0(str_extract(pdf_names[i], "[[:digit:]]{4}"), ".txt"))
}


## step 4: import data 
txt_names <- list.files(pattern = "txt")
txt_names
rawdat <- readLines(txt_names[4]) # only reviewers from 2013
head(rawdat)


## step 5: tidy data
rev13 <- rawdat %>%
              str_c(collapse="") %>% 
              str_replace_all(pattern = "[!\f]", replacement = " ")  %>%
              str_replace_all(pattern = "\\]", replacement = " ") %>%
              str_split(pattern = "\\)") %>%
              unlist()
head(rev13)
rev13 <- rev13[-1]

names <- rev13 %>% 
              str_extract(pattern = "^.*?,") %>% 
              str_replace_all(pattern = " |,", replacement = " ") %>%
              str_trim()        
head(names)

institution <- rev13 %>% 
              str_extract(pattern = ",.*\\(") %>%
              str_replace_all(pattern = " |\\(|^, ", replacement = " ") %>%
              str_trim
head(institution)
institution %>% table %>% sort

reviews <- rev13 %>%
              str_extract("\\(.*") %>%
              str_extract("\\d+") %>%
              as.numeric()
head(reviews)

rev13_dat <- data.frame(names = names, institution = institution, reviews = reviews)
head(rev13_dat)


## step 6: geocode reviewers/institutions
# geocoding takes a while -> save results
# 2500 requests allowed per day
if ( !file.exists("institutions2013_geo.RData")){
  pos <- geocode(rev13_dat$institution)
  geocodeQueryCheck()
  save(pos, file="institutions2013_geo.RData")
} else {
  load("institutions2013_geo.RData")
}
head(pos)
rev13_dat$lon <- pos$lon
rev13_dat$lat <- pos$lat


## step 7: plot reviewers, worldwide
mapWorld <- borders("world")
map <-
  ggplot() +
  mapWorld +
  geom_point(aes(x=rev13_dat$lon, y=rev13_dat$lat) ,
             color="#F54B1A90", size=3 ,
             na.rm=T) +
  theme_bw() +
  coord_map(xlim=c(-180, 180), ylim=c(-60,70))
map