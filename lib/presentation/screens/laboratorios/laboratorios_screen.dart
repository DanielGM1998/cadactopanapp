import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../../../constants/constants.dart';
import '../../widgets/my_app_bar.dart';
import '../../widgets/side_menu.dart';

class LaboratoriosScreen extends StatefulWidget {
  static const String routeName = 'laboratorios';

  const LaboratoriosScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<LaboratoriosScreen> createState() => _LaboratoriosScreenState();
}

class _LaboratoriosScreenState extends State<LaboratoriosScreen> with SingleTickerProviderStateMixin {
  String? _tipoapp;
  String? _userapp;
  String? _idPaciente;

  late List<dynamic> laboratorios;

  Future<bool?> getVariables() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _tipoapp = prefs.getString("tipo_app");
    _userapp = prefs.getString("user");
    _idPaciente = prefs.getString("id_paciente");
    return false;
  }

  final colors = <Color>[
    const Color.fromRGBO(255, 255, 255, 1.1),
    const Color.fromRGBO(55, 171, 204, 0.8),
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final Size _size = MediaQuery.of(context).size;
    return FutureBuilder(
      future: getVariables(),
      builder: (context, snapshot) {
        if (snapshot.data == false) {
          return FutureBuilder(
            future: getLaboratorios(_idPaciente!), 
            builder: (context, snapshot) {
              if (snapshot.data == true) {
                return WillPopScope(
                  onWillPop: _onWillPop,
                  child: Scaffold(
                      backgroundColor: Colors.white.withOpacity(1),
                      appBar: myAppBar(context, nameLaboratorios),
                      drawer: SideMenu(user: _userapp, tipoapp: _tipoapp, idPaciente: _idPaciente!),
                      resizeToAvoidBottomInset: false,
                      body: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: const Alignment(0.0, 1.3),
                            colors: colors,
                            tileMode: TileMode.repeated,
                          ),
                        ),
                        child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: 
                        laboratorios.isEmpty 
                          ? const Expanded(child: Center(child: Text("No existen registros", style: TextStyle(color: myColor, fontSize: 18))))
                          : GridView.builder(
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                              childAspectRatio: 0.7,
                            ),
                            itemCount: laboratorios.length,
                            itemBuilder: (context, index) {
                              final item = laboratorios[index];

                              final List<Color> avatarColors = [
                                Colors.deepPurple,
                              ];

                              final Color avatarColor = avatarColors[index % avatarColors.length];

                              return Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                                elevation: 5,
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      CircleAvatar(
                                        radius: _size.width * 0.101, 
                                        backgroundColor: avatarColor, 
                                        child: Text(
                                          item['valor']+"\n${item['unidad']}", 
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold), 
                                        ),
                                      ),
                                      SizedBox(height: _size.height * 0.015),
                                      Text(
                                        item['nombre']!,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: _size.height * 0.01),
                                      Text('${item['fecha']}', 
                                        style: const TextStyle(color: Colors.black, fontSize: 16),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        )
                      ),
                    ),
                );
              } else if (snapshot.data == false) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return const SizedBox(height: 0, width: 0);
                }
              } else if (snapshot.hasError) {
                return const SizedBox(height: 0, width: 0);
              }
              return WillPopScope(
                onWillPop: _onWillPop,
                child: Scaffold(
                  backgroundColor: Colors.white.withOpacity(1),
                  appBar: myAppBar(context, nameLaboratorios),
                  drawer: SideMenu(user: _userapp, tipoapp: _tipoapp, idPaciente: _idPaciente!),
                  resizeToAvoidBottomInset: false,
                  body: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: const Alignment(0.0, 1.3),
                        colors: colors,
                        tileMode: TileMode.repeated,
                      ),
                    ),
                    child: const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: 
                      Center(
                        child: CircularProgressIndicator(color: myColor),
                      )
                    )
                  ),
                ),
              );
            }
          );
        } else if (snapshot.data == true) {
          if (snapshot.connectionState == ConnectionState.done) {
            return const SizedBox(height: 0, width: 0);
          }
        } else if (snapshot.hasError) {
          return Text("${snapshot.error}");
        }
        return const SizedBox(height: 0, width: 0);
      },
    );
  }

  Future<bool> _onWillPop() async {
    return (await showDialog(
          barrierDismissible: false,
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Cerrar aplicación'),
            content: const Text('¿Deseas salir de la aplicación?'),
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(32.0))),
            actions: <Widget>[
              OutlinedButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('No'),
              ),
              ElevatedButton(
                onPressed: () => SystemNavigator.pop(),
                child: const Text('Si'),
              ),
            ],
          ),
        )) ??
        false;
  }

  Future<bool> getLaboratorios(String idPaciente) async { 
    try {
      var data = {"paciente": idPaciente};
      final response = await http.post(
        Uri(
          scheme: 'https',
          host: 'v8.cadactopan.com.mx',
          path: '/api/getLaboratorios',
        ),
        body: data,
      );

      if (response.statusCode == 200) {
        String body3 = utf8.decode(response.bodyBytes);
        var jsonData = jsonDecode(body3);
        if (jsonData is List || jsonData is Map) {
          laboratorios = jsonData;
        }
        return true;
      } else {
        //print("Error en la respuesta: ${response.statusCode}");        
        return false;
      }
    } catch (e) {
      //print("Error atrapado en el catch: $e");
      return false;
    }
  }

}