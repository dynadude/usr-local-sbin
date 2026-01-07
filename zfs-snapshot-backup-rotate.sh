#!/usr/bin/env bash

backupsToKeep=30

dirsToRemove=$(zfs list -t snapshot -o name storage-zpool/storage | tail -n +2 | head -n -${backupsToKeep})

if [ -n "$dirsToRemove" ]; then
	echo "Removing Backups:"
	echo "$dirsToRemove"
	echo "$dirsToRemove" | xargs -n1 zfs destroy
else
	echo "No Backups to Remove"
fi
