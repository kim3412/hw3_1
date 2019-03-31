# install packages
install.packages("XML")
install.packages("RCurl")
install.packages("plyr")

# load and attach add-on packages
library(XML)
library(RCurl)
library(plyr)

# build url
url1 <- "http://apis.data.go.kr/9710000/NationalAssemblyInfoService/"
category <- "getElectionNumberCurrStateList"
url2 <- "?serviceKey="
mykey <- "your key"
param1 <- "&numOfRows=20"
param2 <- "&pageNo="
param3 <- "&reele_gbn_cd="

# get the list of National Assembly from API by election number
# parameter is election number
extract <- function(electionNum){
  
  table <- data.frame()
  calcPageNum <- 0
  totalPageNum <- 0
  pageNum <- 1
  repeat{
    # build url
    url <- paste0(requestUrl, pageNum, param3, electionNum, sep='')
    page <- getForm(url, query='')
    doc <- xmlParse(page)
    doc <- xmlToList(doc)
    
    # calculate the number of pages
    if(calcPageNum == 0){
      totaldataNum = as.numeric(doc[2]$body$totalCount)
      totalPageNum = (totaldataNum %/%20) + 1
      calcPageNum = 1
    }
    
    # get national assembly info and accumulate
    for(i in 1:20){
      ex <- data.frame(doc[2]$body$item[i])
      if(length(table)==0) table <- ex
      else table <- rbind.fill(table, ex)
    }
    if(pageNum > totalPageNum) break
    pageNum = pageNum + 1
  }
  
  return (table)
}

# get list by election number then save
electNum = 105001:105007
for(i in 1:7){
  df = extract(electNum[i])
  print(df)
  write.csv(df, paste0("your directory path", i, ".csv"))
}

