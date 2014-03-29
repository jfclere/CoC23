#!/bin/sh

BASEDIR=`dirname "${0}"`

OUTFILE=${1:-combined_results.txt}
REPORT_BASE_DIR=${2:-./reports}

#> "${OUTFILE}"

for dir in ${REPORT_BASE_DIR}/c*
do
  > $dir/${OUTFILE}

  file=""
  for results in ${dir}/results_*.txt ; do
    "${BASEDIR}/parsereport.pl" < "$results" > $results.tmp
     file=$results.tmp
  done

  # get a list of the filenames
  > name.txt
  while read line
  do
    #echo "line: $line" >> $dir/${OUTFILE}
    rate=`echo $line | awk ' { print $1 } '`
    name=`echo $line | awk ' { print $2 } '`
    #echo "rate: $rate name: $name" >> $dir/${OUTFILE}
    echo $name >> name.txt 
  done < $file

  # print the header line
  titles="Categories "
  for results in ${dir}/*.tmp
  do
    title=`echo $results | sed 's:results_: :' | sed 's:.txt.tmp: :' | awk ' { print $2 } '`
    titles="$titles$title "
  done
  echo "$titles" >> $dir/${OUTFILE}

  # for each filename find the corresponding results
  while read name
  do
    rates="$name "
    for results in ${dir}/*.tmp
    do
      value=`grep $name $results`
      rate=`echo $value | awk ' { print $1 } '`
      title=`echo $results | sed 's:results_: :' | sed 's:.txt.tmp: :' | awk ' { print $2 } '`
      #echo "value: $value for $name in $results title *$title*" >> $dir/${OUTFILE}
      rates="$rates$rate " 
    done
    echo "$rates" >> $dir/${OUTFILE}
  done < name.txt
  
done
