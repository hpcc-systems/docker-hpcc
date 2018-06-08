#!/bin/sh
set -e

/usr/bin/ssh-keygen -A
#/etc/init.d/hpcc-init start

cmd="$@"
if [ "${EXEC_IN_LOOP}" = "true"]
then
  interval=5
  [ -n EXEC_INTERVAL ] && interval=${EXEC_INTERVAL}
  while [ 1 ]
  do
    [ -e "$cmd" ] && exec "$cmd"
    sleep $interval
  done
else
  exec "$cmd"
fi
