# VB6-Recursos

Recursos descargables de los programas Doscar/Prosicar, organizados por programa.
Sustituye al antiguo alojamiento en `doscar.com/fondo/`.

De momento contiene **fondos** de escritorio (MDI). La estructura está pensada
para alojar más tipos de recurso por programa en el futuro.

## Estructura

```
<programa>/fondos/
    lista.txt                          puntero de versión + nombres de fichero
    fondo<prog>11_<ancho>_<alto>.jpg   un fondo por resolución
```

Programas con fondos: `barRestaurante`, `tpv`, `gestion`, `peluqueria`, `taller`.

## lista.txt

- **Línea 0**: versión (cadena; se compara como texto). Súbela cuando cambien los fondos.
- **Líneas siguientes**: nombre de cada fichero de fondo del programa.

El cliente baja `lista.txt`, y si la versión cambió respecto a la local,
descarga los fondos listados y borra los locales que ya no aparezcan.

## Esquema de URL (raw GitHub)

```
Base:   https://raw.githubusercontent.com/grupodoscar-bot/VB6-Recursos/main/
Lista:  <Base><programa>/fondos/lista.txt
Fondo:  <Base><programa>/fondos/<nombre.jpg>
```

## Nombres de fichero

`fondo<prog>11_<ancho>_<alto>.jpg`. **La resolución va embebida en el nombre**:
la librería (`modFondoMDI.bas`) la parsea para elegir automáticamente el fondo que
mejor cubre la pantalla del cliente. **No renombrar** los ficheros.

## Quién lo consume

`vb6LIbreriasComunes\modFondoMDI.bas` (común a los programas). Prefijo por programa:
`fondobar11_`, `fondotpv11_`, `fondogestion11_`, `fondopeluqueria11_`, `fondotaller11_`.
