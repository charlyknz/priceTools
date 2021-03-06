

#~~~~~~~~~~~~~~~~ Bray-Curtis Functions  ~~~~~~~~~~~~~~~~#

### These functions support automated calculations of Bray-Curtis similarity for all pairs of communities 

# NOTE: there is almost certainly a faster way to do this using the vegdist() function inside the vegan package - however, this approach produces results that are correctly formatted for comparison with the price partition components, which counts for something...

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#


#' Calculate the Bray-Curtis index for all possible community pairs
#' 
#' Given a grouped data set containing a species ID column and a column of species'
#' ecosystem functions, this function returns a dataset of Bray-Curtis indices that results
#' from all pairwise combinations of unique communities as defined by the 
#' grouping variable(s).
#' 
#' @param x  A grouped data set, with grouping variables defined as in dplyr operations
#' @param species The name of the column in \code{x} containing species ID's
#' @param func The name of the column in \code{x} containing species' ecosystem function
#' 
#' @return This function returns a data set of the Bray-Curtis indices
#'  corresponding to pairs of communities, identified by one or more grouping variables,
#'  which are provided in pairs of columns with the format: groupvar1.x groupvar1.y, etc.
#'  These can be conveniently re-combined using the \code{group.columns()} command.
#' 
#' @examples 
#' 
#' set.seed(36)
#' 
#' # Data frame containing multiple communities we want to compare
#' cms<-data.frame(comm.id=sort(rep(seq(1,3),6)),
#'                 species=rep(LETTERS[seq(1,6)],3),
#'                 func=rpois(6*3,lambda = 2))
#'                 
#' #Identify one (or more) grouping columns
#' cms<-group_by(cms,comm.id)
#' 
#' # Perform pairwise comparisons of all communities in cms identified by comm.id
#' pairwise.braycurtis(cms,species='species',func='func')
#' 
#' @export
#' @import tidyr
pairwise.braycurtis<-function(x,species='Species',func='Function'){
  gps<-groups(x)  # extract grouping variables
  
  # standardize user-specified species and function columns
  names(x)[which(names(x)==species)]<-"species"
  names(x)[which(names(x)==func)]<-"func"
  
  if(!(length(gps)>=1)){
    print("ERROR! data provided to pairwise.braycurtis must have at least one identified 
          grouping variable")
    break;
  }else{
    
    # apply the braycurtis.column function across sets of ref. comms in x
    res <- x %>% do(tmp=braycurtis.column(.$species,.$func,dat=x))  
    
    # distinguish grouping column names of refs. from comparison comms.
    names(res)[1:length(gps)] <- paste(names(res[1:length(gps)]),"x",sep=".") 
    
    # expand the tibble returned by do()
    res<-tidyr::unnest(ungroup(res))
    
    # fix labels of comparison community's grouping variables
    locs<-which(names(res) %in% gps)
    names(res)[locs]<-paste(names(res)[locs],'y',sep='.')
    
    res<-rename(res,braycurtis=vd..1..)
    
    return(res)
  }
}




#' Wrapper function for calculating Bray-Curtis index for a list of communities
#' 
#' Given a list of species names and their ecosystem functions, this function generates
#' a reference community, and then compares the reference community against a set of
#' other communities (including species and their ecosystem function) supplied in a
#' separate, grouped data frame. This is a low-level function that invokes 
#' \code{braycurtis.single()} and is called by higher-level functions such as 
#' \code{pairwise.braycurtis()}, which automates the pairwise comparison of many communities.
#' 
#' @param sps  A vector of species' names for the reference community
#' @param func A numerical vector of species' ecosystem functions in the reference
#'  community
#' @param dat A grouped data frame of species' names and ecosystem functions, which 
#'  must contain at least one grouping variable, as created by dplyr's function group_by(). 
#'  Additionally, the species and function columns must be named 'species' and 'func', respectively.
#' 
#' @return This function returns a data set of Bray-Curtis indices for each community 
#' (uniquely identified by the grouping variable(s) of dat) compared against the reference community
#' 
#' @examples 
#' 
#' set.seed(36)
#' cm1<-data.frame(sps=LETTERS[seq(1,6)],func=rpois(6,lambda = 2))
#' 
#' # Data frame containing multiple communities we want to compare with cm1
#' cms<-data.frame(comm.id=sort(rep(seq(1,3),6)),
#'                 species=rep(LETTERS[seq(1,6)],3),
#'                 func=rpois(6*3,lambda = 2))
#' cms<-group_by(cms,comm.id)
#' 
#' # Compare species/functions of cm1 to all communities in cms, individually
#' braycurtis.column(sps=cm1$sps,func=cm1$func,dat=cms)
#'
braycurtis.column<-function(sps,func,dat){
  gps<-groups(dat)      # snag the grouping variables
  ngroups<-length(gps)  # how many are there?
  
  tmpX<-data.frame(sps,func) # define reference community
  
  # calculate all price comparisons against reference community.
  options(dplyr.show_progress=F)  # turn off progress bar for low-level do() command
  
  # calculate price components
  res<-dat %>% group_by_(.dots=gps) %>% do(braycurtis.single(.$species,.$func,tmpX))  
  
  options(dplyr.show_progress=T)  # turn progress bar back on (so it's visible for high-level do command)
  
  res<-ungroup(res)  #remove grouping variable to avoid problems when combining these results in pairwise.braycurtis
  
  res
}


#' Low-level wrapper function for calculating Bray-Curtis index similarity between a pair of communities
#' 
#' Given a list of species names and their functions, and a reference community,
#' calculate the Bray-Curtis index and return it. This is a  low-level function used inside of 
#' higher-level functions (ie, \code{pairwise.braycurtis()}) that automate the pairwise comparison 
#' of many communities. Note that if a comparison fails, NA is returned instead. So far this only 
#' seems to happen when comparisons are made between two communities each containing the same, 
#' single species.
#' 
#' @param sps  A vector of species' names
#' @param func A numerical vector of species' functions
#' @param commX A reference community
#' 
#' @return This function returns a matrix with a single row, and a column with the Bray-Curtis index.
#' 
#' @examples 
#' 
#' # Generate mock community data:
#' set.seed(36)
#' cm1<-data.frame(sps=LETTERS[seq(1,6)],func=rpois(6,lambda = 2))
#' cm2<-data.frame(sps=LETTERS[seq(1,6)],func=rpois(6,lambda = 2))
#' 
#' # Compare community 2's species and function lists to community 1
#' braycurtis.single(sps=cm2$sps,func=cm2$func,commX=cm1)
#' 
#' @import reshape2
braycurtis.single<-function(sps,func,commX){
  commY<-data.frame(sps,func)         # set up comparison community
  commX$ID<-'x'
  commY$ID<-'y'
  comm<-rbind(commX,commY)
  
  comm<-reshape2::dcast(comm,ID~sps,value.var='func',fill = 0)
  
  vd<-try(vegdist(as.matrix(comm[,-1]),"bray"))
  
  if(class(vd)=='try-error'){
    vd<-list(NA)
  }
  
  return(data.frame(vd[[1]]))
}