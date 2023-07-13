#!/bin/bash
#Traduce una cadena de texto de un idioma a otro

PAQUETE=translate-shell
COMANDO=trans
ORIGEN=EN
DESTINO=ES

#Mirar si el comando está instalado
which $COMANDO

#Si no está instalado instalarlo

if [ ${?} -eq 1 ];then
  printf "WARNING:: El paquete $PAQUETE no está instalado. Se procede a instalar\n::"
  sleep 1
  sudo apt-get -y install $PAQUETE
fi
#ejecutar hasta que no se pulse CTRL + C

while true; do
 printf "\n\nPulsa CTRL + C para salir del programa\n\n"
  read -p "Introduce la CADENA  (e) => Traducir del ESPAÑOL al INGLES :" CADENA  
   
 if [ $CADENA == "e" ]; then
    read -p "Cadena en ESPAÑOL: " CADENA
    trans :$DESTINO :$ORIGEN "${CADENA}"
  else
    trans :$ORIGEN :$DESTINO "${CADENA}" 
 fi
done
exit 0
