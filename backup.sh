#!/bin/bash
####################################
#
# Backup script.
#
####################################

# What to backup. 
backup_files="/usr/home /usr/local/etc/apache24 /usr/local/etc/namedb"

# Where to backup to.
dest="/tmp/backup"

# Create archive filename.
day=`date +%d-%b-%Y`
hostname=$(hostname -s)
archive_file="$hostname-$day.tgz"

#Archive Filename
date=`date +%d-%b-%Y`
sql_file="sql_backup-$date.tgz"
src_dir="/tmp/backup"

#Database info
user="root"
password="change.me"
db_name="fulldbbackup"

#Telegram details
api=bot api 
chatid=chat id info

#ssh info
suser="user"
shost="host/ip"
sloc="backup remote location"

# Print start status message.
curl -s -X POST https://api.telegram.org/bot$api/sendMessage -d chat_id=$chatid -d parse_mode="HTML" -d text="Backing up <b>$backup_files</b> to <b>$dest/$archive_file</b>"

# Backup the files using tar.
tar czvfP $dest/$archive_file $backup_files

# Print end status message.
curl -s -X POST https://api.telegram.org/bot$api/sendMessage -d chat_id=$chatid -d parse_mode="HTML" -d text="Backup finished at <b>$dest/$archive_file</b>"

# Copy over ssh
curl -s -X POST https://api.telegram.org/bot$api/sendMessage -d chat_id=$chatid -d parse_mode="HTML" -d text="Copy backup <b>$archive_file</b> to orangepi"

scp $dest/$archive_file $suser@$shost:$sloc

#finished copy 
curl -s -X POST https://api.telegram.org/bot$api/sendMessage -d chat_id=$chatid -d parse_mode="HTML" -d text="Backup <b>$archive_file<b> to orangepi complete"

#Start database backup
curl -s -X POST https://api.telegram.org/bot$api/sendMessage -d chat_id=$chatid -d parse_mode="HTML" -d text="Starting SQL Backup"

#dump database
curl -s -X POST https://api.telegram.org/bot$api/sendMessage -d chat_id=$chatid -d parse_mode="HTML" -d text="dump database"

mysqldump --user=$user --events --ignore-table=mysql.event --password=$password --all-databases > $dest/$db_name-$date.sql

#make tar
curl -s -X POST https://api.telegram.org/bot$api/sendMessage -d chat_id=$chatid -d parse_mode="HTML" -d text="Backup the files using tar."

tar -cpzf $dest/$sql_file --directory=/ --exclude=proc --exclude=sys --exclude=dev/pts --exclude=$dest $src_dir

# Copy over ssh
curl -s -X POST https://api.telegram.org/bot$api/sendMessage -d chat_id=$chatid -d parse_mode="HTML" -d text="Copy backup to orangepi"

scp $dest/$sql_file $suser@$shost:$sloc

uname -onr >> /tmp/backup/info1
uptime >> /tmp/backup/info2

uname=`cat /tmp/backup/info1`
uptime=`cat /tmp/backup/info2`

curl -s -X POST https://api.telegram.org/bot$api/sendMessage -d chat_id=$chatid -d parse_mode="HTML" -d text="Current uptime of <b>$uname</b> is <b>$uptime</b>. All backups complete, good bye! :)"

#delete files
rm $dest/$archive_file
rm $dest/$db_name-$date.sql
rm $dest/$sql_file
rm /tmp/backup/info1
rm /tmp/backup/info2
#done
