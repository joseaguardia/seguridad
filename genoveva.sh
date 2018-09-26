#!/bin/bash

VERSION="1.2"

clear

#Colores y marcas
NOCOL='\e[0m' # No Color
GREEN='\e[1;32m'
BLUE='\e[1;34m'
RED='\e[1;31m'
MAGENTA='\e[1;35m'
OK="[${GREEN}✓${NOCOL}]"
KO="[${RED}✗${NOCOL}]"

#Editar esta variable para quitar/añadir símbolos
CARACTERES="-_!,.%*+\$"

VERBOSE=0
SECONDS=0
COMBOS=17335754    #Combinaciones máximas por palabra


printHelp() {
    echo
    echo "Uso:"
    echo "$0 -i inputFile -o outputFile [-v]"
    echo "$0 -p \"uno dos tres\"  -o outputFile [-v]"
    echo "-i: archivo de entrada que contienen las palabras base"
    echo "-p: listado de palabras entrecomilladas y separadas por espacios"
    echo "-o: archivo de salida para el diccionario"
    echo "-v: modo verbose. Muestra las combinaciones creadas"
    echo
}

printInfo() {
    echo
    echo "Desde un listado de palabras, genera 17335754 combinaciones por cada palabra, mezclando minúsculas, capitalizada, "
    echo "mayúsculas, escritura L33T (completa e individual por cada vocal y "s"), reverso, números de 1 a 4 cifras, fechas en formato "
    echo "mmddyyyy de 1950 a 2020, formato de fecha mmddyy, símbolos al final, símbolos entre nombre y fecha..."
    echo "https://github.com/joseaguardia/GENOVEVA"
    echo
   }


echo -e $MAGENTA
echo " .88888.   88888888b 888888ba   .88888.  dP     dP  88888888b dP     dP  .d888888  ";
echo "d8'   \`88  88        88    \`8b d8'   \`8b 88     88  88        88     88 d8'    88  ";
echo "88        a88aaaa    88     88 88     88 88    .8P a88aaaa    88    .8P 88aaaaa88a ";
echo "88   YP88  88        88     88 88     88 88    d8'  88        88    d8' 88     88  ";
echo "Y8.   .88  88        88     88 Y8.   .8P 88  .d8P   88        88  .d8P  88     88  ";
echo " \`88888'   88888888P dP     dP  \`8888P'  888888'    88888888P 888888'   88     88  ";
echo -e "$NOCOL"
echo -e "$(tput bold)              ---  Generador de nombres veloz y variado v$VERSION  ---     $(tput sgr0)"

#Lanzamos la ayuda si falta algo
    if [ $# -eq 0 ]; then
        printInfo
        printHelp
        exit 2
    fi


#Pasamos como parámetros las opciones
    while getopts "p:i:o:v" OPT; do
            case $OPT in
                p) # palabras de entrada
                   #set -f
                   #IFS=','
                   PALABRAS="$OPTARG"
                   ;;
                i) # archivo de entrada
                   ENTRADA="$OPTARG"
                   ;;
                o) # archivo de salida
                   SALIDA="$OPTARG"
                   ;;
                v) VERBOSE=1
                   ;;
                *) #opciones no reconocidas
                   echo -e "$KO $RED ERROR:$NOCOL opción no reconocida"
                   printHelp  
                   exit 2
                   ;;
            esac
    done


#Comprobamos que solo haya un método de entrada
if [ ! -z $ENTRADA ] && [ ! -z "$PALABRAS" ]; then

    echo
	echo -e "$KO ${RED}ERROR:${NOCOL} Solo es posible un método de entrada: archivo o listado"
    echo
    printHelp
    exit 1
    
fi

#Comprobamos si la variable de entrada y salida son válidas:
if [ -z "$PALABRAS" ]; then
  if [ -z $ENTRADA ] || [ -z $SALIDA ]; then

    echo
	echo -e "$KO ${RED}ERROR:${NOCOL} El archivo de entrada o salida no son válidos"
    echo
    printHelp
    exit 1
  fi  
fi


#Comprobamos si el archivo de entrada existe
if [ -z "$PALABRAS" ]; then
  if [ ! -f $ENTRADA ]; then

    echo
	echo -e "$KO ${RED}ERROR:${NOCOL} El archivo de entrada $ENTRADA no existe"
    echo
    printHelp
    exit 1
  fi
fi

#Comprobamos si el archivo de salida ya existe
if [ -f $SALIDA ]; then

    echo
    echo -e "$KO ${RED}ERROR:${NOCOL} El archivo de salida $SALIDA ya existe"
    echo
    printHelp
    exit 1

fi


#Comprobamos permiso de escritura en el directorio de salida
RUTA=$(dirname $(readlink -f $SALIDA))
if [ ! -w $RUTA ]; then

    echo
    echo -e "$KO ${RED}ERROR:${NOCOL} No se puede escribir en la ruta $RUTA"
    echo
    printHelp
    exit 1

fi


#Si tenemos palabras de entrada, creamos un archivo de entrada temporal
if [ ! -z "$PALABRAS" ]; then

    #Borramos el archivo si existe
    [ -e /tmp/genoveva.tmp ] && rm -f /tmp/genoveva.tmp

    tr [:space:] \\n <<< $PALABRAS > /tmp/genoveva.tmp
    #Comprobamos que se haya creado correctamente
    if [ -f /tmp/genoveva.tmp ]; then

        ENTRADA="/tmp/genoveva.tmp"

    else

        echo
        echo -e "$KO ${RED}ERROR:${NOCOL} No se ha podido escribir en /tmp. Prueba usando la opción '-i archivoEntrada'"
        echo
        printHelp
        exit 1

    fi
fi


#Sacamos el número de palabras de entrada
LINEAS=$(cat $ENTRADA | tr -d " "  | tr "\t" "\n" | tr [:upper:] [:lower:] | grep . | sort | uniq | wc -l)

echo
echo -e "$OK ${GREEN}[TODO OK!]${NOCOL} Comenzamos a crear el diccionario"
echo
echo -e "Palabras de entrada: \t\t$LINEAS"
echo -e "Combinaciones máximas a crear: $(tput bold)\t$(expr $LINEAS \* $COMBOS ) $(tput sgr0)"
echo -e "Tamaño de fichero máximo:\t$(expr $LINEAS \* 321)MB"
echo

sleep  5


