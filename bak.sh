#!/bin/bash
# Genera una copia de seguridad de un fichero

#Detectar nº argumentos

if [ $# -ne 1 ]; then
 printf "Ejecutar $0 [nombre_fichero_copia]\nP.e: $0 tt.txt\n"
 exit 1
fi 

#FECHA del fichero
FECHA=`date +%Y%m%d`
SEGUNDOS=`date +%s`
SEGUNDOS=${SEGUNDOS:8}

#copia
cp "$1" "$1.${FECHA}${SEGUNDOS}.bak"

exit 0

