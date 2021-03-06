% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/vector_summary_stats.R
\name{var.test.2}
\alias{var.test.2}
\title{Test the difference in variances between distributions.}
\usage{
\method{var.test}{2}(x, y)
}
\arguments{
\item{x}{A categorical value (factor) with two levels}

\item{y}{A list of response values}
}
\value{
A p-value coming from \code{\link{var.test()}}
}
\description{
Test the difference in variances between distributions.
}
\examples{

y <- c(rnorm(20,mean=10,sd=2),rnorm(20,mean=25,sd=6))
x <- factor(c(rep('A',20),rep('B',20)))

var.test.2(x,y)

}

