#!/bin/bash
#Controles adicionales
#Agregar y eliminar columnas

#BACKUP
#If you change this var here too in the main archive
DBACK=".tcalc_backup"

FICH="${1}"
CREV="\033[7m"
NC="\033[0m"

#===============

function backupt(){
#crea una copia de los ultimos ficheros
R=`date +%d%m%y_${RANDOM:0:3}`
  if [ ! -d $DBACK  ]; then
     mkdir "$DBACK"
  fi
  cp "${1}" "${DBACK}"/"${1}_$R"
  
}



#Agrega una columna al inicio de la MATRIX
function AddColumnFirst(){
backupt "${1}"
cp "${FICH}" "${FICH}".bak
awk 'BEGIN {FS=OFS = ":"} {print "0",$0}' "${FICH}".bak>"${FICH}" 
}

#Agrega una columna en OTRO LUGAR DESPUES  de la MATRIX
function AddColumn(){
backupt "${1}"
tput cup $(expr `tput lines` - 3) 0 ; tput dch 50
tput cup $(expr `tput lines` - 2) 0 ; tput dch 50
tput cup $(expr `tput lines` - 3) 0 && read -p "Insert 1 Column AFTER Column Nº?: " ACOL
cp "${1}" "${1}".bak
#awk -v C=$ACOL  'BEGIN {FS=OFS=":"} {$C=$C FS (NR==1? "0":"0")} 1' "${FICH}".bak>"${FICH}" 
awk -v C=$ACOL -v FS=":" -v OFS=":" '{$C=$C":"0}1' "${1}".bak>"${1}"
#awk -v FS=":" -v OFS=":" '{$3=$3":"1}1' tutorial.txt

}

#Elimina una columna
function DelColumn(){
  backupt "${1}"
  cp "${1}" "${1}".bak
  tput cup $(expr `tput lines` - 3) 0 ; tput dch 60
  tput cup $(expr `tput lines` - 2) 0 ; tput dch 60 
  tput cup $(expr `tput lines` - 3) 0 && read -p "Delete COLUMN Number ?: " DCOL
  cut  -d: -f${DCOL} --complement  "${1}".bak >"${1}"
}

#Inserta una Fila
function AddRow(){
backupt "${1}"
cad="0:"
#Total columnas
 AROW=`head -1 "${1}" |sed 's/[^:]//g'`
 AROW=${#AROW}
 #printf "Arrow  $AROW "
#cadena a agregar
 for ((i=1;i<$AROW;i++)); do
    cad="${cad}0:";
 done

 #printf "Cad es $cad"

#agregar columna
 read -p "Add ROW Number?: " NROW

#controlar si es la última fila
 UFILA=`cat "${1}"|wc -l`
if [ $NROW -lt $UFILA ] || [ $NROW -eq $UFILA ]; then 
if [[ $NROW -eq $UFILA ]]; then
  printf "$cad">>"${1}"
 else
  sed -i.bak "${NROW}i${cad}" "${1}"
fi
fi
read -p  "Press 4 Intros to /Refresh / continue"
}

#Elimina una columna
function DelRow(){
  backupt "${1}"
 read -p "Delete ROW Number?: " NROW

#si variable no esta vacia 
if  [ ! -z $NROW  ]; then
 
  if [ $NROW -eq 1 ]; then
     sed -i.bak "1d" "${1}"
   else
     sed -i.bak "${NROW}d" "${1}"
   fi
fi
}

tput cup $(expr `tput lines` - 4) 0 ; tput dch 100
tput cup $(expr `tput lines` - 3) 0 ; tput dch 100
tput cup $(expr `tput lines` - 2) 0 ; tput dch 100
tput cup $(expr `tput lines` - 4) 0 && printf "${CREV}| (1) Add Col At First| (2) Add Col Whatever |(3) Del Col | (4) Add Row | (5) Del Row |${NC}"

read -p " Option: " OPT

case $OPT in
  1 ) AddColumnFirst "${1}" ;;
  2 ) AddColumn "${1}" ;;
  3 ) DelColumn "${1}" ;;
  4 ) AddRow "${1}" ;;
  5 ) DelRow "${1}" ;;
esac
./tcalc "${1}"
exit 0
