#!/bin/sh


for var in "$@"
do
    rpm2cpio $var | (cd /app; cpio -id)
done
mv /app/usr/* /app
rmdir /app/usr/
for i in /app/bin/*; do
    ./rewrite-rpath.sh $i;
done

   
