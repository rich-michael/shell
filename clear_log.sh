#!/bin/sh
find /mnt/apache-tomcat-7.0.63/logs/ -mtime +7 -name "*.*" -exec rm {} \;
find /mnt/apache-tomcat-7.0.63/logs/ -mtime -1 -name "*.out" -exec rm {} \;
find /mnt/log/nginx/bak -mtime +7 -name "*.*" -exec rm {} \;
find /mnt/log/nginx/access/bak -mtime +7 -name "*.*" -exec rm {} \;
find /mnt/log/appstore -mtime +7 -name "*.*" -exec rm {} \;
