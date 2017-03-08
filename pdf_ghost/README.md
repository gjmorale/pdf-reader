
# PDF Ghost

Procesa archivos pdf para ser leidos por [pdf_reader](https://github.com/gjmorale/pdf-reader)

### Instalar
Clonar repositorio

### Setup
Configurar rutas _In_, _Out_ y _Source_ en _ghost.rb_
* _In: Ruta desde la cual obtener cartolas_
* _Out: Careta donde guardar archivos procesados_
* _Source: Archivo con texto por eliminar de el archivo original_

**IMPORTANTE: Carpeta _Out_ será completamente eliminada en cada ejecución.**

### Ejecutar
Desde la carpeta principal donde esta el archivo _ghost.rb_ ejecutar
```zsh
$ ruby ghost.rb
```

Si el resultado no es el esperado, solicite ayuda a [Guillermo Morales](gmorales@quaam.cl)

### Notas
Es necesario que todos los archivos en _In_ sean formato pdf sin encriptar y con privilegios de lectura.

***

###### Código para uso privado. Utilizar a discreción y sin garantías.