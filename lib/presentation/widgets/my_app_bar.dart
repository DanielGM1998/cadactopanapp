import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../constants/constants.dart';

AppBar myAppBar(BuildContext context, String name) {

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
              await prefs.remove("nest_date");
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
    centerTitle: false,
    backgroundColor: Colors.white,
    title: Text(name, style: const TextStyle(color: myColor)),
    iconTheme: const IconThemeData(color: myColor),
    actions: <Widget>[
      // IconButton(
      //   onPressed: () {},
      //   icon: const Icon(Icons.notifications_rounded),
      //   color: myColor,
      // ),
      // IconButton(
      //   onPressed: () {},
      //   icon: const Icon(Icons.chat_rounded),
      //   color: myColor,
      // ),
      PopupMenuButton(
        color: Colors.white,
        icon: const Icon(Icons.more_vert_outlined, color: myColor),
        itemBuilder: (context) {
          return const [
            PopupMenuItem<int>(
              value: 1,
              child: Text("Cerrar sesión", style: TextStyle(color: myColor)),
            ),
            // PopupMenuItem<int>(
            //   value: 2,
            //   child: Text("Contacto", style: TextStyle(color: myColor)),
            // ),
          ];
        },
        onSelected: (value) {
          if (value == 1) {
            _onWillPop1(); // Asegúrate de tener definida esta función
          }
          // else if (value == 2) {
          //}
        },
      ),
    ],
  );
}
