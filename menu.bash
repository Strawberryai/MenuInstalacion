#!/bin/bash

##Instalacion y Mantenimiento de una Aplicación Web
#Importar funciones de otros ficheros

###########################################################
#                  1) INSTALAR NGINX                      #
###########################################################
function instalarNGINX(){
	aux=$(aptitude show nginx | grep "State: installed")
	aux2=$(aptitude show nginx | grep "Estado: instalado")
	aux3=$aux$aux2
	if [ -z "$aux3" ]
	then 
 	  echo "instalando ..."
 	  sudo apt install nginx
	else
   	  echo "nginx ya estaba instalado"
    	fi 
}

###########################################################
#                  1) ARRANCAR NGINX                      #
###########################################################
function arrancarNGINX(){
	aux1=$(sudo systemctl status nginx | grep "Active: active")
	aux2=$(sudo systemctl status nginx | grep "Activo: activo")
    aux3=$aux1$aux2

    if [ -z "$aux3" ]
    then
        echo -e "Arrancando el servicio nginx..."
        sudo systemctl start nginx
    else
        echo "El servicio nginx ya está activo"
    fi

}

##################### MAIN ################################
function imprimirMENU(){
	#Muestra el menu
    echo ""
    echo "-------------------------------"
    echo -e "1)\t Instala nginX"
    echo -e "23)\t fin"
    echo "-------------------------------"
}

function setMENU_DEFU(){
    if [ -z "$1" ] || [ -z "$2" ]
    then
        if [ -z "$MENU_DEFU" ]
        then
            export MENU_DEFU="alan:alan"
        fi
        
        echo "Tomando como usuario y grupo por defecto -> $MENU_DEFU"
        echo "Para establecer de forma local un usuario y grupo -> menu.bash <usuario> <grupo>"
    else
        export MENU_DEFU="$1:$2"
        echo "Se ha establecido de forma local el usuario y grupo -> $MENU_DEFU"
    fi
}

function finSEGURO(){
    echo "Saliendo de forma segura del programa..."
    exit 0
}

# logica principal del main
setMENU_DEFU "$1" "$2"

opcionmenuppal=0
while test $opcionmenuppal -ne 23
do
    imprimirMENU

    read -p "Elige una opcion:" opcionmenuppal
	case $opcionmenuppal in
			1) instalarNGINX;;
			23) finSEGURO;;
			*) ;;
	esac 
done 

echo "Fin del Programa" 
exit 0 

