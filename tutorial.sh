## de novo Transcriptome assembly Tutorial 
## cjfiscus
## 7/6/18
##
## Note this tutorial is intended for MacOS. 
## All commands should be ran from the tutorial folder.

##### SOFTWARE INSTALLS #####
## if homebrew is not installed, then uncomment following line and install homebrew
#/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

## Software List
## fastqc to check quality of data, sickle to trim reads, trans-abyss to do de novo assembly
## BLAST for BLAST searches, hisat2 for RNAseq read mapping 

## install java (if not installed already)
brew cask install java

## install fastqc (http://www.bioinformatics.babraham.ac.uk/projects/fastqc/)
brew install fastqc

## install sickle (https://github.com/najoshi/sickle)
brew install sickle 

## install oases (https://github.com/dzerbino/oases) with homebrew
brew install oases

## install BLAST (https://blast.ncbi.nlm.nih.gov/Blast.cgi)
brew install blast 

## install bowtie2 (http://bowtie-bio.sourceforge.net/bowtie2/index.shtml)
brew install bowtie2
#####

##### ANALYSIS #####
# Data is 1 million random subsampled reads from SRR3498215

## Data QC ## 
# Check data for quality with fastqc
fastqc SRR3498215_sub.fastq.gz

# see results in file SRR3498215_sub_fastqc.html 
# FASTQC manual is here for interpreting quality report: https://dnacore.missouri.edu/PDF/FastQC_Manual.pdf

## Only keep reads with length over 45 and quality score of 35 (Sanger)
sickle se -f SRR3498215_sub.fastq.gz -t illumina -o SRR3498212_trimmed.fastq -q 35 -l 45

## Compare quality of data before and after trimming to see if trimming was appropriate
fastqc SRR3498212_trimmed.fastq

# see results in file SRR3498215_trimmed_fastqc.html 


## de novo transcriptome assembly with oases ## 

#(do not worry about steps so much, just the input/ output)
# using 23 mers
velveth ./23 23 -strand_specific -short -fastq.gz SRR3498212_trimmed.fastq
velvetg ./23 -read_trkg yes
oases ./23


# assembled transcripts are in file ./23/transcripts.fa


## Search for KAI2 (or other genes) in transcriptome using BLAST ## 
# first you need to make a blast database using the transcriptome to search against
makeblastdb -in ./23/transcripts.fa -parse_seqids -dbtype nucl

# BLAST gene of interest (KAI2) to transcriptome database
blastn -db ./23/transcripts.fa -query KAI2.fa -out BLAST_results.txt

# check out results in BLAST_results.txt

# determine which transcript(s) are hits in the BLAST search and then map against them using hisat2. 
# for this tutorial there are not hits so we will just map against the gene. 

# build an index of sequence we are aligning to 
bowtie2-build KAI2.fa KAI2

# align reads to reference
bowtie2 -x KAI2 -U SRR3498212_trimmed.fastq -S out.sam

# output is alignment file in SAM format (https://samtools.github.io/hts-specs/SAMv1.pdf)
# output is out.sam 

