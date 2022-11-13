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
-  Si es que se tiene otra versión de Ubuntu (Ej: "Ubuntu 18.04.5 LTS") el comando cambiará a `Ubuntu1804`.
- Luego de instalarse nos pedirá crearnos un usuario y una contraseña que deberemos de confirmar.

[![imagen-2022-11-12-215404985.png](https://i.postimg.cc/KvqZb9Xz/imagen-2022-11-12-215404985.png)](https://postimg.cc/svWF94gd)

Desde ahora cada vez que queramos ingresar a Ubuntu desde consola deberemos introducir el comando `Ubuntu`


A continuación, procederemos a introducir los siguientes comandos en orden para la instalación del lenguaje `Lua`
- `apt-get update` para la descarga y actualización de paquetes.
- `apt-get upgrade` para descargar la ultima versión de `Linux`.
- `apt-cache search lua5` al introducir este comando se desplegará una lista con todas las versiones de `Lua` disponibles para descargar.

[![imagen-2022-11-12-222716156.png](https://i.postimg.cc/5tF7yt6G/imagen-2022-11-12-222716156.png)](https://postimg.cc/3yYCbYjC)

- Nos interesa la versión de `Lua` 5.1 ya que esta es compatible con las librerias MySql.
- introduciremos el comando `sudo apt install lua5.1` 
- Confirmamos con la contraseña que introducimos al entrar por primera vez a `Ubuntu` y esperamos a que se instale .

Luego de haber instalado `Lua` instalaremos su administrador de paquetes llamado `luarocks`.
- Instalaremos `luarocks` mediante el siguiente comando `sudo apt install luarocks`.
- Confirmamos con nuestra contraseña de `Ubuntu` y continuamos.
 
Después de tener `luarocks` instalado, podemos instalar la libreria `mysql-server` 
- Introducimos el comando `sudo apt install mysql-server` para instalar MySql en `Ubuntu`.
- Confirmamos nuevamente con nuestra contraseña de `Ubuntu` y continuamos.

  
  - Ya dentro de la Propiedades del sistema, nos dirigimos a `Opciones avanzadas`.
  - Seleccionamos `Variables de entorno`.
  
  ![image](https://user-images.githubusercontent.com/116284986/201191632-75bdc06c-ed4f-43f7-91d9-edc090a5a35c.png)
  
  - Una vez dentro, nos dirigimos a Variables del sistema.
  - Seleccionamos la variable `Path`.
  - Elegimos Editar.
  
  ![image](https://user-images.githubusercontent.com/116284986/201192138-ca7468f8-3bbc-458f-875e-c83c861f3447.png)

  - Dentro del apartado de edición, elegimos la opción `Nuevo.`
  
  ![image](https://user-images.githubusercontent.com/116284986/201192410-c57243da-c48a-4328-bc4d-3b3744451f34.png)
  
  - Agregamos lo siguiente `C:\lua`.
  - Y finalizamos seleccionando Aceptar y Aplicar.
  
## Estado del proyecto

El proyecto está: _en progreso_

## Tecnologias usadas

 - LUA - 5.4.2
 - Visual Studio Code
 - MySQL
 - MySQL Workbench
