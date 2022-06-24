# Introduction to Focus Areas in Bioinformatics – WS21/22 – Week 6
# TEAM 3

## Preparation / Prerequisites
#-----------------------------

# Step 1:  Please download the raw sequence reads from the total DNA genome skimming of 
# Nymphaea odorata subsp. odorata (SRR12134661) from NCBI SRA. These are your input
# reads for the plastid genome assembly. You are welcome to reduce this read set as
# displayed in the seminar video at your discretion in order to work with smaller files.

# Download Raw reads File from SRA
wget -c https://sra-downloadb.be-md.ncbi.nlm.nih.gov/sos3/sra-pub-run-19/SRR12134661/SRR12134661.1

# Install fastq-dump from https://github.com/ncbi/sra-tools/wiki/02.-Installing-SRA-Toolkit
# or with sudo apt-install sra-toolkit
# Extract sequence reads into FASTQ format ()
fastq-dump --split-files --gzip --skip-technical \
  --read-filter pass --origfmt --readids --clip SRR12134661.1

#> Read 2604548 spots for SRR12134661.1
#> Written 2604548 spots for SRR12134661.1


# Rename FASTQ-files
mv SRR12134661.1_pass_1.fastq.gz raw_reads_R1.fastq.gz
mv SRR12134661.1_pass_2.fastq.gz raw_reads_R2.fastq.gz

# Step 2: Please use the following two NCBI RefSeq sequence records as reference genomes
# for the step of plastome read extraction: Nymphaea odorata (NC_057567) and Nymphaea
# ampla (NC_035680)

# Find NC_057567 and NC_035680 in RefSeq as Reference Sequences
esearch -db nucleotide -query "NC_057567 OR NC_035680" | \
  efetch -format gb | \
  grep -A10 "^COMMENT" | \
  grep "The reference sequence is identical to" | \
  awk 'NF>1{print $NF}' | tr -d '.'
# This show the RefSeq-IDs and is not really necessary

# Download both Reference Sequences with:
esearch -db nucleotide -query "NC_057567 OR NC_035680" | efetch -format fasta > Refgenomes.fasta

# Step 3: For the actual plastid genome assembly, please employ the software NOVOPlasty
# (Dierckxsens et al. 2017; https://doi.org/10.1093/nar/gkw955).


# Step 4: Install other necessary Software
# Check if available
# Defining an array
DEPS=(bowtie2-build bowtie2 samtools bedtools)
# Looping over every element of array
for dep in "${DEPS[@]}"; do
  echo ""
  if ! [ -x "$(command -v $dep)" ]; then
    echo "Error: $dep is not installed"
  fi
done
# If a name is printed, install this tool
# 4.1 Bowtie2:  sudo apt install bowtie
# 4.2 SAMtools: sudo apt install samtools
# 4.3 Bedtools: sudo apt install bedtools

## Exact Set of Input reads
#--------------------------

# First, we take a look at the number of sequences and their length distribution
# Define filenames 
INF1=raw_reads_R1.fastq.gz
INF2=raw_reads_R2.fastq.gz
REFGENOMES=Refgenomes.fasta
# Get Length
gunzip -c $INF1 | grep "^@" | wc -l
#> 2648372
gunzip -c $INF2 | grep "^@" | wc -l
#> 2658606
# Get Length distribution of all reads for both Sequences
zcat $INF1 | awk '{if(NR%4==2) print length($1)}' | \
  sort | uniq -c 
zcat $INF2 | awk '{if(NR%4==2) print length($1)}' | \
  sort | uniq -c

# Building a database index for the reference genomes
mkdir -p db
bowtie2-build $REFGENOMES db/myRef > refdb.log
#> Building a SMALL index

# Mapping reads with bowtie2 to reference genomes and
bowtie2 -x db/myRef -1 $INF1 -2 $INF2 2> mapping.err | \
  # immediately converting the output to a binary file
  samtools view -bS - > mapping.bam

# Inferring mapping statistics
samtools flagstat mapping.bam > mapping_stats.txt

# Extracting reads that are properly paired and fully mapped and
samtools view -b -F12 mapping.bam | \
  # sorting reads (necessary for conversion to fastq) and
  samtools sort -n - > extracted_mappedF12.bam
