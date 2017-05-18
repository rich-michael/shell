#!/bin/bash
#只上传子仓库
set -x
set -e 
pwd=${PWD}

#1、传参$1为具体manifest.git的url,$2为git当前用户，$3为邮箱 
base="$1"
name="$2"
email="$3"

git clone "$1"

#>>>>>>>>>>>>>>>>>>二、上传子仓库<<<<<<<<<<<<<<<<<<<<<<<<<<<
t=$(date +%Y%m%d)
cp path.list path$t.list
gitbase="${base%%/*}"
cat manifest/default.xml|grep "path"|awk -F'"' '{print $2}' >path.list
while read line;do
        if [ -z $line ];then
                echo "当前文件夹不存在，请先创建" 
                exit
        fi

        if [ $(ls -A $pwd/$line|wc -l ) -eq 0 ];then
                echo "文件夹为空，请注意！！！"
                exit
        fi
        git=`echo $line|awk -F "/" '{print $1}'`
        gerrit=`echo $line|sed 's/\//\_/g'`
        gitpath=`echo $line|sed 's/\//\_/g'`.git
        cd $pwd/$line
cat >.gitreview <<EOF
[gerrit]
host=192.168.1.49 
port=29418
project=$git/$gerrit
EOF
cat >.testr.conf <<EOF
est_command=OS_STDOUT_CAPTURE=1
OS_STDERR_CAPTURE=1
OS_TEST_TIMEOUT=60
${PYTHON:-python} -m subunit.run discover -t ./ ./ $LISTOPT $IDOPTION
test_id_option=--load-list $IDFILE
test_list_option=-list
EOF
        rm -rf .git
        git init .  1>&2
        git config --global user.name $2
        git config --global user.email $3
        git add . -f  1>&2
        git commit -m "init commit"  1>&2
        git push --set-upstream $gitbase/$gitpath  master
done < path.list
rm -rf ../manifest

