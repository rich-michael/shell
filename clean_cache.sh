#!/bin/bash
#定期处理服务器缓存
while true;do
    i=0
    while (($i<90))
        do
                /usr/bin/top -bn 1|awk 'NR>7{print $9}'|head -n 3  >>/tmp/top.list
                let "i++"
        done
    sleep 1
    nu=`cat /tmp/top.list|awk '$1>30{print $0}'|wc -l`
    if [ $nu -eq 0 ];then
        sudo sync
        sudo sync
        sudo sync
        sudo sh -c 'echo 3 > /proc/sys/vm/drop_caches'
        t=`date +"%Y%m%d %H:%M:%S"`
        echo "$t 成功清理缓存一次" >> /var/log/clean_cache`date +%Y%m%d`.log
    else
        rm -rf /tmp/top.list
    fi
    sleep 600
    find /var/log/  -mtime +2 -name "clean_cache*" -exec rm {} \;
done

#使用方法:安装nohup命令;编辑/etc/rc.local,加入 nohup bash cache_clean.sh &
