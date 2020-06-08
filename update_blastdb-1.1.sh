#! /bin/bash

help="Download NCBI BLAST database.
    --info | show list that all database type.
    -db | select download database type, ie, nt, nr
    -f | extract all fasta from database
"
fasta=0
while [ "$1" != "" ]; do
    case $1 in
        -db  )           shift
                         dbType=$1
                         ;;
        -info | --info )    info=1
                         ;;
        -h | --help )    echo "$help"
                         exit 1
                         ;;
        -f | --fasta )   fasta=1
                         ;;
        * )              echo "$help"
                         exit 1
    esac
    shift
done

ftp="ftp://ftp.ncbi.nih.gov/blast/db/"
if [ "$info" == 1  ] 
then
    echo "Connect to NCBI..."
    curl $ftp | awk '{print $9}' |
    grep -E ".tar.gz$"  | sed 's/\..*tar.gz//g' | uniq | cat
    exit 1
fi
# check lastest file by md5 value  
if [ ! -z $dbType ]
then 
    echo "Connect to NCBI..."
    md5_value=$(curl $ftp | awk '{print $9}' | grep -E "^$dbType.+md5$")
    echo "Check md value to determine which file required to update"
    for i in $md5_value; do
        wget --tries=50 -c -b -O $i.tmp $ftp$i
        gz=$(echo "$i" | sed 's/.md5//g')
        if test -f "$i"; then
            echo "$i already exist"
            if [ $(awk -F"\t" '{print $1}' $i) ==  $(awk -F"\t" '{print $1}' $i.tmp) ] ; 
                then rm *.tmp ; 
            else #rm old ;download new tar.gz ;
                rm $gz $i ; mv $i.tmp $i
                wget -t0 -c $ftp$gz -O $gz.tmp
                rm $gz; mv $gz.tmp $gz
            fi
        else 
            echo "$i not exist"
            #echo "All $dbType database will be download"
            #axel ftp://ftp.ncbi.nih.gov/blast/db/$i
            wget -t0 -c $ftp$i 
            wget -t0 -c $ftp$gz -O $gz
        fi
    done
fi
rm wget* ; rm -r tmp
echo "Extract files Start"
for g in *.tar.gz; do tar -zvxf $g; done
rm *tar.gz
echo "Update $dbType database finished"

if [ $fasta == 1 ] 
then
    echo "Extract fasta from $dbType database started."
    if [ $dbType == "nt" ]  || [ $dbType == "nr" ] || [ $dbType == "pdbaa" ] || 
    [ $dbType == "swissprot" ]
    then 
        if [ ! -z $(which axel) ] 
        then
            axel $ftpFASTA/$dbType.gz \
            $ftpFASTA/$dbType.gz.md5
        else
            echo "axel is not found, change wget to download."
            wget -c $ftpFASTA/$dbType.gz \
            $ftpFASTA/$dbType.gz.md5
        fi
            gunzip $dbType.gz
            mv $dbType $dbType.fasta        
    else 
        #echo "Except nt,nr,pdbaa,swissprot, other database comming soon...."
        blastdbcmd -db $dbType -entry all -out $dbType.fasta || echo "Extracting interrupted, memory is likely not enough" 
    fi
fi


