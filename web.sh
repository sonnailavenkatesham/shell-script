#!/bin/bash
DATE=$(date +%x-%T)
USER_ID=$(id -u)
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
        echo -e "$G $2....SUCCESSFULL$N"
    fi
}

dnf install nginx -y
VALIDATE $? "install nginx"

systemctl enable nginx
VALIDATE $? "enable nginx"

systemctl restart nginx
VALIDATE $? "start nginx"

rm -rf /usr/share/nginx/html/*
VALIDATE $? "removing html/*"

curl -o /tmp/web.zip https://roboshop-builds.s3.amazonaws.com/web.zip
VALIDATE $? "Downloaded web zip file"

cd /usr/share/nginx/html
VALIDATE $? "Changed to html "

unzip /tmp/web.zip
VALIDATE $? "Unziping web"

cp /home/centos/Shell/roboshop.conf /etc/nginx/default.d/roboshop.conf 
VALIDATE $? "copying roboshop.conf"

systemctl restart nginx  
VALIDATE $? "restart nginx"