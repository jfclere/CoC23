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
SKIP_HTTP_TESTS=true
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
  echo "Running test on https://${HOST}:${HTTPDPORT}/"
  "${SCRIPT_DIR}/runfiletests.sh" 1 1 0 https://${HOST}:${HTTPDSPORT}/ >/dev/null
  sleep ${SLEEP_TIME}
  "${SCRIPT_DIR}/runfiletests.sh" ${REQUESTS} ${CONCURRENCY} ${TIME_LIMIT} https://${HOST}:${HTTPDSPORT}/ | tee "${REPORT_DIR}/${REPORT_FILE}.txt" 2>&1
fi
if ${HTTPD_ONLY}; then
  echo "Done httpd/httpds only proxy"
  quit
  exit
fi

# WildFly AJP
REPORT_FILE=results_widfly_ajp
"${SCRIPT_DIR}/runfiletests.sh" 1 1 0 http://${HOST}:8180/tcaj/ >/dev/null
sleep ${SLEEP_TIME}
"${SCRIPT_DIR}/runfiletests.sh" ${REQUESTS} ${CONCURRENCY} ${TIME_LIMIT} http://${HOST}:8180/tcaj/ | tee "${REPORT_DIR}/${REPORT_FILE}.txt" 2>&1

# SSL WildFly AJP
REPORT_FILE=results_ssl_widfly_ajp
"${SCRIPT_DIR}/runfiletests.sh" 1 1 0 https://${HOST}:8543/tcaj/ >/dev/null
sleep ${SLEEP_TIME}
"${SCRIPT_DIR}/runfiletests.sh" ${REQUESTS} ${CONCURRENCY} ${TIME_LIMIT} https://${HOST}:8180/tcaj/ | tee "${REPORT_DIR}/${REPORT_FILE}.txt" 2>&1

# Proxy AJP
REPORT_FILE=results_proxy_ajp
"${SCRIPT_DIR}/runfiletests.sh" 1 1 0 http://${HOST}:${HTTPDPORT}/tcaj/ >/dev/null
sleep ${SLEEP_TIME}
"${SCRIPT_DIR}/runfiletests.sh" ${REQUESTS} ${CONCURRENCY} ${TIME_LIMIT} http://${HOST}:${HTTPDPORT}/tcaj/ | tee "${REPORT_DIR}/${REPORT_FILE}.txt" 2>&1

# Proxy HTTP
REPORT_FILE=results_proxy_http
"${SCRIPT_DIR}/runfiletests.sh" 1 1 0 http://${HOST}:${HTTPDPORT}/tchp/ >/dev/null
sleep ${SLEEP_TIME}
"${SCRIPT_DIR}/runfiletests.sh" ${REQUESTS} ${CONCURRENCY} ${TIME_LIMIT} http://${HOST}:${HTTPDPORT}/tchp/ | tee "${REPORT_DIR}/${REPORT_FILE}.txt" 2>&1

# Mod_jk
REPORT_FILE=results_mod_jk
"${SCRIPT_DIR}/runfiletests.sh" 1 1 0 http://${HOST}:${HTTPDPORT}/jkaj/ >/dev/null
sleep ${SLEEP_TIME}
"${SCRIPT_DIR}/runfiletests.sh" ${REQUESTS} ${CONCURRENCY} ${TIME_LIMIT} http://${HOST}:${HTTPDPORT}/jkaj/ | tee "${REPORT_DIR}/${REPORT_FILE}.txt" 2>&1

# Proxy AJP SSL tests.
REPORT_FILE=results_ssl_proxy_ajp
"${SCRIPT_DIR}/runfiletests.sh" 1 1 0 https://${HOST}:${HTTPDSPORT}/tcaj/ >/dev/null
sleep ${SLEEP_TIME}
"${SCRIPT_DIR}/runfiletests.sh" ${REQUESTS} ${CONCURRENCY} ${TIME_LIMIT} https://${HOST}:${HTTPDSPORT}/tcaj/ | tee "${REPORT_DIR}/${REPORT_FILE}.txt" 2>&1

# Proxy HTTP
REPORT_FILE=results_ssl_proxy_http
"${SCRIPT_DIR}/runfiletests.sh" 1 1 0 https://${HOST}:${HTTPDSPORT}/tchp/ >/dev/null
sleep ${SLEEP_TIME}
"${SCRIPT_DIR}/runfiletests.sh" ${REQUESTS} ${CONCURRENCY} ${TIME_LIMIT} https://${HOST}:${HTTPDSPORT}/tchp/ | tee "${REPORT_DIR}/${REPORT_FILE}.txt" 2>&1

# Mod_jk
REPORT_FILE=results_ssl_mod_jk
"${SCRIPT_DIR}/runfiletests.sh" 1 1 0 https://${HOST}:${HTTPDSPORT}/jkaj/ >/dev/null
sleep ${SLEEP_TIME}
"${SCRIPT_DIR}/runfiletests.sh" ${REQUESTS} ${CONCURRENCY} ${TIME_LIMIT} https://${HOST}:${HTTPDSPORT}/jkaj/ | tee "${REPORT_DIR}/${REPORT_FILE}.txt" 2>&1

quit
