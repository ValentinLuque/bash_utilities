#!/bin/bash
#Hora local a partir de una hora Internacional


while true; do
  clear
  read -p "Hora del Evento (HH:MM): " TIME
  read -p "Lugar del Evento: " PLACE

#Mostrar información
  N=0
  for i in `find /usr/share/zoneinfo/ -iname "*${PLACE}"`; do
    N=`expr $N + 1`
    VAR=`echo $N ${i##*zoneinfo/}`
    echo "$VAR"
    varTotal="${VAR}\n ${varTotal}"
  done

read -p "Escoge una opción: " NUM

#Procesar la información
  OPCION=$(printf "$varTotal" |awk -v NUMERO_ESCOGIDO=$NUM '$1==NUMERO_ESCOGIDO {print $2}')

#Mostrar la hora local al usuario
  date --date "TZ=\"${OPCION}\" ${TIME}"
  read -p "Deseas Buscar otra fecha? (n): " OPT
  [ $OPT == 'n' ] && break
done
exit 0

