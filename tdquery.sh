#!/bin/bash
#generación de las consultas de tdata
#Rev 0.4
#Valentín Luque Mestanza


CREV="\033[7m"
NC="\033[0m"
COLS=`tput cols`
COL=""

#DEBUG (y => Activate debug)
DEB=y

#File Query
FQ=dtQuery

#File Cab
QueryCAB="cabecera.txt"

#File secundary Query 
Query="temp.txt"

#File to print
PRINT=Query.txt

if [[ ! -f "${FQ}"  ]]; then
   touch "${FQ}"
fi 

#review if pass database as argument
if [[ $# -ne 1 ]];then
  printf "Execute $0 [DATABASE]\n"
  exit 1
fi


#Imprime cabecera
function cabecera(){
  tput cup 1 0 && for ((i=1;i<=$COLS;i++)); do printf "${CREV} "; done 
  tput cup 1 0 && printf "${CREV}Choose Option for ${1} ${TABLE}${NC}\n\n\t1) Create a Query\n\t2) Delete Query\n\t3) Execute Query\n\tq) Exit\n"
  echo
}


function ChooseTable(){
#Escoge la tabla 
  TABLAS=`ls -lat "${1}"* |awk '!/bak/ && /\./' |rev |cut -d" " -f1 |rev`
  z=1
  for i in `printf "$TABLAS"` ;do  
    echo "$z ${i}" 
    z=`expr $z + 1`
  done
  
 read -p "Chose the Number of TABLE: " OPT
 TABLE=`printf "$TABLAS" |awk -v FILA=$OPT 'NR==FILA'`
 printf "tabla : ${TABLE}\n"

}

function DeleteQ(){
cat -n "${FQ}"
read -p  "Choose Number to delete? | (q) Exit? " OPT
 if [[ $OPT != q ]]; then
   sed -i.bak -e "${OPT}d" "${FQ}"
 fi
}


function CreateQ(){
  
  read -p  "Query Name: " NAME
   CAMPO="${NAME}"
   ChooseTable "${1}"  
   #revisar si es relacional
   cat "${1}" |cut -d: -f2|grep "${TABLE}" >/dev/null
   if [[ $? -eq 0 ]]; then
     printf "Relacional Table\n" 

     #Tabla principal
     PTABLE=`cat "${1}" |grep "${TABLE}"|cut -d: -f1`
     #printf "Tabla Principal $PTABLE"

     #agregamos la tabla principal al campo
     CAMPO="${CAMPO}":"${PTABLE}"
     #Num de registros
     NR=`head -n1 "${PTABLE}" |awk -F: '{print NF}'`

     for ((i=1; i<=$NR; i++)); do
       printf "*** CHOOSE REGISTRY FROM PRINCIPAL TABLE ${PTABLE} ***\n " 
       FIELD=`head -n1 "${PTABLE}"| cut -d: -f$i`
       read -p  "Include in the Query the field $FIELD? (y) " OPT
       CAMPO="${CAMPO}":"${FIELD}" 
      done
      CAMPO="${CAMPO}|${TABLE}" 
     


     #Choose FIELDS form  Second table
     NR=`head -n1 "${TABLE}" |awk -F: '{print NF}'`
     for ((i=1; i<=$NR; i++)); do
       printf "\n\nCHOOSE REGISTRY FROM TABLE ${TABLE}\n " 
       FIELD=`head -n1 "${TABLE}"| cut -d: -f$i`

       #Foreign ID not necessary to show
       if [[ $FIELD != "FID" ]] ; then      
         read -p  "Include in the Query the field $FIELD? (y) " OPT
         CAMPO="${CAMPO}":"${FIELD}" 
       fi 
    done

     #Write to file the query
      printf "${CAMPO}\n" >>"${FQ}"
      CAMPO="${CAMPO}|" 
      #replace first :
      sed -i.bak 's/|:/|/g' "${FQ}"

     #Where 
     FIELDS=`tail -n1 "${FQ}"|cut -d"|" -f2`
     [[ $OPT == y ]] && printf "Campos $FIELDS\n"
     NR=`printf "${FIELDS}" |awk -F: '{printf NF}'`
     [[ $OPT == y ]] && echo $NR
      echo
     for ((i=1;i<=$NR;i++)); do
       FIELD=`printf "${FIELDS}" |cut -d: -f$i`
       [[ $FIELD != "${TABLE}" ]] &&  printf "$i → $FIELD\n"
     done
     read -p "Where (Choose Number)? " WHERE
     read -p "Equal to (Intro for ALL Vallues): " EQUAL

     FIELD=`printf "${FIELDS}" |cut -d: -f$WHERE`
     FIELD="${FIELD}=${EQUAL}"
     [[ $OPT == y ]] && printf "FIELD es $FIELD\n"
     
     #last line
     LL=`tail -n1 "${FQ}"`
     [[ $OPT == y ]] && printf "LL es $LL\n"
     sed -i.bak "s/${LL}/${LL}|${FIELD}/g" "${FQ}" 
     read -p "intro"
   else
    printf "No relational Table\n"
    #Tabla principal
       
     #agregamos la tabla principal al campo
     CAMPO="${CAMPO}":"${TABLE}"
     #Num de registros
     
    NR=`head -n1 "${TABLE}" |awk -F: '{print NF}'`
     
     for ((i=1; i<=$NR; i++)); do
       printf "*** CHOOSE REGISTRY FROM TABLE ${TABLE} ***\n " 
       FIELD=`head -n1 "${TABLE}"| cut -d: -f$i`
       read -p  "Include in the Query the field $FIELD? (y) " OPT
       CAMPO="${CAMPO}":"${FIELD}" 
      done 
      [[ $OPT == y ]] && printf "CAMPOS: ${CAMPO}\n"
     #last line
     echo
     printf "${CAMPO}\n">>"${FQ}"
    


       #Where 
     FIELDS=`tail -n1 "${FQ}"|cut -d"*" -f1`
     FIELDS=`echo $FIELDS |cut -d: -f3-`
     [[ $OPT == y ]] && printf "Campos $FIELDS\n"
     NR=`printf "${FIELDS}" |awk -F: '{printf NF}'`
     [[ $OPT == y ]] && echo $NR 
      echo
     for ((i=1;i<=$NR;i++)); do
       FIELD=`printf "${FIELDS}" |cut -d: -f$i`
       [[ $FIELD != "${TABLE}" ]] &&  printf "$i → $FIELD\n"
     done
     read -p "Where (Choose Number)? " WHERE
     read -p "Equal to (Intro for ALL Vallues): " EQUAL

     FIELD=`printf "${FIELDS}" |cut -d: -f$WHERE`
     FIELD="*${FIELD}=${EQUAL}"
     printf "FIELD es $FIELD\n"

  #last line
     LL=`tail -n1 "${FQ}"`
     [[ $OPT == y ]] && printf "LL es $LL\n"
     sed -i.bak "s/${LL}/${LL}${FIELD}/g" "${FQ}" 
     [[ $OPT == y ]] && read -p "intro"




 fi
  read -p "Intro"
}




#=====================
#Execute a QUERY
#====================
function Execute(){
   
  [[ -f "${Query}" ]] && rm "${Query}"  2>/dev/null
  [[ -f "${QueryCAB}" ]] && rm "${QueryCAB}" 2>/dev/null
  [[ -f "${Query}".bak  ]] && rm "${Query}".bak 2>/dev/null
  [[ -f "${QueryCAB}".bak ]] && rm "${Query}".bak 2>/dev/null


[[ $DEB != "y" ]] && clear  
[[ $DEB != "y" ]] && cabecera "${1}" "${TABLE}"

  touch "${Query}"
  [[ $? -ne 0 ]] && exit 1
   touch "${QueryCAB}"
 CAMPO=""
 cat -n "${FQ}"
 printf "\n"
 read -p "Choose Query Number " NUM

 FILA=`cat  "${FQ}"| awk -v NUM=$NUM  'NR==NUM {print}'`
 [[ $DEB == "y" ]] && printf " FILA es $FILA\n"
 [[ $DEB == "y" ]] && read -p  "Intro"
  echo "${FILA}" |grep "|" 

if [[ $? -eq 1 ]]; then
  [[ $DEB == "y" ]] &&  printf "No relational TABLE\n"
  [[ $DEB == "y" ]] && read -p "intro"
  NAME=`echo "$FILA" |cut -d: -f1`
  #tabla primaria  
  TABLE=`echo "$FILA" |cut -d: -f2`


#### TABLE ####
CAMPO=""
 [[ $DEB == "y" ]] && printf "\n **** Primary ID es $PFILA\n ***"

#ID primary TABLE PLINEA = ID FOREIGN TABLE
 [[ $DEB == "y" ]] && printf "TABLE es ${TABLE}\n"

CAMPO=`cat "${TABLE}" |head -n1 "${TABLE}"`
CAMPO="${CAMPO}\n"
tail -n +2  "${TABLE}" |while read line; do
  [[ $DEB == "y" ]] &&  printf "linea: $line\n"
  [[ $DEB == "y" ]] && printf "\n"
  CAMPO="${CAMPO}${line}\n"

 [[ $DEB == "y" ]] && printf "CAMPOS:\n\n ${CAMPO}\n"

 printf "${CAMPO}">"${Query}"

done
 [[ $DEB == "y" ]] && read -p "Intro"
NRFILA=""
FILA=""
FILAC=""
#Escoger las columnas
       #filas del campo
       FILAC=`head -n1 "${Query}"`
       #filas a comparar
       FILA=`cat  "${FQ}"| awk -v NUM=$NUM  'NR==NUM {print}'|cut -d"*" -f1 |cut -d: -f2-`
       NRFILA=`printf "${FILAC}" | awk -F: '{print NF}'`
        [[ $DEB == "y" ]] && printf "FILA: $FILA || FILAS Query: $FILAC || Num. Filas $NRFILA\n"
       for ((i=1;i<=$NRFILA; i++)); do
         VALOR=`head -n1 "${Query}"|cut -d: -f$i`
          printf "${FILA}" | grep "$VALOR"
         if [ $? -eq 0 ];then 
          [[ $DEB == "y" ]] && printf "Valor $VALOR esta en la Query\n" 
         else 
           #BORRAR UNA COLUMNA
            [[ $DEB == "y" ]] && printf "Valor $VALOR NO ESTA en la Query [MARCADO PARA BORRAR]\n"
           BORRAR="${BORRAR}:${i}"
          
         fi    
     done
         #choose the column
         
          [[ $DEB == "y" ]] && read -p "Intro"
         
         #borrar las columnas
         if [[ $BORRAR != "" ]]; then
           BORRAR=`printf "${BORRAR}" |cut -c2- |tr ':' ','`
           [[ $DEB == "y" ]] && printf "Se Borraran las columnas $BORRAR\n"  
           cut -d: -f${BORRAR} --complement "${Query}" >"${Query}".bak
         fi
          cp "${Query}".bak "${Query}" && rm "${Query}".bak 
 

#Where
       FILAC=`head -n1 "${Query}"`
       WHERE=`cat "${FQ}"| awk -v NUM=$NUM  'NR==NUM {print}'|cut -d"*" -f2`
       NRFILA=`printf "${FILAC}" | awk -F: '{print NF}'`
       CAMPO=`printf $WHERE | cut -d= -f1`
       VALOR=`printf $WHERE | cut -d= -f2`
          [[ $DEB == "y" ]] && printf "WHERE $WHERE || Num de filas $NRFILA || Campo $CAMPO || Valor $VALOR\n"
       for ((i=1;i<=$NRFILA; i++)); do
         VALUE=`head -n1 "${Query}"|cut -d: -f$i`
            [[ $DEB == "y" ]] && printf "VALUE es $VALUE y CAMPO es $CAMPO * * *\n\n" 
         if [[ $VALUE == $CAMPO ]]; then
            
             [[ $DEB == "y" ]] && printf "Entro en $CAMPO\n"
             POS=$i
             
            [[ $DEB == "y" ]] && awk -F: -v POS=$POS -v VALOR=$VALOR '$POS~VALOR {print}' "${Query}"        
            awk -F: -v POS=$POS -v VALOR=$VALOR '$POS~VALOR {print}' "${Query}" >>"${Query}".bak       
            
         fi
       done
             cp "${Query}".bak "${Query}"        
             rm "${Query}".bak   


    #append to first line header
    sed -i.bak "1s/^/${FILAC}\n/" "${Query}"
    [[ $DEB == "y" ]] && read -p "intro"


       CAMPO=""
       FILAC=`head -n1 "${Query}"`
       NRFILA=`printf "${FILAC}" | awk -F: '{print NF}'`
       for ((i=1;i<=$NRFILA;i++));do
            REG=`printf "$FILAC" |cut -d: -f$i`
            if [[ $REG != "ID" ]]; then
                REG="${REG:0:(-1)}" 
               [[ $DEB == "y" ]] && printf "REG es : $REG\n"
               CAMPO="$CAMPO:$REG"
             
            else
              CAMPO="$CAMPO:$REG"
              fi
       done
           CAMPO=`echo "${CAMPO}"|cut -c2-`
           [[ $DEB == "y" ]] && printf "Campo es $CAMPO\n"
           [[ $DEB == "y" ]] && read -p "SED"
         
            #replace first line
           sed -i.bak "1 s/^.*$/${CAMPO}/" "${Query}"
           [[ $DEB == "y" ]] && read -p "SED "

#Print the VALUES
clear
printf "${NAME}\n"
column -s ":" -t  "$QueryCAB" |tr "|" " "
printf "\n"
column -s ":" -t "${Query}" |tr "|" " "


#read -p "intro FINAL"
read -p  "Print to file?(y)  "  FILE
if [[ $FILE == "y" ]] ;then
   [[ -f "${PRINT}" ]] && rm "${PRINT}"
  touch "${PRINT}"
  printf "${NAME}\n">"${PRINT}"
  column -s ":" -t "$QueryCAB" |tr "|" " ">>"${PRINT}"
  column -s ":" -t  "$Query" |tr "|" " ">>"${PRINT}"
  #sed -i.bak "s/|/ /g" "${PRINT}"
  read -p "File "${PRINT}" Create Succesfuly. Press Intro" 
fi
rm "${Query}" && rm "${QueryCAB}"


 #TABLE NO RELATIONAL
#Reseteamos las variables
NRFILA=""
CAMPO=""
VALOR=""
FILAC=""
WHERE=""
VALOR=""
VALUE=""
BORRAR=""
INDICE=""




else
 NAME=`echo "$FILA" |cut -d: -f1`
 #tabla primaria  
 TABLE=`echo "$FILA" |cut -d: -f2`
 #tabla secundaria
 TABLES=`echo "$FILA" | cut -d"|" -f2 |cut -d: -f1`
 #TABLES=`echo "${TABLES}" | cut -d: -f1` 
 [[ $DEB == "y" ]] && printf "TABLES es $TABLES\n"
   while true; do
     read -p "Choose REGISTRY for ${TABLE}: (r) Repeat | (q) Exit " OPT

     [[ $OPT == "q" ]] && break 
     if [[ $OPT != "r" ]]; then
        CAMPO=""
        FIELD=""
        INDICE="${OPT}"
        grep  -i "$OPT" "${TABLE}"
        printf "\n"
        read -p "Choose ID: " PFILA
        VALUE=`awk -F: -v FILA=$PFILA '{if ($1==FILA) {print}}' "${TABLE}"`
        #VALUE=`grep -i "$PFILA:" "${TABLE}"`
        [[ $DEB == "y" ]] && printf "\nValor de VALUE $VALUE\n\n"
        
         #Recorremos NUM registros
        FILA=`echo "${FILA}" |cut -d":" -f3- | cut -d"|" -f1`
        NRFILA=`echo "${FILA}" | awk -F: '{print NF}'`
        NRTABLE=`head -n1 "${TABLE}" | awk -F: '{printf NF}'`
        [[ $DEB == "y" ]] && printf "Fila $FILA | Num. de reg. FILA: $NRFILA. | Num Reg. TABLE $NRTABLE| PFILA=${PFILA} \n\n" 
        for ((i=1; i<`expr $NRFILA + 1`; i++)); do
         VALOR=`echo "${FILA}" | cut -d: -f$i`
         TVALUE=`echo "${VALUE}" |cut -d':' -f$i` 
         [[ $DEB == "y" ]] && printf "Valor es $VALOR\n"
         [[ $DEB == "y" ]] && printf "Value es $TVALUE\n"
         
         #choose the column
         #TEST=`awk -F: -v txt="${VALOR}" 'FNR==1{for(c=1;$c!=txt;c++);next} {print $c}' "${TABLE}"`
         #FIELD=`printf "$TEST" | awk -v ROW=$TVALUE '{if (NR==ROW) {print}}'`
         #FIELD=`awk -F: -v OFS=: -v ROW="${TVALUE}" '{if (NR==ROW) {print}}' "${TABLE}"`
           [[ $DEB == "y" ]] && read -p "Intro"
         if [[ -z  "${CAMPO}" ]]; then
             CAMPO="${TVALUE}"
         else
           [[ $DEB == y ]] && printf "C: ${CAMPO} F: ${TVALUE}\n"
           CAMPO="${CAMPO}:${TVALUE}" 
        fi
          [[ $DEB == "y" ]] && printf "\n** CAMPOS $CAMPO **\n"
  
     done 
       [[ $i == `expr $NRFILA + 1` ]]  && break 
    fi
  done  

 [[ $DEB == "y" ]] && read -p "INTRO"


CABECERA=`echo "${FILA}" |cut -d"|" -f1 |cut -f2-`
printf "${NAME}" >>"${QueryCAB}"
echo >>"${QueryCAB}"
printf "$CABECERA" >>"${QueryCAB}"
echo >>"${QueryCAB}"
printf "${CAMPO}" >>"${QueryCAB}"
[[ $DEB == "y" ]] && printf "ALERTA\n "
column -s ":" -t "${QueryCAB}"
 [[ $DEB == "y" ]] && read -p "Continua"

#=========================================================
################# Print Values PRINCIPAL TABLE #############
#=========================================================

#### SECOND TABLE ####
CAMPO=""
[[ $DEB == "y" ]] && printf "\n **** Primary ID es $PFILA\n ***"
#ID primary TABLE PLINEA = ID FOREIGN TABLE
[[ $DEB == "y" ]] && printf "TABLES es ${TABLES}\n"
CAMPO=`cat "${TABLES}" |head -n1 "${TABLES}"`
CAMPO="${CAMPO}\n"
tail -n +2  "${TABLES}" |while read line; do
[[ $DEB == "y" ]] &&    printf "linea: $line\n"
   FK=`echo "${line}" | cut -d: -f2`
   [[ $DEB == "y" ]] && printf "FK es $FK\n"
   if [[ $FK == $PFILA ]]; then
   [[ $DEB == "y" ]] &&  printf "\n"
    CAMPO="${CAMPO}${line}\n"
  fi
[[ $DEB == "y" ]] && printf "CAMPOS:\n\n ${CAMPO}\n"

printf "${CAMPO}">"${Query}"
done
[[ $DEB == "y" ]] && read -p "Intro"


NRFILA=""
FILA=""
FILAC=""
#Escoger las columnas
       #filas del campo
       FILAC=`head -n1 "${Query}"`
       #filas a comparar
       FILA=`cat  "${FQ}"| awk -v NUM=$NUM  'NR==NUM {print}'|cut -d"|" -f2 |cut -d: -f2-`
       NRFILA=`printf "${FILAC}" | awk -F: '{print NF}'`
       [[ $DEB == "y" ]] && printf "FILA: $FILA || FILAS Query: $FILAC || Num. Filas $NRFILA\n"
       for ((i=1;i<=$NRFILA; i++)); do
         VALOR=`head -n1 "${Query}"|cut -d: -f$i`
         printf "${FILA}" | grep "$VALOR"
         if [ $? -eq 0 ];then 
          [[ $DEB == "y" ]] && printf "Valor $VALOR esta en la Query\n" 
         else 
           #BORRAR UNA COLUMNA
           [[ $DEB == "y" ]] && printf "Valor $VALOR NO ESTA en la Query [MARCADO PARA BORRAR]\n"
           BORRAR="${BORRAR}:${i}"
          
         fi    
     done
         #choose the column
         
         [[ $DEB == "y" ]] && read -p "Intro"
         
         #borrar las columnas
         if [[ $BORRAR != "" ]]; then
         BORRAR=`printf "${BORRAR}" |cut -c2- |tr ':' ','`
           [[ $DEB == "y" ]] && printf "Se Borraran las columnas $BORRAR\n"  
            cut -d: -f${BORRAR} --complement "${Query}" >"${Query}".bak
         fi
          cp "${Query}".bak "${Query}" && rm "${Query}".bak 
 

#Where
       FILAC=`head -n1 "${Query}"`
       #
       WHERE=`cat "${FQ}"| awk -v NUM=$NUM  'NR==NUM {print}'|cut -d"|" -f3`
       NRFILA=`printf "${FILAC}" | awk -F: '{print NF}'`
       CAMPO=`printf $WHERE | cut -d= -f1`
       VALOR=`printf $WHERE | cut -d= -f2`
        [[ $DEB == "y" ]] && printf "WHERE $WHERE || Num de filas $NRFILA || Campo $CAMPO || Valor $VALOR\n"
       for ((i=1;i<=$NRFILA; i++)); do
         VALUE=`head -n1 "${Query}"|cut -d: -f$i`
          [[ $DEB == "y" ]] && printf "VALUE es $VALUE y CAMPO es $CAMPO * * *\n\n" 
         if [[ $VALUE == $CAMPO ]]; then
            
             [[ $DEB == "y" ]] && printf "Entro en $CAMPO\n"
             POS=$i
            
            [[ $DEB == "y" ]] && awk -F: -v POS=$POS -v VALOR=$VALOR '$POS~VALOR {print}' "${Query}"        
            awk -F: -v POS=$POS -v VALOR=$VALOR '$POS~VALOR {print}' "${Query}" >>"${Query}".bak       
            [[ $DEB == "y" ]] && read -p "Intro"
         fi
       done
             cp "${Query}".bak "${Query}"        
             rm "${Query}".bak   


    #append to first line header
    sed -i.bak "1s/^/${FILAC}\n/" "${Query}"
    [[ $DEB == "y" ]] && read -p "intro"


#REMOVE LAST DIGIT from FIELDS

       CAMPO=""
       FILAC=`head -n1 "${Query}"`
       NRFILA=`printf "${FILAC}" | awk -F: '{print NF}'`
       for ((i=1;i<=$NRFILA;i++));do
            REG=`printf "$FILAC" |cut -d: -f$i`
            if [[ $REG != "ID" ]]; then
               REG="${REG:0:(-1)}" 
               [[ $DEB == "y" ]] && printf "REG es : $REG\n"
               CAMPO="$CAMPO:$REG"
           
            else
              CAMPO="$CAMPO:$REG"
              fi
       done
           CAMPO=`echo "${CAMPO}"|cut -c2-`
            [[ $DEB == "y" ]] && printf "Campo es $CAMPO\n"
            [[ $DEB == "y" ]] && read -p "SED"
           #replace first line
           sed -i.bak "1 s/^.*$/${CAMPO}/" "${Query}"
            [[ $DEB == "y" ]] && read -p "SED "

#The same for HEADER
        CAMPO=""
       FILAC=`awk 'NR==2 {print}' "${QueryCAB}"`
       NRFILA=`printf "${FILAC}" | awk -F: '{print NF}'`
       for ((i=1;i<=$NRFILA;i++));do
            REG=`printf "$FILAC" |cut -d: -f$i`
            if [[ $REG != "ID" ]]; then
               REG="${REG:0:(-1)}" 
                [[ $DEB == "y" ]] && printf "REG es : $REG\n"
               CAMPO="$CAMPO:$REG"
          
            else
              CAMPO="$CAMPO:$REG"
              fi
       done
           CAMPO=`echo "${CAMPO}"|cut -c2-`
           [[ $DEB == "y" ]] && printf "Campo es $CAMPO\n"
           [[ $DEB == "y" ]] && read -p "SED"
           #replace first line
           sed -i.bak "2 s/^.*$/${CAMPO}/" "${QueryCAB}"
           [[ $DEB == "y" ]] && read -p "SED "

#revisar duplicados de IDS y eliminarlos

 [[ `awk "NR==2 {print}" "${Query}" |cut -d: -f1` == "ID" ]]  && sed -i.bak -e "2d" "${Query}"



#Reseteamos las variables
NRFILA=""
CAMPO=""
VALOR=""
FILAC=""
WHERE=""
VALOR=""
VALUE=""
BORRAR=""
INDICE=""
#Print the VALUES
clear
column -s ":" -t  "$QueryCAB" |tr "|" "  "
printf "\n"
column -s ":" -t "${Query}" |tr "|" " "

 [[ $DEB == "y" ]] && read -p "intro FINAL"

read -p  "Print to file?(y)  "  FILE
if [[ $FILE == "y" ]] ;then
   [[ -f "${PRINT}" ]] && rm "${PRINT}"
  touch "${PRINT}"

  column -s ":" -t "$QueryCAB" |tr "|" " " >>"${PRINT}"
  echo >>"${PRINT}" 
  column -s ":" -t  "$Query"|tr "|" " ">>"${PRINT}"
  read -p "File "${PRINT}" Create Succesfuly. Press Intro" 
fi
rm "${Query}" && rm "${QueryCAB}"

fi #RELATIONAL TABLE (FIRST IF)
}




################
## MAIN PROGRAM
################
while true; do
 clear
 cabecera "${1}" "${TABLE}"
 read -p "Choose Option: " OPT
 case  $OPT in
   1) CreateQ "${1}"  ;;
   2) DeleteQ "${1}" ;;
   3) Execute "${1}" ;;
   q) exit 1 ;;
   *) printf "Incorrect Option" ;;
   esac
done
