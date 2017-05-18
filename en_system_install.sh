#!/bin/bash
#清理yum源，需要手动按Y
sudo apt-get update
sleep 2

#安装JDK
sudo apt-get install openjdk-7-jdk
sleep 2

#安装git服务器，还有其他的库文件
sudo apt-get install git-core gnupg flex bison gperf build-essential \
  zip curl zlib1g-dev gcc-multilib g++-multilib libc6-dev-i386 \
  lib32ncurses5-dev x11proto-core-dev libx11-dev lib32z-dev ccache \
  libgl1-mesa-dev libxml2-utils xsltproc unzip
