#!/bin/bash

source init-main.sh

/usr/sbin/sshd -f /etc/ssh/sshd_config &&
main