#!/bin/ksh

################################
## backup of a file with same date adding
## date of backup and a counter:
## file_to_backup >> file_to_backup.yyyymmdd.nnn 
################################

FICHIN=$1
FECHA=`date '+%Y%m%d'`
ORDINAL="001"

if [ -z $FICHIN ]
then
   echo "create a copy of the file <file_name>.yyyymmdd.nnn"
   echo "Usage: bkcp <file_name>"
   exit
fi

if [ ! -r $FICHIN ]
then
   echo "File [$FICHIN] Not found, aborting."
   exit
fi

if [ -s $FICHIN.$FECHA.[0-9]* ]
then
   ORDINAL=`ls $FICHIN.$FECHA.[0-9]* |\
           awk '{n=split($1,a,"."); print a[n]}'|sort -n|tail -1`
   ORDINAL=`expr $ORDINAL + 1`
   ORDINAL=`echo $ORDINAL| awk '{n=$1; l=3-length(n);s="";\
                                 for(i=0; i<l;i++) {s="0" s};\
                                 print s n;}'`
fi

FICHOUT="$FICHIN.$FECHA.$ORDINAL"

cp -p $FICHIN $FICHOUT
ls -la $FICHIN
ls -la $FICHOUT

