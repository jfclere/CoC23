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
HOST=${5:-localhost}
HTTPDPORT=${6:-8089}
HTTPDSPORT=${7:-8099}
HTTPD_ONLY=false

SCRIPT_DIR=`dirname "${0}"`

function stop_vmstat {
  if [ -n "${VMSTAT_PID}" ] ; then
    echo 'Stopping vmstat'

    kill -15 ${VMSTAT_PID}

    unset VMSTAT_PID
  fi
}

function quit {
  echo
  stop_vmstat

  exit
}

trap "quit" INT TERM EXIT

ssh ${HOST} vmstat -n 5 > "${REPORT_DIR}/vmstat.log" &
VMSTAT_PID=$!

if [ ! "${SKIP_HTTP_TESTS}" ] ; then
  # httpd
  echo "Running test on http://${HOST}:${HTTPDPORT}/"
  "${SCRIPT_DIR}/runfiletests.sh" 1 1 0 http://${HOST}:${HTTPDPORT}/ >/dev/null
  sleep ${SLEEP_TIME}
  "${SCRIPT_DIR}/runfiletests.sh" ${REQUESTS} ${CONCURRENCY} ${TIME_LIMIT} http://${HOST}:${HTTPDPORT}/ | tee "${REPORT_DIR}/results_httpd.txt" 2>&1
fi
if [ ! "${SKIP_HTTPS_TESTS}" ] ; then
  # httpd
  echo "Running test on https://${HOST}:${HTTPDPORT}/"
  "${SCRIPT_DIR}/runfiletests.sh" 1 1 0 https://${HOST}:${HTTPDSPORT}/ >/dev/null
  sleep ${SLEEP_TIME}
  "${SCRIPT_DIR}/runfiletests.sh" ${REQUESTS} ${CONCURRENCY} ${TIME_LIMIT} https://${HOST}:${HTTPDSPORT}/ | tee "${REPORT_DIR}/results_httpd_ssl.txt" 2>&1
fi
if ${HTTPD_ONLY}; then
  echo "Done httpd/httpds only proxy"
  quit
  exit
fi

# Proxy AJP
"${SCRIPT_DIR}/runfiletests.sh" 1 1 0 http://${HOST}:${HTTPDPORT}/tcaj/ >/dev/null
sleep ${SLEEP_TIME}
"${SCRIPT_DIR}/runfiletests.sh" ${REQUESTS} ${CONCURRENCY} ${TIME_LIMIT} http://${HOST}:${HTTPDPORT}/tcaj/ | tee "${REPORT_DIR}/results_proxy_ajp.txt" 2>&1

# Proxy HTTP
"${SCRIPT_DIR}/runfiletests.sh" 1 1 0 http://${HOST}:${HTTPDPORT}/tchp/ >/dev/null
sleep ${SLEEP_TIME}
"${SCRIPT_DIR}/runfiletests.sh" ${REQUESTS} ${CONCURRENCY} ${TIME_LIMIT} http://${HOST}:${HTTPDPORT}/tchp/ | tee "${REPORT_DIR}/results_proxy_http.txt" 2>&1

# Mod_jk
"${SCRIPT_DIR}/runfiletests.sh" 1 1 0 http://${HOST}:${HTTPDPORT}/jkaj/ >/dev/null
sleep ${SLEEP_TIME}
"${SCRIPT_DIR}/runfiletests.sh" ${REQUESTS} ${CONCURRENCY} ${TIME_LIMIT} http://${HOST}:${HTTPDPORT}/jkaj/ | tee "${REPORT_DIR}/results_mod_jk.txt" 2>&1

# Proxy AJP SSL tests.
"${SCRIPT_DIR}/runfiletests.sh" 1 1 0 https://${HOST}:${HTTPDSPORT}/tcaj/ >/dev/null
sleep ${SLEEP_TIME}
"${SCRIPT_DIR}/runfiletests.sh" ${REQUESTS} ${CONCURRENCY} ${TIME_LIMIT} https://${HOST}:${HTTPDSPORT}/tcaj/ | tee "${REPORT_DIR}/results_ssl_proxy_ajp.txt" 2>&1

# Proxy HTTP
"${SCRIPT_DIR}/runfiletests.sh" 1 1 0 https://${HOST}:${HTTPDSPORT}/tchp/ >/dev/null
sleep ${SLEEP_TIME}
"${SCRIPT_DIR}/runfiletests.sh" ${REQUESTS} ${CONCURRENCY} ${TIME_LIMIT} https://${HOST}:${HTTPDSPORT}/tchp/ | tee "${REPORT_DIR}/results_ssl_proxy_http.txt" 2>&1

# Mod_jk
"${SCRIPT_DIR}/runfiletests.sh" 1 1 0 https://${HOST}:${HTTPDSPORT}/jkaj/ >/dev/null
sleep ${SLEEP_TIME}
"${SCRIPT_DIR}/runfiletests.sh" ${REQUESTS} ${CONCURRENCY} ${TIME_LIMIT} https://${HOST}:${HTTPDSPORT}/jkaj/ | tee "${REPORT_DIR}/results_ssl_mod_jk.txt" 2>&1

quit
