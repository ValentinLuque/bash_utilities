#!/bin/bash
#Tiny BBDD
#Valentín Luque Mestanza

CREV="\033[7m"
NC="\033[0m"
COLS=`tput cols`

DEB=n

#Review if we have dtquery.sh and tedit

if [[ ! -f  "tedit" ]] ; then 
 printf "Is necessary the file tedit for working. Would you like to download?\n  "
 read -p "Press Intro for DOWNLOAD or (n) por Abandon!! " OPT
 if [[ $OPT == "n" ]]; then
   printf "Unable to execute the program...\n"
   exit 1
  else
    wget "https://raw.githubusercontent.com/ValentinLuque/bash_utilities/main/tedit"
  fi
fi

if [[ ! -f  "tdquery.sh" ]] ; then 
 printf "Is necessary the file tdquery.sh for working. Would you like to download?\n  "
 read -p "Press Intro for DOWNLOAD or (n) por Abandon!! " OPT
 if [[ $OPT == "n" ]]; then
   printf "Unable to execute the program...\n"
   exit 1
  else
    wget "https://raw.githubusercontent.com/ValentinLuque/bash_utilities/main/tdquery.sh"
  
  fi
   chmod +x tedit
   chmod +x tdquery.sh
  
fi



function AgregarValores(){
while true; do
#Insert Values to de DDBB
   #Control de entrada a relacional
  DENTRO=n 
  CAMPO=""
  FIELD=""
  REGISTROS=`head -n 1 "${1}"|awk -F: '{print NF-1}'`
  REGISTROS=`expr $REGISTROS + 1`
   [[ $DEB == y ]] && echo "Registros $REGISTROS"
  for ((i=1;i<=$REGISTROS;i++)); do
      R=`head -n 1  "${1}" | cut -d: -f$i`
      [[ $DEB == y ]] && printf "R es ${R::-1}\n"
      if [[ "${R}" == "ID" ]]; then
        #ID=`cat "${1}" | wc -l`
        
        ID=`tail -n1 "${1}"| cut -d: -f1`
        if [[ $ID != "ID" ]]; then
          ID=`expr $ID + 1`
        else
           ID=0
        fi 
        CAMPO=$ID$CAMPO
      [[ $DEB == y ]] &&   echo "ID es $ID campo es $CAMPO"
       

       #revisar si es foranea
       elif [[ ! -z "${2}" ]] && [[ $DENTRO == "n" ]]; then
         #Es relacional
         CAMPO=$CAMPO:"${2}"
          [[ $DEB == y ]] && echo "CAMPO es $CAMPO"
         #para que no vuelva a pasar por aqui desactivamos el valor de la variable
         DENTRO="y"
       else
    
         #If Field is text launch editor
         if [ `echo "$R" |rev| cut -c1`  != "t" ]; then
           read -p "${R::-1}: " FIELD 
         else
          ./tedit texto.txt
          FIELD=`cat texto.txt|tr "\n" "|"` 
          rm texto.txt
         fi
       CAMPO="${CAMPO}":`echo -e "${FIELD}"`
       clear
     fi 
     

done
   printf "${CAMPO}\n">>"${1}"
    [[ $DEB == y ]] && read -p "Pulsa intro"

read -p  "New Value? (INTRO=YES |n=EXIT) " OPT
[[ $OPT == "n" ]] && break
done
}


