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
library(ggmap) # geocoding


## directory ---------------------

wd <- ("./data/ajpsReviewers")
dir.create(wd)
setwd(wd)


## code ---------------------

## step 1: inspect page
url <- "http://ajps.org/list-of-reviewers/"
browseURL(url)


## step 2: retrieve pdfs
# get page
content <- html(url)
# get anchor (<a href=...>) nodes via xpath
anchors <- html_nodes(content, xpath = "//a")
# get value of anchors' href attribute
hrefs <- html_attr(anchors, "href")

# filter links to pdfs
pdfs <- hrefs[ str_detect(hrefs, "reviewers.*\\d{4}.*pdf") ]
pdfs <- pdfs[!is.na(pdfs)]
pdfs

# define names for pdfs on disk
pdf_names <- str_extract(pdfs, "\\d{4}.pdf")
pdf_names

# download pdfs
for(i in seq_along(pdfs)) {
  download.file(pdfs[i], pdf_names[i], mode="wb")
}


## step 3: transform pdfs into txt data
# xpdf: http://www.foolabs.com/xpdf/download.html
# function working for windows ...
# should use system() instead of shell() on Mac/Linux
pdftotext <- function(fname){
  path_to_pdftotext <-
    "C:/xpdf/pdftotext.exe"
  fname_txt <- str_replace(fname, ".pdf", ".txt")
  command <- str_c(path_to_pdftotext,
                   fname,
                   fname_txt, sep=" ")
  shell(command)
}

pdftotext(pdf_names[1])
pdftotext(pdf_names[2])
pdftotext(pdf_names[3])
pdftotext(pdf_names[4])
pdftotext(pdf_names[5])


## step 4: import data 
txt_names <- list.files(pattern = "txt")
txt_names
rawdat <- readLines(txt_names[4])
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


## step 8: plot reviewers, germany
url <-
  "http://biogeo.ucdavis.edu/data/gadm2/R/DEU_adm1.RData"
fname <- basename(url)
if ( !file.exists(fname) ){
  download.file(url, fname, mode="wb")
}
load(fname)

map2 <-
  ggplot(data=gadm, aes(x=long, y=lat)) +
  geom_polygon(data = gadm, aes(group=group)) +
  geom_path(color="white", aes(group=group)) +
  geom_point(data = rev13_dat,
             aes(x = lon, y = lat),
             colour = "#F54B1A70", size=5, na.rm=T) +
  coord_map(xlim=c(5, 16), ylim=c(47,55.5)) +
  theme_bw()
map2
