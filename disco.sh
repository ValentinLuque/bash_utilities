#!/bin/bash
#Muestra información del disco

df -H |awk '/Montado|nvme/ {print $6"\t\t"$1"\t"$2"\t"$3"\t"$4"\t"$5}' |grep -v efi
exit 0

