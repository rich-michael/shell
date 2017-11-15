#!/bin/bash

#遍历/home,得出容量与用户，导出到对应文件/tmp/du.log
for i in /home/*
   do
       [ -d  $i ] && du -sh $i

   done | sed -n 's/\/home\///gp' > $HOME/du.log

sleep 2
#机器内部用量，space_sum总容量，space_used已使用量，space_left剩余用量，used_percent百分比
space_sum=`df -h|grep "T"|awk '{print $2}'`
space_used=`df -h|grep "T"|awk '{print $3}'`
space_left=`df -h|grep "T"|awk '{print $4}'`
used_percent=`df -h|grep "T"|awk '{print $5}'`

#测试环境
key="project_auto_check20!*"
url="http://192.168.1.158:8088/"
t=`curl -s "$url/PJset.php?type=102"`
sign=`echo -n "$t$key"|md5sum|cut -d ' ' -f1`

#正式环境
net_url="xxxx.cn"
net_t=`curl -s "$net_url/PJset.php?type=102"`
net_sign=`echo -n "$net_t$key"|md5sum|cut -d ' ' -f1`

#提取参数user,space,ip,上传传参
curl -s "$url/PJset.php?type=66&op=setMachineSpace&space_sum=$space_sum&space_used=$space_used&space_left=$space_left&used_percent=$used_percent&t=$t&sign=$sign&ip=$HOSTNAME"
curl -s "$net_url/PJset.php?type=66&op=setMachineSpace&space_sum=$space_sum&space_used=$space_used&space_left=$space_left&used_percent=$used_percent&t=$net_t&sign=$net_sign&ip=$HOSTNAME"

#读取/tmp/du.log，上传数据。
while read line
        do
                user=`echo "$line" |awk '{print $2}'`
                space=`echo "$line" |awk '{print $1}'`
                curl -s "$url/PJset.php?type=66&op=setUserSpace&user=$user&space=$space&ip=$HOSTNAME&t=$t&sign=$sign"
                curl -s "$net_url/PJset.php?type=66&op=setUserSpace&user=$user&space=$space&ip=$HOSTNAME&t=$net_t&sign=$net_sign"
		T_space=`echo $space|grep "T"`
		if [ -z $T_space ];then
        		continue
		else
        		T_num=`echo $T_space|sed 's/T//g'`
        		c=`echo "$T_num > 1.5"|bc`
        		if [ "$c" -eq "1" ];then
        		echo "你使用的服务器空间已超过1.5T，请及时清理"|mail -s "服务器空间监控"  $user@szprize.com
        		echo "你使用的服务器空间已超过1.5T，请及时清理"|mail -s "服务器空间监控"  $user@szprize.com
        		fi
		fi
	done < $HOME/du.log

#查看结果
[ $? -eq 0 ] && echo "$(date),脚本执行OK" >> $HOME/result.log
