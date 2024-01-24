#!/bin/bash
#
#********************************************************************
#Author:            bmxch
#QQ:                1786964965
#Date:              2022-04-25
#FileName:          ssh_reset_rootpass.sh
#URL:               https://blog.csdn.net/bmxch?type=blog
#Description:       自动化设置root密码为随机数
#Copyright (C):     2023 All rights reserved
#********************************************************************



file_path='./ips.txt'

input_ips () {

# 清空文件内容  

> "$file_path"  

  

# 循环读取用户输入的IP地址并写入文件  

echo "请输入IP地址，输入空行结束："  

while true; do  

    read -r ip  

    if [[ -z "$ip" ]]; then  

        break  

    fi  

    # 使用正则表达式判断IP地址是否合法  

    if [[ ! $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then  

        echo "无效的IP地址格式，请重新输入。"  

        continue  

    fi  

    echo "$ip" >> "$file_path"  

done  

  

echo "IP地址已保存到文件 $file_path 中。"

}

input_ips

read_ips() {  

    local file_path=$1  

    local ip_list=$(while IFS= read -r ip; do echo "$ip"; done < "$file_path")  

    echo "$ip_list"  

}




IPLIST=$(read_ips "$file_path")  





echo "请输入密码："  
read -s PASS




. /etc/os-release

pre_os () {
if [[ $ID =~ ubuntu ]];then
   dpkg -l  sshpass &> /dev/null || { apt update; apt -y install sshpass; }
elif [[ $ID =~ rocky|centos|rhel ]];then
    rpm -q sshpass &>/dev/null || yum -y install sshpass
else
    echo "不支持当前操作系统"
    exit
fi

}

change_root_pass () {

[ -f ip_pass.txt ] && mv ip_pass.txt ip_pass.txt.bak

for ip in $IPLIST;do
    pass=`openssl rand -base64 12` 
    sshpass -p $PASS  ssh -o StrictHostKeyChecking=no  $ip "echo root:$pass | chpasswd" 
    if [ $? -eq 0 ];then
        echo  "$ip:root:$pass" >> ip_pass.txt
        echo "change root password is successfull on $ip"
    else
        echo "change root password is failed on $ip"
    fi
done

}

pre_os

change_root_pass

