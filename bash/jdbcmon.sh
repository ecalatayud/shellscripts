#!/bin/bash

TZ=GMT+10
#################################################
## Environment variables
#################################################

export ORACLE_HOME=
export FMW_HOME=$ORACLE_HOME/fmw
export JAVA_HOME=$ORACLE_HOME/java_home
export WL_HOME=$FMW_HOME/wl_home
export WLS_DOMAIN=$ORACLE_HOME/domains
export OWL_DOMAIN=$WLS_DOMAIN/owl_domain
export PATH=$JAVA_HOME/bin:$PATH:$HOME/bin
export CLASSPATH="classpath"

#################################################
## labour day or not
#################################################

DiaSemana=`date +"%a"`
hora=`date +"%H"`

case $DiaSemana in
Mon)horario=laboral;;
Tue)horario=laboral;;
Wed)horario=laboral;;
Thu)horario=laboral;;
Fri)horario=laboral;;
Sat)horario=fueraHoras;;
Sun)horario=fueraHoras;;
esac

if [ $horario == "laboral" ]
then
        if [ $hora -lt 8 ]
        then
                horario=fueraHoras
        else
                if [ $hora -gt 16 ]
                then
                        horario=fueraHoras
                fi
        fi
fi

#################################################
## WLST execution and output process
#################################################

path/to/java/java weblogic.WLST /path/to/jdbcmon.py

portic=off
bt=off
alarma80=off
alarma95=off

while read LINE
do
        max=`echo $LINE|awk '{print $3;}'`
        actual=`echo $LINE|awk '{print $4;}'`
        porcentage=`echo "scale=0; $actual*100/$max"|bc`
        if [ $porcentage -gt 85 ]
        then
                if [ $porcentage -gt 95 ]
                then
                        alarma95=on
                        echo $LINE  >>/tmp/alarma_pools_95.tmp
                        if [ $horario == "laboral" ]
                        then
                                portic=on
                        else
                                bt=on
                        fi
                else
                        alarma80=on
                        portic=on
                        echo $LINE >>/tmp/alarma_pools_80.tmp
                fi
        fi
done < <(cat /tmp/ActiveConn.log)

#################################################
## Sending email
#################################################

if [ $bt == "on" ]
then
        echo "Hay uno o varios servidores weblogic del entorno de producción con pools de conexiones a base de datos por encima del 95%." >>/tmp/mail_bt.tmp
        echo "Los siguientes servidores han de ser reiniciados urgentemente:" >>/tmp/mail_bt.tmp
        echo "" >>/tmp/mail_bt.tmp
        echo "Servidor Pool Max Actual Estado" >>/tmp/mail_bt.tmp
        echo "-----------------------------------------" >>/tmp/mail_bt.tmp
        cat /tmp/alarma_pools_95.tmp >>/tmp/mail_bt.tmp
        cat /tmp/mail_bt.tmp| mailx -r alarms_mail@domain.com -c alarms_mail@domain.com -s"Reinicio de servidores weblogic urgente" alarms_mail@portic.net
        rm /tmp/alarma_pools_95.tmp
        rm /tmp/alarma_pools_80.tmp
        rm /tmp/mail_bt.tmp
else
        if [ $portic == "on" ]
        then
                if [ $alarma95 == "on" ]
                then
                        echo "Hay uno o varios servidores weblogic del entorno de producción con pools de conexiones a base de datos por encima del 95%." >>/tmp/mail_portic.tmp
                        echo "Los siguientes servidores han de ser reiniciados urgentemente:" >>/tmp/mail_portic.tmp
                        echo "" >>/tmp/mail_portic.tmp
                        echo "Servidor Pool Max Actual Estado" >>/tmp/mail_portic.tmp
                        echo "------------------------------------------------" >>/tmp/mail_portic.tmp
                        cat /tmp/alarma_pools_95.tmp >>/tmp/mail_portic.tmp
                        cat /tmp/mail_portic.tmp| mailx -r alarms_mail@domain.com -c alarms_mail@domain.com -s"Reinicio de servidores weblogic urgente" administracio@domain.com
                        rm /tmp/alarma_pools_95.tmp
                        rm /tmp/alarma_pools_80.tmp
                        rm /tmp/mail_portic.tmp
                else
                        cat /tmp/alarma_pools_80.tmp|mailx -s"Alarma, pools de conexiones por encima del 80%" alarms_mail@domain.com
                        rm /tmp/alarma_pools_80.tmp
                fi
        fi
fi
rm /tmp/ActiveConn.log
