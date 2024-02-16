#!/bin/bash
DATE=$(date +%x-%T)
USER_ID=$(id -u)
UNAME=$(id -u roboshop)
FILE=/tmp/$0.logs
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

dnf module disable nodejs -y >> $FILE
VALIDATE $? "module disable nodejs"

dnf module enable nodejs:18 -y >> $FILE
VALIDATE $? "module enable nodejs:18"


dnf install nodejs -y >> $FILE
VALIDATE $? "install nodejs"

if [ $UNAME -ne 0 ]
then
    echo -e "$Y User roboshop already exist$N"
else
    useradd roboshop
    echo -e "$G Created roboshop user$N"
fi

if [ -d /app ]   # For file "if [ -f /home/rama/file ]"
 then
     echo -e "$Y /app $G dir present $N"
 else
     echo -e "$G dir not present creating $N"
     mkdir /app
fi

if [ -f /tmp/catalogue.zip ]   # For file "if [ -f /home/rama/file ]"
 then
     echo -e "$Y catalogue.zip dir present $N"
 else
     echo -e "$G catalogue.zip Download the application code $N"
     curl -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip >> $FILE
fi

cd /app 
VALIDATE $? "changed to app Directory"

if [ -d /app/schema ]
 then
     echo -e "$Y data present $N"
 else
     echo -e "$G "unzinping catalogue" $N"
     unzip /tmp/catalogue.zip >> $FILE
fi

npm install >> $FILE
VALIDATE $? "npm install "

cp /tmp/shell-script/catalogue.service /etc/systemd/system/catalogue.service
VALIDATE $? "coping catalogue.service"

systemctl daemon-reload
VALIDATE $? "daemon-reload"

systemctl enable catalogue
VALIDATE $? "enable catalogue"

systemctl start catalogue
VALIDATE $? "start catalogue"

cp /tmp/shell-script/mongo.repo /etc/yum.repos.d/mongo.repo
VALIDATE $? "copying mongo.repo"

yum install mongodb-org-shell -y >> $FILE
VALIDATE $? "install mongodb-org-shell"

mongo --host mongodb.venkateshamsonnalia143.online < /app/schema/catalogue.js
VALIDATE $? "connecting to host server"

systemctl start catalogue
VALIDATE $? "start catalogue"