#!/bin/bash
#Empaqueta de un directorio

. utilidades

#llamar a fecha actual
ahora

function help(){
  printf "\nUtiliza $0 [directorio] para empaquetar\n"
  exit 1
}

[  $# -eq '0' ] && help

#Sacar el nombre del fichero
FICH=${1}
FICH="${FICH##*/}"

tar -czvf "${PWD}"/"${FICH}_${FACTUAL}".tar.gz "${1}"

if [ $? -eq 0 ]; then
  printf "\nEmpaquetado correcto\n"
  else
  printf "\nWARNING: Fallo en el empaquetado\n"
fi
exit 0

