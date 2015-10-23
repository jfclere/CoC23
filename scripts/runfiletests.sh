#!/bin/bash
#
# Runs the tests for all files against a particular base URL
#
NUMBER_AB=4
HOSTSLIST="messaging-16 messaging-17 messaging-18 messaging-20"
HOST=messaging-23

AB=/home/jfclere/httpd-2.4.10/support/ab
#AB_OPTS="-r -H 'Host: localhost' -Z 'AES128-GCM-SHA256'"
AB_OPTS="-r -H 'Host: localhost'"
REQUESTS=${1:-1000}
CONCURRENCY=${2:-1}
TIME_LIMIT=${3:-0}
BASE_URL=${4:-http://localhost/}
FILES="4KiB.bin 8KiB.bin 16KiB.bin 32KiB.bin 64KiB.bin 128KiB.bin 256KiB.bin 512KiB.bin 1MiB.bin 2MiB.bin 4MiB.bin 8MiB.bin 16MiB.bin 32MiB.bin"
#FILES="4KiB.bin 16KiB.bin 64KiB.bin 128KiB.bin 512KiB.bin 2MiB.bin 8MiB.bin 32MiB.bin"

function stop_vmstat {
  if [ -n "${VMSTAT_PID}" ] ; then
    echo 'Stopping vmstat'

    kill -15 ${VMSTAT_PID}

    unset VMSTAT_PID
  fi
}
function start_vmstat {
  ssh ${HOST} vmstat -n 5 > "${REPORT_DIR}/${REPORT_FILE}.${f}.log" &
  VMSTAT_PID=$!
}

function quit {
  echo
  stop_vmstat
  exit
}

trap "quit" INT TERM EXIT

if [ "$TIME_LIMIT" = "0" ] ; then
TIME_LIMIT=""
else
TIME_LIMIT="-t $TIME_LIMIT"
fi

for f in ${FILES} ; do
  echo `date`

  concur=`expr ${CONCURRENCY} / ${NUMBER_AB} `
  # 2 ab per box (because ab is single processor logic
  concur=`expr ${CONCURRENCY} / 2 `
  if [ ${concur} -eq 0 ]; then
    concur=1
  fi

  started=0
  start_vmstat
  #while [ ${started} -lt ${CONCURRENCY} ]
  for remote in `echo "$HOSTSLIST"`
  do
    for box in 1 2
    do
      echo $remote.$box
      started=`expr ${started} + ${concur} `
      echo ${AB} ${AB_OPTS} ${AB_KEEPALIVE} -c ${concur} ${TIME_LIMIT} -n ${REQUESTS} ${BASE_URL}${f}
      echo Fetching ${BASE_URL}${f} -c ${concur} ${TIME_LIMIT} -n ${REQUESTS} > $$.ab.${started}
      ssh $remote ${AB} ${AB_OPTS} ${AB_KEEPALIVE} -c ${concur} ${TIME_LIMIT} -n ${REQUESTS} ${BASE_URL}${f} >> $$.ab.${started} &
    done
  done

  # Wait for ab
  while true
  do
    sleep 1
    finished=true
    for file in `ls $$.ab.*`
    do
      grep "Transfer rate:" $file 2>&1 > /dev/null
      if [ $? -ne 0 ]; then
         finished=false
         break
      fi
    done
    if $finished; then
      stop_vmstat
      cat $$.ab.*
      break
    fi
  done
done
