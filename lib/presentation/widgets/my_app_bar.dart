import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../constants/constants.dart';
import '../screens/home/home_screen.dart';
import '../screens/notifications/notificaciones_screen.dart';

AppBar myAppBar(BuildContext context, String name, String idPaciente) {
  final Size _size = MediaQuery.of(context).size;
  Future<bool> _onWillPop1() async {
    return (await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('¿Deseas cerrar sesión?'),
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(32.0))),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () async {
              SharedPreferences prefs =
                  await SharedPreferences.getInstance();
              await prefs.remove("user");
              await prefs.remove("id_paciente");
              await prefs.remove("tipo_app");
              await prefs.remove("id_receta");
              await prefs.remove("telefono");
              await prefs.remove("pass");
              await prefs.remove("next_date");
              await prefs.remove("token");
              await prefs.remove("noti");
              prefs.setBool('is_logged_in', false);
              prefs.remove('last_notification_date');              
              Navigator.pushReplacementNamed(context, 'login');
            },
            child: const Text('Si'),
          ),
        ],
      ),
    )) ??
    false;
  }
  
  return AppBar(
    elevation: 1,
    shadowColor: myColor,
    centerTitle: true,
    backgroundColor: Colors.white,
    title: Text(name, style: const TextStyle(color: myColor)),
    iconTheme: const IconThemeData(color: myColor),
    leading: Row(
      children: [
        Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              Scaffold.of(context).openDrawer(); 
            },
          ),
        ),
        IconButton(
          icon: const Icon(Icons.home_outlined), 
          onPressed: () {
            Navigator.of(context).pushReplacement(
              _buildPageRoute(const HomeScreen()),
            );
          },
        ),
      ],
    ),
    leadingWidth: _size.width * 0.28,
    actions: <Widget>[
      FutureBuilder<String>(
        future: _getNotificationCount(), 
        builder: (context, snapshot) {
          final String notificationCount = snapshot.data ?? "0"; 
          return Stack(
            children: [
              IconButton(
                onPressed: () async{
                  SharedPreferences prefs = await SharedPreferences.getInstance();
                  prefs.setString('noti', "0");
                  Navigator.of(context).pushReplacement(
                    _buildPageRoute(NotificacionesScreen(idPaciente: idPaciente)),
                  );
                },
                icon: const Icon(Icons.notifications_rounded),
                color: myColor,
              ),
              if (notificationCount != "0") 
                Positioned(
                  right: 7,
                  top: 7,
                  child: Container(
                    padding: const EdgeInsets.all(1),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 15,
                      minHeight: 15,
                    ),
                    child: Text(
                      notificationCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
      // IconButton(
      //   onPressed: () {},
      //   icon: const Icon(Icons.chat_rounded),
      //   color: myColor,
      // ),
      PopupMenuButton(
        color: Colors.white,
        icon: const Icon(Icons.more_vert_outlined, color: myColor),
        itemBuilder: (context) {
          return [
            PopupMenuItem<int>(
              value: 1,
              child: Row(
                children: [
                  const Icon(Icons.login),
                  SizedBox(width: _size.width * 0.03),
                  const Text("Cerrar sesión", style: TextStyle(color: myColor)),
                ],
              ),
            ),
            /*PopupMenuItem<int>(
              value: 2,
              child: Row(
                children: [
                  const Icon(Icons.message_rounded),
                  SizedBox(width: _size.width * 0.03),
                  const Text("Chat", style: TextStyle(color: myColor)),
                ],
              ),
            ),*/
          ];
        },
        onSelected: (value) {
          if (value == 1) {
            _onWillPop1();
          }else if (value == 2) {

          }
        },
      ),
    ],
  );
}

Future<String> _getNotificationCount() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('noti') ?? "0";
}

PageRouteBuilder _buildPageRoute(Widget page) {
  return PageRouteBuilder(
    barrierColor: Colors.black.withOpacity(0.6),
    opaque: false,
    pageBuilder: (_, __, ___) => page,
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
  );
}
