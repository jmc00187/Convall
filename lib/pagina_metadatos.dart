import 'package:flutter/material.dart';

class paginaMetadatos extends StatefulWidget {
  const paginaMetadatos({super.key});

  @override
  State<paginaMetadatos> createState() => _paginaMetadatosState();
}

class _paginaMetadatosState extends State<paginaMetadatos> {

  static const Color FloralWhite = Color(0xFFFFFCF2);
  static const Color Timberwolf = Color(0xFFCCC5B9);
  static const Color BlackOlive = Color(0xFF403D39);
  static const Color EerieBlack = Color(0xFF252422);
  static const Color Flame = Color(0xFFEB5E28);

  @override
  Widget build(BuildContext context) {
    return Scaffold(



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
        ),


        body: const SafeArea(
            child: Center(
              child: Text(
                'Pagina de metadatos',
                style: TextStyle(
                    fontSize: 24,
                    color: EerieBlack
                ),
              ),
            )
        )










    );
  }
}
