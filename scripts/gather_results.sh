#!/bin/sh

BASEDIR=`dirname "${0}"`

OUTFILE=${1:-combined_results.txt}
REPORT_BASE_DIR=${2:-./reports}

> "${OUTFILE}"

for results in ${REPORT_BASE_DIR}/c*/*.txt ; do
  echo "=================================" >> "${OUTFILE}"
  echo "$results" >> "${OUTFILE}"
  "${BASEDIR}/parsereport.pl" < "$results" >> "${OUTFILE}"
done
