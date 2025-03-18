import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:image/image.dart' as img;
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:exif/exif.dart';

class paginaImagen extends StatefulWidget {
  const paginaImagen({super.key});

  @override
  State<paginaImagen> createState() => _paginaImagenState();
}




class _paginaImagenState extends State<paginaImagen> {
  static const Color FloralWhite = Color(0xFFFFFCF2);
  static const Color Timberwolf = Color(0xFFCCC5B9);
  static const Color BlackOlive = Color(0xFF403D39);
  static const Color EerieBlack = Color(0xFF252422);
  static const Color Flame = Color(0xFFEB5E28);


  String? _selectedFilePath;
  String? _imageFormat;
  String? _outputFormat;
  String? _convertedImagePath;
  int? _altoOriginal;
  int? _anchoOriginal;
  String? _filename = '';
  int? _altoModificado = -1;
  int? _anchoModificado = -1;
  double? _pngLevel = 6;
  double? _jpgQuality = 100;
  double? _gifQuality = 10;
  double? _webpQuality = 100;
  var _exifData;



  // Lista de formatos soportados
  List<String> _outputFormats = ['JPEG', 'PNG', 'GIF', 'BMP', 'WEBP'];

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      File file = File(image.path);
      List<int> inputBytes = await file.readAsBytes();
      Uint8List uint8List = Uint8List.fromList(inputBytes);
      img.Image? imageData = img.decodeImage(Uint8List.fromList(inputBytes));
      _altoOriginal = imageData!.height;
      _anchoOriginal = imageData!.width;


      List<int> headerBytes = await file.openRead(0, 12).first;
      _imageFormat = _identifyImageFormat(headerBytes);
      _outputFormat = _imageFormat;

      _exifData = await readExifFromBytes(uint8List);


