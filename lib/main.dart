import 'package:flutter/material.dart';
import 'package:convall/conversor_app.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'CloudConvertService.dart';


void main() async{

  await Hive.initFlutter(); // Inicializar Hive
  Hive.registerAdapter(CloudConvertServiceAdapter());

  runApp(const ConversorApp());

}

/*

Quehaceres:
 - Gestion de perfiles de codificacion:
     - Utilizacion de perfiles para codificar segun el nivel de calidad, tipo de dispositivos destino, rendimiento de codificacion, etc.
     - Configuracion de valores para bitrate, resolucion, algoritmo, etc.
 - Edicion interactiva de metadatos
 - Conversor en lotes con carpetas anidadas:
     - Permitir la conversion de medios por lotes de archivos, especificando un tipo de archivo a codificar
     - Especificar una carpeta y procesar todos los archivos que tengan las extensiones seleccionadas
     - Permitir busquedas recursivas por carpetas anidadas


 */