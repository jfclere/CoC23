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
HTTPSCHEME=https
REPORT_FILE="results_httpd.txt"

SCRIPT_DIR=`dirname "${0}"`
export REPORT_DIR
export REPORT_FILE

function quit {
  echo
  exit
}

trap "quit" INT TERM EXIT

# NOHTTPD if [ ! "${SKIP_HTTP_TESTS}" ] ; then
# NOHTTPD   # httpd
# NOHTTPD   REPORT_FILE=results_httpd
# NOHTTPD   echo "Running test on http://${HOST}:${HTTPDPORT}/"
# NOHTTPD   "${SCRIPT_DIR}/runfiletests.sh" 1 1 0 http://${HOST}:${HTTPDPORT}/ >/dev/null
# NOHTTPD   sleep ${SLEEP_TIME}
# NOHTTPD   "${SCRIPT_DIR}/runfiletests.sh" ${REQUESTS} ${CONCURRENCY} ${TIME_LIMIT} http://${HOST}:${HTTPDPORT}/ | tee "${REPORT_DIR}/${REPORT_FILE}.txt" 2>&1
# NOHTTPD fi
# NOHTTPD if [ ! "${SKIP_HTTPS_TESTS}" ] ; then
  # httpd openssl mod_ssl
#  REPORT_FILE=results_httpd_https
#  echo "Running test on https://${HOST}:${HTTPDSPORT}/"
#  "${SCRIPT_DIR}/runfiletests.sh" 1 1 0 https://${HOST}:${HTTPDSPORT}/ >/dev/null
#  sleep ${SLEEP_TIME}
#  "${SCRIPT_DIR}/runfiletests.sh" ${REQUESTS} ${CONCURRENCY} ${TIME_LIMIT} https://${HOST}:${HTTPDSPORT}/ | tee "${REPORT_DIR}/${REPORT_FILE}.txt" 2>&1
# NOHTTPD fi
# NOHTTPD if ${HTTPD_ONLY}; then
# NOHTTPD   echo "Done httpd/httpds only proxy"
# NOHTTPD   quit
# NOHTTPD   exit
# NOHTTPD fi

# Test nio2 openssl h2
REPORT_FILE=results_coyote_nio2_jsse_h2_$HTTPSCHEME
"${SCRIPT_DIR}/runfiletests.sh" 1 1 0 $HTTPSCHEME://${HOST}:8003/ true >/dev/null
sleep ${SLEEP_TIME}
"${SCRIPT_DIR}/runfiletests.sh" ${REQUESTS} ${CONCURRENCY} ${TIME_LIMIT} $HTTPSCHEME://${HOST}:8003/ true | tee "${REPORT_DIR}/${REPORT_FILE}.txt" 2>&1

# Test nio2 openssl http/1.1
REPORT_FILE=results_coyote_nio2_jsse_h1_$HTTPSCHEME
"${SCRIPT_DIR}/runfiletests.sh" 1 1 0 $HTTPSCHEME://${HOST}:8003/ false >/dev/null
sleep ${SLEEP_TIME}
"${SCRIPT_DIR}/runfiletests.sh" ${REQUESTS} ${CONCURRENCY} ${TIME_LIMIT} $HTTPSCHEME://${HOST}:8003/ false | tee "${REPORT_DIR}/${REPORT_FILE}.txt" 2>&1

# STOP the tests here for the moment.
quit


# Nio JSSE
REPORT_FILE=results_coyote_nio_jsse_$HTTPSCHEME
"${SCRIPT_DIR}/runfiletests.sh" 1 1 0 $HTTPSCHEME://${HOST}:8001/ >/dev/null
sleep ${SLEEP_TIME}
"${SCRIPT_DIR}/runfiletests.sh" ${REQUESTS} ${CONCURRENCY} ${TIME_LIMIT} $HTTPSCHEME://${HOST}:8001/ | tee "${REPORT_DIR}/${REPORT_FILE}.txt" 2>&1

