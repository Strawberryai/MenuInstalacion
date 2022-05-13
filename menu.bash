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
    apache1=$(sudo systemctl status apache2 | grep "Active: active")
	apache2=$(sudo systemctl status apache2 | grep "Activo: activo")
    apache3=$apache1$apache2

    if [ -n "$apache3" ]
    then
        sudo systemctl stop apache2
    fi

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

    echo "Abriendo Firefox en segundo plano(http://localhost:5000)..."
    firefox http://localhost:5000 &

    echo "Iniciando el servicio analisisDeSentimiento([Control] + C para parar)..."
    python3 /var/www/EHU_analisisdesentimiento/public_html/webserviceanalizadordesentimiento.py

    echo "Desactivando el entorno virtual..."
    deactivate
}

###########################################################
#                  12) INSTALAR GUNICORN                  #
###########################################################
function instalarGUNICORN(){
    # Instala Gunicorn en el entorno virtual
    echo "Iniciando venv e instalando Gunicorn..."
    source /var/www/EHU_analisisdesentimiento/public_html/venv/bin/activate
    pip install gunicorn

    echo "Desactivando el entorno virtual..."
    deactivate
}

###########################################################
#                  13) CONFIGURAR GUNICORN                #
###########################################################
function configurarGUNICORN(){
    echo "Creando los archivos de configuración..."
    cp src/EHU_analisisdesentimiento/public_html/wsgi.py /var/www/EHU_analisisdesentimiento/public_html

    echo "Asignando usuario y grupo -> $MENU_DEFU"
    sudo chown -R $MENU_DEFU /var/www/EHU_analisisdesentimiento/public_html

    echo "Iniciando venv..." 
    path=$(pwd)
    cd /var/www/EHU_analisisdesentimiento/public_html
    source venv/bin/activate

    echo "Abriendo Firefox en segundo plano(http://localhost:5000)..."
    firefox http://localhost:5000 &

    echo "Comprobando si nuestra aplicación se puede añadir al servicio de Gunicorn..."
    gunicorn --bind 0.0.0.0:5000 wsgi:app & 
    pidsave=$! 
    #sleep 60; kill $pidsave 
    echo "Finalizando gunicorn..."; sleep 2

    echo "Desactivando el entorno virtual..."
    deactivate

    cd $path
}

###########################################################
#                  14) PASAR PERMISOS ww-data             #
###########################################################
function pasarPropiedadYPermisos(){
    sudo chown -R $MENU_PROP /var/www
    sudo chmod -R 755 /var/www
}

###########################################################
#                  15) CREAR SERVICIO FLASK               #
###########################################################
function crearServicioSystemdFlask(){
    # Creamos el servicio
    sudo mkdir -p /etc/systemd/system
    sudo cp ./src/config/flask.service /etc/systemd/system/flask.service

    # Recargamos el demonio systemctl para poder ejecutar el nuevo servicio
    sudo systemctl daemon-reload

    # Iniciamos el nuevo servicio
    sudo systemctl start flask

    # Establecemos que se ejecute nuestro servicio al inicio del sistema
    sudo systemctl enable flask

    # Mostramos el estado del servicio
    systemctl status flask
} 

###########################################################
#                  16) CONFIGURAR NGINX                   #
###########################################################
function configurarNginxProxyInverso(){
    # Creamos el archivo de configuración
    sudo mkdir -p /etc/nginx/conf.d
    sudo cp ./src/config/flask.conf /etc/nginx/conf.d
    
    echo "Comprobando si hay errores en el archivo de configuración de nginx"
    sudo nginx -t
}

###########################################################
#                  17) CARGAR CONFIGURACIÓN NGINX         #
###########################################################
function cargarFicherosConfiguracionNginx(){
    # Recargar la configuración de nginx
    sudo systemctl reload nginx
}

###########################################################
#                  18) REARRANCAR NGINX                   #
###########################################################
function rearrancarNGINX(){
    # Rearrancamos el servicio de nginx
    sudo systemctl restart nginx
}

###########################################################
#                  19) TESTEAR VHOST                      #
###########################################################
function testearVirtualHost(){
     firefox http://localhost:8888/
}

