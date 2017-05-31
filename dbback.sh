#! /bin/bash
 
#DBBack
#This script will backup and restore MySQL/MariaDB database
#
#
#
# https://github.com/AhmadShamli/DBBack/
#

TIMESTAMP=$(date +"%F")
BACKUP_DIR="/var/www/backup/database/$TIMESTAMP"
MYSQL_USER="root"
MYSQL=/usr/bin/mysql
MYSQL_PASSWORD='P@$$w0rd'
MYSQLDUMP=/usr/bin/mysqldump

act=$1
dir=$2

if [[ ! -z "$dir" ]]; then
	BACKUP_DIR=$dir
fi

if [[ ! -d "$BACKUP_DIR" ]];then
	mkdir -p "$BACKUP_DIR"
fi
 
if [[ ! -z "$act" && "$act" -eq "restore" ]];then

	echo "Restoring database/s...."
	
	fcount=$(ls -1 $BACKUP_DIR | wc -l)
	remain=$fcount
	echo "Found total of $fcount file/s in $BACKUP_DIR...."
	
	for files in $BACKUP_DIR/*
	do
		if [[ "$files" =~ \.t?gz$ ]];then
			mkdir $BACKUP_DIR/tmp
			name=$(basename "${files}" .gz)
			gunzip -kdc $files > $BACKUP_DIR/tmp/$name
			$MYSQL -u $MYSQL_USER -p$MYSQL_PASSWORD < $BACKUP_DIR/tmp/$name
			
			rm -rf $BACKUP_DIR/tmp
		else
			$MYSQL -u $MYSQL_USER -p$MYSQL_PASSWORD < $files
		fi
	remain=$(expr $remain - 1)
	echo "Remaining $remain database/s."
	done

else
	
	echo  "Backing database...."

	echo  "Gathering databases...."
	databases=`$MYSQL --user=$MYSQL_USER -p$MYSQL_PASSWORD -e "SHOW DATABASES;" | grep -Ev "(Database|information_schema|performance_schema)"`

	totaldb=${#databases[@]}
	echo  "Found total of $totaldb databases."

	echo  "Begin database backup..."

	for db in $databases
	do
	  echo "Backup $db in progress..."
	  $MYSQLDUMP --force --opt --user=$MYSQL_USER -p$MYSQL_PASSWORD --databases $db | gzip > "$BACKUP_DIR/$db.gz"
	  echo "Database $db has been backed-up"
	done
	
fi


