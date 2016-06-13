# Code and data for SSDL session "Three easy-to-learn tools to scrape data from the Web with R", June 15 2016

This repository contains code and data to implement basic scraping routines with *R*. In particular, the code shows how to

* use regular expression to extract data from raw text (or websites)
* use XPath for static webpage scraping
* tap APIs from within *R*
* scrape data from dynamic webpages (i.e. JavaScript-generated content) using AJAX and Selenium

Obviously, these are four not three tools. However, regular expressions are never easy to learn, so the title is still valid.


## Technical setup

The scripts were tested on a Mac with *R* version 3.30 running.
To be able to run the code, follow these instructions:

* make sure that the newest version of *R* (currently 3.3.0; available [here](http://cran.r-project.org)) is installed on your computer
* install the newest stable version of *RStudio* (available [here](http://www.rstudio.com/products/rstudio/download/))
* install a set of packages using this bunch of R code:

		pkgs <- c('RCurl', 'XML', 'stringr', 'jsonlite', 'httr',
		rvest', 'pdftools', 'devtools', 'RSelenium', 'plyr',
		'dpylr', wikipediatrend', 'twitteR', 'streamR', 'd3Network')
		install.packages(pkgs)

* make sure Firefox is installed on your machine (available [here](https://www.google.com/chrome/browser/desktop/))

* install Java from [here](https://www.java.com/de/download/))
