import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:video_player/video_player.dart';
import 'dart:typed_data';

class paginaVideo extends StatefulWidget {
  const paginaVideo({super.key});

  @override
  State<paginaVideo> createState() => _paginaVideoState();
}

class _paginaVideoState extends State<paginaVideo> {

  static const Color FloralWhite = Color(0xFFFFFCF2);
  static const Color Timberwolf = Color(0xFFCCC5B9);
  static const Color BlackOlive = Color(0xFF403D39);
  static const Color EerieBlack = Color(0xFF252422);
  static const Color Flame = Color(0xFFEB5E28);


  String? _selectedFilePath;
  String? _videoFormat;
  VideoPlayerController? _videoController;


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
          });
        });
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
      'mpeg-2': [0x00, 0x00, 0x01, 0xBA],
      'mpeg-1': [0x00, 0x00, 0x01, 0xB3],
      'wmv': [0x30, 0x26, 0xB2, 0x75, 0x8E, 0x66, 0xCF, 0x11],
      '3gp': [0x66, 0x74, 0x79, 0x70, 0x33, 0x67],
      'rm': [0x2E, 0x52, 0x4D, 0x46],
      'ogg': [0x4F, 0x67, 0x67, 0x53],
      'asf': [0x30, 0x26, 0xB2, 0x75, 0x8E, 0x66, 0xCF, 0x11],
      'ts': [0x47, 0x40, 0x00, 0x00],
      'vob': [0x00, 0x00, 0x01, 0xBD],
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
