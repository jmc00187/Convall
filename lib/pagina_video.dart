import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:video_player/video_player.dart';

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
  VideoPlayerController? _videoController;

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.video);
    if (result != null) {
      String filePath = result.files.single.path!;

      _videoController?.dispose();
      _videoController = VideoPlayerController.file(File(filePath))
        ..initialize().then((_) {
          setState(() {
            _selectedFilePath = filePath;
          });
        });
    }

    return;

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
          child: Container(
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
                      ? Icon(Icons.add_box_outlined, size: 100, color: EerieBlack)
                        :ClipRRect(
                          borderRadius: BorderRadius.circular(20),
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
                    )
                  ),
















                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
