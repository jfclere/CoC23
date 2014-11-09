#!/bin/sh

BASEDIR=`dirname "${0}"`

OUTFILE=${1:-cpu_combined_results.txt}
REPORT_BASE_DIR=${2:-./reports}
SIZEVALS="4KiB 16KiB 64KiB 128KiB 512KiB 2MiB 8MiB 32MiB"


> "${OUTFILE}"

for results in ${REPORT_BASE_DIR}/c*/results_*.txt ; do
  file=`echo $results | awk -F "." ' { print $1 } '`
  echo "$file"
  > $file.mval
  for cpus in $SIZEVALS
  do
    echo "cpu: $cpus"
    if [ -f $file.$cpus.bin.log ]; then
      awk -f cpu.awk $file.$cpus.bin.log > $$.mval
      read value < $$.mval
      echo "$cpus $value" >> $file.mval
    fi
  done
done

for dir in ${REPORT_BASE_DIR}/c*
do
  > $dir/${OUTFILE}

  # print the header line
  > name.txt
  titles="Categories "
  for results in ${dir}/results_*.mval
  do
    title=`echo $results | sed 's:results_: :' | sed 's:.mval: :' | awk ' { print $2 } '`
    titles="$titles$title "
    echo $results >> name.txt
  done
  echo "$titles" >> $dir/${OUTFILE}

  # for each filename find the corresponding results
  for cpus in $SIZEVALS
  do
    out="$cpus"
    while read name
    do
      value=`grep ^$cpus $name | awk ' { print $2 } '`
      out="${out} ${value}"
    done < name.txt
    echo $out >> $dir/${OUTFILE}
  done
done
