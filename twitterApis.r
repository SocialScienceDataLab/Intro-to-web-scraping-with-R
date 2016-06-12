### -----------------------------
### exploring twitter's apis
### simon munzert
### -----------------------------


## goals ------------------------

# explore Twitter's APIs



## packages ---------------------

library(ROAuth)
library(RCurl)
library(twitteR)
library(streamR)


## directory --------------------

wd <- ("./data/twitterApis")
dir.create(wd)
setwd(wd)


## apis --------------------------

# two APIs types of interest:
# REST APIs --> reading/writing/following/etc., "Twitter remote control"
# Streaming APIs --> low latency access to 1% of global stream - public, user and site streams
# authentication via OAuth
# documentation at https://dev.twitter.com/overview/documentation

# how to get started
# 1. register as a developer at https://dev.twitter.com/ - it's free
# 2. create a new app at https://apps.twitter.com/ - choose a random name, e.g., MyTwitterToRApp
# 3. go to "Keys and Access Tokens" and keep the displayed information ready
# 4. paste your consumer key and secret into the following code and execute it:


## code ----------------------

requestURL <- "https://api.twitter.com/oauth/request_token"
accessURL <- "https://api.twitter.com/oauth/access_token"
authURL <- "https://api.twitter.com/oauth/authorize"
consumerKey <- "xxxxxyyyyyzzzzzz"
consumerSecret <- "xxxxxxyyyyyzzzzzzz111111222222"
twitCred <- OAuthFactory$new(consumerKey = consumerKey, consumerSecret = consumerSecret, requestURL = requestURL, accessURL = accessURL, authURL = authURL)
twitCred$handshake(cainfo = system.file("CurlSSL", "cacert.pem", package = "RCurl"))
# stop here, copy URL into browser, enter PIN into console and press enter. then continue.
save(twitCred, file = "twitter_auth.Rdata")

# the twitCred object stores credentials which have to be passed to the API to get access. once you have stored this information, you do not have to execute the code above again in later sessions. just load the twitter_auth.Rdata file and execute registerTwitterOAuth(twitCred) from the twitteR package



## working with the twitteR package ------------

# negotiate credentials
api_key <- Sys.getenv("twitter_api_key")
api_secret <- Sys.getenv("twitter_api_secret")
access_token <- Sys.getenv("twitter_access_token")
access_token_secret <- Sys.getenv("twitter_access_token_secret")
setup_twitter_oauth(api_key,api_secret,access_token,access_token_secret)


# search tweets on twitter
tweets <- searchTwitter(searchString = "Pegida", n=25, lang=NULL, since=NULL, until=NULL, locale=NULL, geocode=NULL, sinceID=NULL, retryOnRateLimit=120)
tweets_df <- twListToDF(tweets)
head(tweets_df)
names(tweets_df)

# get information about users
user <- getUser("RDataCollection")
user$name
user$lastStatus
user$followersCount
user$statusesCount
user_followers <- user$getFollowers()
user_friends <- user$getFriends() 
user_timeline <- userTimeline(user, n=20)
timeline_df <- twListToDF(user_timeline)

# check rate limits
getCurRateLimitInfo()



## working with the streamR package ----------

load("twitter_auth.RData")

filterStream("tweets_stream.json", track = c("halligalli"), timeout = 10, oauth = twitCred)
tweets <- parseTweets("tweets_stream.json", simplify = TRUE)
names(tweets)
cat(tweets$text[1])




