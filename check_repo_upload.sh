#!/bin/bash
#上传原始代码到gitlab上面去
set -x
set -e 
pwd=${PWD}

#1、传参$1为具体manifest.git的url,$2为git当前用户，$3为邮箱 
base="$1"
name="$2"
email="$3"

git clone "$1"
#>>>>>>>>>>>>>>>>>>一、修改defaul.xml<<<<<<<<<<<<<<<<<<<<<<<<<<<

删掉default.xml最后一行</manifest>，方便修改文件。
cd manifest
if [ -z $(ls default.xml) ] ;then
        touch default.xml
else
        cp default.xml defualt.xml.bak
fi
cat > default.xml <<EOF
<?xml version="1.0" encoding="UTF-8"?> 
<manifest> 
  <remote  name="origin" fetch="."/>
  <default revision="master" remote="origin" sync-j="4" />
</manifest>
EOF
sed -i '$d' default.xml
遍历path.list,增加path.list
while read line;do
        git=`echo $line|sed 's/\//\_/g'`.git
        echo -e "  <project path=\"$line\" name=\"$git\" review=\"http://192.168.1.49:9999\"/>"  >> default.xml
done < ../path.list

再增加</manifest>
echo "</manifest>" >>default.xml

git 上传到gitlab里面去
git init  .
git config --global user.name $2
git config --global user.email $3
git add . -f
git commit -m "add default.xml"
git push origin master
cd ../

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
        gitpath=`echo $line|sed 's/\//\_/g'`.git
        cd $pwd/$line
        touch .gitreview
        cat >.gitreview <<EOF
[gerrit]
host=192.168.1.49 
port=29418
project=`echo $line|sed 's/\/\_/g'`
EOF
        touch .testr.conf
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
