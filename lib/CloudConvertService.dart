import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:typed_data';

enum estado { pending, uploading, converting, downloading, finished, error }

class CloudConvertService {

  String? _fileType;
  estado estadoActual = estado.pending;
  String? _outputformat = '';
  String? _videoCodec = '';
  int? _crf = 23;
  int? _width = null;
  int? _height = null;
  String? _audioCodec = '';
  String? _formatoOriginal;
  String? filePath;
  int? _imageQuality = 50;
  String? _imageEngine = '';


  // ARRIBA Clave de API real, ABAJO clave de API de sandbox

  //final String apiKey = 'eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJhdWQiOiIxIiwianRpIjoiMThmYzk4NTkwMzFlYTE4ODE4OTExOTYyODZhMWZlMTQwYmM2N2Y1OGY2ZmJiMTJhMGVlY2Y5OGVkOTExMjljYjJiODIwZTdiMGViMDM1ZTMiLCJpYXQiOjE3NDIxNjAyNzIuOTM1NzQsIm5iZiI6MTc0MjE2MDI3Mi45MzU3NDEsImV4cCI6NDg5NzgzMzg3Mi45MzE3NjYsInN1YiI6IjcxMzUyODQ2Iiwic2NvcGVzIjpbInByZXNldC53cml0ZSIsInByZXNldC5yZWFkIiwid2ViaG9vay53cml0ZSIsIndlYmhvb2sucmVhZCIsInRhc2sud3JpdGUiLCJ0YXNrLnJlYWQiLCJ1c2VyLndyaXRlIiwidXNlci5yZWFkIl19.io2qpe2WCKPgWXx0fRq3clN5vbljaAyZA0j1iJreBBemJoCbYWhaWo-nhQ9puWPa-zbBnQJ6FqrodxwrtiTZveUQbXIoOI1GArnNwa8m861-XbJtGUq_dzrpmocatsTlaZIFSAj51HousWBu-olTaz00GrI4KBKfnguYdBNer-JqcWIObOwcfHJAWIoS1Lg82-lbA7FTb-CV6qJp8PL2EN0HQVx_dMvm5cXpybc33zDAVmH44NVD30fIwK_rTp70Ku0L4FiLooaQIZ3_jU5whB-emo390Keu8IHP3vjCilKjY--31zIifq1VOxRtRAxtH8qD0W86l0vuoXUmsrEYzvRdemsGhYygKnfh2AKr-schcXFjk27dohur7Wxf2ubtTaKq4koPSuQ4ha7dekXoqCEOhwZpxoDo5KBJKwpjPQEeaTHtrVONj8d7_L0zDlaGJq-8gkGa6fqjeqkE5oZFFzQf-14WG99-UC9M9jJgYJEDR31xOqzzcKEddzi447guEMIsrpUNrGsRfw6RoTR7Ej8_sor0rQjb0hUT1QTgBWWivcGRP4cHVn4o4W3ftPKDCiylDATUq1roHxWXpZ3jIO2LXp_yVa5_PC_Nlm6fguGd-_fESxn_Yf4j2efiHCP7saKsHXln8OV0nycFZzNfT6aMC4GYaJ-IKEy1MbmrfaQ';
  final String apiKey = 'eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJhdWQiOiIxIiwianRpIjoiMmY2MTI5OTBmY2JlMjg1NTVhY2NhMTA1NTYyNDQ3YmM2OTczNDM4ZDQzYzViMGRiOWZiMmM1MTVlNjhmNTIzODlhZTI4Y2E5NGUwMmIxMTMiLCJpYXQiOjE3NDQ5OTUzOTkuNzIyNDM1LCJuYmYiOjE3NDQ5OTUzOTkuNzIyNDM5LCJleHAiOjQ5MDA2Njg5OTkuNzE4NTg0LCJzdWIiOiI3MTM1Mjg0NiIsInNjb3BlcyI6WyJwcmVzZXQud3JpdGUiLCJwcmVzZXQucmVhZCIsIndlYmhvb2sud3JpdGUiLCJ3ZWJob29rLnJlYWQiLCJ0YXNrLndyaXRlIiwidXNlci5yZWFkIiwidXNlci53cml0ZSIsInRhc2sucmVhZCJdfQ.FKGgw_8L8LX8-hOLIBFZDURz7HzzyAPS3C7W7BdafC1rhXeMfASbfiDKiVWeHvmlCj6rPi6Is08cqnl4mCNYSPD7RPALmfJOaAiTIbC8yDNFJe8k1qbJ1gF3IJ0fYyenRRfCmvm8b5ME3U2E4z8VFdMpigE4C0AOUR-YGvtF8r1Wg92uk1xdTD3A9P_xUc6sEe3ioteHfOt5q3kafX02IKRYbNX5Cu0NSvTgsdTBXpFZUF7hAyzt4_9UFbx6rDzojUifk8Jors6o8lJRz_uzMP93BEutarufbSZmzrDAqWSv912E-4YzMIxh2XCqUeOJsgnWzN9oGpWOCcp-mvUYyLu9MPC__F_BAv1Vr59g3I-GIMDKRK5pkN1Y5cUUpGWV90eVzejWIgfA0r6AU2B7cxB7ikcIrXgZ-MJYPHl3XP0HYU4sqlAODeXm96zSpzA6yjWb3dB7_od6kK4cyOgb6mrwS6wLURkfR7S92dgeVEMKUlhoCO5IGMx5OMVou5SFcFkfjcf64jv-T05XmPgqOrOdBoqFWeipBUo2fj4G6mOvNH-LmXlPOSU7ok4fREbCe2vilDyM_PhXIHCZXUFdWTJZQxYG_FI-qBVbOHbFC_qTx7KeIDI9O4R1tX9Ez-0TGaNniGtm3OxQ7o5ijgy5OYYngY_bsmEDV6QToTbPvlQ';


