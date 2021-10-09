#!/bin/sh

set -x

cc -o SM-1 -Os -fno-toplevel-reorder SM-1.c
cc -o SM-2 -Os -fno-toplevel-reorder SM-2.c
