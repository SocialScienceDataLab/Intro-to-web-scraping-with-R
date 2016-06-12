### -----------------------------
### scrape data from IEA website
### simon munzert
### -----------------------------


## goals ------------------------

#  fetch policy data from IEA database


## tasks ------------------------

# get Selenium running
# inspect HTML form on http://www.iea.org/policiesandmeasures/renewableenergy/
# access page with RSelenium
# download data output
# import data into R
# data tidying


## packages ---------------------

library(RSelenium)
library(rvest)


## directory --------------------

wd <- ("./ieaSelenium")
dir.create(wd)
setwd(wd)



## web inspection tools ---------

# Chrome, Firefox:
  # right-click on element, then "Inspect Element"

# Safari:
  # Settings --> Advanced --> Show Develop menu in menu bar
  # Web inspector tools visible in menu bar - the console is most useful

# Internet Explorer:
  # go to google.com/chrome/ or mozilla.org/en-US/firefox/new/ and download Chrome/Firefox
  # next: see above



## code --------------------------

url <- "http://www.iea.org/policiesandmeasures/renewableenergy/"
browseURL(url)
content <- read_html(url)

# set up connection via RSelenium package
# documentation: http://cran.r-project.org/web/packages/RSelenium/RSelenium.pdf

# retrieve Selenium Server binary if necessary
checkForServer()

# start server
startServer() 

# connect to server
remDr <- remoteDriver(remoteServerAddr = "localhost", port = 4444, browserName = "firefox") 

# open connection; Firefox window should pop up
remDr$open() 

# navigate to data request page
remDr$navigate(url) 

# open regions menu
css <- 'div.form-container:nth-child(2) > ul:nth-child(2) > li:nth-child(1) > span:nth-child(1)'
regionsElem <- remDr$findElement(using = 'css', value = css)
openRegions <- regionsElem$clickElement() # click on button

# selection "European Union"
css <- 'div.form-container:nth-child(2) > ul:nth-child(2) > li:nth-child(1) > ul:nth-child(3) > li:nth-child(5) > label:nth-child(1) > input:nth-child(1)'
euElem <- remDr$findElement(using = 'css', value = css)
selectEU <- euElem$clickElement() # click on button

# set time frame
css <- 'div.form-container:nth-child(6) > select:nth-child(2)'
fromDrop <- remDr$findElement(using = 'css', value = css) 
clickFrom <- fromDrop$clickElement() # click on drop-down menu
writeFrom <- fromDrop$sendKeysToElement(list("2000")) # enter start year

css <- 'div.form-container:nth-child(6) > select:nth-child(3)'
toDrop <- remDr$findElement(using = 'css', value = css) 
clickTo <- toDrop$clickElement() # click on drop-down menu
writeTo <- toDrop$sendKeysToElement(list("2010")) # enter end year

# click on search button
css <- '#main > div:nth-child(1) > form:nth-child(4) > button:nth-child(14)'
searchElem <- remDr$findElement(using = 'css', value = css)
resultsPage <- searchElem$clickElement() # click on button

# store index page
output <- remDr$getPageSource(header = TRUE)
write(output[[1]], file = "iea-renewables.html")

# close connection
remDr$closeServer()

# parse index table
content <- read_html("iea-renewables.html", encoding = "utf8") 
tabs <- html_table(content, fill = TRUE)
tab <- head(tabs[[1]])

# add names
names(tab) <- c("title", "country", "year", "status", "type", "target")
head(tab)


### a little refresher: R and 2048 ---------------------------
source("rselenium-2048.r") # by Mark T. Patterson
grand.play()
