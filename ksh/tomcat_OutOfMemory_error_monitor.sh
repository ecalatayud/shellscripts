#!/bin/ksh
. /etc/profile
dir_tomcat="tomcat_path"
dir_cata=$dir_tomcat/logs

# Searh for OutOfMemory error on tomcats catalina.out,
# tomcat restart when found and alarm email send.

if [ -f $dir_cata/catalina.out ]
then
   echo "[`date`] - Searching for out of memory ..."

   tmp=`grep OutOfMemory $dir_cata/catalina.out|tail -1`

   if [ $tmp ]
   then
      echo "[`date`] - tomcat has out of memory error"
      echo "[`date`] - Stopping tomcat ..."

         cd ~
         $dir_tomcat/bin/shutdown.sh -force

      echo "[`date`] - catalina.out rotation"

         cd $dir_cata
         /usr/local/bin/bkfich.sh catalina.out
         rm $dir_cata/catalina.out

      echo "[`date`] - Starting tomcat..."

         cd $dir_tomcat/bin
         $dir_tomcat/bin/startup.sh

      echo "[`date`] - Tomcat started"
      asunto="[`date`] - `uname -a` tomcat restarted due to out of memory."
      echo "$asunto" | mailx -s "$asunto" mail_of_alarms@domain.com
   fi
fi
