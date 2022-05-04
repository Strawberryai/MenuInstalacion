# Menu de instalación

Se trata de un menú escrito en bash que automatiza la instalación de una aplicación web escrita en python. En concreto instala el servicio Ngix y Gunicorn y establece un puente entre Flask y Gunicorn para servir una aplicación que recibe un texto e indica el nivel de positivismo del mismo.

# Instalación

Clona el proyecto en una carpeta con:

~~~
git clone https://github.com/Strawberryai/MenuInstalacion.git
~~~

# Utilización

Ejecuta el script situándote en la carpeta de instalación y escribiendo:
~~~
./menu.bash
~~~

Las opciones del comando para establecer el usuario y grupo de la instalación son las siguientes:
~~~
./menu.bash <usuario> <grupo>
~~~


## Variables de entorno

Especifican algunos aspectos del funcionamiento del script. Las variables de
entorno de la aplicación son las siguientes:

- **MENU_DEFU**: Establece el usuario y grupo por defecto de la instalación (usuario y grupo actualis por defecto).
- **MENU_PROP**: Establece el usuario y grupo propietario ("www-data:www-data" por defecto).

Para establecer un valor de una variable de forma global hay que ejecutar lo
siguiente:
~~~
export [nombre_variable]="[valor]"
~~~

Por ejemplo:
~~~
export MENU_DEFU="alan:alan"
~~~


