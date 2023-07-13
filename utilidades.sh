#!/bin/bash
#Utilidades del sistema

function instalar(){
 if [ $# -ne '1' ]; then
  printf "Utiliza instalar [nombre_paquete] para instalar"
  exit 1
 fi
 sudo apt-get -y install "${1}"
}

function ahora(){
#Fecha del sistema
FECHA=`date +%Y%m%d`
SEGUNDOS=`date +%s`
SEGUNDOS=${SEGUNDOS:8}
FACTUAL=$FECHA$SEGUNDOS
}
