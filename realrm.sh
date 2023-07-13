#!/bin/bash
#Utilidad que envia ficheros borrados a la papelera
C="\033[41m"
CB="\033[31;1;5m"
NC="\033[0m"

FCONF="/home/${USER}/.bashrc"
RUTA=/usr/local/bin

#sobreescribir .bashrc del usuario
cat /home/${USER}/.bashrc |grep "alias CursoScripts rm" >/dev/null
if [ $? -eq '1' ]; then
  printf "\n">>$FCONF
  echo "#alias CursoScripts rm">>$FCONF
  echo "alias rm=\"$RUTA/realrm\"" >>$FCONF
  source /home/${USER}/.bashrc
fi



if [ $1 == '-Rf' ]; then
for arg
  do
     if [ $arg != "-Rf" ]; then 
       printf "Enviando \"${arg}\" a la papelera de reciclaje ...\n" 
       cp -Rf "$arg" /home/${USER}/.local/share/Trash/files
       rm -Rf "$arg"
     fi
 done
 else
       clear
       printf "\n${C}***Se va a borrar los ficheros  del directorio: ***${NC}\n\t$PWD\n\t${CB}¿ Desea borrar los ficheros ?${NC} \n\tPulsa Ctrl +c para salir \n"
       read -p ""
       rm "$@"
 fi

exit 0
