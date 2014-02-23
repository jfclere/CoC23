#!/bin/sh

RANDOM_SOURCE=/dev/urandom
INITIAL_SIZE=4096
MAXIMUM_SIZE=33554432

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

exit

dd if=/dev/urandom of=4Kib.bin size=1024 count=4
dd if=/dev/urandom of=8Kib.bin size=1024 count=8
dd if=/dev/urandom of=16Kib.bin size=1024 count=16
dd if=/dev/urandom of=32Kib.bin size=1024 count=32
dd if=/dev/urandom of=64Kib.bin size=1024 count=64
dd if=/dev/urandom of=128Kib.bin size=1024 count=128
dd if=/dev/urandom of=256Kib.bin size=1024 count=256
dd if=/dev/urandom of=512Kib.bin size=1024 count=512
dd if=/dev/urandom of=1MiB.bin size=
