import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:video_player/video_player.dart';
import 'dart:typed_data';
import 'CloudConvertService.dart';
import 'package:hive_flutter/hive_flutter.dart';

class paginaVideo extends StatefulWidget {
  const paginaVideo({super.key});

  @override
  State<paginaVideo> createState() => _paginaVideoState();
}

class _paginaVideoState extends State<paginaVideo> {

  late Box<CloudConvertService> cloudConvertBox;

  @override
  void initState() {
    super.initState();
    _initHive(); // Inicializamos Hive en initState
  }

  static const Color FloralWhite = Color(0xFFFFFCF2);
  static const Color Timberwolf = Color(0xFFCCC5B9);
  static const Color BlackOlive = Color(0xFF403D39);
  static const Color EerieBlack = Color(0xFF252422);
  static const Color Flame = Color(0xFFEB5E28);


  File? _videoFile;
  String? _selectedFilePath;
  String? _videoFormat;
  int? _altoOriginal;
  int? _anchoOriginal;
  VideoPlayerController? _videoController;
  String? _outputFormat;
  String? _outputCodec;
  double? _crf = 23;
  int? _outputHeight;
  int? _outputWidth;
  String? _outputAudioCodec;



  List<String> _outputFormats = ['mp4', 'avi', 'webm', 'mkv', 'flv'];

  List<String> _mp4Codecs = ['copy', 'x264', 'x265', 'av1'];
  List<String> _aviCodecs = ['copy', 'x264', 'x265', 'xvid'];
  List<String> _webmCodecs = ['copy', 'vp8', 'vp9', 'av1'];
  List<String> _mkvCodecs = ['copy', 'x264', 'x265', 'vp8', 'vp9', 'av1'];
  List<String> _flvCodecs = ['copy', 'h264', 'sorenson'];

  List<String> _audioCodecs = ['copy', 'none', 'aac', 'aac_he_1', 'aac_he_2', 'opus', 'vorbis'];
  List<String> _webmAudioCodecs = ['copy', 'none', 'opus', 'vorbis'];



