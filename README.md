# update_blastdb
## Introduction
download and update blast database.

## Requirement  
+ Linux
+ [BLAST+](https://www.ncbi.nlm.nih.gov/books/NBK279690/) (blastdbcmd)

## Usage
+ Show the list of databases
```
bash update_blastdb.sh -info
```
+ Download nr database and decompress
```
bash update_blastdb.sh -db nr 
```
+ if you want to downlaod fasta, `-f` is needed
```
bash update_blastdb.sh -db nr -f
```
