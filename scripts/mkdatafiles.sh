#!/bin/sh

RANDOM_SOURCE=/dev/urandom
INITIAL_SIZE=4096
#MAXIMUM_SIZE=33554432
MAXIMUM_SIZE=1048576

size=${INITIAL_SIZE}

while [ "$size" -le "$MAXIMUM_SIZE" ] ; do
  if [ "${size}" -ge "1048576" ] ; then
    filename=`expr ${size} / 1048576`MiB.bin
  else if [ "${size}" -ge "1024" ] ; then
    filename=`expr ${size} / 1024`KiB.bin
  else
    filename="${size}b.bin"
  fi fi

  echo -n Making ${filename}...
  dd "if=${RANDOM_SOURCE}" "of=${filename}" bs=1 count=${size} 
  echo done

  size=`expr 2 '*' ${size}`
done 
