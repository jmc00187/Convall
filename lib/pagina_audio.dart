import 'package:flutter/material.dart';

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


                  const Text(
                    'Pagina de conversion de audio',
                    style: TextStyle(
                        fontSize: 24,
                        color: EerieBlack
                    ),
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
