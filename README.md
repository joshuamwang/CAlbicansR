# CAlbicansR

This is an [R](https://www.r-project.org/) library to analyze biological datasets in [Candida albicans](https://en.wikipedia.org/wiki/Candida_albicans). The package relies on publically available data and tools housed at the [Candida Genome Database](http://candidagenome.org/). 

## Installation
[R](https://www.r-project.org/) package installations from [Github](github.com) depend on the ```install_github()``` function from [devtools](https://cran.r-project.org/web/packages/devtools/index.html). 

```R
install.packages('devtools')
library('devtools')
devtools::install_github('joshuamwang/CAlbicansR')
library('CAlbicansR')
```
**Optional**: Users are encouraged to run a local instance of [Selenium](http://docs.seleniumhq.org/). Specifically, this R library was tested with [selenium/standalone-firefox-debug](https://hub.docker.com/r/selenium/standalone-firefox-debug/) which can be pulled from docker and executed as follows:

```bash
# to pull from docker & install
sudo docker pull selenium/standalone-firefox-debug

# to execute
sudo docker run -d -p 4445:4444 -p 5901:5900 -v /dev/shm:/dev/shm selenium/standalone-firefox-debug
```
This configuration binds the [Selenium](http://docs.seleniumhq.org/) port to 4445 and allows for [VNC viewer](https://www.realvnc.com/en/connect/download/viewer/) access for debugging on port 5901. More information on debugging [Selenium](http://docs.seleniumhq.org/) with [VNC viewer](https://www.realvnc.com/en/connect/download/viewer/) is available [here](https://github.com/SeleniumHQ/docker-selenium#debugging). 

## Usage

1\. Convert gene names to orf19 values:
```R
genesList <- c("EFG1","WOR1","WOR2")
temp <- nameToOrf(genesList)

print(temp)
EFG1         WOR1         WOR2 
 "orf19.610" "orf19.4884" "orf19.5992"
```


2\. Convert orf19 values to gene names:
```R
orfList <- c("orf19.610","orf19.4884","orf19.5992")
temp <- orfToName(orfList)

print(temp)
orf19.610 orf19.4884 orf19.5992 
    "EFG1"     "WOR1"     "WOR2" 
```


3\. Perform gene ontology enrichment through [CGD Gene Ontology Term Finder](http://candidagenome.org/cgi-bin/GO/goTermFinder):
```R
geneList <- c("orf19.610","orf19.4884","orf19.5992","WOR3","AHR1","CZF1")
ontologyType <- "P"   ### P for Process, F for Function, and C for Component
temp <- runGOEnrichment(geneList, ontologyType)

print(temp)
```
| Gene Ontology term | Corrected P-value |
| ------------- |:-------------:|
| regulation of phenotypic switching | 3.13e-13 |
| positive regulation of phenotypic switching | 1.72e-12 |
| phenotypic switching | 1.62e-09 |
| regulation of filamentous growth of a population of unicellular organisms | 8.90e-06 |
| regulation of filamentous growth | 1.05e-05 |
| regulation of single-species biofilm formation | 1.77e-05 |
| ... | ... |

