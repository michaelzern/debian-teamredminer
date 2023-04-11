#!/bin/sh

USERNAME="3Ls6aHvZvxMFGdt729grtst5AahrVntGxv"
PASS=x
POOL="stratum+ssl://stratum.usa-east.nicehash.com:33353"
ALGO=kawpow

# These environment variables should be set to for the driver to allow max mem allocation from the gpu(s).
export GPU_MAX_ALLOC_PERCENT=100
export GPU_SINGLE_ALLOC_PERCENT=100
export GPU_MAX_HEAP_SIZE=100
export GPU_USE_SYNC_OBJECTS=1

./teamredminer -a "$ALGO" -o "$POOL" -u "$USERNAME".TRM -p "$PASS"