#> [bam_sort_core] merging from 3 files and 1 in-memory blocks...

# converting them to fastq sequences
bedtools bamtofastq -i extracted_mappedF12.bam -fq mappedF12_reads.fastq

# Separationg mapped Pairs into R1 and R23 file
awk -v n=4 'BEGIN{f=2} {if((NR-1)%n==0){f=1-f}; \
  print > "mappedF12_reads_R" f ".fastq"}' mappedF12_reads.fastq
# Correcting a small formatting issue in file name
mv mappedF12_reads_R-1.fastq mappedF12_reads_R1.fastq

## Internal Quality Check
# Number of mapped pairs
grep "with itself and mate mapped" mapping_stats.txt | \
  awk '{print $1}'
#> 4536052
# Number of reads from output-files
grep "^@" mappedF12_reads_R*.fastq | uniq | wc -l
#> 4619200

# Choose first 300,000 reads (first 1,200,000 lines)
head -n1200000 mappedF12_reads_R1.fastq | tail -n4
head -n1200000 mappedF12_reads_R2.fastq | tail -n4
#> Last read is @344408
# We select only the first 344408 reads 
head -n1200000 mappedF12_reads_R1.fastq > mappedF12_reads_R1_reduced.fastq
head -n1200000 mappedF12_reads_R2.fastq > mappedF12_reads_R2_reduced.fastq

# Size of mappedF12_reads_R1.fastq and mappedF12_reads_R2.fastq is 1.3 GB
# Size of mappedF12_reads_R1_reduced.fastq and mappedF12_reads_R2_reduces.fastq is 167MB

# The large files can be removed
rm mappedF12_reads_R1.fastq 
rm mappedF12_reads_R2.fastq 

## Selecting different mapping flags - Not necessary
# Extract properly paired reads, that map to the references genome and map to the reverse strand
samtools view -b -F12 -F16 mapping.bam | \
  samtools sort -n - > extracted_mappedF12F16.bam
#> [bam_sort_core] merging from 1 files and 1 in-memory blocks...
bedtools bamtofastq -i extracted_mappedF12F16.bam \
  -fq mappedF12F16_reads.fastq

awk -v n=4 'BEGIN{f=2} {if((NR-1)%n==0){f=1-f}; \
  print > "mappedF12F16_reads_R" f ".fastq"}' \
  mappedF12F16_reads.fastq
mv mappedF12F16_reads_R-1.fastq mappedF12F16_reads_R1.fastq
# New number of reads:
grep "^@" mappedF12F16_reads_R*.fastq | uniq | wc -l
#> 2317259

## Depth of sequencing coverage
#------------------------------

## Mapping reads to reference genome via Bowtie2

# Format Reference Genome
cat Refgenomes.fasta | tr -d '\n' > Refgenomes_deinterleaved.fasta
# Then recreate Header-Lines in Editor
# Use this as new ReferenceGenome file
REFGENOMES=Refgenomes_deinterleaved.fasta

# Extracting only the first reference genome as reference
head -n2 $REFGENOMES > firstRef.fasta
# mkdir -p db
bowtie2-build firstRef.fasta db/firstRef > firstRefdb.log
#> Building a SMALL index
bowtie2 -x db/firstRef -1 $INF1 -2 $INF2 2> preAdj_mapping.err | \
  samtools view -bS - > preAdj_mapping.bam

# Sort 
samtools sort preAdj_mapping.bam > preAdj_mapping.bam.sorted
#> [bam_sort_core] merging from 3 files and 1 in-memory blocks...
samtools index preAdj_mapping.bam.sorted

# Visulalize in Histogram
# For this to work bamcov should be installed in ~/git/bamcov
# https://github.com/fbreitwieser/bamcov
# If h-files are missing install the packages including them 
# (I needed liblzma-dev and libbz2-dev, libcurl3-dev)
touch preAdj_covHistogr.csv;
echo "start,end,cov" > preAdj_covHistogr.csv;
for i in `seq 0 1000 150000`; do
  start=$(($i+1)); end=$(($i+1000));
  echo -n "${start},${end}," >> preAdj_covHistogr.csv
  ~/git/bamcov/bamcov preAdj_mapping.bam.sorted -H \
  -r NC_057567.1:${start}-${end} | \
  awk '{print $7}' >> preAdj_covHistogr.csv;
