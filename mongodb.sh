#!/bin/bash
DATE=$(date +%x)
USER_ID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
if [ $USER_ID -ne 0 ]
then
    echo -e "$R ERROR..You are not root user $N"
    exit 1
fi
VALIDATE(){
    if [ $1 -ne 0 ]
    then
        echo -e "$R $2....FAILED.$N"
        exit 1
    else    
        echo -e "$G $2....SUCCESSFUL. $N"
    fi
}

cp /home/centos/Shell/mongo.repo /etc/yum.repos.d/mongo.repo 

VALIDATE $? "copying mongo.repo"

yum install mongodb-org -y 
VALIDATE $? "install mongodb-org"

systemctl enable mongod 
VALIDATE $? "enable mongod"

systemctl start mongod 
VALIDATE $? "starting mongod"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf 
VALIDATE $? "127.0.0.1 to 0.0.0.0 changed"

systemctl restart mongod 
VALIDATE $? "restarting mongod"