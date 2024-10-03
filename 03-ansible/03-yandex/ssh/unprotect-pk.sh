#!/bin/sh

SRC_PK=admin
DST_PK=admin-nopwd

cp ${SRC_PK} ${DST_PK}
chmod 600 ${DST_PK}
ssh-keygen -p -f $DST_PK
