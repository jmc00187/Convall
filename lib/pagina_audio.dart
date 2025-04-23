import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'CloudConvertService.dart';
import 'drawer_widget.dart';

class paginaAudio extends StatefulWidget {
  const paginaAudio({super.key});

  @override
  State<paginaAudio> createState() => _paginaAudioState();
}

class _paginaAudioState extends State<paginaAudio> {

  static const Color FloralWhite = Color(0xFFFFFCF2);
  static const Color Timberwolf = Color(0xFFCCC5B9);
  static const Color BlackOlive = Color(0xFF403D39);
  static const Color EerieBlack = Color(0xFF252422);
  static const Color Flame = Color(0xFFEB5E28);

  late AudioPlayer _player;
  bool _showVolumeSlider = false;
  double _volume = 1.0;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  String? _selectedFilePath;
  String? _audioFormat;

  List<CloudConvertService> elementos = [];

  @override
  void dispose() {
    _player?.dispose();
    super.dispose();
  }

  Future<void> _pickAudio() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.audio);

    if (result != null && result.files.single.path != null) {
      _selectedFilePath = result.files.single.path;
      _audioFormat = _getAudioFormat(_selectedFilePath!);
      _player = AudioPlayer();
      await _player!.setFilePath(_selectedFilePath!);
      setState(() {
        _selectedFilePath = result.files.single.path;
        _audioFormat = _getAudioFormat(_selectedFilePath!);
      });


      _player.durationStream.listen((d) {
        if (d != null) {
          setState(() {
            _duration = d;
          });
        }
      });

      _player.positionStream.listen((p) {
        setState(() {
          _position = p;
        });
      });

    }
  }

  String _getAudioFormat(String path) {
    final extension = path.split('.').last;
    return extension.toUpperCase();
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
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
                  onTap: _pickAudio,
                  child: _selectedFilePath == null
                      ? Column(
                      children: [
                        const SizedBox(height: 100),
                        Icon(Icons.add_box_outlined, size: 200, color: EerieBlack)
                      ]
                    )
                      : Column(
                        children: [


                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Timberwolf,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: const [
                                BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 3)),
                              ],
                            ),
                            child: Row(
                              children: [
                                StreamBuilder<PlayerState>(
                                  stream: _player!.playerStateStream,
                                  builder: (context, snapshot) {
                                    final isPlaying = snapshot.data?.playing ?? false;
                                    return IconButton(
                                      icon: Icon(isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded, size: 40, color: EerieBlack),
                                      onPressed: () => isPlaying ? _player!.pause() : _player!.play(),
                                    );
                                  },
                                ),
                                Expanded(
                                  child: StreamBuilder<Duration>(
                                    stream: _player!.positionStream,
                                    builder: (context, snapshot) {
                                      final position = snapshot.data ?? Duration.zero;
                                      return StreamBuilder<Duration?>(
                                        stream: _player!.durationStream,
                                        builder: (context, snapshot) {
                                          final duration = snapshot.data ?? Duration.zero;

                                          return SliderTheme(
                                            data: SliderTheme.of(context).copyWith(
                                              thumbColor: Flame, // Círculo rojo
                                              activeTrackColor: BlackOlive, // Línea activa
                                              inactiveTrackColor: Colors.grey[300], // Línea inactiva
                                              overlayColor: Colors.red.withAlpha(32),
                                              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 13),
                                              trackHeight: 4,
                                            ),
                                            child: Slider(
                                              min: 0,
                                              max: _duration.inMilliseconds.toDouble(),
                                              value: _position.inMilliseconds.clamp(0, _duration.inMilliseconds).toDouble(),
                                              onChanged: (value) async {
                                                final newPosition = Duration(milliseconds: value.round());
                                                await _player?.seek(newPosition);
                                              },
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  ),
                                ),
                                SizedBox(
                                  width: 120,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                                    decoration: BoxDecoration(
                                      color: FloralWhite,
                                      borderRadius: BorderRadius.circular(8),
                                      boxShadow: const [
                                        BoxShadow(
                                          blurRadius: 4,
                                          color: Colors.black26,
                                          offset: Offset(0, 2),
                                        )
                                      ],
                                    ),
                                    child: Text(
                                      "${_formatDuration(_position)} / ${_formatDuration(_duration)}",
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontFamily: 'SF-ProText-Semibold',
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
