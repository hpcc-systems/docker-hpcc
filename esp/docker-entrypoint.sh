#!/bin/sh
set -e

/usr/bin/ssh-keygen -A
#/etc/init.d/hpcc-init start
mkdir -p /var/lib/HPCCSystems/myesp
mkdir -p /var/log/HPCCSystems/myesp
cat /base-esp.xml | sed "s/\[DALIIP\]/$1/" > /var/lib/HPCCSystems/myesp/esp.xml
chown -R hpcc:hpcc /var/lib/HPCCSystems
chown -R hpcc:hpcc /var/log/HPCCSystems

#cat /var/lib/HPCCSystems/myesp/esp.xml
cd /var/lib/HPCCSystems/myesp
/opt/HPCCSystems/bin/esp 