# Coyote APR
REPORT_FILE=results_coyote_apr_$HTTPSCHEME
"${SCRIPT_DIR}/runfiletests.sh" 1 1 0 $HTTPSCHEME://${HOST}:8002/ >/dev/null
sleep ${SLEEP_TIME}
"${SCRIPT_DIR}/runfiletests.sh" ${REQUESTS} ${CONCURRENCY} ${TIME_LIMIT} $HTTPSCHEME://${HOST}:8002/ | tee "${REPORT_DIR}/${REPORT_FILE}.txt" 2>&1

# Next connector
REPORT_FILE=results_coyote_nio_openssl_$HTTPSCHEME
"${SCRIPT_DIR}/runfiletests.sh" 1 1 0 $HTTPSCHEME://${HOST}:8003/ >/dev/null
sleep ${SLEEP_TIME}
"${SCRIPT_DIR}/runfiletests.sh" ${REQUESTS} ${CONCURRENCY} ${TIME_LIMIT} $HTTPSCHEME://${HOST}:8003/ | tee "${REPORT_DIR}/${REPORT_FILE}.txt" 2>&1

# Next connector
REPORT_FILE=results_coyote_nio2_openssl_$HTTPSCHEME
"${SCRIPT_DIR}/runfiletests.sh" 1 1 0 $HTTPSCHEME://${HOST}:8004/ >/dev/null
sleep ${SLEEP_TIME}
"${SCRIPT_DIR}/runfiletests.sh" ${REQUESTS} ${CONCURRENCY} ${TIME_LIMIT} $HTTPSCHEME://${HOST}:8004/ | tee "${REPORT_DIR}/${REPORT_FILE}.txt" 2>&1

# STOP the tests here for the moment.
quit

# Coyote NIO2
REPORT_FILE=results_coyote_nio2_$HTTPSCHEME
"${SCRIPT_DIR}/runfiletests.sh" 1 1 0 $HTTPSCHEME://${HOST}:8004/ >/dev/null
sleep ${SLEEP_TIME}
"${SCRIPT_DIR}/runfiletests.sh" ${REQUESTS} ${CONCURRENCY} ${TIME_LIMIT} $HTTPSCHEME://${HOST}:8004/ | tee "${REPORT_DIR}/${REPORT_FILE}.txt" 2>&1

# Coyote NIO w/o sendfile
REPORT_FILE=results_coyote_nio_openssl_$HTTPSCHEME
"${SCRIPT_DIR}/runfiletests.sh" 1 1 0 $HTTPSCHEME://${HOST}:8006/ >/dev/null
sleep ${SLEEP_TIME}
"${SCRIPT_DIR}/runfiletests.sh" ${REQUESTS} ${CONCURRENCY} ${TIME_LIMIT} $HTTPSCHEME://${HOST}:8006/ | tee "${REPORT_DIR}/${REPORT_FILE}.txt" 2>&1

# Coyote NIO2
REPORT_FILE=results_coyote_nio_$HTTPSCHEME
"${SCRIPT_DIR}/runfiletests.sh" 1 1 0 $HTTPSCHEME://${HOST}:8007/ >/dev/null
sleep ${SLEEP_TIME}
"${SCRIPT_DIR}/runfiletests.sh" ${REQUESTS} ${CONCURRENCY} ${TIME_LIMIT} $HTTPSCHEME://${HOST}:8007/ | tee "${REPORT_DIR}/${REPORT_FILE}.txt" 2>&1

# STOP the tests here for the moment.
quit


# Coyote NIO2 w/o sendfile
REPORT_FILE=results_coyote_nio2_ns_$HTTPSCHEME
"${SCRIPT_DIR}/runfiletests.sh" 1 1 0 $HTTPSCHEME://${HOST}:8008/ >/dev/null
sleep ${SLEEP_TIME}
"${SCRIPT_DIR}/runfiletests.sh" ${REQUESTS} ${CONCURRENCY} ${TIME_LIMIT} $HTTPSCHEME://${HOST}:8008/ | tee "${REPORT_DIR}/${REPORT_FILE}.txt" 2>&1

quit
