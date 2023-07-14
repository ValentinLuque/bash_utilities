#echo $SHELL >/dev/null
#Copia ficheros de un sistema local a remoto y al revés


PUERTO=22
REMOTO="valentin@192.168.1.135:/home/valentin/scripts"
PASSWD=""

function ayuda(){
  printf "\nUtiliza $0 [-ud] [fichero] para copiar remotamente"
  printf "\n\t -u=> Upload Fichero\n\t -d=> Download Fichero\n"
  exit 1
}

if [[ $# -ne '2' ]]; then
  ayuda
fi 

case $1 in
  -u ) printf "\nSubiendo fichero $2\n "
       sshpass -p $PASSWD scp -P ${PUERTO} "${2}" "${REMOTO}"
  ;;
  -d ) printf "\nBajando fichero $2\n "
       sshpass -p $PASSWD scp -P ${PUERTO} "${REMOTO}/$2" .
  ;;

  *) printf "Opción Invalida\n " && ayuda ;;
esac

exit 0

