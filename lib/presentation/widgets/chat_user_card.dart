import 'dart:ui';

import 'package:cadactopanapp/config/helper/my_date_util.dart';
import 'package:cadactopanapp/config/services/apis.dart';
import 'package:cadactopanapp/models/chat_user.dart';
import 'package:cadactopanapp/models/message.dart';
import 'package:cadactopanapp/presentation/screens/chat/chat_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ChatUserCard extends StatefulWidget {
  final ChatUser userContacto;
  final String idPaciente;
  final String userapp;
  final String userLastName;

  const ChatUserCard({Key? key, required this.userContacto, required this.idPaciente, required this.userapp, required this.userLastName}) : super(key: key);

  @override
  State<ChatUserCard> createState() => _ChatUserCardState();
}

class _ChatUserCardState extends State<ChatUserCard> {
  Message? _message;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      // color: Colors.blue.shade100,
      elevation: 0.5,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(15))),
      child: InkWell(
        borderRadius: const BorderRadius.all(Radius.circular(15)),
          onTap: () {
            Navigator.of(context).pushReplacement(
              _buildPageRoute(ChatScreen(userContacto: widget.userContacto, idPaciente: widget.idPaciente, userapp: widget.userapp, userLastName: widget.userLastName)),
            );
          },
          child: StreamBuilder(
            stream: APIs.getLastMessage(widget.userContacto, widget.idPaciente),
            builder: (context, snapshot) {

              switch (snapshot.connectionState) {
                
                // Si los datos están cargando
                case ConnectionState.waiting:
                  return const SizedBox();

                case ConnectionState.none:
                  return const Center(
                    child: Text(
                      "Verificar conexión de internet",
                      style: TextStyle(fontSize: 16),
                    ),
                  );
                              
                // Si los datos están cargados
                case ConnectionState.active:
                  // El stream está emitiendo datos
                  if (snapshot.hasData) {
                    // Hay datos disponibles
                    final QuerySnapshot querySnapshot = snapshot.data as QuerySnapshot;
                    final data = querySnapshot.docs;
                    final _list = data.map((e) {
                      final mapData = e.data() as Map<String, dynamic>; 
                      return Message.fromJson(mapData);
                    }).toList();
                    _message=null;
                    if(_list.isNotEmpty){
                      _message = _list[0];
                    }
                    
                    return ListTile(
                      leading: const CircleAvatar(
                        child: Icon(CupertinoIcons.person),
                      ),
                      title: 
                      widget.userContacto.name=="Marco Antonio Morales de Teresa"
                        ? Text("Dr. "+widget.userContacto.name)
                        : Text(widget.userContacto.name),
                      subtitle: Text(
                        _message != null
                        ? 
                        _message!.type == Type.image
                        ? 'Imagen'
                        : _message!.msg

                        : widget.userContacto.about
                      ),
                      trailing: _message == null 
                      ? null
                      : _message!.read.isEmpty && _message!.fromId != widget.idPaciente
                      ? Container(
                          width: 15,
                          height: 15,
                          decoration: BoxDecoration(
                            color: Colors.greenAccent.shade400,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        )
                      : Text(MyDateUtil.getLastMessageTime(context: context, time: _message!.sent), style: const TextStyle(color: Colors.black54))
                    );

                  } else if (snapshot.hasError) {
                    // Ocurrió un error en el stream
                    return Center(
                      child: Text(
                        "Error: ${snapshot.error}",
                        style: const TextStyle(color: Colors.red, fontSize: 16),
                      ),
                    );
                  } else {
                    // El stream está activo pero no tiene datos
                    return const Center(
                      child: Text(
                        "No hay datos disponibles",
                        style: TextStyle(fontSize: 16),
                      ),
                    );
                  }

                case ConnectionState.done:
                  return const Center(
                    child: Text(
                      "El stream ha terminado",
                      style: TextStyle(fontSize: 16),
                    ),
                  );
              }
            },
          ),          
      ),     
    );
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