import 'package:flutter/material.dart';
import 'CloudConvertService.dart';
import 'package:open_file/open_file.dart';

class DrawerWidget extends StatefulWidget {

  final List<CloudConvertService> elementos;

  DrawerWidget({Key? key, required this.elementos}) : super(key: key);

  @override
  _DrawerWidgetState createState() => _DrawerWidgetState();
}

class _DrawerWidgetState extends State<DrawerWidget> {

  static const Color FloralWhite = Color(0xFFFFFCF2);
  static const Color Timberwolf = Color(0xFFCCC5B9);
  static const Color BlackOlive = Color(0xFF403D39);
  static const Color EerieBlack = Color(0xFF252422);
  static const Color Flame = Color(0xFFEB5E28);

  Widget _getStatusIcon(String status) {
    print('SE HA RECIBIDO EL STATUS: $status');
    switch (status) {
      case 'estado.pending':
        return Icon(Icons.access_time_filled_rounded, color: Flame);
      case 'estado.uploading':
        return Icon(Icons.cloud_upload, color: Flame);
      case 'estado.converting':
        return Icon(Icons.hourglass_bottom_rounded, color: Flame);
      case 'estado.downloading':
        return Icon(Icons.download_rounded, color: Flame);
      case 'estado.finished':
        return Icon(Icons.done_outline_rounded, color: Flame);
      case 'estado.error':
        return Icon(Icons.error_rounded, color: Flame);
      default:
        return Icon(Icons.help_outline, color: Flame);
    }
  }

  void _abrirArchivo(String? path) async {
    final result = await OpenFile.open(path);
    print('Resultado al abrir el archivo: ${result.message}');
    print('Ruta del archivo: $path');
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: FloralWhite,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Flame),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Text(
                  'Conversiones',
                  style: TextStyle(
                    color: FloralWhite,
                    fontSize: 120,
                    fontFamily: 'Outward',
                  ),
                ),
              ),
            ),
            ...widget.elementos.reversed.map((elemento) {
              bool isFinished = elemento.getStatus() == 'estado.finished';

              return Container(
                margin: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: isFinished
                          ? () {
                        print("Abriendo archivo: ${elemento.getFilePath()}");
                        _abrirArchivo(elemento.getFilePath());
                      }
                          : null,
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Text(
                                  elemento.getName(),
                                  style: TextStyle(fontSize: 15, fontFamily: 'SF-ProText-Semibold', fontWeight: FontWeight.w600, color: EerieBlack),
                                ),

                              ),
                            ),
                            _getStatusIcon(elemento.getStatus()),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );


            }),
          ],
        ),
      ),
    );

  }
}