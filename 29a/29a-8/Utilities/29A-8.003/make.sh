#!/bin/sh
nasm -fbin ftpd.s -o ftpd.elf -l ftpd.lst
chmod +x ftpd.elf
