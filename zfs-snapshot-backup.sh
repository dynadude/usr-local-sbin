#!/usr/bin/env bash

TIMESTAMP=$(date +"%Y-%m-%d_%H:%M:%S")

zfs snapshot storage-zpool/storage@"${TIMESTAMP}"
