import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class CloudConvertService {
  final String apiKey = 'eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJhdWQiOiIxIiwianRpIjoiMThmYzk4NTkwMzFlYTE4ODE4OTExOTYyODZhMWZlMTQwYmM2N2Y1OGY2ZmJiMTJhMGVlY2Y5OGVkOTExMjljYjJiODIwZTdiMGViMDM1ZTMiLCJpYXQiOjE3NDIxNjAyNzIuOTM1NzQsIm5iZiI6MTc0MjE2MDI3Mi45MzU3NDEsImV4cCI6NDg5NzgzMzg3Mi45MzE3NjYsInN1YiI6IjcxMzUyODQ2Iiwic2NvcGVzIjpbInByZXNldC53cml0ZSIsInByZXNldC5yZWFkIiwid2ViaG9vay53cml0ZSIsIndlYmhvb2sucmVhZCIsInRhc2sud3JpdGUiLCJ0YXNrLnJlYWQiLCJ1c2VyLndyaXRlIiwidXNlci5yZWFkIl19.io2qpe2WCKPgWXx0fRq3clN5vbljaAyZA0j1iJreBBemJoCbYWhaWo-nhQ9puWPa-zbBnQJ6FqrodxwrtiTZveUQbXIoOI1GArnNwa8m861-XbJtGUq_dzrpmocatsTlaZIFSAj51HousWBu-olTaz00GrI4KBKfnguYdBNer-JqcWIObOwcfHJAWIoS1Lg82-lbA7FTb-CV6qJp8PL2EN0HQVx_dMvm5cXpybc33zDAVmH44NVD30fIwK_rTp70Ku0L4FiLooaQIZ3_jU5whB-emo390Keu8IHP3vjCilKjY--31zIifq1VOxRtRAxtH8qD0W86l0vuoXUmsrEYzvRdemsGhYygKnfh2AKr-schcXFjk27dohur7Wxf2ubtTaKq4koPSuQ4ha7dekXoqCEOhwZpxoDo5KBJKwpjPQEeaTHtrVONj8d7_L0zDlaGJq-8gkGa6fqjeqkE5oZFFzQf-14WG99-UC9M9jJgYJEDR31xOqzzcKEddzi447guEMIsrpUNrGsRfw6RoTR7Ej8_sor0rQjb0hUT1QTgBWWivcGRP4cHVn4o4W3ftPKDCiylDATUq1roHxWXpZ3jIO2LXp_yVa5_PC_Nlm6fguGd-_fESxn_Yf4j2efiHCP7saKsHXln8OV0nycFZzNfT6aMC4GYaJ-IKEy1MbmrfaQ';

  Future<void> videoConvert(File videoFile) async {

    try{
      var url = Uri.parse('https://api.cloudconvert.com/v2/import/upload');
      var request = http.MultipartRequest('POST', url)
        ..headers['Authorization'] = 'Bearer $apiKey'
        ..files.add(await http.MultipartFile.fromPath('file', videoFile.path));

      var response = await request.send();

      if (response.statusCode == 200) {

        var responseBody = await response.stream.bytesToString();
        var responseJson = json.decode(responseBody);

        String fileId = responseJson['data']['id'];
        print('Archivo subido con ID: $fileId');


        await fileConvert(fileId);

      } else {
        print('Error al subir archivo: ${response.statusCode}');
      }

    } catch (e) {
      print('Error: $e');
    }

  }

  Future<void> fileConvert(String fileId) async {
    try {

      var url = Uri.parse('https://api.cloudconvert.com/v2/convert');
      var body = json.encode({
        'input': {'file': fileId},
        'output_format': 'mp4', // Puedes cambiar a otro formato como .avi, .mov, etc.
      });

      var response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        body: body,
      );

      if (response.statusCode == 200) {
        var responseJson = json.decode(response.body);
        String taskId = responseJson['data']['id'];
        print('Tarea de conversión creada con ID: $taskId');


        await monitorizarConversion(taskId);

      } else {
        print('Error al crear la tarea de conversión: ${response.statusCode}');
      }

    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> monitorizarConversion(String taskId) async {
    try {

      var url = Uri.parse('https://api.cloudconvert.com/v2/tasks/$taskId');
      var response = await http.get(url, headers: {
        'Authorization': 'Bearer $apiKey',
      });

      if (response.statusCode == 200) {
        var responseJson = json.decode(response.body);
        String status = responseJson['data']['status'];

        if (status == 'finished') {
          print('Conversión completada.');

          // CODIGO PARA DESCARGAR EL ARCHIVO

        } else if (status == 'failed') {
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
      print('Error: $e');
    }
  }
}