###########################################################
#                  20) VER LOGS NGINX                     #
###########################################################
function verNginxLogs(){
    # "Esta opción del menú llamará a la función verNginxLogs() donde se
    # visualizarán las últimas 100 líneas del fichero
    # '/var/log/nginx/error.log'."
    tail -n 100 /var/log/nginx/error.log | cat -n
    echo "Se han mostrado las 100 últimas líneas de error enumeradas"

}

###########################################################
#                  21) CONTROLAR LOGS SSH                 #
###########################################################
function controlarIntentosConexionSSH(){
    echo "Buscando los logs de ssh..."
    formatted_logs=""
    path="/var/log/"
    # Otenemos las rutas de los ficheros de logs concatenadas y clasificadas
    # según si están comprimidos o no
    auth=$(ls /var/log/ | grep "auth.log" | grep -v "gz" | tr -d '\n')
    authGZ=$(ls /var/log/ | grep "auth.log" | grep "gz" | tr -d '\n')

    # Logs de archivos no comprimidos
    IFS='a' read -r -a archivos <<< "$auth"
    for archivo in "${archivos[@]}"
    do
        if [ -n "$archivo" ]
        then
            echo "Analizando $path"a"$archivo"
            aux=$(cat $path"a"$archivo | grep "sshd" | grep -e "Failed password" -e "Accepted password")

            # Obtener los logs del archivo en el formato deseado y concatenarlo
            formatted_logs=$formatted_logs"\n$(formatearLOGS "$aux")"
        fi
    done

    # Logs de archivos comprimidos
    IFS='a' read -r -a archivosGZ <<< "$authGZ"
    for archivoGZ in "${archivosGZ[@]}"
    do
        if [ -n "$archivoGZ" ]
        then
            echo "Analizando $path"a"$archivoGZ"
            aux=$(zcat $path"a"$archivoGZ | grep "sshd" | grep -e "Failed password" -e "Accepted password")

            # Obtener los logs del archivo en el formato deseado y concatenarlo
            formatted_logs=$formatted_logs"\n$(formatearLOGS "$aux")"
        fi
    done

    echo "LOGS: "
    echo -e "$formatted_logs"
}

