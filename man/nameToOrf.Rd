% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/CAlbicansR_function.R
\name{nameToOrf}
\alias{nameToOrf}
\title{nameToOrf Function}
\usage{
nameToOrf(genesList)
}
\arguments{
\item{genesList}{Object of class "vector"}
}
\description{
This function access a pre-processed local database to convert
gene names to orf19 values.
}
\examples{
genesList <- c("EFG1","WOR1","WOR2")
nameToOrf(genesList)
}