  // Inicializar Hive y abrir el Box
  Future<void> _initHive() async {
    await Hive.initFlutter();
    Hive.registerAdapter(CloudConvertServiceAdapter());
    cloudConvertBox = await Hive.openBox<CloudConvertService>('cloudConvertServices');
    setState(() {});
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.video);
    if (result != null) {
      String filePath = result.files.single.path!;
      _videoFormat = await _identifyVideoFormat(filePath);
      print(filePath);

      _videoController?.dispose();
      _videoController = VideoPlayerController.file(File(filePath))
        ..initialize().then((_) {
          setState(() {
            _selectedFilePath = filePath;
            _videoFile = File(filePath);
            _altoOriginal = _videoController!.value.size.height.toInt();
            _anchoOriginal = _videoController!.value.size.width.toInt();
          });
        });
    }

  }

  void _convertVideo()
  {
    if(_videoFile != null)
    {
      CloudConvertService ccs1 = CloudConvertService();
      ccs1.fileUpload(context, _videoFile!,
        outputformat: _outputFormat!,
        videoCodec: _outputCodec!,
        crf: _crf!.toInt(),
        width: _outputWidth,
        height: _outputHeight,
        audioCodec: _outputAudioCodec!
      );

      cloudConvertBox.add(ccs1);
      setState(() {});

    }
    else
    {
      print('No se ha seleccionado un archivo de video');
    }
  }

  Future<String> _identifyVideoFormat(String filepath) async {
    final file = File(filepath);
    final bytes = await file.readAsBytes();

    const Map<String, List<int>> firmasDeVideo = {
      'mp4': [0x00, 0x00, 0x00, 0x18, 0x66, 0x74, 0x79, 0x70],
      'avi': [0x52, 0x49, 0x46, 0x46],
      'webm/mkv': [0x1A, 0x45, 0xDF, 0xA3],
      'flv': [0x46, 0x4C, 0x56, 0x01],
    };

    for (var formato in firmasDeVideo.keys) {
      final firma = firmasDeVideo[formato];

      if (_empiezaCon(bytes, firma!)) {
        return formato;
      }
    }

    return 'Formato desconocido';
  }

  bool _empiezaCon(Uint8List bytes, List<int> firma) {
    if (bytes.length < firma.length) return false;
    for (int i = 0; i < firma.length; i++) {
      if (bytes[i] != firma[i]) return false;
    }
    return true;
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
                  onTap: () {
                    if (_videoController != null && _videoController!.value.isInitialized) {
                      setState(() {
                        _videoController!.value.isPlaying
                            ? _videoController!.pause()
                            : _videoController!.play();
                      });
                    } else {
                      _pickFile();
                    }
                  },
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
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    AspectRatio(
                                      aspectRatio: _videoController!.value.aspectRatio,
                                      child: VideoPlayer(_videoController!),
                                    ),
                                    if(!_videoController!.value.isPlaying)
                                      Icon(Icons.play_circle_fill, size: 50, color: Colors.white),
                                  ],
                                ),
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
                            '$_videoFormat'.toUpperCase(),
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




                      if(_selectedFilePath != null) ...[

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



                        const SizedBox(height: 20),

                        if(_outputFormat == 'mp4') ...[
                          DropdownButtonFormField<String>(
                            value: _outputCodec,
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
                              "Selecciona un codec",
                              style: TextStyle(fontSize: 16, color: Colors.grey.shade700, fontFamily: 'SF-ProText-Heavy', fontWeight: FontWeight.w600),
                            ),
                            icon: Icon(Icons.expand_circle_down_rounded, color: Colors.grey.shade700),
                            dropdownColor: Timberwolf,
                            items: _mp4Codecs.map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value, style: TextStyle(fontSize: 16, color: Colors.grey.shade700, fontFamily: 'SF-ProText-Heavy', fontWeight: FontWeight.w800)),
                              );
                            }).toList(),
                            onChanged: (String? value) {
                              setState(() {
                                _outputCodec = value;
                              });
                            },
                          ),
                          const SizedBox(height: 20),
                        ],

                        if(_outputFormat == 'avi') ...[
                          DropdownButtonFormField<String>(
                            value: _outputCodec,
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
                              "Selecciona un codec",
                              style: TextStyle(fontSize: 16, color: Colors.grey.shade700, fontFamily: 'SF-ProText-Heavy', fontWeight: FontWeight.w600),
                            ),
                            icon: Icon(Icons.expand_circle_down_rounded, color: Colors.grey.shade700),
                            dropdownColor: Timberwolf,
                            items: _aviCodecs.map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value, style: TextStyle(fontSize: 16, color: Colors.grey.shade700, fontFamily: 'SF-ProText-Heavy', fontWeight: FontWeight.w800)),
                              );
                            }).toList(),
                            onChanged: (String? value) {
                              setState(() {
                                _outputCodec = value;
                              });
                            },
                          ),
                          const SizedBox(height: 20),
                        ],

                        if(_outputFormat == 'webm') ...[
                          DropdownButtonFormField<String>(
                            value: _outputCodec,
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
                              "Selecciona un codec",
                              style: TextStyle(fontSize: 16, color: Colors.grey.shade700, fontFamily: 'SF-ProText-Heavy', fontWeight: FontWeight.w600),
                            ),
                            icon: Icon(Icons.expand_circle_down_rounded, color: Colors.grey.shade700),
                            dropdownColor: Timberwolf,
                            items: _webmCodecs.map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value, style: TextStyle(fontSize: 16, color: Colors.grey.shade700, fontFamily: 'SF-ProText-Heavy', fontWeight: FontWeight.w800)),
                              );
                            }).toList(),
                            onChanged: (String? value) {
                              setState(() {
                                _outputCodec = value;
                              });
                            },
                          ),
                          const SizedBox(height: 20),
                        ],


                        if(_outputFormat == 'mkv') ...[
                          DropdownButtonFormField<String>(
                            value: _outputCodec,
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
                              "Selecciona un codec",
                              style: TextStyle(fontSize: 16, color: Colors.grey.shade700, fontFamily: 'SF-ProText-Heavy', fontWeight: FontWeight.w600),
                            ),
                            icon: Icon(Icons.expand_circle_down_rounded, color: Colors.grey.shade700),
                            dropdownColor: Timberwolf,
                            items: _mkvCodecs.map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value, style: TextStyle(fontSize: 16, color: Colors.grey.shade700, fontFamily: 'SF-ProText-Heavy', fontWeight: FontWeight.w800)),
                              );
                            }).toList(),
                            onChanged: (String? value) {
                              setState(() {
                                _outputCodec = value;
                              });
                            },
                          ),
                          const SizedBox(height: 20),
                        ],

                        if(_outputFormat == 'flv') ...[
                          DropdownButtonFormField<String>(
                            value: _outputCodec,
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
                              "Selecciona un codec",
                              style: TextStyle(fontSize: 16, color: Colors.grey.shade700, fontFamily: 'SF-ProText-Heavy', fontWeight: FontWeight.w600),
                            ),
                            icon: Icon(Icons.expand_circle_down_rounded, color: Colors.grey.shade700),
                            dropdownColor: Timberwolf,
                            items: _flvCodecs.map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value, style: TextStyle(fontSize: 16, color: Colors.grey.shade700, fontFamily: 'SF-ProText-Heavy', fontWeight: FontWeight.w800)),
                              );
                            }).toList(),
                            onChanged: (String? value) {
                              setState(() {
                                _outputCodec = value;
                              });
                            },
                          ),
                          const SizedBox(height: 20),
                        ],


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
                                  'CRF - Compresión del video',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontFamily: 'SF-ProText-Heavy',
                                    fontWeight: FontWeight.w800,
                                    color: Colors.grey.shade700,
                                  ),
                                ),

                                const SizedBox(height: 20),

                                Slider(
                                  value: _crf!,
                                  year2023: false,
                                  min: 0,
                                  max: 51,
                                  divisions: 51,
                                  label: _crf?.toInt().toString(),
                                  onChanged: (double value) {
                                    setState(() {
                                      _crf = value;
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


                        if(_outputFormat == 'webm') ...[

                          const SizedBox(height: 20),

                          DropdownButtonFormField<String>(
                            value: _outputAudioCodec,
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
                              "Selecciona un Codec de audio",
                              style: TextStyle(fontSize: 16, color: Colors.grey.shade700, fontFamily: 'SF-ProText-Heavy', fontWeight: FontWeight.w600),
                            ),
                            icon: Icon(Icons.expand_circle_down_rounded, color: Colors.grey.shade700),
                            dropdownColor: Timberwolf,
                            items: _webmAudioCodecs.map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value, style: TextStyle(fontSize: 16, color: Colors.grey.shade700, fontFamily: 'SF-ProText-Heavy', fontWeight: FontWeight.w800)),
                              );
                            }).toList(),
                            onChanged: (String? value) {
                              setState(() {
                                _outputAudioCodec = value;
                              });
                            },
                          ),


                        ],

                        if(_outputFormat != 'webm') ...[

                          const SizedBox(height: 20),


                          DropdownButtonFormField<String>(
                            value: _outputAudioCodec,
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
                              "Selecciona un Codec de audio",
                              style: TextStyle(fontSize: 16, color: Colors.grey.shade700, fontFamily: 'SF-ProText-Heavy', fontWeight: FontWeight.w600),
                            ),
                            icon: Icon(Icons.expand_circle_down_rounded, color: Colors.grey.shade700),
                            dropdownColor: Timberwolf,
                            items: _audioCodecs.map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value, style: TextStyle(fontSize: 16, color: Colors.grey.shade700, fontFamily: 'SF-ProText-Heavy', fontWeight: FontWeight.w800)),
                              );
                            }).toList(),
                            onChanged: (String? value) {
                              setState(() {
                                _outputAudioCodec = value;
                              });
                            },
                          ),


                        ],








                      ],




                      const SizedBox(height: 20),

                      ElevatedButton(
                        onPressed: _convertVideo,
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

                      const SizedBox(height: 100),


































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
