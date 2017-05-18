#!/bin/bash
#定义变量，用户列表userlist,配置文件
file=./userlist
sambafile=/etc/samba/smb.conf
#创建用户
cat $file | while read line 
do
sudo /usr/bin/expect <<-EOF
spawn sudo adduser $line
expect "password:"
send "123456\r"
expect "password"
send "123456\r"
expect "[]:"
send "\n"
expect "[]:"
send "\n"
expect "[]:"
send "\n"
expect "[]:"
send "\n"
expect "[]:"
send "\n"
expect "n]"
send "\n"
expect eof
EOF
sudo mkdir -p /home/$line/share
sudo chmod 777 /home/$line/share
sudo chown $line:$line  /home/$line/share
done

#修改配置文件，增加共享文件夹
#change smb.conf
cat $file | while read line 
do
cat >>$sambafile << EOF
[$line]
   comment = $line share doc
   path = /home/$line/share
   public = yes
   writable = yes
   valid users = $line
   create mask = 0777
   directory mask = 0777
   force user = $line
   force group = $line
   available = yes
   browseable = yes
EOF
done

#修改samba数据库
#sambauser_add
cat $file | while read line 
do
sudo /usr/bin/expect <<-EOF
spawn sudo smbpasswd -a $line
expect "password"
send "123456\r"
expect "password"
send "123456\r"
expect eof
EOF
done

sudo /etc/init.d/samba restart
sudo testparm
