# VB6-Recursos

Recursos descargables organizados por programa. De momento, **fondos** de escritorio.

## Estructura

```
<programa>/fondos/
    lista.txt                          versión + nombres de fichero
    fondo<prog>11_<ancho>_<alto>.jpg   un fondo por resolución
```

Programas: `barRestaurante`, `tpv`, `gestion`, `peluqueria`, `taller`.

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
