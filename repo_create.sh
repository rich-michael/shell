#!/bin/bash
#此脚本是根据root用户来生成repo所需要的gitlab仓库,并根据manifest.git定时检查是否有新增加的小仓库
set -x 
set -e 

cd /var/opt/gitlab/git-data/repositories
git clone git@192.168.1.49:root/manifest.git
cp manifest/manifest.list  ./
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

