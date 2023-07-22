#!/bin/bash
#Monta una ISO

DIR="/media/iso"

function ayuda(){
  printf "Utiliza $0 [-c -d] IMAGEN_ISO.iso\n\t-c=> Montar un cdrom\n\t-d=> Montar un Dvd\n\t-e ISO=> Desmontar la imagen\nSaliendo...\n\n"
  exit 1
}


if [ $UID -ne 0 ]; then
  printf "utiliza sudo $0\nSaliendo\n"
fi

if [ $# -ne 2 ]; then 
  ayuda
fi

while getopts ":c:d:e" OPT; do
  case $OPT in
	c) VAR="cdrom" ;;
	d) VAR="dvd" ;;
	e) VAR="desmontar" ;;
        ?) printf "Opcion incorrecta\n" ; ayuda && exit 1 ;; 
 esac
done

#shift $((OPTIND-1))
printf "Opcion: $VAR\nFICH: $2\n"


if [ -d "${DIR}" ]; then
   mkdir -p "${DIR}"
fi

sudo modprobe loop

[[ "${VAR}" == "cdrom" ]] && sudo mount "${2}" "${DIR}" -t iso9660 -o loop
[[ "${VAR}" == "iso" ]] && sudo mount "${2}" "${DIR}" -t udf -o loop
[[ "${VAR}" == "desmontar" ]] && sudo umount "${DIR}" 
 
exit 0