  CloudConvertService();

  String getName() {
    if(_fileType == 'video'){
      return '${_formatoOriginal?.toUpperCase()} to ${_outputformat?.toUpperCase()} | ${_videoCodec?.toUpperCase()}';
    } else if(_fileType == 'image' && _outputformat == 'webp' || _outputformat == 'png'){
      return '${_formatoOriginal?.toUpperCase()} to ${_outputformat?.toUpperCase()} | Compresión: ${_imageQuality?.toString()}';
    } else if(_fileType == 'image' && _outputformat == 'jpg'){
      return '${_formatoOriginal?.toUpperCase()} to ${_outputformat?.toUpperCase()} | Calidad: ${_imageQuality?.toString()}';
    } else {
      return '${_formatoOriginal?.toUpperCase()} to ${_outputformat?.toUpperCase()}';
    }

  }

  String getStatus(){
    return estadoActual.toString();
  }

  String? getFilePath(){
    return filePath;
  }



  Future<void> fileUpload(BuildContext context, File file, String format, {outputformat='', videoCodec='', crf=23, width=null, height=null, audioCodec='', imageQuality=50, imageEngine=''}) async {

    _outputformat = outputformat.toLowerCase();
    _videoCodec = videoCodec;
    _crf = crf;
    _width = width;
    _height = height;
    _audioCodec = audioCodec;
    _formatoOriginal = format.toLowerCase();
    _imageQuality = imageQuality;
    _imageEngine = imageEngine;

    if(_formatoOriginal == 'jpg' ||
        _formatoOriginal == 'png' ||
        _formatoOriginal == 'gif' ||
        _formatoOriginal == 'webp' ||
        _formatoOriginal == 'bmp')
    {
      _fileType = 'image';
    }
    if(_formatoOriginal == 'mp4' ||
        _formatoOriginal == 'avi' ||
        _formatoOriginal == 'webm' ||
        _formatoOriginal == 'mkv' ||
        _formatoOriginal == 'flv')
    {
      _fileType = 'video';
    }

    try {

      estadoActual = estado.uploading;


      // Paso 1: Obtener la URL de subida
      var url = Uri.parse('https://api.sandbox.cloudconvert.com/v2/import/upload');
      var response = await http.post(
        url,
        headers: {'Authorization': 'Bearer $apiKey'},
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        print('Error al obtener la URL de subida: ${response.statusCode}');
        print('Respuesta completa: ${response.body}');
        estadoActual = estado.error;
        return;
      }

      var responseJson = json.decode(response.body);
      if (responseJson['data'] == null || responseJson['data']['result'] == null) {
        print('Error: No se recibió la información de subida.');
        print('Respuesta completa: ${response.body}');
        estadoActual = estado.error;
        return;
      }

      // Obtener la URL de subida y los parámetros de AWS S3
      String uploadUrl = responseJson['data']['result']['form']['url'];
      Map<String, dynamic> parameters = responseJson['data']['result']['form']['parameters'];

      print('URL de subida: $uploadUrl');
      print('Parámetros de subida: $parameters');

      // Paso 2: Subir el archivo a la URL de S3 con los parámetros requeridos
      var request = http.MultipartRequest('POST', Uri.parse(uploadUrl));

      // Agregar parámetros como campos del formulario
      parameters.forEach((key, value) {
        request.fields[key] = value.toString();
      });

      // Agregar el archivo
      request.files.add(await http.MultipartFile.fromPath('file', file.path));

      var uploadResponse = await request.send();

      if (uploadResponse.statusCode == 201) {
        print('Archivo subido correctamente.');

        // Paso 3: Obtener el ID del archivo subido
        String fileId = responseJson['data']['id'];

        // Paso 4: Iniciar conversión con el fileId
        await fileConvert(fileId);

        // Ocultar SnackBar después de completar la subida y conversión
        ScaffoldMessenger.of(context).hideCurrentSnackBar();

      } else {
        print('Error al subir el archivo a S3: ${uploadResponse.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }

  }

  Future<void> fileConvert(String fileId) async {
    try {

      var url = Uri.parse('https://api.sandbox.cloudconvert.com/v2/convert');
      estadoActual = estado.converting;
      print("=====================");
      print("FILE TYPE: $_fileType");
      print("=====================");

      var body = json.encode({
        'input': {'file': fileId},
        'output_format': _outputformat,
        'autostart': true
      });

      if(_fileType == 'video')
      {
        body = json.encode({
          'input': {'file': fileId},
          'output_format': _outputformat,
          'autostart': true,
          'video_codec': _videoCodec,
          'crf': _crf,
          'width': _width,
          'height': _height,
          'audio_codec': _audioCodec
        });
      }
      if(_fileType == 'image') {
        body = json.encode({
          'input': {'file': fileId},
          'output_format': _outputformat,
          'autostart': true,
          'width': _width,
          'height': _height,
          'quality': _imageQuality,
          'engine': _imageEngine
        });
      }


      var response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        body: body,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        var responseJson = json.decode(response.body);
        String taskId = responseJson['data']['id'];
        print('Tarea de conversión creada con ID: $taskId');


        await monitorizarConversion(taskId);

      } else {
        print('Error al crear la tarea de conversión: ${response.statusCode}');
        print('Respuesta completa: ${response.body}');
        estadoActual = estado.error;
      }

    } catch (e) {
      print('Error: $e');
      estadoActual = estado.error;
    }
  }

  Future<void> monitorizarConversion(String taskId) async {
    try {

      var url = Uri.parse('https://api.sandbox.cloudconvert.com/v2/tasks/$taskId');
      var response = await http.get(url, headers: {
        'Authorization': 'Bearer $apiKey',
      });

      if (response.statusCode == 200) {
        var responseJson = json.decode(response.body);
        String status = responseJson['data']['status'];
        print('Respuesta completa: ${response.body}');

        if (status == 'finished') {
          print('Conversión completada.');


          obtenerUrlDescarga(responseJson['data']['id']);

        } else if (status == 'failed' || status == 'error') {
          estadoActual = estado.error;
          print('La conversión falló.');
        } else {
          print('La conversión aún está en progreso...');
          // Volver a intentar en algunos segundos
          await Future.delayed(Duration(seconds: 5));
          await monitorizarConversion(taskId);
        }
      } else {
        print('Error al monitorear la conversión: ${response.statusCode}');
      }
    } catch (e) {
      estadoActual = estado.error;
      print('Error: $e');
    }
  }

  Future<void> downloadFile(String url) async {
    try {
      Dio dio = Dio();
      Directory? tempDir = await getDownloadsDirectory();
      filePath = '${tempDir!.path}/ConvallFile.$_outputformat';

      print('Descargando archivo en: $filePath');
      estadoActual = estado.downloading;

      await dio.download(url, filePath, onReceiveProgress: (received, total) {
        if (total != -1) {
          print('Descarga en progreso: ${(received / total * 100).toStringAsFixed(0)}%');

        }
      });

      estadoActual = estado.finished;
      print('Descarga completada. Archivo guardado en: $filePath');
    } catch (e) {
      estadoActual = estado.error;
      print('Error al descargar el archivo: $e');
    }
  }





  Future<void> obtenerUrlDescarga(String fileId) async {
    var url = Uri.parse('https://api.sandbox.cloudconvert.com/v2/export/url');

    // Cuerpo de la solicitud POST
    var body = json.encode({
      "input": fileId,
      "archive_multiple_files": false,
    });

    var response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      },
      body: body,
    );
    var responseJson = json.decode(response.body);

    await Future.delayed(Duration(seconds: 2));
    var urlFinished = Uri.parse('https://api.sandbox.cloudconvert.com/v2/tasks/${responseJson['data']['id']}?include=payload');
    var responseFinished = await http.get(
      urlFinished,
      headers: {
        'Authorization': 'Bearer $apiKey',
      },
    );

    var responseFinishedJson = json.decode(responseFinished.body);




    if (responseFinished.statusCode == 200) {

      print("Estado de la exportacion: ${responseFinishedJson['data']['status']}");
      try {
        String downloadUrl = responseFinishedJson['data']['result']['files'][0]['url'];
        print('URL de descarga: $downloadUrl');
        downloadFile(downloadUrl);
      } catch (e) {
        estadoActual = estado.error;
        print('Error: No se pudo extraer la URL de descarga.');
        print('Detalles: $e');
      }
    } else {
      estadoActual = estado.error;
      print('Error al obtener la URL de descarga: ${response.statusCode}');
      print('Respuesta completa: ${response.body}');
    }



  }




}


