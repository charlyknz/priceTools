% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/Price_functions.R
\name{get.dist.mats}
\alias{get.dist.mats}
\title{Calculate Price component based distance matrix between community pairs.}
\usage{
get.dist.mats(x)
}
\arguments{
\item{x}{A data frame, resulting from \code{pairwise.price}}
}
\value{
This function returns a list of two distance matrices:
 \item{dst5}{A distance matrix calculated based on the full 5-part Price partition}
 \item{dst3}{A distance matrix calculated based on the 3-part sCAFE version of the Price partition}
}
\description{
The Price equation generates a vector of values reflecting a comparison between two 
communities. This vector can be used to establish a distance between different pairs 
of communities, compared with the Price equation. Across all pairwise combinations of
community pairs, this produces a distance matrix, which can be used to perform multivariate
tests on Price analyses.
}
\examples{

# Data frame containing multiple communities we want to compare
set.seed(36)
cms<-data.frame(comm.id=sort(rep(seq(1,3),6)),
                species=rep(LETTERS[seq(1,6)],3),
                func=rpois(6*3,lambda = 2))
                
#Identify a grouping columns
cms<-group_by(cms,comm.id)

# Perform pairwise comparisons of all communities in cms identified by comm.id
pp<-pairwise.price(cms,species='species',func='func')

dm<-get.dist.mats(pp)
dm

}

