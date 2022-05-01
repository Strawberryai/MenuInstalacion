#!/bin/bash

##Instalacion y Mantenimiento de una Aplicación Web
#Importar funciones de otros ficheros

###########################################################
#                  1) INSTALAR NGINX                      #
###########################################################
function instalarNGINX(){
	aux1=$(aptitude show nginx | grep "State: installed")
	aux2=$(aptitude show nginx | grep "Estado: instalado")
	aux3=$aux1$aux2
	if [ -z "$aux3" ]
	then 
 	  echo "instalando ..."
 	  sudo apt install nginx
	else
   	  echo "nginx ya estaba instalado"
    fi 
}

###########################################################
#                  2) ARRANCAR NGINX                      #
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

###########################################################
#                  3) TESTEAR PUERTOS                     #
###########################################################
function testearPUERTOS(){
	aux1=$(aptitude show net-tools | grep "State: installed")
	aux2=$(aptitude show net-tools | grep "Estado: instalado")
	aux3=$aux1$aux2

	if [ -z "$aux3" ]
	then 
 	  echo "instalando net-tools..."
 	  sudo apt install net-tools
    fi 

    sudo netstat -anp | grep "nginx"
}

###########################################################
#                  4) VISUALIZAR INDEX                    #
###########################################################
function visualizarINDEX(){
	aux1=$(aptitude show firefox | grep "State: installed")
	aux2=$(aptitude show firefox | grep "Estado: instalado")
	aux3=$aux1$aux2

	if [ -z "$aux3" ]
	then 
 	  echo "instalando firefox..."
 	  sudo apt install firefox
    fi 

    firefox http://localhost 
}

###########################################################
#                  5) PERSONALIZAR INDEX                  #
###########################################################
function personalizarINDEX(){
    sudo cp -RT ./src/nginx /var/www/html
    firefox http://localhost/index.html
}

###########################################################
#                  6) CREAR NUEVA UBICACION               #
###########################################################
function crearNuevaUbicacion(){
    echo "Creando la nueva ubicación con el usuario y grupo -> $MENU_DEFU"
    sudo mkdir -p /var/www/EHU_analisisdesentimiento/public_html
    sudo chown -R $MENU_DEFU /var/www/EHU_analisisdesentimiento/public_html
}

###########################################################
#                  7) EJECUTAR VENV                       #
###########################################################
function ejecutarEntornoVirtual(){
    echo "Actualizando paquetes..."
    sudo apt update
    sudo apt -y upgrade
    instalarPYTHON3

    echo "Instalando paquetes..."
    sudo apt install -y python3-pip
    sudo apt install python3-pip python3-dev build-essential libssl-dev libffi-dev python3-setuptools
    sudo apt install python3-virtualenv

    echo "Limpiando paquetes temporales..."
    sudo apt autoremove

    #¿Siempre se crea uno nuevo?
    echo "Creando entorno virtual..."
    mkdir /var/www/EHU_analisisdesentimiento/public_html/venv #Si la carpeta existe no se crea una nueva
    virtualenv -p python3 /var/www/EHU_analisisdesentimiento/public_html/venv

    echo "Ejecutando entorno virtual..."
    source /var/www/EHU_analisisdesentimiento/public_html/venv/bin/activate

}

###########################################################
#                  8) INSTALAR LIBRERIAS VENV             #
###########################################################
function instalarLibreriasEntornoVirtual(){
    # Activamos el entorno virtual
    echo "Ejecutando entorno virtual..."
    source /var/www/EHU_analisisdesentimiento/public_html/venv/bin/activate

    # Actualizamos pip e instalamos las librerías
    echo "Actualizando pip e instalando paquetes..."
    python3 -m pip install --upgrade pip
    pip install transformers[torch]

    echo "Desactivando el entorno virtual..."
    deactivate
}