#Modify Value
function ModifyValue(){
 
 while true; do
    clear
   read -p "Write Value for Modify? (Intro All Values) : " VALUE
  #si esta vacia la var. 
  #mostrar solo las opciones 

  if [ -s $VALUE ]; then 
      tail  -n +2 "${1}"
     else
      grep -E "${VALUE}" "${1}"
  fi
  printf  "\nChoose Value (index) to Modify | First Column\n"
  read -p "(r) Repeat Search | (q) Exit " OPT    
   
   [[ $OPT == "q" ]] && break
   if  [ $OPT != "r" ]; then
      MOD=`awk -F: -v OPT=$OPT '{ if ($1==OPT) {print}}' "${1}"`
      #MOD=`grep -E "${OPT}:" "${1}"` 
      NREG=`head -n 1 "${1}" |awk -F: '{printf NF -1}'`
      NREG=`expr $NREG + 1`
      [[ $DEB == y ]] && echo "Registros $NREG"
      for (( j=2;j<=$NREG;j++)); do
        R=`head -n 1  "${1}" | cut -d: -f$j`
        if [[ $R != "FID" ]]; then

	  [[ $DEB == y ]] &&  printf "R es ${R::-1}\n"
          printf "${R::-1}: " &&  printf "${MOD}" | cut -d: -f$j
          ACTUAL=`printf "${MOD}" | cut -d: -f$j`

          read -p "For change Press (y) otherwise ENTER " OPTION
          if [[ $OPTION == "y" ]] ; then 
          #Apuntamos el numero correcto de la fila
          FILA=`awk -F: -v OPT=$OPT '{ if ($1==OPT) {print}}' "${1}" |cut -d: -f1` 
          #FILA=`grep -Fn "${OPT}:" "${1}" | cut -d: -f1`
 	    if [ `echo "$R" |rev| cut -c1`  != "t" ]; then
            
              read -p "New Value for ${R::-1}: " FIELD 
              #change value of column and row
               [[ $DEB == y ]] && printf "Fila $FILA Columna $j valor $FIELD\n"
              cp "${1}" "${1}".bak
	    
              [[ $DEB == y ]] && awk -F: -v OFS=: -v FILA=$FILA -v COL=$j -v FIELD="${FIELD}" '($1==FILA) {$COL=FIELD}1'
              awk -F: -v OFS=: -v FILA=$FILA -v COL=$j -v FIELD="${FIELD}" '($1==FILA) {$COL=FIELD}1' "${1}".bak>"${1}"
             read -p "Intro..."    
            else
              #change | for \n in feld and put in file
              printf "${MOD}" | cut -d: -f$j |tr "|" "\n" >>texto.txt
              #cat texto.txt|tr "|" "\n" >>texto.txt.bak
              #execute tedit for edit
              ./tedit texto.txt
              clear
              echo
             #When finish change \n for |
             FIELD=`cat texto.txt|tr "\n" "|"`
             printf "$FIELD"
              [[ $DEB == y ]] && read -p "Intro ..."      
             rm texto.txt
             #change value of column and row
	     cp "${1}" "${1}".bak
             [[ $DEB == y ]] && awk -F: -v OFS=: -v FILA=$FILA -v COL=$j -v FIELD="${FIELD}" '($1==FILA) {$COL=FIELD}1'
             awk -F: -v OFS=: -v FILA=$FILA -v COL=$j -v FIELD="${FIELD}" '($1==FILA) {$COL=FIELD}1' "${1}".bak>"${1}"
             printf "\n"  
           fi
         
         fi

     fi #FID
      done      

       [[ $DEB == y ]] && read -p "Press INTRO to Continue" O
  fi
done
}


##
# Delete Values to de DDBB
##
function DeleteValue(){
 
 while true; do
    clear
   read -p "Write Value for delete? (Intro All Values) : " VALUE
  #si esta vacia la var. 
  #mostrar solo las opciones 

  if [ -s $VALUE ]; then 
      tail  -n +2 "${1}"
     else
      grep  -i "${VALUE}" "${1}"
   fi
  printf  "\nChoose Value (index) to delete | First Column\n"
  read -p "(r) Repeat Search | (q) Exit " OPT    
   
   [[ $OPT == "q" ]] && break
   if  [ $OPT != "r" ]; then
      DEL=`awk -F: -v OPT=$OPT '{ if ($1==OPT) {print}}' "${1}"`
      #DEL=`grep -E "${OPT}:" "${1}"` 
      read -p  "Deleting RECORD $DEL (y)" O
      if [[ $O == y ]]; then
      #awk -v n=$OPT 'NR == n {next} {print}' "${1}" 
      sed -i.bak "/${DEL}/d" "${1}"
      printf "Deleted Record"
      else
        printf "Record not deleted\n"
     fi
     read -p "Press INTRO to Continue" O
  fi
done
}



