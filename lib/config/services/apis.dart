import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:cadactopanapp/config/services/get_service_key.dart';
import 'package:cadactopanapp/models/chat_user.dart';
import 'package:cadactopanapp/models/message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:http/http.dart';

class APIs {

  // para acceder a la base de datos de Cloud Firestore
  static FirebaseFirestore firestore = FirebaseFirestore.instance;

  // para acceder al almacenamiento de Firebase
  static FirebaseStorage storage = FirebaseStorage.instance;

  // ¿para comprobar si el usuario existe o no?
  static Future<bool> userExists(String id) async {
    return (await firestore.collection('usuarios').doc(id).get()).exists;
  }

  // para crear un nuevo usuario
  static Future<void> createUser(String id, String name) async {
    final time = DateTime.now().millisecondsSinceEpoch.toString();

    final chatUser = ChatUser(
        id: id,
        name: name,
        email: "",
        about: "",
        image: "",
        createdAt: time,
        isOnline: false,
        lastActive: time,
        pushToken: "");

    return await firestore
        .collection('usuarios')
        .doc(id)
        .set(chatUser.toJson());
  }
  
  // útil para obtener el ID de la conversación
  static String getConversationID(String idPrincipal, String idSecundario) => idSecundario.hashCode <= idPrincipal.hashCode
      ? '${idSecundario}_$idPrincipal'
      : '${idPrincipal}_$idSecundario';

  // obtener push_token por id
  static Future<String?> getPushToken(String userId) async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore.instance
          .collection('usuarios')
          .where('id', isEqualTo: userId)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        var data = querySnapshot.docs.first.data();
        return data['push_token'] as String?;
      } else {
        //print('No se encontró el usuario con ID: $userId');
        return null;
      }
    } catch (e) {
      //print('Error al obtener el push_token: $e');
      return null;
    }
  }

  // para enviar mensaje
  static Future<void> sendMessage(ChatUser chatUser, String idPrincipal, String usernameComplete, String msg, Type type) async {

    String token = await getPushToken(chatUser.id) ?? chatUser.id;

    // //Hora de envío del mensaje (también se usa como id)
    final time = DateTime.now().millisecondsSinceEpoch.toString();

    //mensaje a enviar
    final Message message = Message(
        toId: chatUser.id,
        msg: msg,
        read: '',
        type: type,
        fromId: idPrincipal,
        sent: time);

    final ref = firestore.collection('conversaciones/${getConversationID(idPrincipal, chatUser.id)}/mensajes/');
    await ref.doc(time).set(message.toJson()).then((value) async{
      GetServiceKey getServiceKey = GetServiceKey();
      String accessToken = await getServiceKey.getServerKeyToken();
      //log(accessToken);
      sendPushNotification(token, usernameComplete, type == Type.text ? msg : 'Imagen', accessToken);
    });
  }

  //actualizar el estado de lectura del mensaje
  static Future<void> updateMessageReadStatus(Message message) async {
    firestore
        .collection('conversaciones/${getConversationID(message.fromId, message.toId)}/mensajes/')
        .doc(message.sent)
        .update({'read': DateTime.now().millisecondsSinceEpoch.toString()});
  }

  //obtener solo el último mensaje de un chat específico
  static Stream<QuerySnapshot<Map<String, dynamic>>> getLastMessage(ChatUser user, String idPrincipal) {
    return firestore
        .collection('conversaciones/${getConversationID(idPrincipal, user.id)}/mensajes/')
        .orderBy('sent', descending: true)
        .limit(1)
        .snapshots();
  }

  // para obtener información específica del usuario
  static Stream<QuerySnapshot<Map<String, dynamic>>> getUserInfo(String id) {
    return firestore
        .collection('usuarios')
        .where('id', isEqualTo: id)
        .snapshots();
  }

  // actualizar el estado en línea o el último estado activo del usuario
  static Future<void> updateActiveStatus(bool isOnline, String idPrincipal) async {
    firestore.collection('usuarios').doc(idPrincipal).update({
      'is_online': isOnline,
      'last_active': DateTime.now().millisecondsSinceEpoch.toString(),
    });
  }

  // borra token al cerrar sesion de usuario
  static Future<void> deleteTokenSesion(String idPrincipal) async {
    firestore.collection('usuarios').doc(idPrincipal).update({
      'push_token': "",
    });
  }

    // para enviar notificaciones push (Códigos actualizados)
  static Future<void> sendPushNotification(String pushToken, String to, String msg, String token) async {
    try {
      final body = {
        "message": {
          "token": pushToken,
          "notification": {
            "title": to,
            "body": msg,
          },
          "data":{
            "tipo": "3"
          }
        },
      };

      const projectID = 'cad-actopan';
      //var res = 
      await post(
        Uri.parse(
            'https://fcm.googleapis.com/v1/projects/$projectID/messages:send'),
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
          HttpHeaders.authorizationHeader: 'Bearer $token'
        },
        body: jsonEncode(body),
      );
      // log('Response status: ${res.statusCode}');
      // log('Response body: ${res.body}');
    } catch (e) {
      // log('sendPushNotificationE: $e');
    }
  }

  
}
