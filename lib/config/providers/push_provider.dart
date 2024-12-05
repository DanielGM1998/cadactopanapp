import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cadactopanapp/constants/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../../main.dart';
import '../../presentation/screens/notifications/notificaciones_screen.dart';

class PushProvider {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  final int typeNotification = 1;
  final int typeRefreshData = 2;
  final int typeChatMessage = 3;

  final _msgStreamController = StreamController<String>.broadcast();
  Stream<String> get notificacion => _msgStreamController.stream;

  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  String _version = '0.0.0';
  Future<void> _checkVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    _version = packageInfo.version;
  }

  void initPush() async {
    // Solicitar permisos de notificaciones
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      //print('Permisos de notificaciones otorgados.');
    } else {
      //print('Permisos de notificaciones denegados.');
      return;
    }

    // Obtener token de FCM
    _firebaseMessaging.getToken().then((token) async {
      //print('==== FCM Token ====');
      //print(token);

      SharedPreferences prefs = await _prefs;
      String _tokenSaved = prefs.getString('token') ?? '';
      int paciente = int.parse(prefs.getString('id_paciente') ?? '0');

      if (paciente != 0 && token != null) {
        FirebaseFirestore.instance
            .collection('users')
            .doc(paciente.toString())
            .update({
          'id': paciente.toString(),
          'pushToken': token,
        });

        if (_tokenSaved != token) {
          try {
            await _checkVersion();
            var data = {"paciente": paciente.toString(), "token": token, "version": _version};
            final response = await http.post(
                Uri( 
                  scheme: 'https',
                  host: 'v8.cadactopan.com.mx',
                  path: '/api/saveFBToken',
                ),
                body: data,
              );
            if (response.statusCode == 200) {
              String body3 = utf8.decode(response.bodyBytes);
              var jsonData = jsonDecode(body3);
              if(jsonData['success']==true){
                prefs.setString('token', token);
              }
            }
          } catch (e) {
            return 'Error, verificar conexión a Internet';
          }
        }
      }
    });

    // Listeners para notificaciones
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async{
      // print('Mensaje recibido en primer plano: ${message.notification?.title}');
      // print('Mensaje recibido en primer plano: ${message.notification?.body}');
      // print('=============== onMessage ====================');
      // print('Message data: ${message.data}');
      int tipo = _getNotificationType(message);

      if (tipo == typeNotification) {
        _msgStreamController.sink.add('onMessage');

        await flutterLocalNotificationsPlugin.show(
          0,
          message.notification?.title,
          message.notification?.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              'your_channel_id', 'your_channel_name',
              importance: Importance.max,
              priority: Priority.high,
              icon: '@mipmap/launcher_icon', 
              largeIcon: const DrawableResourceAndroidBitmap('@mipmap/launcher_icon'), 
              color: myColor, 
              styleInformation: BigTextStyleInformation(
                message.notification?.body ?? "",
                contentTitle: message.notification?.title,
                htmlFormatContent: true,
                htmlFormatContentTitle: true,
              ),
              playSound: true, 
              ticker: 'ticker',
              enableVibration: true,
            ),
          ),
        );

      } else if (tipo == typeRefreshData) {
        _msgStreamController.sink.add('REFRESH_DATA');
      } else if (tipo == typeChatMessage) {
        _msgStreamController.sink.add('CHAT_MESSAGE');
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async{
      // print('Notificación tocada: ${message.notification?.title}');
      // print('Notificación tocada: ${message.notification?.body}');
      // print('=============== onMessageOpenedApp ====================');
      // print('Message data: ${message.data}');
      int tipo = _getNotificationType(message);

      String titulo = message.notification?.title ?? 'Sin título';
      if (tipo == typeNotification) {
        _msgStreamController.sink.add(titulo);
      } else if (tipo == typeRefreshData) {
        _msgStreamController.sink.add('REFRESH_DATA');
      }

      if (titulo.isNotEmpty && titulo != "Sin título") { 

        SharedPreferences prefs = await _prefs;
        int paciente = int.parse(prefs.getString('id_paciente') ?? '0');

        navigatorKey.currentState?.pushReplacement(
          MaterialPageRoute(
            builder: (_) => NotificacionesScreen(idPaciente: paciente.toString()),
          ),
        );

      }

    });

    RemoteMessage? initialMessage = await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      // print('=============== getInitialMessage ====================');
      // print('Message data: ${initialMessage.data}');
      int tipo = _getNotificationType(initialMessage);

      String titulo = initialMessage.notification?.title ?? 'Sin título';
      if (tipo == typeNotification) {
        _msgStreamController.sink.add(titulo);
      } else if (tipo == typeRefreshData) {
        _msgStreamController.sink.add('REFRESH_DATA');
      }
    }
  }

  // Método auxiliar para determinar el tipo de notificación
  int _getNotificationType(RemoteMessage message) {
    int tipo = 1;
    if (Platform.isAndroid) {
      tipo = int.parse(message.data['type'] ?? '1');
    } else {
      tipo = int.parse(message.data['type'] ?? '1');
    }
    return tipo;
  }

  void dispose() {
    _msgStreamController.close();
  }
}
