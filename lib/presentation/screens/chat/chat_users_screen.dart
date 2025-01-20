import 'dart:async';
import 'dart:ui';

import 'package:cadactopanapp/config/services/apis.dart';
import 'package:cadactopanapp/main.dart';
import 'package:cadactopanapp/models/chat_user.dart';
import 'package:cadactopanapp/presentation/screens/home/home_screen.dart';
import 'package:cadactopanapp/presentation/widgets/chat_user_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../constants/constants.dart';
import '../../widgets/side_menu.dart';

class ChatUsersScreen extends StatefulWidget {
  static const String routeName = 'chat_users';

  final String idPaciente;

  const ChatUsersScreen({
    Key? key, required this.idPaciente,
  }) : super(key: key);

  @override
  State<ChatUsersScreen> createState() => _ChatUsersScreenState();
}

class _ChatUsersScreenState extends State<ChatUsersScreen> with SingleTickerProviderStateMixin {
  String? _tipoapp;
  String? _userapp;
  String? _userLastNameApp;

  Future<bool?> getVariables() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _tipoapp = prefs.getString("tipo_app");
    _userapp = prefs.getString("user");
    _userLastNameApp = prefs.getString("user_last_name");
    return false;
  }

  final colors = <Color>[
    const Color.fromRGBO(255, 255, 255, 1.1),
    const Color.fromRGBO(55, 171, 204, 0.8),
  ];

  List<ChatUser> _list = [];
  final List<ChatUser> _searchList = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();

    // Actualizar estado en linea activo o no
    APIs.updateActiveStatus(true, widget.idPaciente);

    // borrar notificaciones
    flutterLocalNotificationsPlugin.cancelAll();

    SystemChannels.lifecycle.setMessageHandler((message) {
      if(message.toString().contains('resume')){
        APIs.updateActiveStatus(true, widget.idPaciente);
      }else if(message.toString().contains('pause')){
        APIs.updateActiveStatus(false, widget.idPaciente);
      }
      return Future.value(message);
    });
  }

  @override
  Widget build(BuildContext context) {
    final Size _size = MediaQuery.of(context).size;
    return FutureBuilder(
      future: getVariables(),
      builder: (context, snapshot) {
        if (snapshot.data == false) {
          return PopScope(
            canPop: false,
            onPopInvokedWithResult: (didPop, result) async {
              if (didPop) { return; }
              bool value = await _onWillPop();
              if (value) {
                //FocusScope.of(context).unfocus();
                
                // if(_isSearching){
                //   setState(() {
                //     _isSearching = !_isSearching;
                //   });
                // }
                Navigator.of(context).pop(value);
              }
            },
            child: Scaffold(
                backgroundColor: Colors.white.withOpacity(1),
                appBar: AppBar(
                  elevation: 1,
                  shadowColor: myColor,
                  centerTitle: true,
                  backgroundColor: Colors.white,
                  title: _isSearching
                  ? TextField(
                      decoration: const InputDecoration(
                        border: InputBorder.none, hintText: "Nombre, Expediente..."
                      ),
                      autofocus: true,
                      style: const TextStyle(fontSize: 15, letterSpacing: 0.5),
                      onChanged: (value) {
                        _searchList.clear();
                        for(var i in _list){
                          if(i.name.toLowerCase().contains(value.toLowerCase()) || i.id.toLowerCase().contains(value.toLowerCase())){
                            _searchList.add(i);
                          }
                          setState(() {
                            _searchList;
                          });
                        }
                      },
                    )
                  : const Text(nameChat, style: TextStyle(color: myColor)),
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
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _isSearching = !_isSearching;
                        });
                      },
                      icon: Icon(_isSearching 
                      ? CupertinoIcons.clear_circled_solid
                      : Icons.search),
                      color: myColor,
                    ),
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
                        ];
                      },
                      onSelected: (value) {
                        if (value == 1) {
                          _onWillPop1();
                        }
                      },
                    ),
                  ],
                ),
                drawer: SideMenu(user: _userapp, tipoapp: _tipoapp, idPaciente: widget.idPaciente),
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
                    padding: const EdgeInsets.all(1.0),
                    child: Center(
                      child: Column(
                        children: [
                          Expanded(
                            child: StreamBuilder(

                              // Sólo pueden ver algunos chats // 49 Morales - // 3396 Dr. Jose Luis Hernandez Perez

                              stream: 
                              widget.idPaciente=="49"
                              ? APIs.firestore.collection('usuarios').where('id', whereNotIn: ["49"]).orderBy('last_active', descending: true).snapshots()
                              : widget.idPaciente=="2031"
                                ? APIs.firestore.collection('usuarios').where('id', whereNotIn: ["2031"]).orderBy('last_active', descending: true).snapshots()
                                : widget.idPaciente=="6854" || widget.idPaciente=="8556"
                                ? APIs.firestore.collection('usuarios').where('id', whereIn: ["49","2031"]).orderBy('last_active', descending: true).snapshots()
                                : APIs.firestore.collection('usuarios').where('id', whereIn: ["49"]).orderBy('last_active', descending: true).snapshots(),

                              builder: (context, snapshot) {
                                switch (snapshot.connectionState) {
                                  //if data is loading
                                  case ConnectionState.waiting:
                                  case ConnectionState.none:
                                    return const Center(
                                      child: CircularProgressIndicator()
                                    );

                                  //if some or all data is loaded then show it
                                  case ConnectionState.active:
                                  case ConnectionState.done:

                                  if (snapshot.hasData) {
                                    final QuerySnapshot querySnapshot = snapshot.data as QuerySnapshot;
                                    final data = querySnapshot.docs;
                                    _list = data.map((e) {
                                      final mapData = e.data() as Map<String, dynamic>; 
                                      return ChatUser.fromJson(mapData);
                                    }).toList();
                                  }
                                }                    
                                if(_list.isNotEmpty){
                                  return ListView.builder(
                                    itemCount: _isSearching ? _searchList.length : _list.length,
                                    padding: const EdgeInsets.only(top: 10),
                                    physics: const BouncingScrollPhysics(),
                                    itemBuilder: (context, index) {
                                      return ChatUserCard(userContacto: _isSearching ? _searchList[index] : _list[index], idPaciente: widget.idPaciente, userapp: _userapp!, userLastName: _userLastNameApp!);
                                    },
                                  );
                                }else{
                                  return const Expanded(child: Center(child: Text("No existen registros", style: TextStyle(color: myColor, fontSize: 18))));
                                }
                              },  
                            ),
                          ),
                        ],
                      ),
                    )
                  ),
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
              await APIs.deleteTokenSesion(widget.idPaciente);
              await flutterLocalNotificationsPlugin.cancelAll();
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
              await prefs.remove("user_last_name");
              prefs.setBool('is_logged_in', false);
              await prefs.remove('last_notification_date');              
              Navigator.pushReplacementNamed(context, 'login');
            },
            child: const Text('Si'),
          ),
        ],
      ),
    )) ??
    false;
  }

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