# Taller-1-FLP

# Catedra-1

El sistema a desarrollar se hará mediante uso del lenguaje [LUA](https://www.lua.org/) y el gestor de base de datos [MySQL](https://www.mysql.com/).

## Tabla de Contenidos
* [Catedra 1](#catedra-1)
* [Instalacion](#instalacion)
* [Estado del proyecto](#estado-del-proyecto)
* [Tecnologias usadas](#tecnologias-usadas)

## Instalacion

Por favor siga la guía de instrucciones para su correcta instalación.

- Primero, instalaremos la terminal de entorno Ubuntu con el subsistema de Windows para Linux por medio de la tienda Microsoft.

[![imagen-2022-11-12-210119990.png](https://i.postimg.cc/bJx3p24Y/imagen-2022-11-12-210119990.png)](https://postimg.cc/r0pS9z87)

- Para el caso, instalaremos la que dice solo "Ubuntu".

- Una vez instalado inicializamos la consola como administrador.

[![cmd.png](https://i.postimg.cc/Hn4Yw3RG/cmd.png)](https://postimg.cc/rRs2cGqg)

- Luego en la consola, debemos introducir el siguiente comando `Ubuntu`.
- Si es que se tiene otra versión de Ubuntu (Ej: "Ubuntu 18.04.5 LTS") el comando cambiará a `Ubuntu1804`.
- Luego de instalarse nos pedirá crearnos un usuario y una contraseña que deberemos de confirmar.

[![imagen-2022-11-12-215404985.png](https://i.postimg.cc/KvqZb9Xz/imagen-2022-11-12-215404985.png)](https://postimg.cc/svWF94gd)

Desde ahora cada vez que queramos ingresar a Ubuntu desde consola deberemos introducir el comando `Ubuntu`


A continuación, procederemos a introducir los siguientes comandos en orden para la instalación del lenguaje Lua
- `apt-get update` para la descarga y actualización de paquetes.
- `apt-get upgrade` para descargar la ultima versión de `Linux`.
- `apt-cache search lua5` al introducir este comando se desplegará una lista con todas las versiones de `Lua` disponibles para descargar.

[![imagen-2022-11-12-222716156.png](https://i.postimg.cc/5tF7yt6G/imagen-2022-11-12-222716156.png)](https://postimg.cc/3yYCbYjC)

- Nos interesa la versión `Lua5.1` ya que esta es compatible con las librerias MySql.
- introduciremos el comando `sudo apt install lua5.1` 
- Confirmamos con la contraseña que introducimos al entrar por primera vez a `Ubuntu` y esperamos a que se instale.

Luego de haber instalado Lua instalaremos su administrador de paquetes llamado `luarocks`.
- Instalaremos `luarocks` mediante el siguiente comando `sudo apt install luarocks`.
- Confirmamos con nuestra contraseña de `Ubuntu` y continuamos.
 
Después de tener luarocks instalado, podemos instalar la libreria `mysql-server` 
- Introducimos el comando `sudo apt install mysql-server` para instalar MySQL en `Ubuntu`.
- Confirmamos nuevamente con nuestra contraseña de `Ubuntu` y continuamos.

Luego de esto procederemos a configurar MySQL
- Escribimos `sudo service mysql start`.
- Luego `sudo mysql`.
- Y después `ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'contraseña';`.

[![imagen-2022-11-16-114305715.png](https://i.postimg.cc/Xv3N7ZC8/imagen-2022-11-16-114305715.png)](https://postimg.cc/rDn2fwg0)

Para verificar de que esto funciona correctamente podemos intentar el siguiente comando:
- `CREATE DATABASE nombre_tabla`
Si funciona correctamente, deberìa de aparecer lo de la siguiente imagen:

[![Whats-App-Image-2022-11-16-at-11-50-19-AM.jpg](https://i.postimg.cc/W3vrSst3/Whats-App-Image-2022-11-16-at-11-50-19-AM.jpg)](https://postimg.cc/94LrQ5d5)

Hecho esto podremos salir usando el comando `exit`.

Posteriormente procederemos a instalar LuaSQL:
- Escribimos el comando `sudo apt-get install libmysqlclient-dev`.
- `mysql_config --include`
- Este ultimo comando nos devolverà un directorio que debemos incluir en el comando a continuaciòn.
- `sudo luarocks install luasql-mysql MYSQL_INCDIR="directorio_obtenido"`.

Terminado esto ya deberiamos de tener LuaSQL en nuestro sistema.

Seguidamente instalaremos  [MySQL Workbench - 8.0.31](https://dev.mysql.com/downloads/workbench/)
- Una vez instalamos MySQL Workbench, en la pantalla de inicio, debemos dirigirnos al apartado que dice `Database`
- `Connect to Database`
- dentro de los datos rellenamos en Hostanme = Localhost, Port 3306, Username = root, Password = Store in vault.

[![imagen-2022-11-16-192426570.png](https://i.postimg.cc/qB6QYbvH/imagen-2022-11-16-192426570.png)](https://postimg.cc/4nZzH1cW)

- Al seleccionar Store in Vault, nos pedira una contraseña que sera la misma que introducimos al configurar MySQL desde ubuntu.
- Terminado esto seleccionames "OK" y esperamos a que se conecte.

### Posibles errores
En caso de presentar algun error al intentar acceder con el comando `sudo mysql`, como por ejemplo:
- `Access denied for user 'root'@'localhost' (using password: NO)`
- Entonces introduciremos el siguiente comando `sudo mysql -u root -p`.
- Nos pedirá una contraseña que es la misma que introducimos en el comando de configuracion de MySQL.
 
[![Whats-App-Image-2022-11-16-at-11-47-19-AM.jpg](https://i.postimg.cc/jdKNyxmk/Whats-App-Image-2022-11-16-at-11-47-19-AM.jpg)](https://postimg.cc/V5Gd88Yj)

Realizado esto ya deberiamos poder acceder a mysql desde ubuntu.


  
## Estado del proyecto

El proyecto está: _en progreso_

## Tecnologias usadas

 - LUA - 5.1.5
 - [Visual Studio Code - 1.73](https://code.visualstudio.com/Download)
 - MySQL
 - [MySQL Workbench - 8.0.31](https://dev.mysql.com/downloads/workbench/)
