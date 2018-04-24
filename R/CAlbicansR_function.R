library("RSelenium")

#' nameToOrf Function
#' 
#' This function access a pre-processed local database to convert
#' gene names to orf19 values.
#' @param genesList Object of class "vector"
#' @export
#' @examples 
#' genesList <- c("EFG1","WOR1","WOR2")
#' nameToOrf(genesList)
nameToOrf <- function(genesList){
  genesList <- toupper(genesList)
  return(db.nameToOrf[genesList])
}

#' orfToName Function
#' 
#' This function access a pre-processed local database to convert
#' orf19 values to gene names
#' @param orfList Object of class "vector"
#' @export
#' @examples 
#' orfList <- c("orf19.610","orf19.4884","orf19.5992")
#' nameToOrf(orfList)
orfToName <- function(orfList){
  return(db.orfToName[orfList])
}

#' runGOEnrichment Function
#' 
#' This function uses an RSelenium wrapper to access the CGD
#' GO Term Finder site, run the search, and download results with
#' corrected p-values.
#' @param geneList Object of class "vector". Should contain list of desired genes to be searched.
#' @param type Object of class "character". Type of ontology: P for Process, F for Function, C for Component. Defaults to P.
#' @param server Object of class "character". Users are encouraged to setup a local RSelenium instance. Defaults to a remote server.
#' @param port Object of class "integer". Defaults to port 4445.
#' @export
#' @examples 
#' geneList <- c("orf19.610","orf19.4884","orf19.5992","WOR3","AHR1","CZF1")
#' runGOEnrichment(geneList,type='F')
runGOEnrichment <- function(geneList=NULL,type='P',
                             server='selenium.joshuawang.com',
                             port=4445){
  if(length(geneList)<2){
    return(NULL)
    #stop("Please enter at least 2 genes.")
  }
  
  type <- toupper(type)
  
  message(paste0('Opening Browser Connection: ',server,":",port))
  mybrowser <- remoteDriver(remoteServerAddr=server,port=port,browserName='firefox')
  capture.output(mybrowser$open(),file='blank')
  Sys.sleep(2)
  
  mybrowser$navigate("http://www.candidagenome.org/cgi-bin/GO/goTermFinder")
  Sys.sleep(2)
  
  message('Inputting Gene List')
  genesList <- sapply(geneList,function(x){paste0(x," ")})
  names(genesList) <- NULL
  textarea <- mybrowser$findElement(using='css selector','textarea')
  textarea$sendKeysToElement(genesList)
  Sys.sleep(2)
  
  if(type=='F'){
    radio <- mybrowser$findElement(using='xpath','//label[(((count(preceding-sibling::*) + 1) = 3) and parent::*)]')
    radio$clickElement()
    Sys.sleep(2)
  }else if(type=='C'){
    radio <- mybrowser$findElement(using='xpath','//b//label[(((count(preceding-sibling::*) + 1) = 5) and parent::*)]')
    radio$clickElement()
    Sys.sleep(2)
  }
  
  message("Executing Search")
  
  #selenium/standalone-firefox does not wait for page to finish loading
  #although standalone-chrome does, selenium has a max timeout of 10 minutes
  #after which the session is terminated if no additional calls to sesison are made. 
  
  #below method works for standalone-chrome, but deprecated due to max session 
  #timeout restriction. 
  
  ### Does anyone know how to launch standalone-chrome in docker with a higher
  # max session timeout?
  #mybrowser$setTimeout(type='page load',milliseconds = 2400000)
  #mybrowser$setTimeout(type='implicit',milliseconds = 2400000)
  #mybrowser$setTimeout(type='script',milliseconds = 2400000)
  
  button <- mybrowser$findElement(using='xpath','//*[(@id = "paddedtbl") and (((count(preceding-sibling::*) + 1) = 5) and parent::*)]//input[(((count(preceding-sibling::*) + 1) = 1) and parent::*)]')
  button$sendKeysToElement(list("\uE007"))
  
  message("Waiting for Results")
  
  # method below is for standalone-firefox - soft ping session every 10 seconds
  #to check if final page has reloaded + prevent session from timing out.
  pageLoad <- FALSE
  while(pageLoad==FALSE){
    Sys.sleep(10)
    temp <- suppressMessages(try(mybrowser$findElement(using='css selector','p font'),silent=T))
    if(class(temp)!="try-error"){
      pageLoad <- TRUE
    }
  }
  
  Sys.sleep(3)
  table <- suppressMessages(try(mybrowser$findElement(using='xpath','//*[(@id = "paddedtbl")]'),silent=T))
  message("Cleaning Results")
  if(typeof(table)=="S4"){
    goTerms <- unlist(strsplit(table$getElementText()[[1]],split="\n"))
    goTerms <- goTerms[3:length(goTerms)]
    names <- sapply(goTerms,function(x){strsplit(x,split=" \\|")[[1]][1]})
    pValues <- as.numeric(sapply(goTerms,function(x){strsplit(strsplit(x,split=", ")[[1]][3],split=" ")[[1]][2]}))
    names(pValues) <- names
  }else{
    pValues <- NULL
  }
  
  Sys.sleep(3)
  
  if(fileName!=F){
    output <- data.frame(matrix(0,nrow=length(goTerms),ncol=6))
    colnames(output) <- c('GO_term','Cluster frequency','Background frequency',
                          'Corrected P-value','False discovery rate',
                          'Gene(s) annotated to the term')
    for(index in 1:length(goTerms)){
      split <- strsplit(goTerms[index],split=' ')[[1]]
      
      term <- paste0(split[1:grep("\\|",split)-1],collapse=" ")
      freq1 <- paste0(split[(grep("\\|",split)+2):(grep("\\|",split)+7)],collapse=" ")
      freq2 <- paste0(split[(grep("\\|",split)+8):(grep("\\|",split)+14)],collapse=" ")
      p <- split[(grep("\\|",split)+15)]
      q <- split[(grep("\\|",split)+16)]
      genes <- paste0(split[(grep("\\|",split)+17):length(split)],collapse='')
      
      output[index,] <- cbind(term,freq1,freq2,p,q,genes)
    }
    
    write.csv(output,fileName,row.names=F)
  }
  
  mybrowser$quit()
  Sys.sleep(3)
  
  return(pValues)
}
