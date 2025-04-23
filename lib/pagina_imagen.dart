import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:image/image.dart' as img;
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'CloudConvertService.dart';
import 'drawer_widget.dart';

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

  List<CloudConvertService> elementos = [];


  File? _imageFile;
  String? _selectedFilePath;
  String? _imageFormat;
  int? _altoOriginal;
  int? _anchoOriginal;
  String? _outputFormat;
  int? _outputWidth;
  int? _outputHeight;
  double? _outputQuality = 50;
  String? _outputEngine;




  List<String> _outputFormats = ['JPG', 'PNG', 'GIF', 'BMP', 'WEBP'];
  List<String> _outputEngines = ['imagemagick', 'graphicsmagick'];

  bool isReadyToDownload()
  {
    if(_outputFormat == null)
    {
      return false;
    }
    else
    {
      return true;
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      _imageFile = File(image.path);
      List<int> inputBytes = (await _imageFile?.readAsBytes()) as List<int>;
      Uint8List uint8List = Uint8List.fromList(inputBytes);
      img.Image? imageData = img.decodeImage(Uint8List.fromList(inputBytes));
      _altoOriginal = imageData!.height;
      _anchoOriginal = imageData!.width;


      List<int>? headerBytes = await _imageFile?.openRead(0, 12).first;
      _imageFormat = _identifyImageFormat(headerBytes!);


      setState(() {
        _selectedFilePath = image.path;
      });


    }
  }

  String _identifyImageFormat(List<int> bytes) {
    if (bytes.length < 12) return "Desconocido";

    // Identificación de formatos
    if (bytes[0] == 0xFF && bytes[1] == 0xD8 && bytes[2] == 0xFF) {
      return "JPG";
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

  void _convertImage()
  {
    if(_imageFile != null)
    {
      _outputEngine ??= 'imagemagick';
      CloudConvertService ccs1 = CloudConvertService();
      ccs1.fileUpload(context, _imageFile!, _imageFormat!,
        outputformat: _outputFormat,
        width: _outputWidth,
        height: _outputHeight,
        imageQuality: _outputQuality?.toInt(),
        imageEngine: _outputEngine
      );

      setState(() {
        elementos.add(ccs1);
      });

    }
    else
    {
      print('No se ha seleccionado un archivo de video');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FloralWhite,

      drawer: DrawerWidget(elementos: elementos),

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
        leading: Builder(
          builder: (context) => Align(
            alignment: Alignment(1.6, -0.3),
            child: SizedBox(
              width: 40,
              height: 40,
              child: Material(
                color: Flame,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => Scaffold.of(context).openDrawer(),
                  child: Center(
                    child: Icon(
                      Icons.archive_rounded,
                      color: FloralWhite,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
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
                              selectedItemBuilder: (BuildContext context) {
                                return _outputFormats.map((String value) {
                                  return Text(
                                    'Formato de salida seleccionado: ${value.toUpperCase()}',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey.shade700,
                                      fontFamily: 'SF-ProText-Heavy',
                                      fontWeight: FontWeight.w600,
                                    ),
                                  );
                                }).toList();
                              },
                              onChanged: (String? value) {
                                setState(() {
                                  _outputFormat = value;
                                });
                              },
                            ),



                            const SizedBox(height: 20),
                            DropdownButtonFormField<String>(
                              value: _outputEngine,
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
                                "Selecciona un motor de procesamiento",
                                style: TextStyle(fontSize: 16, color: Colors.grey.shade700, fontFamily: 'SF-ProText-Heavy', fontWeight: FontWeight.w600),
                              ),
                              icon: Icon(Icons.expand_circle_down_rounded, color: Colors.grey.shade700),
                              dropdownColor: Timberwolf,
                              items: _outputEngines.map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value, style: TextStyle(fontSize: 16, color: Colors.grey.shade700, fontFamily: 'SF-ProText-Heavy', fontWeight: FontWeight.w800)),
                                );
                              }).toList(),
                              selectedItemBuilder: (BuildContext context) {
                                return _outputEngines.map((String value) {
                                  return Text(
                                    'Engine seleccionado: ${value.toUpperCase()}',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey.shade700,
                                      fontFamily: 'SF-ProText-Heavy',
                                      fontWeight: FontWeight.w600,
                                    ),
                                  );
                                }).toList();
                              },
                              onChanged: (String? value) {
                                setState(() {
                                  _outputEngine = value;
                                });
                              },
                            ),




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
                                                        _outputWidth = int.tryParse(value);
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
                                                        _outputHeight = int.tryParse(value);
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
                                      value: _outputQuality!,
                                      year2023: false,
                                      min: 0,
                                      max: 99,
                                      divisions: 100,
                                      label: _outputQuality?.toInt().toString(),
                                      onChanged: (double value) {
                                        setState(() {
                                          _outputQuality = value;
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


                            if(_outputFormat == 'JPG') ...[

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
                                        'Calidad de imagen',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontFamily: 'SF-ProText-Heavy',
                                          fontWeight: FontWeight.w800,
                                          color: Colors.grey.shade700,
                                        ),
                                      ),

                                      const SizedBox(height: 20),

                                      Slider(
                                        value: _outputQuality!,
                                        year2023: false,
                                        min: 1,
                                        max: 100,
                                        divisions: 100,
                                        label: _outputQuality?.toInt().toString(),
                                        onChanged: (double value) {
                                          setState(() {
                                            _outputQuality = value;
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
                                        value: _outputQuality!,
                                        year2023: false,
                                        min: 0,
                                        max: 100,
                                        divisions: 100,
                                        label: _outputQuality?.toInt().toString(),
                                        onChanged: (double value) {
                                          setState(() {
                                            _outputQuality = value;
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



                            const SizedBox(height: 20),



                            ElevatedButton(
                              onPressed: isReadyToDownload() ? _convertImage : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isReadyToDownload() ? BlackOlive : BlackOlive.withOpacity(0.5),
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