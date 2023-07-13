#!/bin/bash
#Eliminar de memoria procesos pasados por argumento

#si no hay parametro mostrar mensaje sino ejecutar comando
if [ $# -ne 1 ]; then
  printf "Ejecutar $0 [Comando a liberar]\nSaliendo...\n"
else
  for i in `ps aux |grep ${1} |awk '{print $2}'`; do echo "Matando Proceso ${i}" && kill -9 ${i}; done
fi
exit 0

