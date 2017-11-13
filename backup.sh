#!/bin/csh
#######################################
#                                     #
# Backup script for FreeBSD           #
# using restic & telegram messages    #
#                                     #
#######################################

# Folders to backup
backup_files="/usr/home /usr/local/etc/apache24 /usr/local/etc/namedb /usr/local/etc/squid"

# Where to backup.
dest="change-me"
sshuser="user"
sshhost="host/ip"

#Telegram details
api=bot-api
chatid=chat-id
url="https://api.telegram.org/bot$api/sendMessage"

#Archive Filename
date=`date +%d-%b-%Y`
sql_file="sql_backup-$date.tgz"
src_dir="/tmp/backup"
tmp_dir="/tmp/backup"

#Database info
user="user"
password="mysql_password"
db_name="fulldbbackup"

# Print start status message.
curl -s -X POST $url -d chat_id=$chatid -d parse_mode="HTML" -d text="Backing up <b>$backup_files</b> to <b>$sshhost/$dest</b>"

#starting backup
restic -r sftp:$sshuser@$sshhost:$dest -p /root/pw backup $backup_files

mysqldump --user=$user --events --ignore-table=mysql.event --password=$password --all-databases > $tmp_dir/$db_name-$date.sql

tar -cpzf $tmp_dir/$sql_file --directory=/ --exclude=proc --exclude=sys --exclude=dev/pts --exclude=$tmp_dir $src_dir

restic -r sftp:$sshuser@$sshhost:$dest -p /root/pw backup $src_dir/$sql_file

restic -r sftp:$sshuser@$sshhost:$dest -p /root/pw forget --keep-last 1

restic -r sftp:$sshuser@$sshhost:$dest -p /root/pw snapshots >> /tmp/backup/ss

uname -onr >> /tmp/backup/info1
uptime >> /tmp/backup/info2

uname=`cat /tmp/backup/info1`
uptime=`cat /tmp/backup/info2`
snapshots=`cat /tmp/backup/ss`

curl -s -X POST $url -d chat_id=$chatid -d parse_mode="HTML" -d text="<b>Current backups</b>%0A %0A $snapshots%0A %0A Current uptime of %0A <b>$uname</b> is %0A %0A <b>$uptime</b>"

#delete files
rm /tmp/backup/$db_name-$date.sql
rm /tmp/backup/$sql_file
rm /tmp/backup/info1
rm /tmp/backup/info2
rm /tmp/backup/ss
#done
