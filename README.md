# Variables de entorno

Especifican algunos aspectos del funcionamiento del script. Las variables de
entorno de la aplicación son las siguientes:

- **MENU_DEFU**: Establece el usuario y grupo por defecto de la instalación ("alan:alan" por defecto).
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


