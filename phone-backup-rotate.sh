#!/usr/bin/env bash

IFS=$'\n'

backupDir="$1"

if [ -z "$backupDir" ] ; then
	echo "Backup Dir is Required" >&2
	exit 1
fi

backupsToKeep=30

dirsToRemove=$(find "$backupDir"/* -maxdepth 0 -type d | head -n -"${backupsToKeep}")

if [ -n "$dirsToRemove" ] ; then
	echo "Removing Backups:"
	echo "$dirsToRemove"
	(cd "$backupDir" && rm -rf $dirsToRemove)
else
	echo "No Backups to Remove"
fi
