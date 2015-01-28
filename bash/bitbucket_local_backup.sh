#!/bin/bash

curl -u user:passwd https://bitbucket.org/api/1.0/user/repositories >/tmp/repositories.txt
tr ',' '\012' < /tmp/repositories.txt | grep "name" | awk -F: '{print $2}'> /tmp/repositories2.txt
sed 's/\"//g' /tmp/repositories2.txt >/tmp/repos.txt
rm /tmp/repositories.txt /tmp/repositories2.txt

for repo in `cat /tmp/repos.txt`
do
        if [ -a /app/bitbucket_backup/$repo ]
        then
                echo "El repositorio $repo ya existe, procedemos a actualizarlo"
                cd /app/bitbucket_backup/$repo
                hg pull ssh://hg@bitbucket.org/user/$repo
                hg update
        else
                echo "El repositorio $repo no existe, procedemos a ejecutar el clone"
                cd /app/bitbucket_backup
                hg clone ssh://hg@bitbucket.org/user/$repo
        fi
done

rm /tmp/repos.txt
