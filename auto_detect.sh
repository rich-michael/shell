#!/bin/bash
echo 
echo 
echo ">>>>>>>>>>>>>>>>>>>>>统计硬件信息<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
# "查看流通网卡em，网关gate,ip",
gate=`route -n|grep UG|awk '{print $2}'`
em=`route -n| grep UG |awk '{print $8}'`
ip=`ifconfig $em |awk -F":" 'NR==2{print $2}'|awk '{print $1}'`
#总容量space_sum,已用容量space_used,space_left,used_percent.
space_sum=`df -h|awk 'NR==2{print $2}'`
space_used=`df -h|awk 'NR==2{print $3}'`
space_left=`df -h|awk 'NR==2{print $4}'`
used_percent=`df -h|awk 'NR==2{print $5}'`
#系统，版本，cpu,缓存！
os=`cat /etc/issue|awk 'NR==1{print $0}'`
kernel=`awk '{print $3}' /proc/version`
cpu_model=`cat /proc/cpuinfo|grep "model name" |awk -F":" 'NR==1{print $2}'`
cache=`cat /proc/cpuinfo|grep "cache size"|awk -F":" 'NR==1{print $2}'`
echo "当前使用系统是：$os,当前内核版本：$kernel,CPU型号:$cpu_model,"
echo "节点ip：$ip, 网关:$gate ,网卡：$em，主机名：$HOSTNAME."
echo "磁盘情况,总用量:$space_sum,已使用空间：$space_used"
echo "剩余空间：$space_left,使用百分比:$used_percent."
echo
echo

sleep 1
# 统计用户信息
echo ">>>>>>>>>>>>>>>>>>>>>>>用户信息>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
#统计用户个数total,在线用户数online,用户列表userlist,在线用户列表onlielist"
total=`grep -v nobody /etc/passwd | awk -F: '$3>=500{print $1}'|wc -l`
online=`w -u|awk 'NR>=3{print $1}'|sort|uniq|wc -l`
userlist=`grep -v nobody /etc/passwd | awk -F: '$3>=500{print $1}'`
onlinelist=`w -u|awk 'NR>=3{print $1}'|sort|uniq`
echo "屏幕打印汇总："
echo "服务器的总用户数：$total个,在线用户：$online个"
echo "在线用户列表:"
echo "$onlinelist"
echo
echo
sleep 1
echo ">>>>>>>>>>>>>>>>>>>>>>>服务信息>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
#统计正在运行的服务
service=`service --status-all|grep running|awk -F"is" '{print $1}'`
on_service=`chkconfig --list|grep 3:on`

echo "正在运行的服务有"
echo "$service"
echo "开机启动的服务:"
echo "$on_service"

#
echo 
echo
echo "<<<<<<<<<<<<<<<<<<<<<<<当前的运行状态>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
echo "当前系统的状态："
status=`top -n 1|awk 'NR<=5{print $0}'`
echo "$status"


echo "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<状态分析>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
echo "load average(负载均衡，任务队列长度)："
balance_1=`top -n 1|awk -F ":" 'NR==1{print $5}'|awk -F"," '{print $1}'|sed 's/[[:space:]]//g'`
balance_5=`top -n 1|awk -F ":" 'NR==1{print $5}'|awk -F"," '{print $2}'|sed 's/[[:space:]]//g'`
balance_15=`top -n 1|awk -F ":" 'NR==1{print $5}'|awk -F"," '{print $3}'|sed 's/[[:space:]]//g'`
balance_limit=40
if (($balance_1 > $balance_limit ));then
        if (($balance_5 > $balance_limit));then
                if (($balance_15 > $balance_limit)); then
                        echo "系统负载可能过高，请检查！"
                fi
        fi
else echo "系统负载正常！"
fi
echo 
echo 
echo "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<进程分析>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
progress=`top -n 1|awk 'NR==2{print $0}'`
echo
