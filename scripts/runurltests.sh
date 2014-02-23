#!/bin/bash
#
# Runs tests on all base URLs for a particular concurrency level.
#

# Enough requests to fill 10 minutes?
REQUESTS=10000000

TIME_LIMIT=${1:-30}
CONCURRENCY=${2:-40}
REPORT_DIR=${3:-.}
SLEEP_TIME=${4:-5}

SCRIPT_DIR=`dirname "${0}"`

function stop_vmstat {
  if [ -n "${VMSTAT_PID}" ] ; then
    echo 'Stopping vmstat'

    kill -HUP ${VMSTAT_PID}

    unset VMSTAT_PID
  fi
}

function quit {
  echo
  stop_vmstat

  exit
}

trap "quit" INT TERM EXIT

vmstat -n 5 > "${REPORT_DIR}/vmstat.log" &
VMSTAT_PID=$!

if [ ! "${SKIP_HTTP_TESTS}" ] ; then
  # httpd
  "${SCRIPT_DIR}/runfiletests.sh" 1 1 0 http://localhost/ >/dev/null
  sleep ${SLEEP_TIME}
  "${SCRIPT_DIR}/runfiletests.sh" ${REQUESTS} ${CONCURRENCY} ${TIME_LIMIT} http://localhost/ | tee "${REPORT_DIR}/results_httpd.txt" 2>&1
fi

# Coyote non-APR
"${SCRIPT_DIR}/runfiletests.sh" 1 1 0 http://localhost:8001/ >/dev/null
sleep ${SLEEP_TIME}
"${SCRIPT_DIR}/runfiletests.sh" ${REQUESTS} ${CONCURRENCY} ${TIME_LIMIT} http://localhost:8001/ | tee "${REPORT_DIR}/results_coyote.txt" 2>&1

# Coyote APR
"${SCRIPT_DIR}/runfiletests.sh" 1 1 0 http://localhost:8002/ >/dev/null
sleep ${SLEEP_TIME}
"${SCRIPT_DIR}/runfiletests.sh" ${REQUESTS} ${CONCURRENCY} ${TIME_LIMIT} http://localhost:8002/ | tee "${REPORT_DIR}/results_coyote_apr.txt" 2>&1

# Coyote APR w/o sendfile
"${SCRIPT_DIR}/runfiletests.sh" 1 1 0 http://localhost:8003/ >/dev/null
sleep ${SLEEP_TIME}
"${SCRIPT_DIR}/runfiletests.sh" ${REQUESTS} ${CONCURRENCY} ${TIME_LIMIT} http://localhost:8003/ | tee "${REPORT_DIR}/results_coyote_apr_ns.txt" 2>&1

# Coyote NIO
"${SCRIPT_DIR}/runfiletests.sh" 1 1 0 http://localhost:8004/ >/dev/null
sleep ${SLEEP_TIME}
"${SCRIPT_DIR}/runfiletests.sh" ${REQUESTS} ${CONCURRENCY} ${TIME_LIMIT} http://localhost:8004/ | tee "${REPORT_DIR}/results_coyote_nio.txt" 2>&1

# Coyote NIO w/o sendfile
"${SCRIPT_DIR}/runfiletests.sh" 1 1 0 http://localhost:8006/ >/dev/null
sleep ${SLEEP_TIME}
"${SCRIPT_DIR}/runfiletests.sh" ${REQUESTS} ${CONCURRENCY} ${TIME_LIMIT} http://localhost:8006/ | tee "${REPORT_DIR}/results_coyote_nio_ns.txt" 2>&1

quit
