library(MASS)
library(seqinr)


slidingwindowplot <- function(windowsize, inputseq)
{
   print(inputseq)
   starts <- seq(1, length(inputseq)-windowsize, by = windowsize)
   n <- length(starts)    # Find the length of the vector "starts"
   GCs <- numeric(n) # Make a vector of the same length as vector "starts", but just containing zeroes
   for (i in 1:n) {
        chunk <- inputseq[starts[i]:(starts[i]+windowsize-1)]
        GC <- GC(chunk)
        print(GC)
        GCs[i] <- GC
   }
   plot(starts,GCs,type="b",xlab="Nucleotide start position",ylab="GC content")
}


slidingwindowfreq <- function(windowsize, inputdir, binsize)
{
   GCs <- numeric()
   v <- 0 
   files <- list.files(inputdir,full.names=TRUE)

   for (f in files) {
       singleseqvec <- read.fasta(file = f)
       singleseqnuc<-singleseqvec[[1]]
       lengthseq = length(singleseqnuc) 

       if (lengthseq > windowsize) {

            starts <- seq(1, length(singleseqnuc)-windowsize, by = windowsize)
            n <- length(starts)    # Find the length of the vector "starts"
     
            for (i in 1:n) {
                 chunk <- singleseqnuc[starts[i]:(starts[i]+windowsize-1)]
                 GC <- GC(chunk)
                 GCs[v] <- GC
                 v <- v+1
            }
       }
   } 

   bins <- seq(0,1,by=binsize)
   hist1<-hist(GCs,breaks=bins,plot=FALSE)
   print(hist1$counts)
   hist1$counts <- hist1$counts*100/sum(hist1$counts)
   print(hist1$counts)
   plot(hist1)
}


slidingwindowfreqtwosets <- function(windowsize, inputdir1, inputdir2, binsize)
{
   GCs1 <- numeric()
   v <- 0 
   files <- list.files(inputdir1,full.names=TRUE)

   for (f in files) {
       singleseqvec <- read.fasta(file = f)
       singleseqnuc<-singleseqvec[[1]]
       lengthseq = length(singleseqnuc) 

       if (lengthseq > windowsize) {

            starts <- seq(1, length(singleseqnuc)-windowsize, by = windowsize)
            n <- length(starts)    
     
            for (i in 1:n) {
                 chunk <- singleseqnuc[starts[i]:(starts[i]+windowsize-1)]
                 GC <- GC(chunk)
                 GCs1[v] <- GC
                 v <- v+1
            }
       }
   } 


   GCs2 <- numeric()
   v <- 0 
   files <- list.files(inputdir2,full.names=TRUE)

   for (f in files) {
       singleseqvec <- read.fasta(file = f)
       singleseqnuc<-singleseqvec[[1]]
       lengthseq = length(singleseqnuc) 

       if (lengthseq > windowsize) {

            starts <- seq(1, length(singleseqnuc)-windowsize, by = windowsize)
            n <- length(starts)   
     
            for (i in 1:n) {
                 chunk <- singleseqnuc[starts[i]:(starts[i]+windowsize-1)]
                 GC <- GC(chunk)
                 GCs2[v] <- GC
                 v <- v+1
            }
       }
   } 

   bins <- seq(0,1,by=binsize)
   hist1<-hist(GCs1,breaks=bins,plot=FALSE) 
   hist2<-hist(GCs2,breaks=bins,plot=FALSE) 
   hist1$counts <- hist1$counts*100/sum(hist1$counts)
   hist2$counts <- hist2$counts*100/sum(hist2$counts)
   
   data12 <- t(cbind(hist1$counts,hist2$counts))
   barplot(data12,beside=TRUE, space=rep(0,2*ncol(data12)), col=c("red", "green"), main='red bars : S.downei,  green bars: unmapped', xlab='GC content ratio', ylab='% of 1kb bins with this GC content' )
   axis(1, at=bins)
}


gcvssize <- function(inputdir)
{
   GCs <- numeric()
   lengths <- numeric()
   v <- 0 
   files <- list.files(inputdir,full.names=TRUE)

   for (f in files) {
       singleseqvec <- read.fasta(file = f)
       singleseqnuc<-singleseqvec[[1]]
       lengthseq = length(singleseqnuc) 

       GC <- GC(singleseqnuc)
       GCs[v] <- GC
       lengths[v] <- lengthseq
       v <- v+1

   } 

   plot(lengths, GCs, ylab="GC content", xlab="Contig length")
}

