import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:cadactopanapp/constants/constants.dart';
import 'package:cadactopanapp/main.dart';
import 'package:cadactopanapp/presentation/screens/glucosa/glucosa_screen.dart';
import 'package:cadactopanapp/presentation/screens/presion/presion_screen.dart';
import 'package:cadactopanapp/presentation/screens/receta/receta_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../config/providers/push_provider.dart';
import '../../widgets/my_app_bar.dart';
import '../../widgets/side_menu.dart';
import '../laboratorios/laboratorios_screen.dart';

class HomeScreen extends StatefulWidget {
  static const String routeName = 'home';

  const HomeScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  String? _tipoapp;
  String? _userapp;
  String? _idPaciente;
  String? _nextDate;

  late DateTime date;

  Future<bool?> getVariables() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _nextDate = prefs.getString("next_date");
    _tipoapp = prefs.getString("tipo_app");
    _userapp = prefs.getString("user");
    _idPaciente = prefs.getString("id_paciente");

    if (_nextDate != null && _nextDate!.isNotEmpty) {
      String trimmedDateString = _nextDate!.split(' ')[1];
      trimmedDateString = trimmedDateString+" 01:00";
      //print(trimmedDateString);
      date = DateFormat("dd/MM/yyyy HH:mm", 'es').parse(trimmedDateString);
      //print(date);
      //////change 10-11-2024
      //date = DateTime(2024, 11, 10, 5, 31);      
      checkAndNotify(date);    
    }
    return false;
  }

  final colors = <Color>[
    const Color.fromRGBO(255, 255, 255, 1.1),
    const Color.fromRGBO(55, 171, 204, 0.8),
  ];

  late List<Map<String, dynamic>> modulos;

  @override
  void initState() {
    super.initState();

    // PUSH NOTIFICATIONS
    final pushProvider = PushProvider();
    pushProvider.initPush();

    //pushProvider.notificacion.listen((titulo) {
      //log(titulo);
      // if (titulo.isNotEmpty && titulo != "Sin título") { 
      //   setState(() {
      //     if (titulo == 'REFRESH_DATA') {
      //       //setState(() {
      //       doRefresh();
      //       //});
      //     } else if (titulo == 'CHAT_MESSAGE') {
      //       // if (_chatCount < 99) _chatCount++;
      //       // _paciente.chat = _chatCount;          
      //     } else {
      //       // si quiero ir a una pantalla cuando estoy con la app abierta
      //       // Navigator.of(context).push(
      //       //   _buildPageRoute(NotificacionesScreen(idPaciente: _idPaciente!)),
      //       // );
      //       // if (_notiCount < 99) _notiCount++;
      //       // _paciente.noti = _notiCount;
      //       if (titulo != 'onMessage' && titulo != 'REFRESH_DATA') {
      //         Navigator.of(context).pushReplacement(
      //           _buildPageRoute(NotificacionesScreen(idPaciente: _idPaciente!)),
      //         );
      //         //_notiCount = 0;
      //       }
      //     }
      //   });
      // }
    //});
  }

  // despues de initState
  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
  }

  void doRefresh() async {
    // check de login
  }

  Future<void> checkAndNotify(DateTime targetDate) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? lastNotificationDate = prefs.getString('last_notification_date');
    final bool isUserLoggedIn = prefs.getBool('is_logged_in') ?? false;
    //print(targetDate);
    final currentDate = DateTime.now();
    //print(currentDate);
    final difference = targetDate.difference(currentDate).inDays;
    //print(difference);
  
    if (!isUserLoggedIn) return;

    if (lastNotificationDate != null &&
      DateTime.parse(lastNotificationDate).day == currentDate.day &&
      DateTime.parse(lastNotificationDate).month == currentDate.month &&
      DateTime.parse(lastNotificationDate).year == currentDate.year) {
        return;
    }

    if (difference <= 5 && difference >= 0) {
      await flutterLocalNotificationsPlugin.show(
        0,
        'Recordatorio',
        '¡Queda menos de una semana para tu consulta!',
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'your_channel_id', 'your_channel_name',
            importance: Importance.max,
            priority: Priority.high,
            icon: '@mipmap/launcher_icon', 
            largeIcon: DrawableResourceAndroidBitmap('@mipmap/launcher_icon'), 
            color: myColor, 
            styleInformation: BigTextStyleInformation(
              '¡Queda menos de una semana para tu consulta programada! Asegúrate de estar preparado.',
               contentTitle: 'Recordatorio de consulta',
               htmlFormatContent: true,
               htmlFormatContentTitle: true,
            ),
            playSound: true, 
            // sound: const RawResourceAndroidNotificationSound('notification_sound'), // Sonido personalizado en /android/app/src/main/res/raw
            ticker: 'ticker',
            enableVibration: true,
          ),
        ),
      );
      await prefs.setString('last_notification_date', currentDate.toIso8601String());
    }
  }


  @override
  Widget build(BuildContext context) {
    final Size _size = MediaQuery.of(context).size;
    return FutureBuilder(
      future: getVariables(),
      builder: (context, snapshot) {
        if (snapshot.data == false) {
          modulos = [
            {'nombre': 'Glucosa', 'icono': Icons.water_drop_outlined, 'color': Colors.green, 'ruta': GlucosaScreen(idPaciente: _idPaciente!.toString())},
            {'nombre': 'Presión Arterial', 'icono': Icons.favorite_border, 'color': Colors.yellow[600], 'ruta': PresionScreen(idPaciente: _idPaciente!.toString())},
            {'nombre': 'Receta', 'icono': Icons.medication, 'color': Colors.red, 'ruta': RecetaScreen(idPaciente: _idPaciente.toString())},
            {'nombre': 'Laboratorios', 'icono': Icons.assignment, 'color': Colors.deepPurple, 'ruta': const LaboratoriosScreen()},
          ];
          return PopScope(
            canPop: false,
            onPopInvokedWithResult: (didPop, result) async {
              if (didPop) { return; }
              bool value = await _onWillPop();
              if (value) {
                Navigator.of(context).pop(value);
              }
            },
            child: Scaffold(
                backgroundColor: Colors.white.withOpacity(1),
                appBar: myAppBar(context, nameApp, _idPaciente!),
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
                  padding: EdgeInsets.symmetric(vertical: _size.width*0.02),
                  child: Column(
                    children: [
                      InkWell(
                          child: Stack(
                            children: [
                              ClipRect(
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                                  child: Container(
                                    height: _size.height*0.15,
                                    margin: const EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                      color: Colors.white24.withOpacity(0.3),
                                      borderRadius: BorderRadius.circular(20),                                        
                                    ),
                                  ),
                                ),
                              ),
                              Positioned.fill(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.symmetric(horizontal: _size.width * 0.05),
                                      child: Column(
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  "Hola " + _userapp!,
                                                  style: const TextStyle(
                                                    fontSize: 20,
                                                    color: myColor,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                  maxLines: 2, 
                                                  overflow: TextOverflow.ellipsis, 
                                                ),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              const Text(
                                                "Núm. de expediente: ",
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  color: myColor,
                                                ),
                                              ),
                                              Expanded(
                                                child: Text(
                                                  _idPaciente!,
                                                  style: const TextStyle(
                                                    fontSize: 18,
                                                    color: myColor,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                  maxLines: 2, 
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  _nextDate == "" || _nextDate == null
                                                    ? "No hay consulta programada"
                                                    : "Próx. consulta: ",
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    color: myColor,
                                                  ),
                                                  maxLines: 3,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                              Text(
                                                _nextDate == "" || _nextDate == null
                                                  ? ""
                                                  : _nextDate!,
                                                style: const TextStyle(
                                                  fontSize: 18,
                                                  color: myColor,
                                                  fontWeight: FontWeight.bold,
                                                  decoration: TextDecoration.underline,
                                                  decorationColor: myColor,
                                                  decorationThickness: 1,
                                                ),
                                                maxLines: 3,
                                                overflow: TextOverflow.ellipsis,
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
                      Expanded(
                        child: ListView.builder(
                          itemCount: modulos.length,
                          itemBuilder: (BuildContext context, int index) {
                            return Column(
                              children: [
                                InkWell(
                                  onTap: () {
                                    Navigator.of(context).push(
                                    PageRouteBuilder(
                                      barrierColor: Colors.black.withOpacity(0.6),
                                      opaque: false,
                                      pageBuilder: (_, __, ___) => modulos[index]['ruta'],
                                      transitionDuration: const Duration(milliseconds: 200),
                                      transitionsBuilder: (_, animation, __, child) {
                                        return BackdropFilter(
                                          filter: ImageFilter.blur(
                                            sigmaX: 5 * animation.value,
                                            sigmaY: 5 * animation.value,
                                          ),
                                          child: FadeTransition(
                                            opacity: animation,
                                            child: child,
                                          ),
                                        );
                                      },
                                    ),
                                  );
                                  },
                                  child: Stack(
                                    children: [
                                      ClipRect(
                                        child: BackdropFilter(
                                          filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                                          child: Container(
                                            height: _size.height*0.12,
                                            margin: const EdgeInsets.all(15),
                                            decoration: BoxDecoration(
                                              color: Colors.white24.withOpacity(0.3),
                                              borderRadius: BorderRadius.circular(20),                                        
                                            ),
                                          ),
                                        ),
                                      ),
                                      Positioned.fill(
                                        child: Row(
                                          children: [
                                            SizedBox(width: _size.width*0.1),
                                            Container(
                                              padding: const EdgeInsets.all(12.0),
                                              decoration: BoxDecoration(
                                                color: modulos[index]['color'],
                                                borderRadius: BorderRadius.circular(10.0),
                                              ),
                                              child: Icon(
                                                modulos[index]['icono'],
                                                size: 40,
                                                color: Colors.white,
                                              ),
                                            ),
                                            SizedBox(width: _size.width*0.05),
                                            Text(
                                              modulos[index]['nombre'],
                                              style: const TextStyle(
                                                fontSize: 20,
                                                color: myColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ); 
                          },
                        ),
                      ),
                    ],
                  ),
                  )
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

  // PageRouteBuilder _buildPageRoute(Widget page) {
  //   return PageRouteBuilder(
  //     barrierColor: Colors.black.withOpacity(0.6),
  //     opaque: false,
  //     pageBuilder: (_, __, ___) => page,
  //     transitionDuration: const Duration(milliseconds: 200),
  //     transitionsBuilder: (_, animation, __, child) {
  //       return BackdropFilter(
  //         filter: ImageFilter.blur(
  //           sigmaX: 5 * animation.value,
  //           sigmaY: 5 * animation.value,
  //         ),
  //         child: FadeTransition(
  //           opacity: animation,
  //           child: child,
  //         ),
  //       );
  //     },
  //   );
  // }
}