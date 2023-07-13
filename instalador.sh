#!/bin/bash
#Instala los Scripts como ejecutables en el sistema

RUTA="/usr/local/bin"

#si es usuario root adelante

if [ $UID -ne 0 ];then
  printf "Utiliza $0 como root\n"
  exit 1
fi

for i in `find -maxdepth 1 -name "*.sh"`;do
  printf "Copiando $i a $RUTA\n"
  sudo cp $i "$RUTA/${i%.*}"
done
exit 0
 
