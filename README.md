# VB6-Recursos

Recursos descargables organizados por programa: **fondos** de escritorio y **configuración**
del importador de datos.

## Estructura

```
<programa>/
    fondos/
        lista.txt                          versión + nombres de fichero
        fondo<prog>11_<ancho>_<alto>.jpg   un fondo por resolución
    importador/
        importador.ini                     configuración del importador de datos
```

Programas: `barRestaurante`, `tpv`, `gestion`, `peluqueria`, `taller`.

Recursos compartidos por todos los programas:

```
comun/
    recursos/    imágenes y recursos comunes
    remoto/      utilidades (asistencia remota, instalador multipuesto)
    utilidades/  scripts de despliegue (compartir la instalación en red)
    esquemas/    estructura de las bases de datos
```

## Compartir la instalación en red

`comun/utilidades/CompartirDoscar.bat` prepara un equipo para trabajar en red:

- **En el servidor** (el PC que tiene el programa): copie el `.bat` en la carpeta de
  instalación y ejecútelo **como administrador**. Comparte la carpeta, crea el usuario
  de acceso y genera un segundo script `ConectarDoscar_<EQUIPO>.bat`.
- **En cada puesto**: ejecute ese `ConectarDoscar_<EQUIPO>.bat` con **doble clic normal**.
  Monta la unidad de red (busca la primera letra libre) y crea en el escritorio los
  accesos directos de los programas encontrados.

## lista.txt (fondos)

- **Línea 0**: versión (texto). Se actualiza cuando cambian los fondos.
- **Líneas siguientes**: nombre de cada fichero del programa.

## importador.ini

Configuración del importador de datos de cada programa: qué tablas se pueden importar y
qué valores se ponen en los registros nuevos cuando el fichero de origen no los trae.

- Lleva su propia versión en la sección `[Config]`.
- El programa lo descarga si no lo tiene. Si ya lo tiene, **no se toca**: el usuario puede
  pedir desde el propio programa que compruebe si hay una versión más nueva, y siempre se
  guarda una copia de la anterior antes de sustituirla.

## URL (raw)

```
Base:        https://raw.githubusercontent.com/grupodoscar-bot/VB6-Recursos/main/
Lista:       <Base><programa>/fondos/lista.txt
Fondo:       <Base><programa>/fondos/<nombre.jpg>
Importador:  <Base><programa>/importador/importador.ini
```

## Nombres de fichero

`fondo<prog>11_<ancho>_<alto>.jpg`. La resolución va embebida en el nombre. **No renombrar.**

## Codificación

Los ficheros de texto (`lista.txt`, `importador.ini`) van en **ANSI / Windows-1252**, no en
UTF-8. En UTF-8 las tildes y las eñes se leen mal.
