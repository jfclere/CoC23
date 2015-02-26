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
HTTPD_ONLY=true
REPORT_FILE="results_httpd.txt"

SCRIPT_DIR=`dirname "${0}"`
export REPORT_DIR
export REPORT_FILE

function quit {
  echo
  exit
}

trap "quit" INT TERM EXIT

if [ ! "${SKIP_HTTP_TESTS}" ] ; then
  # httpd
  REPORT_FILE=results_httpd
  echo "Running test on http://${HOST}:${HTTPDPORT}/"
  "${SCRIPT_DIR}/runfiletests.sh" 1 1 0 http://${HOST}:${HTTPDPORT}/ >/dev/null
  sleep ${SLEEP_TIME}
  "${SCRIPT_DIR}/runfiletests.sh" ${REQUESTS} ${CONCURRENCY} ${TIME_LIMIT} http://${HOST}:${HTTPDPORT}/ | tee "${REPORT_DIR}/${REPORT_FILE}.txt" 2>&1
fi
if [ ! "${SKIP_HTTPS_TESTS}" ] ; then
  # httpd
  REPORT_FILE=results_httpd_ssl
  echo "Running test on https://${HOST}:${HTTPDSPORT}/"
  "${SCRIPT_DIR}/runfiletests.sh" 1 1 0 https://${HOST}:${HTTPDSPORT}/ >/dev/null
  sleep ${SLEEP_TIME}
  "${SCRIPT_DIR}/runfiletests.sh" ${REQUESTS} ${CONCURRENCY} ${TIME_LIMIT} https://${HOST}:${HTTPDSPORT}/ | tee "${REPORT_DIR}/${REPORT_FILE}.txt" 2>&1
fi
if ${HTTPD_ONLY}; then
  echo "Done httpd/httpds only proxy"
  quit
  exit
fi

# Coyote non-APR
REPORT_FILE=results_coyote
"${SCRIPT_DIR}/runfiletests.sh" 1 1 0 http://${HOST}:8001/ >/dev/null
sleep ${SLEEP_TIME}
"${SCRIPT_DIR}/runfiletests.sh" ${REQUESTS} ${CONCURRENCY} ${TIME_LIMIT} http://${HOST}:8001/ | tee "${REPORT_DIR}/${REPORT_FILE}.txt" 2>&1

# Coyote APR
REPORT_FILE=results_coyote_apr
"${SCRIPT_DIR}/runfiletests.sh" 1 1 0 http://${HOST}:8002/ >/dev/null
sleep ${SLEEP_TIME}
"${SCRIPT_DIR}/runfiletests.sh" ${REQUESTS} ${CONCURRENCY} ${TIME_LIMIT} http://${HOST}:8002/ | tee "${REPORT_DIR}/${REPORT_FILE}.txt" 2>&1

# Coyote APR w/o sendfile
REPORT_FILE=results_coyote_apr_ns
"${SCRIPT_DIR}/runfiletests.sh" 1 1 0 http://${HOST}:8003/ >/dev/null
sleep ${SLEEP_TIME}
"${SCRIPT_DIR}/runfiletests.sh" ${REQUESTS} ${CONCURRENCY} ${TIME_LIMIT} http://${HOST}:8003/ | tee "${REPORT_DIR}/${REPORT_FILE}.txt" 2>&1

# Coyote NIO
REPORT_FILE=results_coyote_nio
"${SCRIPT_DIR}/runfiletests.sh" 1 1 0 http://${HOST}:8004/ >/dev/null
sleep ${SLEEP_TIME}
"${SCRIPT_DIR}/runfiletests.sh" ${REQUESTS} ${CONCURRENCY} ${TIME_LIMIT} http://${HOST}:8004/ | tee "${REPORT_DIR}/${REPORT_FILE}.txt" 2>&1

# Coyote NIO w/o sendfile
REPORT_FILE=results_coyote_nio_ns
"${SCRIPT_DIR}/runfiletests.sh" 1 1 0 http://${HOST}:8006/ >/dev/null
sleep ${SLEEP_TIME}
"${SCRIPT_DIR}/runfiletests.sh" ${REQUESTS} ${CONCURRENCY} ${TIME_LIMIT} http://${HOST}:8006/ | tee "${REPORT_DIR}/${REPORT_FILE}.txt" 2>&1

# Coyote NIO2
REPORT_FILE=results_coyote_nio2
"${SCRIPT_DIR}/runfiletests.sh" 1 1 0 http://${HOST}:8007/ >/dev/null
sleep ${SLEEP_TIME}
"${SCRIPT_DIR}/runfiletests.sh" ${REQUESTS} ${CONCURRENCY} ${TIME_LIMIT} http://${HOST}:8007/ | tee "${REPORT_DIR}/${REPORT_FILE}.txt" 2>&1

# Coyote NIO2 w/o sendfile
REPORT_FILE=results_coyote_nio2_ns
"${SCRIPT_DIR}/runfiletests.sh" 1 1 0 http://${HOST}:8008/ >/dev/null
sleep ${SLEEP_TIME}
"${SCRIPT_DIR}/runfiletests.sh" ${REQUESTS} ${CONCURRENCY} ${TIME_LIMIT} http://${HOST}:8008/ | tee "${REPORT_DIR}/${REPORT_FILE}.txt" 2>&1

quit
