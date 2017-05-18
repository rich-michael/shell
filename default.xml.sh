#!/bin/bash
#根据path.list生成repo需要的default.xml文件
set -x
set -e 
pwd=${PWD}
#1、传参$1为具体manifest.git的url,$2为git当前用户，$3为邮箱 
base="$1"
name="$2"
email="$3"
git clone "$1"
#>>>>>>>>>>>>>>>>>>一、修改defaul.xml<<<<<<<<<<<<<<<<<<<<<<<<<<<
#删掉default.xml最后一行</manifest>，方便修改文件。
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
#遍历path.list,增加path.list
while read line;do
        git=`echo $line|sed 's/\//\_/g'`.git
        echo -e "  <project path=\"$line\" name=\"$git\" review=\"http://192.168.1.49\"/>"  >> default.xml
done < ../path.list

#再增加</manifest>
echo "</manifest>" >>default.xml

#git 上传到gitlab里面去
git init  .
git config --global user.name $2
git config --global user.email $3
git add . -f
git commit -m "add default.xml"
git push origin master
cd ../
rm -rf manifest
