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

#Telegram details
api=bot api 
chatid=chat id info

#Archive Filename
date=`date +%d-%b-%Y`
sql_file="sql_backup-$date.tgz"
src_dir="/tmp/backup"

#Database info
user="root"
password="change.me"
db_name="fulldbbackup"

#ssh info
suser=user
shost=host
sloc=ssh host location

# Print start status message.
curl -s -X POST https://api.telegram.org/bot$api/sendMessage -d chat_id=$chatid -d text="Backing up $backup_files to $dest/$archive_file"

# Backup the files using tar.
tar czvfP $dest/$archive_file $backup_files

# Print end status message.
curl -s -X POST https://api.telegram.org/bot$api/sendMessage -d chat_id=$chatid -d text="Backup finished at $dest/$archive_file"


# Copy over ssh
curl -s -X POST https://api.telegram.org/bot$api/sendMessage -d chat_id=$chatid -d text="Copy backup $archive_file to orangepi"

scp $dest/$archive_file $suser@$shost:$sloc

#finished copy 
curl -s -X POST https://api.telegram.org/bot$api/sendMessage -d chat_id=$chatid -d text="Backup $archive_file to orangepi complete"

#delete tmp
rm $dest/$archive_file

#done
curl -s -X POST https://api.telegram.org/bot$api/sendMessage -d chat_id=$chatid -d text="Backups complete"

#Start database backup
curl -s -X POST https://api.telegram.org/bot$api/sendMessage -d chat_id=$chatid -d text="Starting SQL Backup"


#dump database
curl -s -X POST https://api.telegram.org/bot$api/sendMessage -d chat_id=$chatid -d text="dump database"

mysqldump --user=$user --events --ignore-table=mysql.event --password=$password --all-databases > $dest/$db_name-$date.sql

#make tar
curl -s -X POST https://api.telegram.org/bot$api/sendMessage -d chat_id=$chatid -d text="Backup the files using tar."

tar -cpzf $dest/$sql_file --directory=/ --exclude=proc --exclude=sys --exclude=dev/pts --exclude=$dest $src_dir

#delete sql file
rm $dest/$db_name-$date.sql

# Copy over ssh
curl -s -X POST https://api.telegram.org/bot$api/sendMessage -d chat_id=$chatid -d text="Copy backup to orangepi"

scp $dest/$sql_file $suser@$shost:$sloc

#delete sql tar file
rm $dest/$sql_file

uname -a >> /tmp/backup/info1
uptime >> /tmp/backup/info2

uname=`cat /tmp/backup/info1`
uptime=`cat /tmp/backup/info2`

curl -s -X POST https://api.telegram.org/bot$api/sendMessage -d chat_id=$chatid -d text="Current uptime of $uname is $uptime. All backups complete, good bye! :)"
rm /tmp/backup/info1
rm /tmp/backup/info2
#done