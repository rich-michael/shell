#!/bin/bash
#此脚本是根据root用户来生成repo所需要的gitlab仓库,并根据manifest.git定时检查是否有新增加的小仓库
set -x 
set -e 

cd /var/opt/gitlab/git-data/repositories
git clone git@192.168.1.49:root/manifest.git
cp manifest/manifest.list  ./
cp manifest/manifest.list  /home/gerrit/gerrit_dir/
rm -rf manifest/

while read list;do
	#1、获取清单列表manifes.git中的default.xml
	group=$(echo "$list" |awk -F':' '{print $2}'|awk -F '/' '{print $1}')
	echo "=========所属组是$group==========="

	#判断组存不存在
	if [ -d $group ];then
		cd $group
	else 
		echo "所属组是$group,请创建组"
		mkdir $group
		chown -R  git:root  $group
		cd $group
	fi

	#查看defaut.xml清单，生成path.list
	git clone $list
	cat manifest/default.xml|grep "path" | awk -F '"' '{print $4}' > project.list
	#遍历清单，初始化仓库
	while read line;do 
		if [ -d $line ];then
			continue
		else
			git init --bare $line
			chown -R git:root $line
			echo "=========$line.git init ============"
		fi
	done < project.list
	rm -rf manifest/
	cd ../
done < manifest.list
#导入仓库
gitlab-rake gitlab:import:repos
sleep 5
gitlab-ctl restart
sleep 20

#gerrit生成对应的仓库
cd /home/gerrit/gerrit_dir/
pwd=${PWD}
t=$(date +%Y%m%d)
cp $pwd/etc/replication.config  $pwd/etc/replication.config.bak$t
while read list ; do 
	if [ -d manifest ] ;then
	        rm -rf ./manifest/
	fi
	git clone "$list"
	cat ./manifest/default.xml|grep "path"|awk -F'"' '{print $2}' >path.list
	rm -rf ./manifest/
	base="$list"
	gitbase="${base%%/*}"
	while read line; do
	        git=`echo $line|awk -F "/" '{print $1}'`
	        gerrit=`echo $line|sed 's/\//\_/g'`
	        gitpath=`echo $line|sed 's/\//\_/g'`.git
	        if [ -d $pwd/$git/$gitpath ]; then
	                continue
	        else
	                ssh -p 29418 admin@localhost gerrit create-project --empty-commit --name ./$git/$gerrit  < /dev/null
	                cd $pwd/$git/
	                rm -rf "$gitpath"
	                git clone --bare $gitbase/$gerrit
	                cd $pwd
	                chown -R gerrit:gerrit $pwd/$git
#针对replication.config由于错误，不断增加新的同名标签，因此做一个判断
cat $pwd/etc/replication.config|grep "\[remote \"$gerrit\"\]" 
if [ $? -eq 0 ];then
exit
else
cat >>$pwd/etc/replication.config<<EOF
[remote "$gerrit"]
projects = $git/$gerrit
url = $gitbase/$gitpath
push = +refs/heads/*:refs/heads/*
push = +refs/tags/*:refs/tags/*
push = +refs/changes/*:refs/changes/*
threads = 3
EOF
fi
	        fi
	done < path.list
done < manifest.list

[ $? -eq 0 ] && /etc/init.d/gerrit restart