#Limpiamos la entrada de tildes, espacios, líneas vacias, pasamos a minúsculas...
cat $ENTRADA | tr -d " "  | tr "\t" "\n" | tr [:upper:] [:lower:] | grep . | sort | uniq | sed 'y/áÁàÀãÃâÂéÉêÊíÍóÓõÕôÔúÚçÇ/aAaAaAaAeEeEiIoOoOoOuUcC/' | while read NOMBRE

    do

        #En algunos casos tenemos una variable intermedia
        #para que la generación sea mucho más rápida
        NCAP="$(sed -e 's/^./\U&/g; s/ ./\U&/g' <<< $NOMBRE)"
        NMAY="$(tr [:lower:] [:upper:] <<< $NOMBRE)"
        NREV="$(rev <<< $NOMBRE)"
        NREVCAP="$(sed -e 's/^./\U&/g; s/ ./\U&/g' <<< $NREV)"            #Soiradeceba
        NCAPREV="$(sed -e 's/^./\U&/g; s/ ./\U&/g' <<< $NOMBRE | rev)"    #soiradecebA
        NREVMAY="$(tr [:lower:] [:upper:] <<< $NREV)"


        echo -e "$OK Generando combinaciones para $NOMBRE"
        echo


        #Nombre normal, capitalizado, mayúsculas, reverso:
        if [ $VERBOSE = 1 ]; then
            echo "Para el ejemplo 'abecedarios'..."
            echo -e "\t[${SECONDS} s]\t${BLUE}Generando 'abecedarios'$NOCOL"
        fi
        echo $NOMBRE >> $SALIDA                                                             #Nombre

        if [ $VERBOSE = 1 ]; then
            echo -e "\t[${SECONDS} s]\t${BLUE}Generando 'Abecedarios'$NOCOL"
        fi
        echo ${NOMBRE} | sed -e 's/^./\U&/g; s/ ./\U&/g' >> $SALIDA                         #Nombre Capitalizado

        if [ $VERBOSE = 1 ]; then
            echo -e "\t[${SECONDS} s]\t${BLUE}Generando 'ABECEDARIOS'$NOCOL"
        fi
        echo ${NOMBRE} | tr [:lower:] [:upper:] >> $SALIDA                                  #Nombre Mayúsculas

        if [ $VERBOSE = 1 ]; then
            echo -e "\t[${SECONDS} s]\t${BLUE}Generando 'soiradeceba'$NOCOL"
        fi
        echo ${NOMBRE} | rev >> $SALIDA                                                     #Reverso

        if [ $VERBOSE = 1 ]; then
            echo -e "\t[${SECONDS} s]\t${BLUE}Generando 'soiradecebA'$NOCOL"
        fi
        echo ${NOMBRE} | sed -e 's/^./\U&/g; s/ ./\U&/g' | rev >> $SALIDA

        if [ $VERBOSE = 1 ]; then
            echo -e "\t[${SECONDS} s]\t${BLUE}Generando 'Soiradeceba'$NOCOL"
        fi
        echo ${NOMBRE} | rev | sed -e 's/^./\U&/g; s/ ./\U&/g' >> $SALIDA

        if [ $VERBOSE = 1 ]; then
            echo -e "\t[${SECONDS} s]\t${BLUE}Generando 'SOIRADECEBA'$NOCOL"
        fi
        echo ${NOMBRE} | tr [:lower:] [:upper:] | rev >> $SALIDA


        #l33t completo de vocales:
        if [ $VERBOSE = 1 ]; then
            echo -e "\t[${SECONDS} s]\t${BLUE}Generando '4b3c3d4r10s'$NOCOL"
        fi
        echo ${NOMBRE} | sed 'y/aeioAeio/43104310/' >> $SALIDA                                        #Nombre L33t Solo Vocales

        if [ $VERBOSE = 1 ]; then
            echo -e "\t[${SECONDS} s]\t${BLUE}Generando '4b3c3d4r10s'$NOCOL"
        fi
        echo ${NOMBRE} | sed -e 's/^./\U&/g; s/ ./\U&/g' | sed 'y/aeioAEIO/43104310/' >> $SALIDA       #Nombe capitalizado L33t Solo vocales

        if [ $VERBOSE = 1 ]; then
            echo -e "\t[${SECONDS} s]\t${BLUE}Generando '4B3C3D4R10S'$NOCOL"
        fi
        echo ${NOMBRE} | tr [:lower:] [:upper:] | sed 'y/aeioAEIO/43104310/' >> $SALIDA


        #l33t completo de vocales y 's' si lleva "S" el nombre:
        if [[ $NOMBRE == *[Ss]* ]]; then

            if [ $VERBOSE = 1 ]; then
                echo -e "\t[${SECONDS} s]\t${BLUE}Generando '4b3c3d4r10$'$NOCOL"
            fi
            echo ${NOMBRE} | sed 'y/sSaeioAeio/$$43104310/' >> $SALIDA

            if [ $VERBOSE = 1 ]; then
                echo -e "\t[${SECONDS} s]\t${BLUE}Generando '4b3c3d4r10$'$NOCOL"
            fi
            echo ${NOMBRE} | sed -e 's/^./\U&/g; s/ ./\U&/g' | sed 'y/sSaeioAEIO/$$43104310/' >> $SALIDA

            if [ $VERBOSE = 1 ]; then
                echo -e "\t[${SECONDS} s]\t${BLUE}Generando '4B3C3D4R10$'$NOCOL"
            fi
            echo ${NOMBRE} | tr [:lower:] [:upper:] | sed 'y/sSaeioAEIO/$$43104310/' >> $SALIDA

        fi


        #l33t solo de una letra cada vez:
        if [[ $NOMBRE == *[aA]* ]]; then
            if [ $VERBOSE = 1 ]; then
              echo -e "\t[${SECONDS} s]\t${BLUE}Generando '4becedarios'$NOCOL"
            fi
            echo ${NOMBRE} | sed 'y/aA/44/' >> $SALIDA

            if [ $VERBOSE = 1 ]; then
                echo -e "\t[${SECONDS} s]\t${BLUE}Generando '4becedarios'$NOCOL"
            fi
            echo ${NOMBRE} | sed -e 's/^./\U&/g; s/ ./\U&/g' | sed 'y/aA/44/' >> $SALIDA
            if [ $VERBOSE = 1 ]; then
                echo -e "\t[${SECONDS} s]\t${BLUE}Generando '4BECEDARIOS'$NOCOL"
            fi
            echo ${NOMBRE} | tr [:lower:] [:upper:]| sed 'y/aA/44/' >> $SALIDA
        fi

        if [[ $NOMBRE == *[eE]* ]]; then
            if [ $VERBOSE = 1 ]; then
                echo -e "\t[${SECONDS} s]\t${BLUE}Generando '4b3c3darios'$NOCOL"
            fi
            echo ${NOMBRE} | sed 'y/eE/33/' >> $SALIDA
            if [ $VERBOSE = 1 ]; then
                echo -e "\t[${SECONDS} s]\t${BLUE}Generando 'Ab3c3darios'$NOCOL"
            fi
            echo ${NOMBRE} | sed -e 's/^./\U&/g; s/ ./\U&/g' | sed 'y/eE/33/' >> $SALIDA
            if [ $VERBOSE = 1 ]; then
                echo -e "\t[${SECONDS} s]\t${BLUE}Generando 'AB3C3DARIOS'$NOCOL"
            fi
            echo ${NOMBRE} | tr [:lower:] [:upper:]| sed 'y/eE/33/' >> $SALIDA
        fi
        if [[ $NOMBRE == *[iI]* ]]; then
            if [ $VERBOSE = 1 ]; then
                echo -e "\t[${SECONDS} s]\t${BLUE}Generando 'abecedar1os'$NOCOL"
            fi
            echo ${NOMBRE} | sed 'y/iI/11/' >> $SALIDA
            if [ $VERBOSE = 1 ]; then
                echo -e "\t[${SECONDS} s]\t${BLUE}Generando 'Abecedar1os'$NOCOL"
            fi
            echo ${NOMBRE} | sed -e 's/^./\U&/g; s/ ./\U&/g' | sed 'y/iI/11/' >> $SALIDA
            if [ $VERBOSE = 1 ]; then
                echo -e "\t[${SECONDS} s]\t${BLUE}Generando 'ABECEDAR1OS'$NOCOL"
            fi
            echo ${NOMBRE} | tr [:lower:] [:upper:]| sed 'y/iI/11/' >> $SALIDA
        fi
        if [[ $NOMBRE == *[oO]* ]]; then
            if [ $VERBOSE = 1 ]; then
                echo -e "\t[${SECONDS} s]\t${BLUE}Generando 'abecedari0s'$NOCOL"
            fi
            echo ${NOMBRE} | sed 'y/oO/00/' >> $SALIDA
            if [ $VERBOSE = 1 ]; then
                echo -e "\t[${SECONDS} s]\t${BLUE}Generando 'Abecedari0s'$NOCOL"
            fi
            echo ${NOMBRE} | sed -e 's/^./\U&/g; s/ ./\U&/g' | sed 'y/oO/00/' >> $SALIDA
            if [ $VERBOSE = 1 ]; then
                echo -e "\t[${SECONDS} s]\t${BLUE}Generando 'ABECEDARI0S'$NOCOL"
            fi
            echo ${NOMBRE} | tr [:lower:] [:upper:]| sed 'y/oO/00/' >> $SALIDA
        fi


        #Añadimos un símbolo detrás
        grep -o . <<< $CARACTERES | while read SIMBOLOS
        do
            if [ $VERBOSE = 1 ]; then
                echo -e "\t[${SECONDS} s]\t${BLUE}Generando 'abecedarios${SIMBOLOS}'$NOCOL"
            fi
            echo "${NOMBRE}${SIMBOLOS}" >> $SALIDA
            if [ $VERBOSE = 1 ]; then
                echo -e "\t[${SECONDS} s]\t${BLUE}Generando 'Abecedarios${SIMBOLOS}'$NOCOL"
            fi
            echo "$(echo ${NOMBRE} | sed -e 's/^./\U&/g; s/ ./\U&/g')${SIMBOLOS}" >> $SALIDA
            if [ $VERBOSE = 1 ]; then
                echo -e "\t[${SECONDS} s]\t${BLUE}Generando 'ABECEDARIOS${SIMBOLOS}'$NOCOL"
            fi
            echo "$(echo ${NOMBRE} | tr [:lower:] [:upper:])${SIMBOLOS}" >> $SALIDA


            if [ $VERBOSE = 1 ]; then
                echo -e "\t[${SECONDS} s]\t${BLUE}Generando 'soiradeceba${SIMBOLOS}'$NOCOL"
            fi
            echo "$(echo ${NOMBRE} | rev)${SIMBOLOS}" >> $SALIDA
            if [ $VERBOSE = 1 ]; then
                echo -e "\t[${SECONDS} s]\t${BLUE}Generando 'soiradecebA${SIMBOLOS}'$NOCOL"
            fi
            echo "$(echo ${NOMBRE} | sed -e 's/^./\U&/g; s/ ./\U&/g' | rev)${SIMBOLOS}" >> $SALIDA
            if [ $VERBOSE = 1 ]; then
                echo -e "\t[${SECONDS} s]\t${BLUE}Generando 'Soiradeceba${SIMBOLOS}'$NOCOL"
            fi
            echo "$(echo ${NOMBRE} | rev | sed -e 's/^./\U&/g; s/ ./\U&/g')${SIMBOLOS}" >> $SALIDA
            if [ $VERBOSE = 1 ]; then
                echo -e "\t[${SECONDS} s]\t${BLUE}Generando 'SOIRADECEBA${SIMBOLOS}'$NOCOL"
            fi
            echo "$(echo ${NOMBRE} | rev | tr [:lower:] [:upper:])${SIMBOLOS}" >> $SALIDA



            if [ $VERBOSE = 1 ]; then
                echo -e "\t[${SECONDS} s]\t${BLUE}Generando '4b3c3d4r10s${SIMBOLOS}'$NOCOL"
            fi
            echo "$(echo ${NOMBRE} | sed 'y/sSaeioAeio/$$43104310/')${SIMBOLOS}" >> $SALIDA
            if [ $VERBOSE = 1 ]; then
                echo -e "\t[${SECONDS} s]\t${BLUE}Generando '4b3c3d4r10s${SIMBOLOS}'$NOCOL"
            fi
            echo "$(echo ${NOMBRE} | sed -e 's/^./\U&/g; s/ ./\U&/g' | sed 'y/aeioAEIO/43104310/')${SIMBOLOS}" >> $SALIDA
            if [ $VERBOSE = 1 ]; then
                echo -e "\t[${SECONDS} s]\t${BLUE}Generando '4B3C3D4R10S${SIMBOLOS}'$NOCOL"
            fi
            echo "$(echo ${NOMBRE} | tr [:lower:] [:upper:] | sed 'y/aeioAEIO/43104310/')${SIMBOLOS}" >> $SALIDA



            if [[ $NOMBRE == *[Ss]* ]]; then
                if [ $VERBOSE = 1 ]; then
                    echo -e "\t[${SECONDS} s]\t${BLUE}Generando 'abecedario\$${SIMBOLOS}'$NOCOL"
                fi
                echo "$(echo ${NOMBRE} | sed 'y/sS/$$/')${SIMBOLOS}" >> $SALIDA
                if [ $VERBOSE = 1 ]; then
                    echo -e "\t[${SECONDS} s]\t${BLUE}Generando 'Abecedario\$${SIMBOLOS}'$NOCOL"
                fi
                echo "$(echo ${NOMBRE} | sed -e 's/^./\U&/g; s/ ./\U&/g' | sed 'y/sS/$$/')${SIMBOLOS}" >> $SALIDA
                if [ $VERBOSE = 1 ]; then
                    echo -e "\t[${SECONDS} s]\t${BLUE}Generando 'ABECEDARIO\$${SIMBOLOS}'$NOCOL"
                fi
                echo "$(echo ${NOMBRE} | tr [:lower:] [:upper:]| sed 'y/sS/$$/')${SIMBOLOS}" >> $SALIDA

            fi

            if [[ $NOMBRE == *[aA]* ]]; then
                if [ $VERBOSE = 1 ]; then
                    echo -e "\t[${SECONDS} s]\t${BLUE}Generando '4beced4rios${SIMBOLOS}'$NOCOL"
                fi
                echo "$(echo ${NOMBRE} | sed 'y/aA/44/')${SIMBOLOS}" >> $SALIDA
                if [ $VERBOSE = 1 ]; then
                    echo -e "\t[${SECONDS} s]\t${BLUE}Generando '4beced4rios${SIMBOLOS}'$NOCOL"
                fi
                echo "$(echo ${NOMBRE} | sed -e 's/^./\U&/g; s/ ./\U&/g' | sed 'y/aA/44/')${SIMBOLOS}" >> $SALIDA
                if [ $VERBOSE = 1 ]; then
                    echo -e "\t[${SECONDS} s]\t${BLUE}Generando '4BECED4RIOS${SIMBOLOS}'$NOCOL"
                fi
                echo "$(echo ${NOMBRE} | tr [:lower:] [:upper:]| sed 'y/aA/44/')${SIMBOLOS}" >> $SALIDA
            fi

            if [[ $NOMBRE == *[eE]* ]]; then
                if [ $VERBOSE = 1 ]; then
                    echo -e "\t[${SECONDS} s]\t${BLUE}Generando 'ab3c3darios${SIMBOLOS}'$NOCOL"
                fi
                echo "$(echo ${NOMBRE} | sed 'y/eE/33/')${SIMBOLOS}" >> $SALIDA
                if [ $VERBOSE = 1 ]; then
                    echo -e "\t[${SECONDS} s]\t${BLUE}Generando 'Ab3c3darios${SIMBOLOS}'$NOCOL"
                fi
                echo "$(echo ${NOMBRE} | sed -e 's/^./\U&/g; s/ ./\U&/g' | sed 'y/eE/33/')${SIMBOLOS}" >> $SALIDA
                if [ $VERBOSE = 1 ]; then
                    echo -e "\t[${SECONDS} s]\t${BLUE}Generando 'AB3C3DARIOS${SIMBOLOS}'$NOCOL"
                fi
                echo "$(echo ${NOMBRE} | tr [:lower:] [:upper:]| sed 'y/eE/33/')${SIMBOLOS}" >> $SALIDA
            fi

            if [[ $NOMBRE == *[iI]* ]]; then
                if [ $VERBOSE = 1 ]; then
                    echo -e "\t[${SECONDS} s]\t${BLUE}Generando 'abecedar1os${SIMBOLOS}'$NOCOL"
                fi
                echo "$(echo ${NOMBRE} | sed 'y/iI/11/')${SIMBOLOS}" >> $SALIDA
                if [ $VERBOSE = 1 ]; then
                    echo -e "\t[${SECONDS} s]\t${BLUE}Generando 'Abecedar1os${SIMBOLOS}'$NOCOL"
                fi
                echo "$(echo ${NOMBRE} | sed -e 's/^./\U&/g; s/ ./\U&/g' | sed 'y/iI/11/')${SIMBOLOS}" >> $SALIDA
                if [ $VERBOSE = 1 ]; then
                    echo -e "\t[${SECONDS} s]\t${BLUE}Generando 'ABECEDAR1OS${SIMBOLOS}'$NOCOL"
                fi
                echo "$(echo ${NOMBRE} | tr [:lower:] [:upper:]| sed 'y/iI/11/')${SIMBOLOS}" >> $SALIDA
            fi

            if [[ $NOMBRE == *[oO]* ]]; then
                if [ $VERBOSE = 1 ]; then
                    echo -e "\t[${SECONDS} s]\t${BLUE}Generando 'abecedari0s${SIMBOLOS}'$NOCOL"
                fi
                echo "$(echo ${NOMBRE} | sed 'y/oO/00/')${SIMBOLOS}" >> $SALIDA
                if [ $VERBOSE = 1 ]; then
                    echo -e "\t[${SECONDS} s]\t${BLUE}Generando 'Abecedari0s${SIMBOLOS}'$NOCOL"
                fi
                echo "$(echo ${NOMBRE} | sed -e 's/^./\U&/g; s/ ./\U&/g' | sed 'y/oO/00/')${SIMBOLOS}" >> $SALIDA
                if [ $VERBOSE = 1 ]; then
                    echo -e "\t[${SECONDS} s]\t${BLUE}Generando 'ABECEDARI0S${SIMBOLOS}'$NOCOL"
                fi
                echo "$(echo ${NOMBRE} | tr [:lower:] [:upper:]| sed 'y/oO/00/')${SIMBOLOS}" >> $SALIDA
            fi

        done


        #Secuencia de números
        if [ $VERBOSE = 1 ]; then
            echo -e "\t[${SECONDS} s]\t${BLUE}Generando 'abecedarios0 -> abecedarios9'$NOCOL"
        fi
        echo -e ${NOMBRE}{0..9} | tr [:space:] \\n >> $SALIDA
        if [ $VERBOSE = 1 ]; then
            echo -e "\t[${SECONDS} s]\t${BLUE}Generando 'abecedarios00 -> abecedarios99'$NOCOL"
        fi
        echo -e ${NOMBRE}{00..99} | tr [:space:] \\n >> $SALIDA
        if [ $VERBOSE = 1 ]; then
            echo -e "\t[${SECONDS} s]\t${BLUE}Generando 'abecedarios000 -> abecedarios999'$NOCOL"
        fi
        echo -e ${NOMBRE}{000..999} | tr [:space:] \\n >> $SALIDA
        if [ $VERBOSE = 1 ]; then
            echo -e "\t[${SECONDS} s]\t${BLUE}Generando 'abecedarios0000 -> abecedarios9999'$NOCOL"
        fi
        echo -e ${NOMBRE}{0000..9999} | tr [:space:] \\n >> $SALIDA

        if [ $VERBOSE = 1 ]; then
            echo -e "\t[${SECONDS} s]\t${BLUE}Generando 'Abecedarios0 -> Abecedarios9'$NOCOL"
        fi
        echo -e $(echo ${NOMBRE} | sed -e 's/^./\U&/g; s/ ./\U&/g'){0..9} | tr [:space:] \\n >> $SALIDA
        if [ $VERBOSE = 1 ]; then
            echo -e "\t[${SECONDS} s]\t${BLUE}Generando 'Abecedarios00 -> Abecedarios99'$NOCOL"
        fi
        echo -e $(echo ${NOMBRE} | sed -e 's/^./\U&/g; s/ ./\U&/g'){00..99} | tr [:space:] \\n >> $SALIDA
        if [ $VERBOSE = 1 ]; then
            echo -e "\t[${SECONDS} s]\t${BLUE}Generando 'Abecedarios000 -> Abecedarios999'$NOCOL"
        fi
        echo -e $(echo ${NOMBRE} | sed -e 's/^./\U&/g; s/ ./\U&/g'){000..999} | tr [:space:] \\n >> $SALIDA
        if [ $VERBOSE = 1 ]; then
            echo -e "\t[${SECONDS} s]\t${BLUE}Generando 'Abecedarios0000 -> Abecedarios9999'$NOCOL"
        fi
        echo -e ${NCAP}{0000..9999} | tr [:space:] \\n >> $SALIDA

        if [ $VERBOSE = 1 ]; then
            echo -e "\t[${SECONDS} s]\t${BLUE}Generando 'ABECEDARIOS0 -> ABECEDARIOS9'$NOCOL"
        fi
        echo -e $(echo ${NOMBRE} | tr [:lower:] [:upper:]){0..9} | tr [:space:] \\n >> $SALIDA
        if [ $VERBOSE = 1 ]; then
            echo -e "\t[${SECONDS} s]\t${BLUE}Generando 'ABECEDARIOS00 -> ABECEDARIOS99'$NOCOL"
        fi
        echo -e $(echo ${NOMBRE} | tr [:lower:] [:upper:]){00..99} | tr [:space:] \\n >> $SALIDA
        if [ $VERBOSE = 1 ]; then
            echo -e "\t[${SECONDS} s]\t${BLUE}Generando 'ABECEDARIOS000 -> ABECEDARIOS999'$NOCOL"
        fi
        echo -e $(echo ${NOMBRE} | tr [:lower:] [:upper:]){000..999} | tr [:space:] \\n >> $SALIDA
        if [ $VERBOSE = 1 ]; then
            echo -e "\t[${SECONDS} s]\t${BLUE}Generando 'ABECEDARIOS0000 -> ABECEDARIOS9999'$NOCOL"
        fi
        echo -e ${NMAY}{0000..9999} | tr [:space:] \\n >> $SALIDA


        if [ $VERBOSE = 1 ]; then
            echo -e "\t[${SECONDS} s]\t${BLUE}Generando 'soiradeceba0 -> soiradeceba9'$NOCOL"
        fi
        echo -e $(echo ${NOMBRE} | rev){0..9} | tr [:space:] \\n >> $SALIDA
        if [ $VERBOSE = 1 ]; then
            echo -e "\t[${SECONDS} s]\t${BLUE}Generando 'soiradeceba00 -> soiradeceba99'$NOCOL"
        fi
        echo -e $(echo ${NOMBRE} | rev){00..99} | tr [:space:] \\n >> $SALIDA
        if [ $VERBOSE = 1 ]; then
            echo -e "\t[${SECONDS} s]\t${BLUE}Generando 'soiradeceba000 -> soiradeceba999'$NOCOL"
        fi
        echo -e $(echo ${NOMBRE} | rev){000..999} | tr [:space:] \\n >> $SALIDA
        if [ $VERBOSE = 1 ]; then
            echo -e "\t[${SECONDS} s]\t${BLUE}Generando 'soiradeceba0000 -> soiradeceba9999'$NOCOL"
        fi
        echo -e ${NREV}{0000..9999} | tr [:space:] \\n >> $SALIDA

        if [ $VERBOSE = 1 ]; then
            echo -e "\t[${SECONDS} s]\t${BLUE}Generando 'soiradecebA0 -> soiradecebA9'$NOCOL"
        fi
        echo -e $(echo ${NOMBRE} | sed -e 's/^./\U&/g; s/ ./\U&/g' | rev){0..9} | tr [:space:] \\n >> $SALIDA
        if [ $VERBOSE = 1 ]; then
            echo -e "\t[${SECONDS} s]\t${BLUE}Generando 'soiradecebA00 -> soiradecebA99'$NOCOL"
        fi
        echo -e $(echo ${NOMBRE} | sed -e 's/^./\U&/g; s/ ./\U&/g' | rev){00..99} | tr [:space:] \\n >> $SALIDA
        if [ $VERBOSE = 1 ]; then
            echo -e "\t[${SECONDS} s]\t${BLUE}Generando 'soiradecebA000 -> soiradecebA999'$NOCOL"
        fi
        echo -e ${NCAPREV}{000..999} | tr [:space:] \\n >> $SALIDA
        if [ $VERBOSE = 1 ]; then
            echo -e "\t[${SECONDS} s]\t${BLUE}Generando 'soiradecebA0000 -> soiradecebA9999'$NOCOL"
        fi
        echo -e ${NCAPREV}{0000..9999} | tr [:space:] \\n >> $SALIDA


        if [ $VERBOSE = 1 ]; then
            echo -e "\t[${SECONDS} s]\t${BLUE}Generando 'Soiradeceba0 -> Soiradeceba9'$NOCOL"
        fi
        echo -e $(echo ${NOMBRE} | rev | sed -e 's/^./\U&/g; s/ ./\U&/g'){0..9} | tr [:space:] \\n >> $SALIDA
        if [ $VERBOSE = 1 ]; then
            echo -e "\t[${SECONDS} s]\t${BLUE}Generando 'Soiradeceba00 -> Soiradeceba99'$NOCOL"
        fi
        echo -e $(echo ${NOMBRE} | rev | sed -e 's/^./\U&/g; s/ ./\U&/g'){00..99} | tr [:space:] \\n >> $SALIDA
        if [ $VERBOSE = 1 ]; then
            echo -e "\t[${SECONDS} s]\t${BLUE}Generando 'Soiradeceba000 -> Soiradeceba999'$NOCOL"
        fi
        echo -e ${NREVCAP}{000..999} | tr [:space:] \\n >> $SALIDA
        if [ $VERBOSE = 1 ]; then
            echo -e "\t[${SECONDS} s]\t${BLUE}Generando 'Soiradeceba0000 -> Soiradeceba9999'$NOCOL"
        fi
        echo -e ${NREVCAP}{0000..9999} | tr [:space:] \\n >> $SALIDA

        if [ $VERBOSE = 1 ]; then
            echo -e "\t[${SECONDS} s]\t${BLUE}Generando 'SOIRADECEBA0 -> SOIRADECEBA9'$NOCOL"
        fi
        echo -e $(echo ${NOMBRE} | rev | tr [:lower:] [:upper:]){0..9} | tr [:space:] \\n >> $SALIDA
        if [ $VERBOSE = 1 ]; then
            echo -e "\t[${SECONDS} s]\t${BLUE}Generando 'SOIRADECEBA00 -> SOIRADECEBA99'$NOCOL"
        fi
        echo -e $(echo ${NOMBRE} | rev | tr [:lower:] [:upper:]){00..99} | tr [:space:] \\n >> $SALIDA
        if [ $VERBOSE = 1 ]; then
            echo -e "\t[${SECONDS} s]\t${BLUE}Generando 'SOIRADECEBA000 -> SOIRADECEBA999'$NOCOL"
        fi
        echo -e ${NREVMAY}{000..999} | tr [:space:] \\n >> $SALIDA
        if [ $VERBOSE = 1 ]; then
            echo -e "\t[${SECONDS} s]\t${BLUE}Generando 'SOIRADECEBA0000 -> SOIRADECEBA9999'$NOCOL"
        fi
        echo -e ${NREVMAY}{0000..9999} | tr [:space:] \\n >> $SALIDA





        #Fechas ddmmyyyy
        if [ $VERBOSE = 1 ]; then
            echo -e "\t[${SECONDS} s]\t${BLUE}Generando 'abecedarios01011950 -> abecedarios31122020'$NOCOL"
        fi
        echo -e ${NOMBRE}{01..31}{01..12}{1950..2020} | tr [:space:] \\n >> $SALIDA
        if [ $VERBOSE = 1 ]; then
            echo -e "\t[${SECONDS} s]\t${BLUE}Generando 'Abecedarios01011950 -> Abecedarios31122020'$NOCOL"
        fi
        echo -e ${NCAP}{01..31}{01..12}{1950..2020} | tr [:space:] \\n >> $SALIDA
        if [ $VERBOSE = 1 ]; then
            echo -e "\t[${SECONDS} s]\t${BLUE}Generando 'ABECEDARIOS01011950 -> ABECEDARIOS31122020'$NOCOL"
        fi
        echo -e ${NMAY}{01..31}{01..12}{1950..2020} | tr [:space:] \\n >> $SALIDA


        if [ $VERBOSE = 1 ]; then
            echo -e "\t[${SECONDS} s]\t${BLUE}Generando 'soiradeceba01011950 -> soiradeceba31122020'$NOCOL"
        fi
        echo -e ${NREV}{01..31}{01..12}{1950..2020} | tr [:space:] \\n >> $SALIDA
        if [ $VERBOSE = 1 ]; then
            echo -e "\t[${SECONDS} s]\t${BLUE}Generando 'soiradecebA01011950 -> soiradecebA31122020'$NOCOL"
        fi
        echo -e ${NCAPREV}{01..31}{01..12}{1950..2020} | tr [:space:] \\n >> $SALIDA
        if [ $VERBOSE = 1 ]; then
            echo -e "\t[${SECONDS} s]\t${BLUE}Generando 'Soiradeceba01011950 -> Soiradeceba31122020'$NOCOL"
        fi
        echo -e ${NREVCAP}{01..31}{01..12}{1950..2020} | tr [:space:] \\n >> $SALIDA
        if [ $VERBOSE = 1 ]; then
            echo -e "\t[${SECONDS} s]\t${BLUE}Generando 'SOIRADECEBA01011950 -> SOIRADECEBA31122020'$NOCOL"
        fi
        echo -e ${NREVMAY}{01..31}{01..12}{1950..2020} | tr [:space:] \\n >> $SALIDA




        #Fechas ddmmyy
        if [ $VERBOSE = 1 ]; then
            echo -e "\t[${SECONDS} s]\t${BLUE}Generando 'abecedarios010100 -> abecedarios311299'$NOCOL"
        fi
        echo -e ${NOMBRE}{01..31}{01..12}{00..99} | tr [:space:] \\n >> $SALIDA
        if [ $VERBOSE = 1 ]; then
            echo -e "\t[${SECONDS} s]\t${BLUE}Generando 'Abecedarios010100 -> Abecedarios311299'$NOCOL"
        fi
        echo -e ${NCAP}{01..31}{01..12}{00..99} | tr [:space:] \\n >> $SALIDA
        if [ $VERBOSE = 1 ]; then
            echo -e "\t[${SECONDS} s]\t${BLUE}Generando 'ABECEDARIOS010100 -> ABECEDARIOS311299'$NOCOL"
        fi
        echo -e ${NMAY}{01..31}{01..12}{00..99} | tr [:space:] \\n >> $SALIDA

        if [ $VERBOSE = 1 ]; then
            echo -e "\t[${SECONDS} s]\t${BLUE}Generando 'soiradeceba010100 -> soiradeceba311299'$NOCOL"
        fi
        echo -e ${NREV}{01..31}{01..12}{00..99} | tr [:space:] \\n >> $SALIDA
        if [ $VERBOSE = 1 ]; then
            echo -e "\t[${SECONDS} s]\t${BLUE}Generando 'soiradecebA010100 -> soiradecebA311299'$NOCOL"
        fi
        echo -e ${NCAPREV}{01..31}{01..12}{00..99} | tr [:space:] \\n >> $SALIDA
        if [ $VERBOSE = 1 ]; then
            echo -e "\t[${SECONDS} s]\t${BLUE}Generando 'Soiradeceba010100 -> Soiradeceba311299'$NOCOL"
        fi
        echo -e ${NREVCAP}{01..31}{01..12}{00..99} | tr [:space:] \\n >> $SALIDA
        if [ $VERBOSE = 1 ]; then
            echo -e "\t[${SECONDS} s]\t${BLUE}Generando 'SOIRADECEBA010100 -> SOIRADECEBA311299'$NOCOL"
        fi
        echo -e ${NREVMAY}{01..31}{01..12}{00..99} | tr [:space:] \\n >> $SALIDA




        #Simbolo entre nombre y secuencia de números

        grep -o . <<< $CARACTERES | while read SIMBOLOS
        do
            if [ $VERBOSE = 1 ]; then
                echo -e "\t[${SECONDS} s]\t${BLUE}Generando 'abecedarios${SIMBOLOS}0 -> abecedarios${SIMBOLOS}9'$NOCOL"
            fi
            echo -e ${NOMBRE}${SIMBOLOS}{0..9} | tr [:space:] \\n >> $SALIDA
            if [ $VERBOSE = 1 ]; then
                echo -e "\t[${SECONDS} s]\t${BLUE}Generando 'abecedarios${SIMBOLOS}00 -> abecedarios${SIMBOLOS}99'$NOCOL"
            fi
            echo -e ${NOMBRE}${SIMBOLOS}{00..99} | tr [:space:] \\n >> $SALIDA
            if [ $VERBOSE = 1 ]; then
                echo -e "\t[${SECONDS} s]\t${BLUE}Generando 'abecedarios${SIMBOLOS}000 -> abecedarios${SIMBOLOS}999'$NOCOL"
            fi
            echo -e ${NOMBRE}${SIMBOLOS}{000..999} | tr [:space:] \\n >> $SALIDA
            if [ $VERBOSE = 1 ]; then
                echo -e "\t[${SECONDS} s]\t${BLUE}Generando 'abecedarios${SIMBOLOS}0000 -> abecedarios${SIMBOLOS}9999'$NOCOL"
            fi
            echo -e ${NOMBRE}${SIMBOLOS}{0000..9999} | tr [:space:] \\n >> $SALIDA
            if [ $VERBOSE = 1 ]; then
                echo -e "\t[${SECONDS} s]\t${BLUE}Generando 'abecedarios${SIMBOLOS}010100 -> abecedarios${SIMBOLOS}311299'$NOCOL"
            fi
            echo -e ${NOMBRE}${SIMBOLOS}{01..31}{01..12}{00..99} | tr [:space:] \\n >> $SALIDA
            if [ $VERBOSE = 1 ]; then
                echo -e "\t[${SECONDS} s]\t${BLUE}Generando 'abecedarios${SIMBOLOS}01011950 -> abecedarios${SIMBOLOS}31122020'$NOCOL"
            fi
            echo -e ${NOMBRE}${SIMBOLOS}{01..31}{01..12}{1950..2020} | tr [:space:] \\n >> $SALIDA

            if [ $VERBOSE = 1 ]; then
                echo -e "\t[${SECONDS} s]\t${BLUE}Generando 'Abecedarios${SIMBOLOS}0 -> Abecedarios${SIMBOLOS}9'$NOCOL"
            fi
            echo -e ${NCAP}${SIMBOLOS}{0..9} | tr [:space:] \\n >> $SALIDA
            if [ $VERBOSE = 1 ]; then
                echo -e "\t[${SECONDS} s]\t${BLUE}Generando 'Abecedarios${SIMBOLOS}00 -> Abecedarios${SIMBOLOS}99'$NOCOL"
            fi
            echo -e ${NCAP}${SIMBOLOS}{00..99} | tr [:space:] \\n >> $SALIDA
            if [ $VERBOSE = 1 ]; then
                echo -e "\t[${SECONDS} s]\t${BLUE}Generando 'Abecedarios${SIMBOLOS}000 -> Abecedarios${SIMBOLOS}999'$NOCOL"
            fi
            echo -e ${NCAP}${SIMBOLOS}{000..999} | tr [:space:] \\n >> $SALIDA
            if [ $VERBOSE = 1 ]; then
                echo -e "\t[${SECONDS} s]\t${BLUE}Generando 'Abecedarios${SIMBOLOS}0000 -> Abecedarios${SIMBOLOS}9999'$NOCOL"
            fi
            echo -e ${NCAP}${SIMBOLOS}{0000..9999} | tr [:space:] \\n >> $SALIDA
            if [ $VERBOSE = 1 ]; then
                echo -e "\t[${SECONDS} s]\t${BLUE}Generando 'Abecedarios${SIMBOLOS}010100 -> Abecedarios${SIMBOLOS}311299'$NOCOL"
            fi
            echo -e ${NCAP}${SIMBOLOS}{01..31}{01..12}{00..99} | tr [:space:] \\n >> $SALIDA
            if [ $VERBOSE = 1 ]; then
                echo -e "\t[${SECONDS} s]\t${BLUE}Generando 'Abecedarios${SIMBOLOS}01011950 -> Abecedarios${SIMBOLOS}31122020'$NOCOL"
            fi
            echo -e ${NCAP}${SIMBOLOS}{01..31}{01..12}{1950..2020} | tr [:space:] \\n >> $SALIDA

            if [ $VERBOSE = 1 ]; then
                echo -e "\t[${SECONDS} s]\t${BLUE}Generando 'ABECEDARIOS${SIMBOLOS}0 -> ABECEDARIOS${SIMBOLOS}9'$NOCOL"
            fi
            echo -e $(echo ${NOMBRE} | tr [:lower:] [:upper:])${SIMBOLOS}{0..9} | tr [:space:] \\n >> $SALIDA
            if [ $VERBOSE = 1 ]; then
                echo -e "\t[${SECONDS} s]\t${BLUE}Generando 'ABECEDARIOS${SIMBOLOS}00 -> ABECEDARIOS${SIMBOLOS}99'$NOCOL"
            fi
            echo -e $(echo ${NOMBRE} | tr [:lower:] [:upper:])${SIMBOLOS}{00..99} | tr [:space:] \\n >> $SALIDA
            if [ $VERBOSE = 1 ]; then
                echo -e "\t[${SECONDS} s]\t${BLUE}Generando 'ABECEDARIOS${SIMBOLOS}000 -> ABECEDARIOS${SIMBOLOS}999'$NOCOL"
            fi
            echo -e ${NMAY}${SIMBOLOS}{000..999} | tr [:space:] \\n >> $SALIDA
            if [ $VERBOSE = 1 ]; then
                echo -e "\t[${SECONDS} s]\t${BLUE}Generando 'ABECEDARIOS${SIMBOLOS}0000 -> ABECEDARIOS${SIMBOLOS}9999'$NOCOL"
            fi
            echo -e ${NMAY}${SIMBOLOS}{0000..9999} | tr [:space:] \\n >> $SALIDA
            if [ $VERBOSE = 1 ]; then
                echo -e "\t[${SECONDS} s]\t${BLUE}Generando 'ABECEDARIOS${SIMBOLOS}010100 -> ABECEDARIOS${SIMBOLOS}311299'$NOCOL"
            fi
            echo -e ${NMAY}${SIMBOLOS}{01..31}{01..12}{00..99} | tr [:space:] \\n >> $SALIDA
            if [ $VERBOSE = 1 ]; then
                echo -e "\t[${SECONDS} s]\t${BLUE}Generando 'ABECEDARIOS${SIMBOLOS}01011950 -> ABECEDARIOS${SIMBOLOS}31122020'$NOCOL"
            fi
            echo -e ${NMAY}${SIMBOLOS}{01..31}{01..12}{1950..2020} | tr [:space:] \\n >> $SALIDA

            if [ $VERBOSE = 1 ]; then
                echo -e "\t[${SECONDS} s]\t${BLUE}Generando 'soiradeceba${SIMBOLOS}0 -> soiradeceba${SIMBOLOS}9'$NOCOL"
            fi
            echo -e ${NREV}${SIMBOLOS}{0..9} | tr [:space:] \\n >> $SALIDA
            if [ $VERBOSE = 1 ]; then
                echo -e "\t[${SECONDS} s]\t${BLUE}Generando 'soiradeceba${SIMBOLOS}00 -> soiradeceba${SIMBOLOS}99'$NOCOL"
            fi
            echo -e ${NREV}${SIMBOLOS}{00..99} | tr [:space:] \\n >> $SALIDA
            if [ $VERBOSE = 1 ]; then
                echo -e "\t[${SECONDS} s]\t${BLUE}Generando 'soiradeceba${SIMBOLOS}000 -> soiradeceba${SIMBOLOS}999'$NOCOL"
            fi
            echo -e ${NREV}${SIMBOLOS}{000..999} | tr [:space:] \\n >> $SALIDA
            if [ $VERBOSE = 1 ]; then
                echo -e "\t[${SECONDS} s]\t${BLUE}Generando 'soiradeceba${SIMBOLOS}0000 -> soiradeceba${SIMBOLOS}9999'$NOCOL"
            fi
            echo -e ${NREV}${SIMBOLOS}{0000..9999} | tr [:space:] \\n >> $SALIDA
            if [ $VERBOSE = 1 ]; then
                echo -e "\t[${SECONDS} s]\t${BLUE}Generando 'soiradeceba${SIMBOLOS}010100 -> soiradeceba${SIMBOLOS}311299'$NOCOL"
            fi
            echo -e ${NREV}${SIMBOLOS}{01..31}{01..12}{00..99} | tr [:space:] \\n >> $SALIDA
            if [ $VERBOSE = 1 ]; then
                echo -e "\t[${SECONDS} s]\t${BLUE}Generando 'soiradeceba${SIMBOLOS}01011950 -> soiradeceba${SIMBOLOS}31122020'$NOCOL"
            fi
            echo -e ${NREV}${SIMBOLOS}{01..31}{01..12}{1950..2020} | tr [:space:] \\n >> $SALIDA


            if [ $VERBOSE = 1 ]; then
                echo -e "\t[${SECONDS} s]\t${BLUE}Generando 'Soiradeceba${SIMBOLOS}0 -> Soiradeceba${SIMBOLOS}9'$NOCOL"
            fi
            echo -e $(echo ${NOMBRE} | rev | sed -e 's/^./\U&/g; s/ ./\U&/g')${SIMBOLOS}{0..9} | tr [:space:] \\n >> $SALIDA
            if [ $VERBOSE = 1 ]; then
                echo -e "\t[${SECONDS} s]\t${BLUE}Generando 'Soiradeceba${SIMBOLOS}00 -> Soiradeceba${SIMBOLOS}99'$NOCOL"
            fi
            echo -e $(echo ${NOMBRE} | rev | sed -e 's/^./\U&/g; s/ ./\U&/g')${SIMBOLOS}{00..99} | tr [:space:] \\n >> $SALIDA
            if [ $VERBOSE = 1 ]; then
                echo -e "\t[${SECONDS} s]\t${BLUE}Generando 'Soiradeceba${SIMBOLOS}000 -> Soiradeceba${SIMBOLOS}999'$NOCOL"
            fi
            echo -e ${NREVCAP}${SIMBOLOS}{000..999} | tr [:space:] \\n >> $SALIDA
            if [ $VERBOSE = 1 ]; then
                echo -e "\t[${SECONDS} s]\t${BLUE}Generando 'Soiradeceba${SIMBOLOS}0000 -> Soiradeceba${SIMBOLOS}9999'$NOCOL"
            fi
            echo -e ${NREVCAP}${SIMBOLOS}{0000..9999} | tr [:space:] \\n >> $SALIDA
            if [ $VERBOSE = 1 ]; then
                echo -e "\t[${SECONDS} s]\t${BLUE}Generando 'Soiradeceba${SIMBOLOS}010100 -> Soiradeceba${SIMBOLOS}311299'$NOCOL"
            fi
            echo -e ${NREVCAP}${SIMBOLOS}{01..31}{01..12}{00..99} | tr [:space:] \\n >> $SALIDA
            if [ $VERBOSE = 1 ]; then
                echo -e "\t[${SECONDS} s]\t${BLUE}Generando 'Soiradeceba${SIMBOLOS}01011950 -> Soiradeceba${SIMBOLOS}31122020'$NOCOL"
            fi
            echo -e ${NREVCAP}${SIMBOLOS}{01..31}{01..12}{1950..2020} | tr [:space:] \\n >> $SALIDA

            if [ $VERBOSE = 1 ]; then
                echo -e "\t[${SECONDS} s]\t${BLUE}Generando 'soiradecebA${SIMBOLOS}0 -> soiradecebA${SIMBOLOS}9'$NOCOL"
            fi
            echo -e ${NCAPREV}${SIMBOLOS}{0..9} | tr [:space:] \\n >> $SALIDA
            if [ $VERBOSE = 1 ]; then
                echo -e "\t[${SECONDS} s]\t${BLUE}Generando 'soiradecebA${SIMBOLOS}00 -> soiradecebA${SIMBOLOS}99'$NOCOL"
            fi
            echo -e ${NCAPREV}${SIMBOLOS}{00..99} | tr [:space:] \\n >> $SALIDA
            if [ $VERBOSE = 1 ]; then
                echo -e "\t[${SECONDS} s]\t${BLUE}Generando 'soiradecebA${SIMBOLOS}000 -> soiradecebA${SIMBOLOS}999'$NOCOL"
            fi
            echo -e ${NCAPREV}${SIMBOLOS}{000..999} | tr [:space:] \\n >> $SALIDA
            if [ $VERBOSE = 1 ]; then
                echo -e "\t[${SECONDS} s]\t${BLUE}Generando 'soiradecebA${SIMBOLOS}0000 -> soiradecebA${SIMBOLOS}9999'$NOCOL"
            fi
            echo -e ${NCAPREV}${SIMBOLOS}{0000..9999} | tr [:space:] \\n >> $SALIDA
            if [ $VERBOSE = 1 ]; then
                echo -e "\t[${SECONDS} s]\t${BLUE}Generando 'soiradecebA${SIMBOLOS}010100 -> soiradecebA${SIMBOLOS}311299'$NOCOL"
            fi
            echo -e ${NCAPREV}${SIMBOLOS}{01..31}{01..12}{00..99} | tr [:space:] \\n >> $SALIDA
            if [ $VERBOSE = 1 ]; then
                echo -e "\t[${SECONDS} s]\t${BLUE}Generando 'soiradecebA${SIMBOLOS}01011950 -> soiradecebA${SIMBOLOS}31122020'$NOCOL"
            fi
            echo -e ${NCAPREV}${SIMBOLOS}{01..31}{01..12}{1950..2020} | tr [:space:] \\n >> $SALIDA

            if [ $VERBOSE = 1 ]; then
                echo -e "\t[${SECONDS} s]\t${BLUE}Generando 'SOIRADECEBA${SIMBOLOS}0 -> SOIRADECEBA${SIMBOLOS}9'$NOCOL"
            fi
            echo -e ${NREVMAY}${SIMBOLOS}{0..9} | tr [:space:] \\n >> $SALIDA
            if [ $VERBOSE = 1 ]; then
                echo -e "\t[${SECONDS} s]\t${BLUE}Generando 'SOIRADECEBA${SIMBOLOS}00 -> SOIRADECEBA${SIMBOLOS}99'$NOCOL"
            fi
            echo -e ${NREVMAY}${SIMBOLOS}{00..99} | tr [:space:] \\n >> $SALIDA
            if [ $VERBOSE = 1 ]; then
                echo -e "\t[${SECONDS} s]\t${BLUE}Generando 'SOIRADECEBA${SIMBOLOS}000 -> SOIRADECEBA${SIMBOLOS}999'$NOCOL"
            fi
            echo -e ${NREVMAY}${SIMBOLOS}{000..999} | tr [:space:] \\n >> $SALIDA
            if [ $VERBOSE = 1 ]; then
                echo -e "\t[${SECONDS} s]\t${BLUE}Generando 'SOIRADECEBA${SIMBOLOS}0000 -> SOIRADECEBA${SIMBOLOS}9999'$NOCOL"
            fi
            echo -e ${NREVMAY}${SIMBOLOS}{0000..9999} | tr [:space:] \\n >> $SALIDA
            if [ $VERBOSE = 1 ]; then
                echo -e "\t[${SECONDS} s]\t${BLUE}Generando 'SOIRADECEBA${SIMBOLOS}010100 -> SOIRADECEBA${SIMBOLOS}311299'$NOCOL"
            fi
            echo -e ${NREVMAY}${SIMBOLOS}{01..31}{01..12}{00..99} | tr [:space:] \\n >> $SALIDA
            if [ $VERBOSE = 1 ]; then
                echo -e "\t[${SECONDS} s]\t${BLUE}Generando 'SOIRADECEBA${SIMBOLOS}01011950 -> SOIRADECEBA${SIMBOLOS}31122020'$NOCOL"
            fi
            echo -e ${NREVMAY}${SIMBOLOS}{01..31}{01..12}{1950..2020} | tr [:space:] \\n >> $SALIDA

            N="$(sed 'y/aeioAeio/43104310/' <<< $NOMBRE)"
            if [ $VERBOSE = 1 ]; then
                echo -e "\t[${SECONDS} s]\t${BLUE}Generando '4b3c3d4r10s${SIMBOLOS}0 -> 4b3c3d4r10s${SIMBOLOS}9'$NOCOL"
            fi
            echo -e ${N}${SIMBOLOS}{0..9} | tr [:space:] \\n >> $SALIDA
            if [ $VERBOSE = 1 ]; then
                echo -e "\t[${SECONDS} s]\t${BLUE}Generando '4b3c3d4r10s${SIMBOLOS}00 -> 4b3c3d4r10s${SIMBOLOS}99'$NOCOL"
            fi
            echo -e ${N}${SIMBOLOS}{00..99} | tr [:space:] \\n >> $SALIDA
            if [ $VERBOSE = 1 ]; then
                echo -e "\t[${SECONDS} s]\t${BLUE}Generando '4b3c3d4r10s${SIMBOLOS}000 -> 4b3c3d4r10s${SIMBOLOS}999'$NOCOL"
            fi
            echo -e ${N}${SIMBOLOS}{000..999} | tr [:space:] \\n >> $SALIDA
            if [ $VERBOSE = 1 ]; then
                echo -e "\t[${SECONDS} s]\t${BLUE}Generando '4b3c3d4r10s${SIMBOLOS}0000 -> 4b3c3d4r10s${SIMBOLOS}9999'$NOCOL"
            fi
            echo -e ${N}${SIMBOLOS}{0000..9999} | tr [:space:] \\n >> $SALIDA
            if [ $VERBOSE = 1 ]; then
                echo -e "\t[${SECONDS} s]\t${BLUE}Generando '4b3c3d4r10s${SIMBOLOS}010100 -> 4b3c3d4r10s${SIMBOLOS}311299'$NOCOL"
            fi
            echo -e ${N}${SIMBOLOS}{01..31}{01..12}{00..99} | tr [:space:] \\n >> $SALIDA
            if [ $VERBOSE = 1 ]; then
                echo -e "\t[${SECONDS} s]\t${BLUE}Generando '4b3c3d4r10s${SIMBOLOS}01011950 -> 4b3c3d4r10s${SIMBOLOS}31122020'$NOCOL"
            fi
            echo -e ${N}${SIMBOLOS}{01..31}{01..12}{1950..2020} | tr [:space:] \\n >> $SALIDA

            N="$(sed -e 's/^./\U&/g; s/ ./\U&/g' <<< $NOMBRE | sed 'y/aeioAeio/43104310/')"
            echo -e ${N}${SIMBOLOS}{0..9} | tr [:space:] \\n >> $SALIDA
            echo -e ${N}${SIMBOLOS}{00..99} | tr [:space:] \\n >> $SALIDA
            echo -e ${N}${SIMBOLOS}{000..999} | tr [:space:] \\n >> $SALIDA
            echo -e ${N}${SIMBOLOS}{0000..9999} | tr [:space:] \\n >> $SALIDA
            echo -e ${N}${SIMBOLOS}{01..31}{01..12}{00..99} | tr [:space:] \\n >> $SALIDA
            echo -e ${N}${SIMBOLOS}{01..31}{01..12}{1950..2020} | tr [:space:] \\n >> $SALIDA


            if [[ $NOMBRE == *[Ss]* ]]; then

                N="$(sed 'y/sSaeioAeio/$$43104310/' <<< $NOMBRE)"
                if [ $VERBOSE = 1 ]; then
                    echo -e "\t[${SECONDS} s]\t${BLUE}Generando '4b3c3d4r10\$${SIMBOLOS}0 -> 4b3c3d4r10\$${SIMBOLOS}9'$NOCOL"
                fi
                echo -e ${N}${SIMBOLOS}{0..9} | tr [:space:] \\n >> $SALIDA
                if [ $VERBOSE = 1 ]; then
                    echo -e "\t[${SECONDS} s]\t${BLUE}Generando '4b3c3d4r10\$${SIMBOLOS}00 -> 4b3c3d4r10\$${SIMBOLOS}99'$NOCOL"
                fi
                echo -e ${N}${SIMBOLOS}{00..99} | tr [:space:] \\n >> $SALIDA
                if [ $VERBOSE = 1 ]; then
                    echo -e "\t[${SECONDS} s]\t${BLUE}Generando '4b3c3d4r10\$${SIMBOLOS}000 -> 4b3c3d4r10\$${SIMBOLOS}999'$NOCOL"
                fi
                echo -e ${N}${SIMBOLOS}{000..999} | tr [:space:] \\n >> $SALIDA
                if [ $VERBOSE = 1 ]; then
                    echo -e "\t[${SECONDS} s]\t${BLUE}Generando '4b3c3d4r10\$${SIMBOLOS}0000 -> 4b3c3d4r10\$${SIMBOLOS}9999'$NOCOL"
                fi
                echo -e ${N}${SIMBOLOS}{0000..9999} | tr [:space:] \\n >> $SALIDA
                if [ $VERBOSE = 1 ]; then
                    echo -e "\t[${SECONDS} s]\t${BLUE}Generando '4b3c3d4r10\$${SIMBOLOS}010100 -> 4b3c3d4r10\$${SIMBOLOS}311299'$NOCOL"
                fi
                echo -e ${N}${SIMBOLOS}{01..31}{01..12}{00..99} | tr [:space:] \\n >> $SALIDA
                if [ $VERBOSE = 1 ]; then
                    echo -e "\t[${SECONDS} s]\t${BLUE}Generando '4b3c3d4r10\$${SIMBOLOS}01011950 -> 4b3c3d4r10\$${SIMBOLOS}31122020'$NOCOL"
                fi
                echo -e ${N}${SIMBOLOS}{01..31}{01..12}{1950..2020} | tr [:space:] \\n >> $SALIDA

                N="$(sed 'y/sS/$$/' <<< $NOMBRE)"
                if [ $VERBOSE = 1 ]; then
                    echo -e "\t[${SECONDS} s]\t${BLUE}Generando 'abecedario\$${SIMBOLOS}0 -> abecedario\$${SIMBOLOS}9'$NOCOL"
                fi
                echo -e ${N}${SIMBOLOS}{0..9} | tr [:space:] \\n >> $SALIDA
                if [ $VERBOSE = 1 ]; then
                    echo -e "\t[${SECONDS} s]\t${BLUE}Generando 'abecedario\$${SIMBOLOS}00 -> abecedario\$${SIMBOLOS}99'$NOCOL"
                fi
                echo -e ${N}${SIMBOLOS}{00..99} | tr [:space:] \\n >> $SALIDA
                if [ $VERBOSE = 1 ]; then
                    echo -e "\t[${SECONDS} s]\t${BLUE}Generando 'abecedario\$${SIMBOLOS}000 -> abecedario\$${SIMBOLOS}999'$NOCOL"
                fi
                echo -e ${N}${SIMBOLOS}{000..999} | tr [:space:] \\n >> $SALIDA
                if [ $VERBOSE = 1 ]; then
                    echo -e "\t[${SECONDS} s]\t${BLUE}Generando 'abecedario\$${SIMBOLOS}0000 -> abecedario\$${SIMBOLOS}9999'$NOCOL"
                fi
                echo -e ${N}${SIMBOLOS}{0000..9999} | tr [:space:] \\n >> $SALIDA
                if [ $VERBOSE = 1 ]; then
                    echo -e "\t[${SECONDS} s]\t${BLUE}Generando 'abecedario\$${SIMBOLOS}010150 -> abecedario\$${SIMBOLOS}311220'$NOCOL"
                fi
                echo -e ${N}${SIMBOLOS}{01..31}{01..12}{00..99} | tr [:space:] \\n >> $SALIDA
                if [ $VERBOSE = 1 ]; then
                    echo -e "\t[${SECONDS} s]\t${BLUE}Generando 'abecedario\$${SIMBOLOS}01011950 -> abecedario\$${SIMBOLOS}31122020'$NOCOL"
                fi
                echo -e ${N}${SIMBOLOS}{01..31}{01..12}{1950..2020} | tr [:space:] \\n >> $SALIDA

                N="$(sed 'y/sS/$$/' <<< $NCAP)"
                if [ $VERBOSE = 1 ]; then
                    echo -e "\t[${SECONDS} s]\t${BLUE}Generando 'Abecedario\$${SIMBOLOS}0 -> Abecedario\$${SIMBOLOS}9'$NOCOL"
                fi
                echo -e ${N}${SIMBOLOS}{0..9} | tr [:space:] \\n >> $SALIDA
                if [ $VERBOSE = 1 ]; then
                    echo -e "\t[${SECONDS} s]\t${BLUE}Generando 'Abecedario\$${SIMBOLOS}00 -> Abecedario\$${SIMBOLOS}99'$NOCOL"
                fi
                echo -e ${N}${SIMBOLOS}{00..99} | tr [:space:] \\n >> $SALIDA
                if [ $VERBOSE = 1 ]; then
                    echo -e "\t[${SECONDS} s]\t${BLUE}Generando 'Abecedario\$${SIMBOLOS}000 -> Abecedario\$${SIMBOLOS}999'$NOCOL"
                fi
                echo -e ${N}${SIMBOLOS}{000..999} | tr [:space:] \\n >> $SALIDA
                if [ $VERBOSE = 1 ]; then
                    echo -e "\t[${SECONDS} s]\t${BLUE}Generando 'Abecedario\$${SIMBOLOS}0000 -> Abecedario\$${SIMBOLOS}9999'$NOCOL"
                fi
                echo -e ${N}${SIMBOLOS}{0000..9999} | tr [:space:] \\n >> $SALIDA
                if [ $VERBOSE = 1 ]; then
                    echo -e "\t[${SECONDS} s]\t${BLUE}Generando 'Abecedario\$${SIMBOLOS}010100 -> Abecedario\$${SIMBOLOS}311299'$NOCOL"
                fi
                echo -e ${N}${SIMBOLOS}{01..31}{01..12}{00..99} | tr [:space:] \\n >> $SALIDA
                if [ $VERBOSE = 1 ]; then
                    echo -e "\t[${SECONDS} s]\t${BLUE}Generando 'Abecedario\$${SIMBOLOS}01011950 -> Abecedario\$${SIMBOLOS}31122020'$NOCOL"
                fi
                echo -e ${N}${SIMBOLOS}{01..31}{01..12}{1950..2020} | tr [:space:] \\n >> $SALIDA

                N="$(sed 'y/sS/$$/' <<< $NMAY)"
                if [ $VERBOSE = 1 ]; then
                    echo -e "\t[${SECONDS} s]\t${BLUE}Generando 'ABECEDARIO\$${SIMBOLOS}0 -> ABECEDARIO\$${SIMBOLOS}9'$NOCOL"
                fi
                echo -e ${N}${SIMBOLOS}{0..9} | tr [:space:] \\n >> $SALIDA
                if [ $VERBOSE = 1 ]; then
                    echo -e "\t[${SECONDS} s]\t${BLUE}Generando 'ABECEDARIO\$${SIMBOLOS}00 -> ABECEDARIO\$${SIMBOLOS}99'$NOCOL"
                fi
                echo -e ${N}${SIMBOLOS}{00..99} | tr [:space:] \\n >> $SALIDA
                if [ $VERBOSE = 1 ]; then
                    echo -e "\t[${SECONDS} s]\t${BLUE}Generando 'ABECEDARIO\$${SIMBOLOS}000 -> ABECEDARIO\$${SIMBOLOS}999'$NOCOL"
                fi
                echo -e ${N}${SIMBOLOS}{000..999} | tr [:space:] \\n >> $SALIDA
                if [ $VERBOSE = 1 ]; then
                    echo -e "\t[${SECONDS} s]\t${BLUE}Generando 'ABECEDARIO\$${SIMBOLOS}0000 -> ABECEDARIO\$${SIMBOLOS}9999'$NOCOL"
                fi
                echo -e ${N}${SIMBOLOS}{0000..9999} | tr [:space:] \\n >> $SALIDA
                if [ $VERBOSE = 1 ]; then
                    echo -e "\t[${SECONDS} s]\t${BLUE}Generando 'ABECEDARIO\$${SIMBOLOS}010100 -> ABECEDARIO\$${SIMBOLOS}311299'$NOCOL"
                fi
                echo -e ${N}${SIMBOLOS}{01..31}{01..12}{00..99} | tr [:space:] \\n >> $SALIDA
                if [ $VERBOSE = 1 ]; then
                    echo -e "\t[${SECONDS} s]\t${BLUE}Generando 'ABECEDARIO\$${SIMBOLOS}01011950 -> ABECEDARIO\$${SIMBOLOS}31122020'$NOCOL"
                fi
                echo -e ${N}${SIMBOLOS}{01..31}{01..12}{1950..2020} | tr [:space:] \\n >> $SALIDA


            fi

            if [[ $NOMBRE == *[aA]* ]]; then

                N="$(sed 'y/aA/44/' <<< $NOMBRE)"
                if [ $VERBOSE = 1 ]; then
                    echo -e "\t[${SECONDS} s]\t${BLUE}Generando '4beced4rios${SIMBOLOS}0 -> 4beced4rios${SIMBOLOS}9'$NOCOL"
                fi
                echo -e ${N}${SIMBOLOS}{0..9} | tr [:space:] \\n >> $SALIDA
                if [ $VERBOSE = 1 ]; then
                    echo -e "\t[${SECONDS} s]\t${BLUE}Generando '4beced4rios${SIMBOLOS}00 -> 4beced4rios${SIMBOLOS}99'$NOCOL"
                fi
                echo -e ${N}${SIMBOLOS}{00..99} | tr [:space:] \\n >> $SALIDA
                if [ $VERBOSE = 1 ]; then
                    echo -e "\t[${SECONDS} s]\t${BLUE}Generando '4beced4rios${SIMBOLOS}000 -> 4beced4rios${SIMBOLOS}999'$NOCOL"
                fi
                echo -e ${N}${SIMBOLOS}{000..999} | tr [:space:] \\n >> $SALIDA
                if [ $VERBOSE = 1 ]; then
                    echo -e "\t[${SECONDS} s]\t${BLUE}Generando '4beced4rios${SIMBOLOS}0000 -> 4beced4rios${SIMBOLOS}9999'$NOCOL"
                fi
                echo -e ${N}${SIMBOLOS}{0000..9999} | tr [:space:] \\n >> $SALIDA
                if [ $VERBOSE = 1 ]; then
                    echo -e "\t[${SECONDS} s]\t${BLUE}Generando '4beced4rios${SIMBOLOS}010100 -> 4beced4rios${SIMBOLOS}311299'$NOCOL"
                fi
                echo -e ${N}${SIMBOLOS}{01..31}{01..12}{00..99} | tr [:space:] \\n >> $SALIDA
                if [ $VERBOSE = 1 ]; then
                    echo -e "\t[${SECONDS} s]\t${BLUE}Generando '4beced4rios${SIMBOLOS}01011950 -> 4beced4rios${SIMBOLOS}31122020'$NOCOL"
                fi
                echo -e ${N}${SIMBOLOS}{01..31}{01..12}{1950..2020} | tr [:space:] \\n >> $SALIDA

                N="$(sed 'y/aA/44/' <<< $NCAP)"
                if [ $VERBOSE = 1 ]; then
                    echo -e "\t[${SECONDS} s]\t${BLUE}Generando '4beced4rios${SIMBOLOS}0 -> 4beced4rios${SIMBOLOS}9'$NOCOL"
                fi
                echo -e ${N}${SIMBOLOS}{0..9} | tr [:space:] \\n >> $SALIDA
                if [ $VERBOSE = 1 ]; then
                    echo -e "\t[${SECONDS} s]\t${BLUE}Generando '4beced4rios${SIMBOLOS}00 -> 4beced4rios${SIMBOLOS}99'$NOCOL"
                fi
                echo -e ${N}${SIMBOLOS}{00..99} | tr [:space:] \\n >> $SALIDA
                if [ $VERBOSE = 1 ]; then
                    echo -e "\t[${SECONDS} s]\t${BLUE}Generando '4beced4rios${SIMBOLOS}000 -> 4beced4rios${SIMBOLOS}999'$NOCOL"
                fi
                echo -e ${N}${SIMBOLOS}{000..999} | tr [:space:] \\n >> $SALIDA
                if [ $VERBOSE = 1 ]; then
                    echo -e "\t[${SECONDS} s]\t${BLUE}Generando '4beced4rios${SIMBOLOS}0000 -> 4beced4rios${SIMBOLOS}9999'$NOCOL"
                fi
                echo -e ${N}${SIMBOLOS}{0000..9999} | tr [:space:] \\n >> $SALIDA
                if [ $VERBOSE = 1 ]; then
                    echo -e "\t[${SECONDS} s]\t${BLUE}Generando '4beced4rios${SIMBOLOS}010100 -> 4beced4rios${SIMBOLOS}311299'$NOCOL"
                fi
                echo -e ${N}${SIMBOLOS}{01..31}{01..12}{00..99} | tr [:space:] \\n >> $SALIDA
                if [ $VERBOSE = 1 ]; then
                    echo -e "\t[${SECONDS} s]\t${BLUE}Generando '4beced4rios${SIMBOLOS}01011050 -> 4beced4rios${SIMBOLOS}31122020'$NOCOL"
                fi
                echo -e ${N}${SIMBOLOS}{01..31}{01..12}{1950..2020} | tr [:space:] \\n >> $SALIDA

                N="$(sed 'y/aA/44/' <<< $NMAY)"
                if [ $VERBOSE = 1 ]; then
                    echo -e "\t[${SECONDS} s]\t${BLUE}Generando '4BECED4RIOS${SIMBOLOS}0 -> 4BECED4RIOS${SIMBOLOS}9'$NOCOL"
                fi
                echo -e ${N}${SIMBOLOS}{0..9} | tr [:space:] \\n >> $SALIDA
                if [ $VERBOSE = 1 ]; then
                    echo -e "\t[${SECONDS} s]\t${BLUE}Generando '4BECED4RIOS${SIMBOLOS}00 -> 4BECED4RIOS${SIMBOLOS}99'$NOCOL"
                fi
                echo -e ${N}${SIMBOLOS}{00..99} | tr [:space:] \\n >> $SALIDA
                if [ $VERBOSE = 1 ]; then
                    echo -e "\t[${SECONDS} s]\t${BLUE}Generando '4BECED4RIOS${SIMBOLOS}000 -> 4BECED4RIOS${SIMBOLOS}999'$NOCOL"
                fi
                echo -e ${N}${SIMBOLOS}{000..999} | tr [:space:] \\n >> $SALIDA
                if [ $VERBOSE = 1 ]; then
                    echo -e "\t[${SECONDS} s]\t${BLUE}Generando '4BECED4RIOS${SIMBOLOS}0000 -> 4BECED4RIOS${SIMBOLOS}9999'$NOCOL"
                fi
                echo -e ${N}${SIMBOLOS}{0000..9999} | tr [:space:] \\n >> $SALIDA
                if [ $VERBOSE = 1 ]; then
                    echo -e "\t[${SECONDS} s]\t${BLUE}Generando '4BECED4RIOS${SIMBOLOS}010100 -> 4BECED4RIOS${SIMBOLOS}311299'$NOCOL"
                fi
                echo -e ${N}${SIMBOLOS}{01..31}{01..12}{00..99} | tr [:space:] \\n >> $SALIDA
                if [ $VERBOSE = 1 ]; then
                    echo -e "\t[${SECONDS} s]\t${BLUE}Generando '4BECED4RIOS${SIMBOLOS}01011950 -> 4BECED4RIOS${SIMBOLOS}31122020'$NOCOL"
                fi
                echo -e ${N}${SIMBOLOS}{01..31}{01..12}{1950..2020} | tr [:space:] \\n >> $SALIDA


            fi



            if [[ $NOMBRE == *[eE]* ]]; then

                N="$(sed 'y/eE/33/' <<< $NOMBRE)"
                if [ $VERBOSE = 1 ]; then
                    echo -e "\t[${SECONDS} s]\t${BLUE}Generando 'ab3c3darios${SIMBOLOS}0 -> ab3c3darios${SIMBOLOS}9'$NOCOL"
                fi
                echo -e ${N}${SIMBOLOS}{0..9} | tr [:space:] \\n >> $SALIDA
                if [ $VERBOSE = 1 ]; then
                    echo -e "\t[${SECONDS} s]\t${BLUE}Generando 'ab3c3darios${SIMBOLOS}00 -> ab3c3darios${SIMBOLOS}99'$NOCOL"
                fi
                echo -e ${N}${SIMBOLOS}{00..99} | tr [:space:] \\n >> $SALIDA
                if [ $VERBOSE = 1 ]; then
                    echo -e "\t[${SECONDS} s]\t${BLUE}Generando 'ab3c3darios${SIMBOLOS}000 -> ab3c3darios${SIMBOLOS}999'$NOCOL"
                fi
                echo -e ${N}${SIMBOLOS}{000..999} | tr [:space:] \\n >> $SALIDA
                if [ $VERBOSE = 1 ]; then
                    echo -e "\t[${SECONDS} s]\t${BLUE}Generando 'ab3c3darios${SIMBOLOS}0000 -> ab3c3darios${SIMBOLOS}9999'$NOCOL"
                fi
                echo -e ${N}${SIMBOLOS}{0000..9999} | tr [:space:] \\n >> $SALIDA
                if [ $VERBOSE = 1 ]; then
                    echo -e "\t[${SECONDS} s]\t${BLUE}Generando 'ab3c3darios${SIMBOLOS}010100 -> ab3c3darios${SIMBOLOS}311299'$NOCOL"
                fi
                echo -e ${N}${SIMBOLOS}{01..31}{01..12}{00..99} | tr [:space:] \\n >> $SALIDA
                if [ $VERBOSE = 1 ]; then
                    echo -e "\t[${SECONDS} s]\t${BLUE}Generando 'ab3c3darios${SIMBOLOS}01011950 -> ab3c3darios${SIMBOLOS}31122020'$NOCOL"
                fi
                echo -e ${N}${SIMBOLOS}{01..31}{01..12}{1950..2020} | tr [:space:] \\n >> $SALIDA

                N="$(sed 'y/eE/33/' <<< $NCAP)"
                if [ $VERBOSE = 1 ]; then
                    echo -e "\t[${SECONDS} s]\t${BLUE}Generando 'Ab3c3darios${SIMBOLOS}0 -> Ab3c3darios${SIMBOLOS}9'$NOCOL"
                fi
                echo -e ${N}${SIMBOLOS}{0..9} | tr [:space:] \\n >> $SALIDA
                if [ $VERBOSE = 1 ]; then
                    echo -e "\t[${SECONDS} s]\t${BLUE}Generando 'Ab3c3darios${SIMBOLOS}00 -> Ab3c3darios${SIMBOLOS}99'$NOCOL"
                fi
                echo -e ${N}${SIMBOLOS}{00..99} | tr [:space:] \\n >> $SALIDA
                if [ $VERBOSE = 1 ]; then
                    echo -e "\t[${SECONDS} s]\t${BLUE}Generando 'Ab3c3darios${SIMBOLOS}000 -> Ab3c3darios${SIMBOLOS}999'$NOCOL"
                fi
                echo -e ${N}${SIMBOLOS}{000..999} | tr [:space:] \\n >> $SALIDA
                if [ $VERBOSE = 1 ]; then
                    echo -e "\t[${SECONDS} s]\t${BLUE}Generando 'Ab3c3darios${SIMBOLOS}0000 -> Ab3c3darios${SIMBOLOS}9999'$NOCOL"
                fi
                echo -e ${N}${SIMBOLOS}{0000..9999} | tr [:space:] \\n >> $SALIDA
                if [ $VERBOSE = 1 ]; then
                    echo -e "\t[${SECONDS} s]\t${BLUE}Generando 'Ab3c3darios${SIMBOLOS}010100 -> Ab3c3darios${SIMBOLOS}311299'$NOCOL"
                fi
                echo -e ${N}${SIMBOLOS}{01..31}{01..12}{00..99} | tr [:space:] \\n >> $SALIDA
                if [ $VERBOSE = 1 ]; then
                    echo -e "\t[${SECONDS} s]\t${BLUE}Generando 'Ab3c3darios${SIMBOLOS}01011950 -> Ab3c3darios${SIMBOLOS}31122020'$NOCOL"
                fi
                echo -e ${N}${SIMBOLOS}{01..31}{01..12}{1950..2020} | tr [:space:] \\n >> $SALIDA

                N="$(sed 'y/eE/33/' <<< $NMAY)"
                if [ $VERBOSE = 1 ]; then
                    echo -e "\t[${SECONDS} s]\t${BLUE}Generando 'AB3C3DARIOS${SIMBOLOS}0 -> AB3C3DARIOS${SIMBOLOS}9'$NOCOL"
                fi
                echo -e ${N}${SIMBOLOS}{0..9} | tr [:space:] \\n >> $SALIDA
                if [ $VERBOSE = 1 ]; then
                    echo -e "\t[${SECONDS} s]\t${BLUE}Generando 'AB3C3DARIOS${SIMBOLOS}00 -> AB3C3DARIOS${SIMBOLOS}99'$NOCOL"
                fi
                echo -e ${N}${SIMBOLOS}{00..99} | tr [:space:] \\n >> $SALIDA
                if [ $VERBOSE = 1 ]; then
                    echo -e "\t[${SECONDS} s]\t${BLUE}Generando 'AB3C3DARIOS${SIMBOLOS}000 -> AB3C3DARIOS${SIMBOLOS}999'$NOCOL"
                fi
                echo -e ${N}${SIMBOLOS}{000..999} | tr [:space:] \\n >> $SALIDA
                if [ $VERBOSE = 1 ]; then
                    echo -e "\t[${SECONDS} s]\t${BLUE}Generando 'AB3C3DARIOS${SIMBOLOS}0000 -> AB3C3DARIOS${SIMBOLOS}9999'$NOCOL"
                fi
                echo -e ${N}${SIMBOLOS}{0000..9999} | tr [:space:] \\n >> $SALIDA
                if [ $VERBOSE = 1 ]; then
                    echo -e "\t[${SECONDS} s]\t${BLUE}Generando 'AB3C3DARIOS${SIMBOLOS}010100 -> AB3C3DARIOS${SIMBOLOS}311299'$NOCOL"
                fi
                echo -e ${N}${SIMBOLOS}{01..31}{01..12}{00..99} | tr [:space:] \\n >> $SALIDA
                if [ $VERBOSE = 1 ]; then
                    echo -e "\t[${SECONDS} s]\t${BLUE}Generando 'AB3C3DARIOS${SIMBOLOS}01011950 -> AB3C3DARIOS${SIMBOLOS}31122020'$NOCOL"
                fi
                echo -e ${N}${SIMBOLOS}{01..31}{01..12}{1950..2020} | tr [:space:] \\n >> $SALIDA


            fi

            if [[ $NOMBRE == *[iI]* ]]; then

                N="$(sed 'y/iI/11/' <<< $NOMBRE)"
                if [ $VERBOSE = 1 ]; then
                    echo -e "\t[${SECONDS} s]\t${BLUE}Generando 'abecedar1os${SIMBOLOS}0 -> abecedar1os${SIMBOLOS}9'$NOCOL"
                fi
                echo -e ${N}${SIMBOLOS}{0..9} | tr [:space:] \\n >> $SALIDA
                if [ $VERBOSE = 1 ]; then
                    echo -e "\t[${SECONDS} s]\t${BLUE}Generando 'abecedar1os${SIMBOLOS}00 -> abecedar1os${SIMBOLOS}99'$NOCOL"
                fi
                echo -e ${N}${SIMBOLOS}{00..99} | tr [:space:] \\n >> $SALIDA
                if [ $VERBOSE = 1 ]; then
                    echo -e "\t[${SECONDS} s]\t${BLUE}Generando 'abecedar1os${SIMBOLOS}000 -> abecedar1os${SIMBOLOS}999'$NOCOL"
                fi
                echo -e ${N}${SIMBOLOS}{000..999} | tr [:space:] \\n >> $SALIDA
                if [ $VERBOSE = 1 ]; then
                    echo -e "\t[${SECONDS} s]\t${BLUE}Generando 'abecedar1os${SIMBOLOS}0000 -> abecedar1os${SIMBOLOS}9999'$NOCOL"
                fi
                echo -e ${N}${SIMBOLOS}{0000..9999} | tr [:space:] \\n >> $SALIDA
                if [ $VERBOSE = 1 ]; then
                    echo -e "\t[${SECONDS} s]\t${BLUE}Generando 'abecedar1os${SIMBOLOS}010100 -> abecedar1os${SIMBOLOS}311299'$NOCOL"
                fi
                echo -e ${N}${SIMBOLOS}{01..31}{01..12}{00..99} | tr [:space:] \\n >> $SALIDA
                if [ $VERBOSE = 1 ]; then
                    echo -e "\t[${SECONDS} s]\t${BLUE}Generando 'abecedar1os${SIMBOLOS}01011950 -> abecedar1os${SIMBOLOS}31122020'$NOCOL"
                fi
                echo -e ${N}${SIMBOLOS}{01..31}{01..12}{1950..2020} | tr [:space:] \\n >> $SALIDA

                N="$(sed 'y/iI/11/' <<< $NCAP)"
                if [ $VERBOSE = 1 ]; then
                    echo -e "\t[${SECONDS} s]\t${BLUE}Generando 'Abecedar1os${SIMBOLOS}0 -> Abecedar1os${SIMBOLOS}9'$NOCOL"
                fi
                echo -e ${N}${SIMBOLOS}{0..9} | tr [:space:] \\n >> $SALIDA
                if [ $VERBOSE = 1 ]; then
                    echo -e "\t[${SECONDS} s]\t${BLUE}Generando 'Abecedar1os${SIMBOLOS}00 -> Abecedar1os${SIMBOLOS}99'$NOCOL"
                fi
                echo -e ${N}${SIMBOLOS}{00..99} | tr [:space:] \\n >> $SALIDA
                if [ $VERBOSE = 1 ]; then
                    echo -e "\t[${SECONDS} s]\t${BLUE}Generando 'Abecedar1os${SIMBOLOS}000 -> Abecedar1os${SIMBOLOS}999'$NOCOL"
                fi
                echo -e ${N}${SIMBOLOS}{000..999} | tr [:space:] \\n >> $SALIDA
                if [ $VERBOSE = 1 ]; then
                    echo -e "\t[${SECONDS} s]\t${BLUE}Generando 'Abecedar1os${SIMBOLOS}0000 -> Abecedar1os${SIMBOLOS}9999'$NOCOL"
                fi
                echo -e ${N}${SIMBOLOS}{0000..9999} | tr [:space:] \\n >> $SALIDA
                if [ $VERBOSE = 1 ]; then
                    echo -e "\t[${SECONDS} s]\t${BLUE}Generando 'Abecedar1os${SIMBOLOS}010100 -> Abecedar1os${SIMBOLOS}311299'$NOCOL"
                fi
                echo -e ${N}${SIMBOLOS}{01..31}{01..12}{00..99} | tr [:space:] \\n >> $SALIDA
                if [ $VERBOSE = 1 ]; then
                    echo -e "\t[${SECONDS} s]\t${BLUE}Generando 'Abecedar1os${SIMBOLOS}01011950 -> Abecedar1os${SIMBOLOS}31122020'$NOCOL"
                fi
                echo -e ${N}${SIMBOLOS}{01..31}{01..12}{1950..2020} | tr [:space:] \\n >> $SALIDA

                N="$(sed 'y/iI/11/' <<< $NMAY)"
                if [ $VERBOSE = 1 ]; then
                    echo -e "\t[${SECONDS} s]\t${BLUE}Generando 'ABECEDAR1OS${SIMBOLOS}0 -> ABECEDAR1OS${SIMBOLOS}9'$NOCOL"
                fi
                echo -e ${N}${SIMBOLOS}{0..9} | tr [:space:] \\n >> $SALIDA
                if [ $VERBOSE = 1 ]; then
                    echo -e "\t[${SECONDS} s]\t${BLUE}Generando 'ABECEDAR1OS${SIMBOLOS}00 -> ABECEDAR1OS${SIMBOLOS}99'$NOCOL"
                fi
                echo -e ${N}${SIMBOLOS}{00..99} | tr [:space:] \\n >> $SALIDA
                if [ $VERBOSE = 1 ]; then
                    echo -e "\t[${SECONDS} s]\t${BLUE}Generando 'ABECEDAR1OS${SIMBOLOS}000 -> ABECEDAR1OS${SIMBOLOS}999'$NOCOL"
                fi
                echo -e ${N}${SIMBOLOS}{000..999} | tr [:space:] \\n >> $SALIDA
                if [ $VERBOSE = 1 ]; then
                    echo -e "\t[${SECONDS} s]\t${BLUE}Generando 'ABECEDAR1OS${SIMBOLOS}0000 -> ABECEDAR1OS${SIMBOLOS}9999'$NOCOL"
                fi
                echo -e ${N}${SIMBOLOS}{0000..9999} | tr [:space:] \\n >> $SALIDA
                if [ $VERBOSE = 1 ]; then
                    echo -e "\t[${SECONDS} s]\t${BLUE}Generando 'ABECEDAR1OS${SIMBOLOS}010100 -> ABECEDAR1OS${SIMBOLOS}311299'$NOCOL"
                fi
                echo -e ${N}${SIMBOLOS}{01..31}{01..12}{00..99} | tr [:space:] \\n >> $SALIDA
                if [ $VERBOSE = 1 ]; then
                    echo -e "\t[${SECONDS} s]\t${BLUE}Generando 'ABECEDAR1OS${SIMBOLOS}01011950 -> ABECEDAR1OS${SIMBOLOS}31122020'$NOCOL"
                fi
                echo -e ${N}${SIMBOLOS}{01..31}{01..12}{1950..2020} | tr [:space:] \\n >> $SALIDA


            fi

            if [[ $NOMBRE == *[oO]* ]]; then

                N="$(sed 'y/oO/00/' <<< $NOMBRE)"
                if [ $VERBOSE = 1 ]; then
                    echo -e "\t[${SECONDS} s]\t${BLUE}Generando 'abecedari0s${SIMBOLOS}0 -> abecedari0s${SIMBOLOS}9'$NOCOL"
                fi
                echo -e ${N}${SIMBOLOS}{0..9} | tr [:space:] \\n >> $SALIDA
                if [ $VERBOSE = 1 ]; then
                    echo -e "\t[${SECONDS} s]\t${BLUE}Generando 'abecedari0s${SIMBOLOS}00 -> abecedari0s${SIMBOLOS}99'$NOCOL"
                fi
                echo -e ${N}${SIMBOLOS}{00..99} | tr [:space:] \\n >> $SALIDA
                if [ $VERBOSE = 1 ]; then
                    echo -e "\t[${SECONDS} s]\t${BLUE}Generando 'abecedari0s${SIMBOLOS}000 -> abecedari0s${SIMBOLOS}999'$NOCOL"
                fi
                echo -e ${N}${SIMBOLOS}{000..999} | tr [:space:] \\n >> $SALIDA
                if [ $VERBOSE = 1 ]; then
                    echo -e "\t[${SECONDS} s]\t${BLUE}Generando 'abecedari0s${SIMBOLOS}0000 -> abecedari0s${SIMBOLOS}9999'$NOCOL"
                fi
                echo -e ${N}${SIMBOLOS}{0000..9999} | tr [:space:] \\n >> $SALIDA
                if [ $VERBOSE = 1 ]; then
                    echo -e "\t[${SECONDS} s]\t${BLUE}Generando 'abecedari0s${SIMBOLOS}010100 -> abecedari0s${SIMBOLOS}311299'$NOCOL"
                fi
                echo -e ${N}${SIMBOLOS}{01..31}{01..12}{00..99} | tr [:space:] \\n >> $SALIDA
                if [ $VERBOSE = 1 ]; then
                    echo -e "\t[${SECONDS} s]\t${BLUE}Generando 'abecedari0s${SIMBOLOS}01011950 -> abecedari0s${SIMBOLOS}31122020'$NOCOL"
                fi
                echo -e ${N}${SIMBOLOS}{01..31}{01..12}{1950..2020} | tr [:space:] \\n >> $SALIDA

                N="$(sed 'y/oO/00/' <<< $NCAP)"
                if [ $VERBOSE = 1 ]; then
                    echo -e "\t[${SECONDS} s]\t${BLUE}Generando 'Abecedari0s${SIMBOLOS}0 -> Abecedari0s${SIMBOLOS}9'$NOCOL"
                fi
                echo -e ${N}${SIMBOLOS}{0..9} | tr [:space:] \\n >> $SALIDA
                if [ $VERBOSE = 1 ]; then
                    echo -e "\t[${SECONDS} s]\t${BLUE}Generando 'Abecedari0s${SIMBOLOS}00 -> Abecedari0s${SIMBOLOS}99'$NOCOL"
                fi
                echo -e ${N}${SIMBOLOS}{00..99} | tr [:space:] \\n >> $SALIDA
                if [ $VERBOSE = 1 ]; then
                    echo -e "\t[${SECONDS} s]\t${BLUE}Generando 'Abecedari0s${SIMBOLOS}000 -> Abecedari0s${SIMBOLOS}999'$NOCOL"
                fi
                echo -e ${N}${SIMBOLOS}{000..999} | tr [:space:] \\n >> $SALIDA
                if [ $VERBOSE = 1 ]; then
                    echo -e "\t[${SECONDS} s]\t${BLUE}Generando 'Abecedari0s${SIMBOLOS}0000 -> Abecedari0s${SIMBOLOS}9999'$NOCOL"
                fi
                echo -e ${N}${SIMBOLOS}{0000..9999} | tr [:space:] \\n >> $SALIDA
                if [ $VERBOSE = 1 ]; then
                    echo -e "\t[${SECONDS} s]\t${BLUE}Generando 'Abecedari0s${SIMBOLOS}010100 -> Abecedari0s${SIMBOLOS}311299'$NOCOL"
                fi
                echo -e ${N}${SIMBOLOS}{01..31}{01..12}{00..99} | tr [:space:] \\n >> $SALIDA
                if [ $VERBOSE = 1 ]; then
                    echo -e "\t[${SECONDS} s]\t${BLUE}Generando 'Abecedari0s${SIMBOLOS}01011950 -> Abecedari0s${SIMBOLOS}31122020'$NOCOL"
                fi
                echo -e ${N}${SIMBOLOS}{01..31}{01..12}{1950..2020} | tr [:space:] \\n >> $SALIDA

                N="$(sed 'y/oO/00/'<<< $NMAY)"
                if [ $VERBOSE = 1 ]; then
                    echo -e "\t[${SECONDS} s]\t${BLUE}Generando 'ABECEDARI0S${SIMBOLOS}0 -> ABECEDARI0S${SIMBOLOS}9'$NOCOL"
                fi
                echo -e ${N}${SIMBOLOS}{0..9} | tr [:space:] \\n >> $SALIDA
                if [ $VERBOSE = 1 ]; then
                    echo -e "\t[${SECONDS} s]\t${BLUE}Generando 'ABECEDARI0S${SIMBOLOS}00 -> ABECEDARI0S${SIMBOLOS}99'$NOCOL"
                fi
                echo -e ${N}${SIMBOLOS}{00..99} | tr [:space:] \\n >> $SALIDA
                if [ $VERBOSE = 1 ]; then
                    echo -e "\t[${SECONDS} s]\t${BLUE}Generando 'ABECEDARI0S${SIMBOLOS}000 -> ABECEDARI0S${SIMBOLOS}999'$NOCOL"
                fi
                echo -e ${N}${SIMBOLOS}{000..999} | tr [:space:] \\n >> $SALIDA
                if [ $VERBOSE = 1 ]; then
                    echo -e "\t[${SECONDS} s]\t${BLUE}Generando 'ABECEDARI0S${SIMBOLOS}0000 -> ABECEDARI0S${SIMBOLOS}9999'$NOCOL"
                fi
                echo -e ${N}${SIMBOLOS}{0000..9999} | tr [:space:] \\n >> $SALIDA
                if [ $VERBOSE = 1 ]; then
                    echo -e "\t[${SECONDS} s]\t${BLUE}Generando 'ABECEDARI0S${SIMBOLOS}010100 -> ABECEDARI0S${SIMBOLOS}311299'$NOCOL"
                fi
                echo -e ${N}${SIMBOLOS}{01..31}{01..12}{00..99} | tr [:space:] \\n >> $SALIDA
                if [ $VERBOSE = 1 ]; then
                    echo -e "\t[${SECONDS} s]\t${BLUE}Generando 'ABECEDARI0S${SIMBOLOS}01011950 -> ABECEDARI0S${SIMBOLOS}31122020'$NOCOL"
                fi
                echo -e ${N}${SIMBOLOS}{01..31}{01..12}{1950..2020} | tr [:space:] \\n >> $SALIDA


            fi
        done


    done


echo
echo -e "Palabras generadas: \\t$(tput bold)$(wc -l $SALIDA | awk '{print $1}')$(tput sgr0)"
echo -e "Tamaño de archivo: \\t$( du -lh $SALIDA | cut -f1)"
TIEMPO=$(eval "echo $(date -ud "@$SECONDS" +'%Hh %Mm %Ss')")
echo -e "Tiempo total: \\t\\t$TIEMPO"
echo
echo -e "$GREEN Archivo $(readlink -f $SALIDA) generado con éxito $NOCOL"
echo
