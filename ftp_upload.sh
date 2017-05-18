#!/bin/bash
#先压缩再ftp上传
logsname=$(date -d "1 day ago" +"%Y-%m-%d")
cd /mnt/tomcat-ins/appstore/logs/
echo $logsname
ftpdir=$(hostname)
echo $ftpdir
m=$(tar zcvf ./$logsname.log.tar.gz *$logsname*)
ftp -n<<!
open 210.21.222.202
user serverlog Szprize@2017
binary
cd /appcenter
lcd /mnt/tomcat-ins/appstore/logs/
mkdir $ftpdir
prompt
put ./$logsname.log.tar.gz ./${ftpdir}/$logsname.log.tar.gz
close
bye
!