      setState(() {
        _selectedFilePath = image.path;
      });


    }
  }

  String _identifyImageFormat(List<int> bytes) {
    if (bytes.length < 12) return "Desconocido";

    // Identificación de formatos
    if (bytes[0] == 0xFF && bytes[1] == 0xD8 && bytes[2] == 0xFF) {
      return "JPEG";
    } else if (bytes[0] == 0x89 && bytes[1] == 0x50 && bytes[2] == 0x4E && bytes[3] == 0x47) {
      return "PNG";
    } else if (bytes[0] == 0x47 && bytes[1] == 0x49 && bytes[2] == 0x46) {
      return "GIF";
    } else if (bytes[0] == 0x42 && bytes[1] == 0x4D) {
      return "BMP";
    } else if (bytes[0] == 0x52 && bytes[1] == 0x49 && bytes[2] == 0x46 && bytes[3] == 0x46) {
      return "WEBP";
    }

    return "Desconocido";
  }

  Future<List<int>> changeFormatAndResolution(List<int> inputBytes) async {

    List<int> outputBytes = [];
    img.Image? image = img.decodeImage(Uint8List.fromList(inputBytes));
    Uint8List uint8List = Uint8List.fromList(inputBytes);

    int? alto2 = _altoOriginal, ancho2 = _anchoOriginal;
    if(_altoModificado != -1)
    {
        alto2 = _altoModificado;
    }
    if(_anchoModificado != -1)
    {
        ancho2 = _anchoModificado;
    }
    if(_altoModificado != -1 || _anchoModificado != -1)
    {
        image = img.copyResize(image!, height: alto2!, width: ancho2!);
    }


    switch (_outputFormat!.toLowerCase()) {
      case 'png':
        outputBytes = img.encodePng(image!, level: _pngLevel!.toInt());
        break;
      case 'jpeg':
        outputBytes = img.encodeJpg(image!, quality: _jpgQuality!.toInt());
        break;
      case 'gif':
        outputBytes = img.encodeGif(image!, samplingFactor: _gifQuality!.toInt());
        break;
      case 'bmp':
        outputBytes = img.encodeBmp(image!);
        break;
      case 'webp':
        outputBytes = await FlutterImageCompress.compressWithList(
          uint8List,
          format: CompressFormat.webp,
          quality: _webpQuality!.toInt(),
        );
        break;
      default:
        print("Formato de salida no soportado.");
    }



    return outputBytes;

  }



  Future<void> convertImage(String inputPath) async {

    File inputFile = File(inputPath);
    List<int> inputBytes = await inputFile.readAsBytes();


    List<int> outputBytes = [];

    //CAMBIAR RESOLUCION Y FORMATO ---------------------------------------------
    outputBytes = await changeFormatAndResolution(inputBytes);


    // Guardar la imagen convertida en el cache de la aplicaicon
    final directory = await getApplicationCacheDirectory();
    final outputPath = '${directory.path}/converted_image.$_outputFormat';
    File(outputPath).writeAsBytes(outputBytes);
    setState(() {
      _convertedImagePath = outputPath; // Ruta de la imagen convertida
    });
    print("Imagen convertida y guardada en: $outputPath");
  }

  Future<void> saveImageToGallery() async {
    if (_convertedImagePath != null && _outputFormat != null) {

      if(_filename == '')
      {
        _filename = 'convallImage_${DateTime.now().millisecondsSinceEpoch}.$_outputFormat';
      }
      else
      {
        _filename = '$_filename.$_outputFormat';
      }


      if (await checkStoragePermission())
      {

        Directory? directory = await getDownloadsDirectory();

        if (directory != null)
        {
          String filePath = '${directory.path}/$_filename';
          File file = File(_convertedImagePath!);
          Uint8List imageBytes = await file.readAsBytes();
          await File(filePath).writeAsBytes(imageBytes);
          print('Imagen guardada en: $filePath');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Imagen descargada correctamente.'),
            ),
          );

        } else {

          print('No se pudo obtener el directorio de almacenamiento');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('No se pudo obtener el directorio de almacenamiento')),
          );

        }

      } else {
        print('Permiso de almacenamiento denegado');
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Permiso de almacenamiento denegado')),
        );
      }
    } else {
      print('No hay imagen convertida o formato de salida no especificado');
    }
  }

  Future<bool> checkStoragePermission() async {
    var statusStorage = await Permission.storage.status;
    var statusPhotos = await Permission.photos.status;

    if (statusStorage.isPermanentlyDenied || statusPhotos.isPermanentlyDenied) {
      /*ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Storage permission permanently denied'),
        ),
      );*/
      return false;
    } else {
      statusStorage = await Permission.storage.request();
      statusPhotos = await Permission.photos.request();
      if (statusStorage.isGranted || statusPhotos.isGranted) {

        /*ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Storage permission granted'),
          ),
        );*/
        return true;
      } else {
        /*ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Storage permission denied'),
          ),
        );*/
        return false;
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FloralWhite,



      appBar: AppBar(
        title: const Text(
          'Convall',
          style: TextStyle(
              color: Flame,
              fontSize: 100,
              fontFamily: 'Outward'
          ),
        ),
        centerTitle: true,
        toolbarHeight: 100,
        backgroundColor: FloralWhite,
      ),


      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                GestureDetector(
                  onTap: _pickImage,
                  child: _selectedFilePath == null
                      ? Column(
                          children: [
                            const SizedBox(height: 100),
                            Icon(Icons.add_box_outlined, size: 200, color: EerieBlack)
                          ]
                        )
                      : Column(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: LayoutBuilder(
                                builder: (context, constraints) {
                                  return ConstrainedBox(
                                    constraints: const BoxConstraints(
                                      maxWidth: 400,
                                      maxHeight: 400,
                                      minHeight: 200,
                                      minWidth: 200,
                                    ),
                                    child: Image.file(File(_selectedFilePath!), fit: BoxFit.contain)
                                  );
                                },
                              ),
                            ),
                            Container(
                                width: 100,
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Flame,
                                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
                                ),
                                child: Center(
                                  child: Text(
                                    '$_imageFormat',
                                    style: TextStyle(
                                      color: FloralWhite,
                                      fontSize: 21,
                                      fontFamily: 'SF-ProText-Heavy',
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                            ),



                            const SizedBox(height: 20),
                            DropdownButtonFormField<String>(
                              value: _outputFormat,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Timberwolf,
                                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colors.grey.shade300),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colors.grey.shade300),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: EerieBlack, width: 2),
                                ),
                              ),
                              hint: Text(
                                "Selecciona un formato de salida",
                                style: TextStyle(fontSize: 16, color: Colors.grey.shade700, fontFamily: 'SF-ProText-Heavy', fontWeight: FontWeight.w600),
                              ),
                              icon: Icon(Icons.expand_circle_down_rounded, color: Colors.grey.shade700),
                              dropdownColor: Timberwolf,
                              items: _outputFormats.map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value, style: TextStyle(fontSize: 16, color: Colors.grey.shade700, fontFamily: 'SF-ProText-Heavy', fontWeight: FontWeight.w800)),
                                );
                              }).toList(),
                              onChanged: (String? value) {
                                setState(() {
                                  _outputFormat = value;
                                });
                              },
                            ),

                            if(_outputFormat == 'PNG') ...[

                              const SizedBox(height: 20),

                              Container(
                                width: double.infinity,
                                padding: EdgeInsets.all(16.0),
                                decoration: BoxDecoration(
                                  color: Timberwolf,
                                  borderRadius: BorderRadius.circular(20),
                                ),

                                child: Column(
                                  children: [

                                    Text(
                                      'Nivel de compresión',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontFamily: 'SF-ProText-Heavy',
                                        fontWeight: FontWeight.w800,
                                        color: Colors.grey.shade700,
                                      ),
                                    ),

                                    const SizedBox(height: 20),

                                    Slider(
                                      value: _pngLevel!,
                                      year2023: false,
                                      min: 0,
                                      max: 9,
                                      divisions: 9,
                                      label: _pngLevel?.toInt().toString(),
                                      onChanged: (double value) {
                                        setState(() {
                                          _pngLevel = value;
                                        });
                                      },
                                      activeColor: Flame,
                                      inactiveColor: BlackOlive,
                                      //thumbColor: Colors.transparent,
                                      overlayColor: MaterialStateProperty.resolveWith<Color?>(
                                            (Set<MaterialState> states) {
                                          if (states.contains(MaterialState.pressed)) {
                                            // Si está presionado, usa un color semitransparente
                                            return Colors.transparent;
                                          }
                                          return Colors.transparent; // Sin color cuando no está presionado
                                        },
                                      ),

                                    ),
                                  ],
                                )
                              ),
                            ],

                            if(_outputFormat == 'JPEG') ...[

                              const SizedBox(height: 20),

                              Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.all(16.0),
                                  decoration: BoxDecoration(
                                    color: Timberwolf,
                                    borderRadius: BorderRadius.circular(20),
                                  ),

                                  child: Column(
                                    children: [

                                      Text(
                                        'Calidad del JPEG',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontFamily: 'SF-ProText-Heavy',
                                          fontWeight: FontWeight.w800,
                                          color: Colors.grey.shade700,
                                        ),
                                      ),

                                      const SizedBox(height: 20),

                                      Slider(
                                        value: _jpgQuality!,
                                        year2023: false,
                                        min: 0,
                                        max: 100,
                                        divisions: 100,
                                        label: _jpgQuality?.toInt().toString(),
                                        onChanged: (double value) {
                                          setState(() {
                                            _jpgQuality = value;
                                          });
                                        },
                                        activeColor: Flame,
                                        inactiveColor: BlackOlive,
                                        //thumbColor: Colors.transparent,
                                        overlayColor: MaterialStateProperty.resolveWith<Color?>(
                                              (Set<MaterialState> states) {
                                            if (states.contains(MaterialState.pressed)) {
                                              // Si está presionado, usa un color semitransparente
                                              return Colors.transparent;
                                            }
                                            return Colors.transparent; // Sin color cuando no está presionado
                                          },
                                        ),

                                      ),
                                    ],
                                  )
                              ),
                            ],

                            if(_outputFormat == 'GIF') ...[

                              const SizedBox(height: 20),

                              Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.all(16.0),
                                  decoration: BoxDecoration(
                                    color: Timberwolf,
                                    borderRadius: BorderRadius.circular(20),
                                  ),

                                  child: Column(
                                    children: [

                                      Text(
                                        'Compresion del GIF',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontFamily: 'SF-ProText-Heavy',
                                          fontWeight: FontWeight.w800,
                                          color: Colors.grey.shade700,
                                        ),
                                      ),

                                      const SizedBox(height: 20),

                                      Slider(
                                        value: _gifQuality!,
                                        year2023: false,
                                        min: 0,
                                        max: 30,
                                        divisions: 30,
                                        label: _gifQuality?.toInt().toString(),
                                        onChanged: (double value) {
                                          setState(() {
                                            _gifQuality = value;
                                          });
                                        },
                                        activeColor: Flame,
                                        inactiveColor: BlackOlive,
                                        //thumbColor: Colors.transparent,
                                        overlayColor: MaterialStateProperty.resolveWith<Color?>(
                                              (Set<MaterialState> states) {
                                            if (states.contains(MaterialState.pressed)) {
                                              // Si está presionado, usa un color semitransparente
                                              return Colors.transparent;
                                            }
                                            return Colors.transparent; // Sin color cuando no está presionado
                                          },
                                        ),

                                      ),
                                    ],
                                  )
                              ),
                            ],

                            if(_outputFormat == 'WEBP') ...[

                              const SizedBox(height: 20),

                              Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.all(16.0),
                                  decoration: BoxDecoration(
                                    color: Timberwolf,
                                    borderRadius: BorderRadius.circular(20),
                                  ),

                                  child: Column(
                                    children: [

                                      Text(
                                        'Calidad del WEBP',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontFamily: 'SF-ProText-Heavy',
                                          fontWeight: FontWeight.w800,
                                          color: Colors.grey.shade700,
                                        ),
                                      ),

                                      const SizedBox(height: 20),

                                      Slider(
                                        value: _webpQuality!,
                                        year2023: false,
                                        min: 0,
                                        max: 100,
                                        divisions: 100,
                                        label: _webpQuality?.toInt().toString(),
                                        onChanged: (double value) {
                                          setState(() {
                                            _webpQuality = value;
                                          });
                                        },
                                        activeColor: Flame,
                                        inactiveColor: BlackOlive,
                                        //thumbColor: Colors.transparent,
                                        overlayColor: MaterialStateProperty.resolveWith<Color?>(
                                              (Set<MaterialState> states) {
                                            if (states.contains(MaterialState.pressed)) {
                                              // Si está presionado, usa un color semitransparente
                                              return Colors.transparent;
                                            }
                                            return Colors.transparent; // Sin color cuando no está presionado
                                          },
                                        ),

                                      ),
                                    ],
                                  )
                              ),
                            ],


                            if(_exifData.isNotEmpty) ...[

                              const SizedBox(height: 20),

                              Card(
                                elevation: 4,
                                color: Timberwolf,
                                child: ExpansionTile(
                                  title: Text(
                                    'Metadatos',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontFamily: 'SF-ProText-Heavy',
                                      fontWeight: FontWeight.w800,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                  children: _exifData.entries.map<Widget>((entry) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(entry.key, style: TextStyle(fontSize: 16, color: Colors.grey.shade700, fontFamily: 'SF-ProText-Heavy', fontWeight: FontWeight.w800)),
                                          SizedBox(
                                            width: 150,
                                            child: TextFormField(
                                              initialValue: entry.value.toString(),
                                              decoration: InputDecoration(
                                                border: OutlineInputBorder(),
                                                contentPadding: EdgeInsets.symmetric(horizontal: 8),
                                              ),
                                              onChanged: (newValue) {
                                                setState(() {
                                                  _exifData[entry.key] = newValue;
                                                });
                                              },
                                            ),

                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ),
                              )
                            ],




                            const SizedBox(height: 20),

                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(16.0),
                              decoration: BoxDecoration(
                                color: Timberwolf,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Column(
                                children: [

                                  Text(
                                    'Resolución',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontFamily: 'SF-ProText-Heavy',
                                        fontWeight: FontWeight.w800,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),

                                  const SizedBox(height: 10),

                                  Row(
                                    children: [
                                      Expanded(
                                        child: Container(
                                          padding: EdgeInsets.all(16.0),
                                          decoration: BoxDecoration(
                                            color: FloralWhite,
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Row(
                                            children: [
                                              Text(
                                                'Alto',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontFamily: 'SF-ProText-Heavy',
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.grey.shade700,
                                                ),
                                              ),
                                              SizedBox(width: 16), // Add some spacing between the text and the text field
                                              Expanded(
                                                child: TextField(
                                                  keyboardType: TextInputType.number,
                                                  decoration: InputDecoration(
                                                    hintText: '${_altoOriginal.toString()}',
                                                  ),
                                                  onChanged: (value) {
                                                  setState(() {
                                                    _altoModificado = int.tryParse(value);
                                                  });
                                                },
                                                ),
                                              ),
                                            ],
                                          )
                                        ),
                                      ),
                                      SizedBox(width: 20),
                                      Expanded(
                                        child: Container(
                                          padding: EdgeInsets.all(16.0),
                                          decoration: BoxDecoration(
                                            color: FloralWhite,
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Row(
                                            children: [
                                              Text(
                                                'Ancho',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontFamily: 'SF-ProText-Heavy',
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.grey.shade700,
                                                ),
                                              ),
                                              SizedBox(width: 16), // Add some spacing between the text and the text field
                                              Expanded(
                                                child: TextField(
                                                  keyboardType: TextInputType.number,
                                                  decoration: InputDecoration(
                                                    hintText: '${_anchoOriginal.toString()}',
                                                  ),
                                                onChanged: (value) {
                                                  setState(() {
                                                  _anchoModificado = int.tryParse(value);
                                                  });
                                                },
                                                ),
                                              ),
                                            ],
                                          )
                                        ),
                                      ),
                                    ],
                                  ),

                                ],
                              ),
                            ),

                            SizedBox(height: 20),


                            ElevatedButton(
                              onPressed: (_selectedFilePath != null && _outputFormat != null)
                                  ? () {
                                    convertImage(_selectedFilePath!);
                                    }
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Flame,
                                disabledBackgroundColor: Colors.grey.shade400,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 30),
                                elevation: 2,
                              ),
                              child: const Text(
                                'CONVERTIR',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white, // Texto en blanco para buen contraste
                                  fontFamily: 'SF-ProText-Heavy', // Mismo estilo que otros textos
                                ),
                              ),
                            ),







                            if(_convertedImagePath != null) ...[
                              const SizedBox(height: 20),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: LayoutBuilder(
                                  builder: (context, constraints) {
                                    return ConstrainedBox(
                                      constraints: const BoxConstraints(
                                        maxWidth: 400,
                                        maxHeight: 400,
                                        minHeight: 200,
                                        minWidth: 200,
                                      ),
                                      child: Image.file(File(_convertedImagePath!), fit: BoxFit.contain)
                                    );
                                  },
                                ),
                              ),

                              Container(
                                width: 100,
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Flame,
                                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
                                ),
                                child: Center(
                                  child: Text(
                                    '$_outputFormat',
                                    style: TextStyle(
                                      color: FloralWhite,
                                      fontSize: 21,
                                      fontFamily: 'SF-ProText-Heavy',
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 20),

                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12), // Esquinas redondeadas
                                  border: Border.all(color: Colors.blue, width: 2), // Borde azul
                                ),
                                child: TextField(
                                  decoration: InputDecoration(
                                    hintText: 'Nombre del archivo (opcional)', // Texto de sugerencia cuando está vacío
                                    border: InputBorder.none,  // Elimina el borde predeterminado
                                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12), // Padding dentro del campo
                                  ),
                                  onChanged: (value) {
                                    setState(() {
                                      _filename = value;  // Guardar el texto en la variable
                                    });
                                  },
                                ),
                              ),

                              const SizedBox(height: 20),

                              ElevatedButton(
                                  onPressed: saveImageToGallery,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: BlackOlive,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 30),
                                  elevation: 2,
                                ),
                                child: const Text(
                                  'DESCARGAR',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white, // Texto en blanco para buen contraste
                                    fontFamily: 'SF-ProText-Heavy', // Mismo estilo que otros textos
                                  ),
                                ),
                              ),
                            ],
                            const SizedBox(height: 200),








                          ],
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

}