done 
# For vizualization use coverage_viz.r (Later)


# -----------------------------------------
# KMer based sequencing depth normalization
# Step 1: Inferring kmer-based normalization factor based on desired sequencing depth 
# For details, see: https://jgi.doe.gov/data-and-tools/bbtools/bb-tools-user-guide/bbnorm-guide/
ReadDepth=200
ReadLength=151
BestKmerSize=31

var1=$(echo "$ReadLength-$BestKmerSize+1" | bc)
var2=$(echo "scale=2;$ReadLength/$var1" | bc)
var3=$(echo "scale=2;$ReadDepth/$var2" | bc)

KmerDepth=${var3%.*}

# Step 2: . Normalizing sequencing depth: BBTools (Bushnell 2014, https://jgi.doe.gov/data-and-tools/bbtools/)
INF1=mappedF12_reads_R1_reduced.fastq
INF2=mappedF12_reads_R2_reduced.fastq
OTF1=plastomeReads_CovDepNormedAt${ReadDepth}_R1.fastq
OTF2=plastomeReads_CovDepNormedAt${ReadDepth}_R2.fastq

# Install bbtools from https://jgi.doe.gov/data-and-tools/bbtools/bb-tools-user-guide/installation-guide/
# Use bbtools
/mnt/c/Users/sinag/Documents/Git/ifabi-2021/bbmap/bbnorm.sh in=$INF1 in2=$INF2 out=$OTF1 out2=$OTF2 min=0 \
  target=$KmerDepth > CovDepNormedAt${ReadDepth}.log 2>&1

# Visualize Sequencing Coverage after Adjustment
INF1=plastomeReads_CovDepNormedAt${ReadDepth}_R1.fastq
INF2=plastomeReads_CovDepNormedAt${ReadDepth}_R2.fastq
bowtie2 -x db/firstRef -1 $INF1 -2 $INF2 2> postAdj_mapping.err | \
  samtools view -bS - > postAdj_mapping.bam

## Sort 
samtools sort postAdj_mapping.bam > postAdj_mapping.bam.sorted
#> [bam_sort_core] merging from 3 files and 1 in-memory blocks...
samtools index postAdj_mapping.bam.sorted

# Visulalize in Histogram
# For this to work bamcov should be installed in ~/git/bamcov
# https://github.com/fbreitwieser/bamcov
# If h-files are missing install the packages including them 
# (I needed liblzma-dev and libbz2-dev, libcurl3-dev)
touch postAdj_covHistogr.csv;
echo "start,end,cov" > postAdj_covHistogr.csv;
for i in `seq 0 1000 150000`; do
  start=$(($i+1)); end=$(($i+1000));
  echo -n "${start},${end}," >> postAdj_covHistogr.csv
  ~/git/bamcov/bamcov postAdj_mapping.bam.sorted -H \
  -r NC_057567.1:${start}-${end} | \
  awk '{print $7}' >> postAdj_covHistogr.csv;
done 
# For vizualization use coverage_viz.r
#------------------------------------------

## Assembling The Genome
#-----------------------
# With NOVOPlasty
# Installation: Downlad ZIP-File from Git (https://github.com/ndierckx/NOVOPlasty)

# Take the first read of the extracted plastome reads as Seed Sequence
echo ">mySeedSequence" > mySeedSequence.fasta
head -n2 plastomeReads_CovDepNormedAt500_R1.fastq | \
  tail -n1 >> mySeedSequence.fasta

# Execute NOVOPlasty for preAdj
perl NOVOPlasty/NOVOPlasty-master/NOVOPlasty4.3.1.pl \
  -c NOVOPlasty/NOVOPlasty-master/config_preAdjust.txt 
# Execute NOVOPlasty for postAdj
perl NOVOPlasty/NOVOPlasty-master/NOVOPlasty4.3.1.pl \
  -c NOVOPlasty/NOVOPlasty-master/config_postAdjust.txt 

