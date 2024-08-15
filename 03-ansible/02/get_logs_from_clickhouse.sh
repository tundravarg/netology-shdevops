#!/bin/bash

set -x
docker exec ntlg-clickhouse clickhouse client --query 'SELECT * FROM logs.file_log'
