#!/bin/bash
#
# Runs the tests for all files against a particular base URL
#
NUMBER_AB=4

AB=/usr/sbin/ab
AB_OPTS="-r"
REQUESTS=${1:-1000}
CONCURRENCY=${2:-1}
TIME_LIMIT=${3:-0}
BASE_URL=${4:-http://localhost/}
FILES="4KiB.bin 8KiB.bin 16KiB.bin 32KiB.bin 64KiB.bin 128KiB.bin 256KiB.bin 512KiB.bin 1MiB.bin 2MiB.bin 4MiB.bin 8MiB.bin 16MiB.bin 32MiB.bin"

if [ -x /usr/bin/ab ]; then
  AB=/usr/bin/ab
fi

if [ "$TIME_LIMIT" = "0" ] ; then
TIME_LIMIT=""
else
TIME_LIMIT="-t $TIME_LIMIT"
fi

for f in ${FILES} ; do
  echo `date`
  echo Fetching ${BASE_URL}${f} -c ${CONCURRENCY} ${TIME_LIMIT} -n ${REQUESTS}

  concur=`expr ${CONCURRENCY} / ${NUMBER_AB} `
  if [ ${concur} -eq 0 ]; then
    concur=1
  fi

  started=0
  while [ ${started} -lt ${CONCURRENCY} ]
  do
    started=`expr ${started} + ${concur} `
    echo ${AB} ${AB_OPTS} ${AB_KEEPALIVE} -c ${CONCURRENCY} ${TIME_LIMIT} -n ${REQUESTS} ${BASE_URL}${f}
    ${AB} ${AB_OPTS} ${AB_KEEPALIVE} -c ${CONCURRENCY} ${TIME_LIMIT} -n ${REQUESTS} ${BASE_URL}${f} > $$.ab.${started} &
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
      cat $$.ab.*
      break
    fi
  done
done
