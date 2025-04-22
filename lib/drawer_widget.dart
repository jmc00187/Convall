import 'package:flutter/material.dart';
import 'CloudConvertService.dart';
import 'package:hive_flutter/hive_flutter.dart';

class DrawerWidget extends StatefulWidget {

  @override
  _DrawerWidgetState createState() => _DrawerWidgetState();
}

class _DrawerWidgetState extends State<DrawerWidget> {

  static const Color FloralWhite = Color(0xFFFFFCF2);
  static const Color Timberwolf = Color(0xFFCCC5B9);
  static const Color BlackOlive = Color(0xFF403D39);
  static const Color EerieBlack = Color(0xFF252422);
  static const Color Flame = Color(0xFFEB5E28);

  late Box<CloudConvertService> _cloudConvertBox;

  @override
  void initState() {
    super.initState();
    _initHive();
  }

  Future<void> _initHive() async {
    await Hive.initFlutter();
    Hive.registerAdapter(CloudConvertServiceAdapter());
    _cloudConvertBox = await Hive.openBox<CloudConvertService>('cloudConvertServices');
    setState(() {}); // Después de abrir el Box, actualiza el estado
  }



  @override
  Widget build(BuildContext context) {
    // Asegúrate de que el Box esté abierto antes de construir el Drawer
    return Scaffold(
      drawer: FutureBuilder(
        future: _initHive(), // Espera a que el Box se abra
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Drawer(
              child: Center(child: CircularProgressIndicator()),
            ); // Muestra un cargador mientras Hive se inicializa
          } else if (snapshot.hasError) {
            return Drawer(
              child: Center(child: Text('Error al cargar los datos')),
            ); // Muestra un mensaje de error si falla la inicialización
          } else {
            return Drawer(
              child: Container(
                color: FloralWhite,
                child: ValueListenableBuilder(
                  valueListenable: _cloudConvertBox.listenable(),
                  builder: (context, Box<CloudConvertService> box, _) {
                    final elementos = box.values.toList();

                    return ListView(
                      padding: EdgeInsets.zero,
                      children: [
                        DrawerHeader(
                          decoration: BoxDecoration(color: Flame),
                          child: Text(
                            'Conversiones',
                            style: TextStyle(color: FloralWhite, fontSize: 24),
                          ),
                        ),
                        ...elementos.map((elemento) => Container(
                          margin: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          padding: EdgeInsets.all(16),
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
                          child: Text(
                            elemento.getName(),
                            style: TextStyle(fontSize: 18),
                          ),
                        )),
                      ],
                    );
                  },
                ),
              ),
            );
          }
        },
      ),
    );
  }
}