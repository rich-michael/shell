

#!/bin/bash
#只在gerrit里面生成仓库
cd /home/gerrit/gerrit_dir/
pwd=${PWD}
t=$(date +%Y%m%d)
cp $pwd/etc/replication.config  $pwd/etc/replication.config.bak$t
if [ -d manifest ] ;then
        rm -rf ./manifest/
fi
git clone "$1"
cat ./manifest/default.xml|grep "path"|awk -F'"' '{print $2}' >path.list
rm -rf ./manifest/
base="$1"
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
cat >>$pwd/etc/replication.config<<EOF
[remote "$gerrit"]
projects = "$gerrit"
url = $gitbase/$gitpath
push = +refs/heads/*:refs/heads/*
push = +refs/tags/*:refs/tags/*
push = +refs/changes/*:refs/changes/*
threads = 3
EOF
fi
        fi
done < path.list

[ $? -eq 0 ] && /etc/init.d/gerrit restar