###########################################################
#                  9) COPIAR FICHEROS NUEVA UBICACION     #
###########################################################
function copiarFicherosProyectoNuevaUbicacion(){
    echo "Copiando ficheros..."
    sudo cp ./src/EHU_analisisdesentimiento/public_html/webserviceanalizadordesentimiento.py /var/www/EHU_analisisdesentimiento/public_html
    sudo cp -r ./src/EHU_analisisdesentimiento/public_html/static /var/www/EHU_analisisdesentimiento/public_html
    sudo cp -r ./src/EHU_analisisdesentimiento/public_html/templates /var/www/EHU_analisisdesentimiento/public_html

    echo "Asignando usuario y grupo -> $MENU_DEFU"
    sudo chown -R $MENU_DEFU /var/www/EHU_analisisdesentimiento/public_html
}

###########################################################
#                  10) INSTALAR FLASK                      #
###########################################################
function instalarFLASK(){
    # Instala Flask en el entorno virtual
    echo "Iniciando venv e instalando Flask..."
    source /var/www/EHU_analisisdesentimiento/public_html/venv/bin/activate
    pip install flask

    echo "Desactivando el entorno virtual..."
    deactivate
}

###########################################################
#                  11) PROBAR FLASK                       #
###########################################################
function probarFLASK(){
    echo "Iniciando venv..." 
    source /var/www/EHU_analisisdesentimiento/public_html/venv/bin/activate

    echo "Abriendo Firefox en segundo plano(http://localhos:5000)..."
    firefox http://localhost:5000 &

    echo "Iniciando el servicio analisisDeSentimiento([Control] + C para parar)..."
    python3 /var/www/EHU_analisisdesentimiento/public_html/webserviceanalizadordesentimiento.py

    echo "Desactivando el entorno virtual..."
    deactivate
}

##################### MAIN ################################
#Funciones auxiliares
function imprimirMENU(){
	#Muestra el menu
    echo ""
    echo "-------------------------------"
    echo -e "1)\t Instalar nginX"
    echo -e "2)\t Arrancar nginX"
    echo -e "3)\t Testear puertos de nginX"
    echo -e "4)\t Visualizar index (localhost:80)"
    echo -e "5)\t Personalizar index"
    echo -e "6)\t Crear nueva ubicación (u:g -> $MENU_DEFU)"
    echo -e "7)\t Ejecutar entorno virtual"
    echo -e "8)\t Instalar librerías entorno virtual"
    echo -e "9)\t Copiar ficheros en la nueva ubicación"
    echo -e "10)\t Instalar Flask"
    echo -e "11)\t Probar Flask"
    echo -e "23)\t fin"
    echo "-------------------------------"
}

function instalarAPTITUDE(){
    echo "Comprobando la instalación de aptitude..."
    aux1=$(apt-cache policy aptitude | grep "Installed: (none)")
    aux2=$(apt-cache policy aptitude | grep "Instalados: (ninguno)")
	aux3=$aux1$aux2

	if [ -z "$aux3" ]
	then 
        echo "Aptitude está instalado"
    else
        echo "instalando aptitude..."
        sudo apt install aptitude 
    fi 
}

function instalarPYTHON3(){
    echo "Comprobando la instalación de Python3..."
    aux1=$(apt-cache policy python3 | grep "Installed: (none)")
    aux2=$(apt-cache policy python3 | grep "Instalados: (ninguno)")
	aux3=$aux1$aux2

	if [ -z "$aux3" ]
	then 
        echo "Python3 está instalado"
    else
        echo "instalando Python3..."
        sudo apt install python3 
    fi 
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
instalarAPTITUDE

opcionmenuppal=0
while test $opcionmenuppal -ne 23
do
    imprimirMENU

    read -p "Elige una opcion:" opcionmenuppal
	case $opcionmenuppal in
			1) instalarNGINX;;
			2) arrancarNGINX;;
			3) testearPUERTOS;;
			4) visualizarINDEX;;
			5) personalizarINDEX;;
			6) crearNuevaUbicacion;;
			7) ejecutarEntornoVirtual;;
			8) instalarLibreriasEntornoVirtual;;
			9) copiarFicherosProyectoNuevaUbicacion;;
			10) instalarFLASK;;
			11) probarFLASK;;
			23) finSEGURO;;
			*) ;;
	esac 
done 

echo "Fin del Programa" 
exit 0 

