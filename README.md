# VB6-Recursos

Recursos descargables organizados por programa. De momento, **fondos** de escritorio.

## Estructura

```
<programa>/fondos/
    lista.txt                          versión + nombres de fichero
    fondo<prog>11_<ancho>_<alto>.jpg   un fondo por resolución
```

Programas: `barRestaurante`, `tpv`, `gestion`, `peluqueria`, `taller`.

Recursos compartidos por todos los programas:

```
comun/
    recursos/    imágenes y recursos comunes
    remoto/      utilidades (asistencia remota, instalador multipuesto)
    utilidades/  scripts de despliegue (compartir la instalación en red)
```

## Compartir la instalación en red

`comun/utilidades/CompartirDoscar.bat` prepara un equipo para trabajar en red:

- **En el servidor** (el PC que tiene el programa): copie el `.bat` en la carpeta de
  instalación y ejecútelo **como administrador**. Comparte la carpeta, crea el usuario
  de acceso y genera un segundo script `ConectarDoscar_<EQUIPO>.bat`.
- **En cada puesto**: ejecute ese `ConectarDoscar_<EQUIPO>.bat` con **doble clic normal**.
  Monta la unidad de red (busca la primera letra libre) y crea en el escritorio los
  accesos directos de los programas encontrados.

## lista.txt

- **Línea 0**: versión (texto). Se actualiza cuando cambian los fondos.
- **Líneas siguientes**: nombre de cada fichero del programa.

## URL (raw)

```
Base:   https://raw.githubusercontent.com/grupodoscar-bot/VB6-Recursos/main/
Lista:  <Base><programa>/fondos/lista.txt
Fondo:  <Base><programa>/fondos/<nombre.jpg>
```

## Nombres de fichero

`fondo<prog>11_<ancho>_<alto>.jpg`. La resolución va embebida en el nombre. **No renombrar.**