function formatearLOGS(){
    # Para todos los parámetros exceptuando el estado y el nombre
    # (porque cambia de posición) vamos a suponer
    # que el string nunca cambia de formato
    # TO:       Status: [fail] Account name: kepa Date: Apr, 25, 17:22:20
    # FROM:     Apr 25 17:22:20 kepa-Latitude-E6440 sshd[12911]: Failed password for kepa from 127.0.0.1 port 42414 ssh2

    # Iteramos sobre cada log
    IFS=$'\n' read -d '' -r -a logs <<<"$1"
    for log in "${logs[@]}"
    do
        # Buscar substring en el log
        stat=""
        if [[ "$log" == *"Failed"* ]]; then
            stat="fail"
        else
            stat="accept"
        fi

        # Acceder a los valores del log (reverse loop)
        name=""; sigName="False"
        IFS=$' ' read -d '' -r -a params <<<"$log"
        for ((i=${#params[@]}-1; i>=0; i--)); do
            if [ "$sigName" = "True" ]; then 
                name="${params[$i]}"
            fi

            if [ "${params[$i]}" = "from" ]; then  
                sigName="True"
            else
                sigName="False"
            fi
        done

        month="${params[0]}"
        day="${params[1]}"
        hour="${params[2]}"

        echo "Status: [$stat] Account name: $name Date: $month, $day, $hour"
    done
}

###########################################################
#                  22) OPCION EXAMEN                      #
###########################################################
function nuevaOpcionEXAMEN(){
    echo "ESTA ES LA NUEVA OPCION"

    # A) Desinstalar las librerías instaladas en el venv
    echo "Desinstalando las librerías del entorno virtual"
    source /var/www/EHU_analisisdesentimiento/public_html/venv/bin/activate
    pip uninstall transformers[torch]
    pip uninstall flask
    pip uninstall gunicorn
    deactivate

    # B) Eliminar el entorno virtual de python
    echo "Eliminando entorno virtual de python"
    sudo rm -rf /var/www/EHU_analisisdesentimiento/public_html/venv

    # C) Desinstala las aplicaciones que has instalado
    echo "Desinstalando aplicaciones instaladas..."
    #sudo apt remove aptitude
    #sudo apt remove python3
    sudo apt remove nginx
 	sudo apt remove net-tools
    #sudo apt remove python3-pip
    #sudo apt remove python3-pip python3-dev build-essential libssl-dev libffi-dev python3-setuptools
    #sudo apt remove python3-virtualenv

    # D) Elimina la aplicación web
    echo "Eliminando la aplicación web"
    sudo rm -rf /var/www/EHU_analisisdesentimiento
}

###########################################################
#                  23) SALIR DEL MENU                     #
###########################################################
function salirMenu(){
    echo ""
    echo "-----------------------------------------"
    echo "Los integrantes de este grupo somos: "
    echo -e "\t - Adrián López"
    echo -e "\t - Alan García"
    echo -e "\t - Álvaro Díez-Andino"
    echo -e "\t - Danel Alonso"
    echo "-----------------------------------------"
    echo ""
    echo "Hasta la próximaaa..."
    exit 0
}

##################### MAIN ################################
#Funciones auxiliares
function imprimirMENU(){
	#Muestra el menu
    echo ""
    echo "-----------------------------------------"
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
    echo -e "12)\t Instalar Gunicorn"
    echo -e "13)\t Configurar Gunicorn"
    echo -e "14)\t Pasar propiedad (u:g -> $MENU_PROP)"
    echo -e "15)\t Crear servicio Flask"
    echo -e "16)\t Configurar nginX"
    echo -e "17)\t Cargar configuración nginX"
    echo -e "18)\t Rearrancar nginX"
    echo -e "19)\t Testear virtual host (localhost:8888)"
    echo -e "20)\t Ver los logs de nginx"
    echo -e "21)\t Controlar logs ssh"
    echo -e "22)\t Opción menu EXAMEN (desinstalación)"
    echo -e "23)\t Salir del menú"
    echo "-----------------------------------------"
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
            usuario=$(id -un);
            export MENU_DEFU="$usuario:$usuario"
        fi
        
        echo "Tomando como usuario y grupo por defecto -> $MENU_DEFU"
        echo "Para establecer de forma local un usuario y grupo -> menu.bash <usuario> <grupo>"
    else
        export MENU_DEFU="$1:$2"
        echo "Se ha establecido de forma local el usuario y grupo -> $MENU_DEFU"
    fi
}

function setMENU_PROP(){
    if [ -z "$MENU_PROP" ]
    then
        export MENU_PROP="www-data:www-data"
        echo "Tomando como usuario y grupo propietarios -> $MENU_PROP"
        echo "Para establecer un usuario y grupo distintos hay que modificar la variable de entorno MENU_PROP"
    else
        echo "Tomando como usuario y grupo propietarios -> $MENU_PROP"
    fi

}

# logica principal del main
setMENU_DEFU "$1" "$2"
setMENU_PROP
instalarAPTITUDE

opcionmenuppal=0
while test $opcionmenuppal -ne 24
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
			12) instalarGUNICORN;;
			13) configurarGUNICORN;;
			14) pasarPropiedadYPermisos;;
			15) crearServicioSystemdFlask;;
			16) configurarNginxProxyInverso;;
			17) cargarFicherosConfiguracionNginx;;
			18) rearrancarNGINX;;
			19) testearVirtualHost;;
			20) verNginxLogs;;
			21) controlarIntentosConexionSSH;;
            22) nuevaOpcionEXAMEN;;
			23) salirMenu;;
			*) ;;
	esac 
done 

echo "Fin del programa. Utiliza 22 para salir la próxima vez ;)" 
exit 0 

# cat /var/log/auth.log  > auth.log.txt
# less auth.log.txt | tr -s ' ' '@' > auth.log.lineaporlinea.txt
# buscar="authentication@failure"
# 
# echo -e "Mes\tDía\tHora\tUsuario\tComando\n"
# echo -e "____________________________\n"
# 
# for linea in `less auth.log.lineaporlinea.txt | grep $buscar` 
# do
#    user=`echo $linea | cut -d@ -f15`
#    comando=`echo $linea | cut -d@ -f6`
#    dia=`echo $linea | cut -d@ -f2`
#    mes=`echo $linea | cut -d@ -f1`
#    hora=`echo $linea | cut -d@ -f3`
#    echo -e "$mes\t$dia\t$hora\t$user\t$comando\n"
# done
# 
# rm auth.log.txt  auth.log.lineaporlinea.txt

