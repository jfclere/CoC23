#!/bin/sh

BASEDIR=`dirname "${0}"`

OUTFILE=${1:-combined_results.txt}

> "${OUTFILE}"

for results in c*/*.txt ; do
  echo "=================================" >> "${OUTFILE}"
  echo "$results" >> "${OUTFILE}"
  "${BASEDIR}/parsereport.pl" < "$results" >> "${OUTFILE}"
done