#Agrega una tabla
function AddTable(){
#Generar los campos
   while true; do
      clear  
      tput cup 1 0 && for ((i=1;i<=$COLS;i++)); do printf "${CREV} "; done 
      tput cup 1 0 &&  printf "${CREV}Write the Name of FIELDS of BBDD | (q) Exit:${NC}\n"
      read -p "Field Name: " FIELD
      [ $FIELD == 'q' ] && break
       
       #si el campo es de valor texto largo debemos saberlo para pasar editor
       read -p "Is longer text?(y) " TEXT
 
      if [ $TEXT == "y" ]; then
          FIELD="${FIELD}t"
       else
          FIELD="${FIELD}n"
       fi

      CAMPO="$CAMPO:$FIELD"  
  done
     echo "$CAMPO">"${DTABLE}"
}


#====================
##Inicio de la BBDD
#===================
if [ ${#} -ne 1 ];then
 printf "Use $0 BBDD\n"
 exit 1
else
  if [ ! -f "${1}" ]; then
    touch "${1}"
    CAMPO="ID"
  
#Generar la primera tabla
read -p "First Name Table: " TABLE
touch "${1}.${TABLE}"
DTABLE="${1}.${TABLE}"

AddTable "${DTABLE}"
 fi
fi

##Fin inicio BBDD 



#Escoge la tabla 
function EscogeTabla(){
  TABLAS=`ls -lat "${1}"* |awk '!/bak/ && /\./' |rev |cut -d" " -f1 |rev`
  z=1
  for i in `printf "$TABLAS"` ;do  
    echo "$z ${i}" 
    z=`expr $z + 1`
  done
  
 read -p "Chose the Number of TABLE: | (q) Exit: " OPT
if [[ $OPT != q ]]; then
 OTABLA=`printf "$TABLAS" |awk -v FILA=$OPT 'NR==FILA'`
 printf "tabla : ${OTABLA}\n"
  
#revisamos si es relacional
 #grep  "${OTABLA}""${1}"
 #revisamos si la tabla en el segundo valor esta introducido en el fichero
#si da positivo es relacional sino no es relacional

 cat "${1}" |cut -d: -f2 | grep "${OTABLA}"
 if [[ $? -eq 0 ]] && [[ ${2} -eq 1 ]]; then
    REL=`grep  "${OTABLA}" "${1}" |head -n1|cut -d: -f1`
    Relacional $REL
    printf "Relacional es $REL\n"
     [[ $DEB == y ]] && read -p "Intro..." 
    VALUE=`echo $VALUE|cut -d: -f1`
      case ${2} in 
      1) AgregarValores "${OTABLA}" $VALUE;;
      2) ModifyValue "${OTABLA}"  $VALUE;;
      3) DeleteValue "${OTABLA}" $VALUE;;
    esac  
  else
    case ${2} in 
      1) AgregarValores "${OTABLA}" ;;
      2) ModifyValue "${OTABLA}" ;;
      3) DeleteValue "${OTABLA}" ;;
    esac 
  fi

fi
}




#==============================================
########### TABLAS RELACIONALES ###############
#==============================================
function AddTableR(){
read -p  "New Table Name: " NTABLE
touch "${1}"."${NTABLE}"
CAMPO=ID
DTABLE="${1}"."${NTABLE}"
read -p "Relational 1 to ∞ ? (y) " REL

if [[ $REL == "y" ]]; then
   TABLAS=`ls -lat "${1}"* |awk '!/bak/ && /\./' |rev |cut -d" " -f1 |rev`
    z=1
    for i in `printf "$TABLAS"` ;do  
      echo "$z ${i}" 
      z=`expr $z + 1`
     done
  
 read -p "Chose the Number of [ PRIMARY ] Table : " OPT
 OTABLA=`printf "$TABLAS" |awk -v FILA=$OPT 'NR==FILA'`
 printf "tabla : ${OTABLA}\n"  
 echo "${OTABLA}":"${1}"."${NTABLE}" >> "${1}"
 CAMPO="$CAMPO:FID"  
 AddTable "${DTABLE}" 
 else
   
   printf " Table Create Succesfuly\n"
   AddTable "${DTABLE}"  
   read -p "Press INTRO"
fi
}


#Escoge la tabla primaria
function Relacional(){
while true; do
  clear
  read -p  "Search Registry from ${1}: " OPT
  grep  "${OPT}"  "${1}"
  echo 
  read -p  "Select Record (r) =>Repeat | (q)=> Exit " OPT 
  [[ $OPT == "q" ]] && break
  if [[ $OPT != "r" ]]; then
    VALUE=`grep "${OPT}:" "${1}"`
     [[ $DEB == y ]] && printf "You choose $VALUE\n"
     [[ $DEB == y ]] && read -p  "Intro..."  
    break
   fi
done
}

