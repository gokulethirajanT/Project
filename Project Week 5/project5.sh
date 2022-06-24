# Introduction to Focus Areas 
# Project Week 5
# TEAM 3

# Before running the script: 
# chmod +x project5.sh

# To run the script:
# ./project5.sh
# WARNING: runs take a very long time

# To log all output to a file FILE.log:
# ./project5.sh > FILE.log

TEAM3QUERY="complete genome[TITLE] \
    AND (chloroplast[TITLE] OR plastid[TITLE]) \
    AND 2020/01/01:2020/12/31[PDAT] \
    AND 50000:250000[SLEN] \
    NOT unverified[TITLE] NOT partial[TITLE]"

echo "Built query for:
- complete and verified plastid genomes 
- with a sequence length between 50,000 and 250,000 bp
- first released by NCBI within 2020"

echo "Search number of records."

esearch -db nucleotide -query "$TEAM3QUERY" | \
    xtract -pattern ENTREZ_DIRECT -element Count

echo "Count unique accession numbers."

esearch -db nucleotide -query "$TEAM3QUERY" | \
    efetch -format acc | \
    wc -l

echo "Sort the accession numbers and save them in TEAM3QUERY_UIDs.txt."

esearch -db nucleotide -query "$TEAM3QUERY" | \
    efetch -format acc | \
    sort > TEAM3QUERY_UIDs.txt

echo "Identifying entries in NBCI RefSeq and NBCI SRA."

for acc in $(grep "NC_" TEAM3QUERY_UIDs.txt); do
    echo -n "$acc " >> TEAM3FILTERED_Ref.txt;
    esearch -db nucleotide -query "$acc" |
    efetch -format gb | \
    grep -A10 "^COMMENT" | \
    grep "The reference sequence is identical to" | \
    awk 'NF>1{print $NF}' | tr -d '.' >> TEAM3FILTERED_Ref.txt ;
done

for acc in $(cat TEAM3QUERY_UIDs.txt); do
    echo -n "$acc;" >> TEAM3FILTERED_UIDs.txt;
    esearch -db nuccore -query "$acc" |  \
    elink  -name nuccore_sra -target sra | \
    xtract -pattern ENTREZ_DIRECT -element Count >> TEAM3FILTERED_UIDs.txt;
done

echo "Extract exact NCBI release dates."

for acc in $(cat TEAM3FILTERED_UIDs.txt); do
    echo -n "$acc;" >> TEAM3FILTERED_UIDs_Dates.txt;
    esearch -db nucleotide -query "$acc" | \
    efetch -format docsum | \
    xtract -pattern DocumentSummary -element CreateDate | \
    tr '/' '-' >> TEAM3FILTERED_UIDs_Dates.txt;
done

echo "Done."
