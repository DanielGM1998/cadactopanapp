import 'dart:async';
import 'dart:convert';

import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../../../constants/constants.dart';
import '../../widgets/my_app_bar.dart';
import '../../widgets/side_menu.dart';

class NotificacionesScreen extends StatefulWidget {
  static const String routeName = 'notificacion';

  final String idPaciente;

  const NotificacionesScreen({
    Key? key, required this.idPaciente,
  }) : super(key: key);

  @override
  State<NotificacionesScreen> createState() => _NotificacionesScreenState();
}

class _NotificacionesScreenState extends State<NotificacionesScreen>{
  String? _tipoapp;
  String? _userapp;
  String? _noti;

  List<dynamic> glucosas = [];
  bool isLoading = false; 
  bool finalScreen = false;

  Future<bool?> getVariables() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _tipoapp = prefs.getString("tipo_app");
    _userapp = prefs.getString("user");
    _noti = prefs.getString("noti");
    return false;
  }

  bool isFirstLoadRunning = false;
  bool hasNextPage = true;
  bool isLoadMoreRunning = false;
  int page = 1;
  final int limit = 50;
  List items = [];
  late ScrollController controller;

  final colors = <Color>[
    const Color.fromRGBO(255, 255, 255, 1.1),
    const Color.fromRGBO(55, 171, 204, 0.8),
  ];

  void fistLoad() async {
    setState(() {
      isFirstLoadRunning = true;
    });
    try {
      var data = {"paciente": widget.idPaciente, "page": page.toString()};
      final response = await http.post(
        Uri(
          scheme: 'https',
          host: 'v8.cadactopan.com.mx',
          path: '/api/getNotificaciones',
        ),
        body: data,
      );

      //if (response.statusCode == 200) {
        List newItems = jsonDecode(response.body)["items"];
        setState(() {
          items = newItems;
        });
      // } else {
      //   if (kDebugMode) {
      //     print("Error en la respuesta: ${response.statusCode}");
      //   }
      // }
    } catch (e) {
      if (kDebugMode) {
        print('Error al cargar datos');
      }
    }

    setState(() {
      isFirstLoadRunning = false;
    });
  }

  void loadMore() async {
    if (hasNextPage == true &&
        isFirstLoadRunning == false &&
        isLoadMoreRunning == false) {
      setState(() {
        isLoadMoreRunning = true;
      });

      page += 1;

      try {
        var data = {"paciente": widget.idPaciente, "page": page.toString()};
        final response = await http.post(
          Uri(
            scheme: 'https',
            host: 'v8.cadactopan.com.mx',
            path: '/api/getNotificaciones',
          ),
          body: data,
        );

        // if (response.statusCode == 200) {
          List newItems = jsonDecode(response.body)["items"];

          if (newItems.isNotEmpty) {
            setState(() {
              items.addAll(newItems); 
            });
          } else {
            // verifica que sea el final de paginacion y agrega sizedbox
            finalScreen = true;
            setState(() {
              hasNextPage = false;
            });
          }
        // } else {
        //   if (kDebugMode) {
        //     print("Error en la respuesta: ${response.statusCode}");
        //   }
        // }
      } catch (e) {
        if (kDebugMode) {
          print('Error al cargar más datos');
        }
      }

      setState(() {
        isLoadMoreRunning = false;
      });
    }
  }

  Future<String> _readNotificaciones() async {
    try {
      var data = {"paciente": widget.idPaciente};
      await http.post(
        Uri( 
          scheme: 'https',
          host: 'v8.cadactopan.com.mx',
          path: '/api/readNotificaciones',
        ),
        body: data,
      );
      return 'Error, verificar conexión a Internet';
    } catch (e) {
      return 'Error, verificar conexión a Internet';
    }
  }
  
  @override
  void initState() {
    super.initState();
    fistLoad();
    _readNotificaciones();
    controller = ScrollController()..addListener(loadMore);
  }

  @override
  Widget build(BuildContext context) {
    final Size _size = MediaQuery.of(context).size;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      delNoti();
    });
    return FutureBuilder(
      future: getVariables(),
      builder: (context, snapshot) {
        if (snapshot.data == false) {
          return WillPopScope(
            onWillPop: _onWillPop,
            child: Scaffold(
              backgroundColor: Colors.white.withOpacity(1),
              appBar: myAppBar(context, nameNotificaciones, widget.idPaciente),
              drawer: SideMenu(user: _userapp, tipoapp: _tipoapp, idPaciente: widget.idPaciente),
              resizeToAvoidBottomInset: false,
              body: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: const Alignment(0.0, 1.3),
                        colors: colors,
                        tileMode: TileMode.repeated,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal:10.0),
                    child: CustomRefreshIndicator(
                      builder: MaterialIndicatorDelegate(
                        builder: (context, controller) {
                          return Icon(
                            Icons.refresh_outlined,
                            color: myColor,
                            size: _size.width*0.1,
                          );
                        },
                      ),
                      onRefresh: () async {
                        delNoti();
                        isFirstLoadRunning = false;
                        hasNextPage = true;
                        isLoadMoreRunning = false;
                        items = [];
                        page = 1;
                        fistLoad();
                        controller = ScrollController()..addListener(loadMore);
                        return setState(() {});
                      },
                      child: isFirstLoadRunning
                          ? const Center(child: CircularProgressIndicator(color: myColor,))
                          : Column(children: [
                            if(items.isEmpty)
                              const Expanded(child: Center(child: Text("No existen registros", style: TextStyle(color: myColor, fontSize: 18)))),
                              SizedBox(height: _size.height*0.01),
                              Expanded(
                                  child: ListView.builder(
                                  controller: controller,
                                  itemCount: items.length,
                                  itemBuilder: (context, index) {
                                    bool isNotRead = index < int.parse(_noti!);
                                    return Card(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20.0), 
                                      ), 
                                      elevation: 5, 
                                      child: Padding(
                                        padding: const EdgeInsets.all(12.0), 
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.start, 
                                          children: [
                                            Align(
                                              alignment: Alignment.topLeft,
                                              child: CircleAvatar(
                                                backgroundColor: myColor,
                                                radius: _size.width * 0.06,
                                                child: const Icon(
                                                  Icons.notifications,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: _size.width*0.02), 
                                            Expanded( 
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.start, 
                                                crossAxisAlignment: CrossAxisAlignment.start, 
                                                children: [ 
                                                  Padding(
                                                    padding: const EdgeInsets.only(left: 10),
                                                    child: Column(
                                                      children: [
                                                        Row(
                                                          mainAxisAlignment: MainAxisAlignment.start,
                                                          children: [
                                                            Expanded(
                                                              child: Text(
                                                                items[index]['titulo'].toString(), 
                                                                style: const TextStyle(
                                                                  fontSize: 16, 
                                                                  fontWeight: FontWeight.bold, 
                                                                ), 
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        Row(
                                                          mainAxisAlignment: MainAxisAlignment.start,
                                                          children: [
                                                            Expanded(
                                                              child: Text(
                                                                items[index]['mensaje'].toString(), 
                                                                style: TextStyle(
                                                                  fontSize: 16, 
                                                                  fontWeight: isNotRead ? FontWeight.bold : FontWeight.normal,
                                                                ), 
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        SizedBox(height: _size.height*0.02), 
                                                        Row(
                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                          children: [
                                                            Text(
                                                              items[index]['fechaLarga'].toString(), 
                                                              textAlign: TextAlign.center, 
                                                              style: TextStyle(
                                                                  fontSize: 12, 
                                                                  fontWeight: isNotRead ? FontWeight.bold : FontWeight.normal,
                                                                ), 
                                                            ),
                                                            Text(
                                                              items[index]['hora'].toString(), 
                                                              textAlign: TextAlign.center, 
                                                              style: TextStyle(
                                                                  fontSize: 12, 
                                                                  fontWeight: isNotRead ? FontWeight.bold : FontWeight.normal,
                                                                ), 
                                                            ),
                                                          ],
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
                                    ); 
                                  },
                                ),
                              ),
                              if(finalScreen)
                                SizedBox(height: _size.height*0.06),
                              if (isLoadMoreRunning)
                                const Padding(
                                  padding: EdgeInsets.all(10),
                                  child: Center(child: CircularProgressIndicator(
                                    color: myColor,
                                  )),
                                )
                            ]),
                    ),
                  ),
                ],
              ),
            ),
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

  Future<void> delNoti() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('noti', "0");
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

}