function DelTable(){
#Delete table

  TABLAS=`ls -lat "${1}"* |awk '!/bak/ && /\./' |rev |cut -d" " -f1 |rev`
  z=1
  for i in `printf "$TABLAS"` ;do  
    echo "$z ${i}" 
    z=`expr $z + 1`
  done
 echo  
 read -p "Choose  Number TABLE to DELETE (q) Exit : " OPT
 
if [[ $OPT != q ]]; then
  OTABLA=`printf "$TABLAS" |awk -v FILA=$OPT 'NR==FILA'`
 
  #Mirar relaciones
   TAB=`grep "${OTABLA}" "${1}" |head -n1 | cut -d: -f1`
   printf "TABLA en RELACION es $TAB Tabla Selec $OTABLA\n"
  if [[ "${TAB}" == "${OTABLA}" ]]; then
   CHILD=`grep "${OTABLA}" "${1}" |cut -d: -f2`
   printf "Table ${OTABLA} is a PARENT RELATIONAL. PLEASE REMOVE AFTER THE NEXT CHILD TABLES:\n\n"
   printf "$CHILD"
   echo 
 else
    
    printf "WARNING ALL DATA FROM **** ${OTABLA} *** WILL BE DESTROYED . This action is not REVERSIBLE \n"
    read -p "Option (y)? " OPT
    if [ $OPT == "y" ]; then
      #revisar relacionar y borrar el fichero y la bbdd
      CHILD=`grep "${OTABLA}" "${1}" |cut -d: -f2`
      [[ $DEB == y ]] &&  printf "Tabla es $CHILD"
      sed -i.bak "/${CHILD}/d" "${1}" 2>/dev/null
      #rm "${CHILD}"
      rm "${OTABLA}"
      if [[ $? -eq 1 ]]; then
        printf "Failed to remove. Plese review permissions on directory\n"
        else
        printf "DataBase Removed Correctly\n"
       fi   
 fi
  fi
  echo
 read -p "Press Intro "

fi #Exit 
}


########################
## BACKUP
#######################
function Backup(){

read -p "Backup FULL directory =>(d) | or DataBase ${1}=>Intro ?" OPT
HOY=`date +%y%m%d`.${RANDOM:0:2}

if [[ $OPT == "d" ]]; then
 DIR="${PWD}"
 echo $DIR
 cd ..
  tar cvfz tdata."${HOY}".tar.gz "${DIR##*/}"
  if [ $? -eq 0 ]; then
     cd -
     mv ../tdata."${HOY}".tar.gz .
     printf "\nBackup Succesfully\n"
  else
    cd -
    printf "\nFailed to backup. Review Permissions\n"
    
  fi 

else
  tar cvfz "${1}"."${HOY}".tar.gz  "${1}"* dtQuery
    if [ $? -eq 0 ]; then
       printf "\nBackup Succesfully\n"
  else
    
    printf "\nFailed to backup. Review Permissions\n"
    
  fi 
    


fi
read -p "Intro"
}


#Imprime cabecera
function cabecera(){
  tput cup 1 0 && for ((i=1;i<=$COLS;i++)); do printf "${CREV} "; done 
  tput cup 1 0 && printf "${CREV}Choose Option for ${1} ${OTABLA}${NC}\n\n\t(1) Append Values 2 BBDD\n\t(2) Modify Values\n\t(3) Delete Values\n\t(4) Querys\n\t(5) Add Table\n\t(6) Delete Table\n\t(7) Backup\n\t(q) Exit\n\n"
}


##MAIN PROG ##
 while true ; do
    clear
    cabecera "${1}" "${OTABLA}"
    read -p "Option: " OPT
    case $OPT in
       1) EscogeTabla "${1}" 1 ;;  #&& AgregarValores "${1}" ;;
       2) EscogeTabla "${1}" 2 ;;
       3) EscogeTabla "${1}" 3 ;;
       4) ./tdquery.sh "${1}"  ;;
       5) AddTableR "${1}" ;;
       6) DelTable "${1}" ;;
       7) Backup "${1}" ;;
       q) exit 1 ;;
       *) printf "Incorrect Option" ;;
      esac
 done
exit 0
