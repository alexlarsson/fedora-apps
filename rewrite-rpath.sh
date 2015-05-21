#!/bin/sh

# Only apply on regular non-symlink files
if [ -f $1 -a ! -L $1 ]; then
    if patchelf --print-rpath $1 &> /dev/null; then
        if (patchelf --print-rpath $1 | grep "/usr" > /dev/null); then
            patchelf --set-rpath `(patchelf --print-rpath $1 | sed s%/usr%/self%)` $1
        fi
    fi
fi
