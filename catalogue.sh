#!/bin/bash
DATE=$(date +%x-%T)
USER_ID=$(id -u)
USER=$(id roboshop)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
if [ $USER_ID -ne 0 ]
then
    echo -e "$R ERROR: You are not root user $N"
    exit 1
fi

VALIDATE(){
    if [ $1 -ne 0 ]
    then
        echo -e "$R $2....FAILED $N"
        exit 1
    else
        echo -e "$G $2....SUCCESSFULL $N"
    fi
}

dnf module disable nodejs -y
VALIDATE $? "module disable nodejs"

dnf module enable nodejs:18 -y
VALIDATE $? "module enable nodejs:18"


dnf install nodejs -y
VALIDATE $? "install nodejs"

if [ $USER -ne 0 ]
then
    useradd roboshop
else    
    echo -e "$Y user roboshop is already exist $N"
fi

if [ -d /app ]   # For file "if [ -f /home/rama/file ]"
 then
     echo -e "$Y /app $G dir present $N"
 else
     echo -e "$G dir not present creating $N"
     mkdir /app
fi

if [ -d /tmp/catalogue.zip ]   # For file "if [ -f /home/rama/file ]"
 then
     echo -e "$Y catalogue.zip dir present $N"
 else
     echo -e "$G catalogue.zip Download the application code $N"
     curl -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip
fi

cd /app 
VALIDATE $? "changeing to app Directory"

if [ -f /app/package.jon ]
 then
     echo -e "$Y data present $N"
 else
     echo -e "$G "unzinping catalogue" $N"
     unzip /tmp/catalogue.zip
fi
# unzip /tmp/catalogue.zip
# VALIDATE $? "unzinping catalogue"

npm install 
VALIDATE $? "npm install "

cp /home/centos/shell-script/catalogue.service /etc/systemd/system/catalogue.service
VALIDATE $? "coping catalogue.service"

systemctl daemon-reload
VALIDATE $? "daemon-reload"

systemctl enable catalogue
VALIDATE $? "enable catalogue"

systemctl start catalogue
VALIDATE $? "start catalogue"

cp /home/centos/shell-script/mongo.repo /etc/yum.repos.d/mongo.repo
VALIDATE $? "copying mongo.repo"

yum install mongodb-org-shell -y
VALIDATE $? "install mongodb-org-shell"

mongo --host mongodb.venkateshamsonnalia143.online < /app/schema/catalogue.js
VALIDATE $? "connecting to host server"