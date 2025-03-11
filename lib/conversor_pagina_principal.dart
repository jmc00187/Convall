import 'package:convall/pagina_audio.dart';
import 'package:convall/pagina_imagen.dart';
import 'package:convall/pagina_video.dart';
import 'package:convall/pagina_carpetas.dart';
import 'package:flutter/material.dart';
import 'dart:ui';


class ConversorPaginaPrincipal extends StatefulWidget {
  const ConversorPaginaPrincipal({super.key});

  @override
  State<ConversorPaginaPrincipal> createState() => _ConversorPaginaPrincipalState();
}

class _ConversorPaginaPrincipalState extends State<ConversorPaginaPrincipal> {

  static const Color FloralWhite = Color(0xFFFFFCF2);
  static const Color Timberwolf = Color(0xFFCCC5B9);
  static const Color BlackOlive = Color(0xFF403D39);
  static const Color EerieBlack = Color(0xFF252422);
  static const Color Flame = Color(0xFFEB5E28);


  int _selectedIndex = 0; //Pagina seleccionada

  final List<Widget> _pages  = [
    paginaVideo(),
    paginaImagen(),
    paginaAudio(),
    paginaCarpetas()
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; //Cambia la pagina seleccionada
    });
  }



  @override
  Widget build(BuildContext context) {

    return Scaffold(
      extendBody: true,


      body: Stack(
        children: [

          _pages[_selectedIndex],

          Align(
            alignment: Alignment.bottomCenter,
            child: ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: BottomNavigationBar(
                    type: BottomNavigationBarType.fixed,
                    backgroundColor: Timberwolf.withOpacity(0.7),
                    selectedIconTheme: IconThemeData(
                        color: EerieBlack,
                        opacity: 1,
                        size: 35
                    ),
                    unselectedIconTheme: IconThemeData(
                        color: BlackOlive,
                        opacity: 0.5,
                      size: 30
                    ),
                    selectedLabelStyle: TextStyle(
                        color: EerieBlack,
                        fontFamily: 'SF-ProText-Heavy',
                        fontWeight: FontWeight.w900,
                        fontSize: 12
                    ),
                    unselectedLabelStyle: TextStyle(
                        color: BlackOlive,
                        fontFamily: 'SF-ProText-Semibold',
                        fontWeight: FontWeight.w800,
                        fontSize: 12
                    ),
                    currentIndex: _selectedIndex,
                    onTap: _onItemTapped,
                    items: const [
                      BottomNavigationBarItem(icon: Icon(Icons.video_camera_back_rounded), label: 'Video'),
                      BottomNavigationBarItem(icon: Icon(Icons.image), label: 'Imagen'),
                      BottomNavigationBarItem(icon: Icon(Icons.audiotrack_rounded), label: 'Audio'),
                      BottomNavigationBarItem(icon: Icon(Icons.folder_copy), label: 'Carpetas'),
                    ]
                ),
              ),
            ),
          ),






        ],
      )




      /*bottomNavigationBar: ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20)
        ),


        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Timberwolf.withOpacity(0.4),
          selectedIconTheme: IconThemeData(
              color: EerieBlack,
              opacity: 1,
              size: 28
          ),
          unselectedIconTheme: IconThemeData(
              color: BlackOlive,
              opacity: 0.5
          ),
          selectedLabelStyle: TextStyle(
            color: EerieBlack,
            fontFamily: 'SF-ProText-Heavy',
            fontWeight: FontWeight.w900,
            fontSize: 12
          ),
          unselectedLabelStyle: TextStyle(
            color: BlackOlive,
            fontFamily: 'SF-ProText-Semibold',
            fontWeight: FontWeight.w800,
            fontSize: 12
          ),
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.video_camera_back_rounded), label: 'Video'),
            BottomNavigationBarItem(icon: Icon(Icons.image), label: 'Imagen'),
            BottomNavigationBarItem(icon: Icon(Icons.audiotrack_rounded), label: 'Audio'),
            BottomNavigationBarItem(icon: Icon(Icons.folder_copy), label: 'Carpetas'),
          ]
        ),
      ),*/
















    );
  }



  // 16

}

























