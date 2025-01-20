import 'dart:async';
import 'dart:convert';

import 'package:cadactopanapp/constants/constants.dart';
import 'package:cadactopanapp/presentation/screens/chat/chat_users_screen.dart';
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
  static final PushProvider _instance = PushProvider._internal();
  factory PushProvider() => _instance;
  PushProvider._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  final _msgStreamController = StreamController<String>.broadcast();
  Stream<String> get notificacion => _msgStreamController.stream;

  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  bool _listenersInitialized = false;

  String _version = '0.0.0';
  Future<void> _checkVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    _version = packageInfo.version;
  }

  Future<void> initPush() async {

    if (_listenersInitialized) return; // Verifica si ya fue inicializado
    _listenersInitialized = true; // Marca como inicializado

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
      // log('Permisos de notificaciones otorgados.');
    } else {
      // log('Permisos de notificaciones denegados.');
      return;
    }

    // Obtener token de FCM
    _firebaseMessaging.getToken().then((token) async {
      // log('==== FCM Token ====');
      // log(token);

      SharedPreferences prefs = await _prefs;
      String _tokenSaved = prefs.getString('token') ?? '';
      int paciente = int.parse(prefs.getString('id_paciente') ?? '0');

      if (paciente != 0 && token != null) {
        FirebaseFirestore.instance
            .collection('usuarios')
            .doc(paciente.toString())
            .update({
              'id': paciente.toString(),
              'push_token': token,
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

    // Listener para notificaciones en primer plano
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async{
      // log('=============== onMessage ====================');
      // log('Mensaje recibido en primer plano: ${message.notification?.title}');
      // log('Mensaje recibido en primer plano: ${message.notification?.body}');
      //log("Datos onMessage: ${message.data}");
      
      int tipo = _getNotificationType(message);
      //log("Tipo onMessage: ${tipo.toString()}");

      switch (tipo) {
        case 1: // typeNotification
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
            payload: jsonEncode({
              "tipo": "typeNotification",
            }), 
          );
          break;
        case 2: // typeRefreshData
          _msgStreamController.sink.add('REFRESH_DATA');  
          break;
        case 3: // typeChatMessage
          _msgStreamController.sink.add('CHAT_MESSAGE');

          await flutterLocalNotificationsPlugin.show(
            0,
            message.notification?.title,
            message.notification?.body,
            NotificationDetails(
              android: AndroidNotificationDetails(
                'your_channel_id', 'your_channel_name',
                importance: Importance.defaultImportance,
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
            payload: jsonEncode({
              "tipo": "CHAT_MESSAGE",
            }), 
          );
          break;
        default:
        // log("Tipo de notificación desconocido: $tipo");
      }
    });

    // Listener para notificaciones tocadas (segundo plano)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async{
      // log('=============== onMessageOpenedApp ====================');
      // log('Notificación tocada: ${message.notification?.title}');
      // log('Notificación tocada: ${message.notification?.body}');
      // log("Datos onMessageOpenedApp: ${message.data}");
      
      int tipo = _getNotificationType(message);
      //log("Tipo onMessageOpenedApp: ${tipo.toString()}");

      SharedPreferences prefs = await _prefs;
      int paciente = int.parse(prefs.getString('id_paciente') ?? '0');

      switch (tipo) {
        case 1: // typeNotification
          // String titulo = message.notification?.title ?? 'Sin título';
          // _msgStreamController.sink.add(titulo);
          navigatorKey.currentState?.pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (_) => NotificacionesScreen(idPaciente: paciente.toString()),
            ),
            (Route<dynamic> route) => false,
          );
          break;
        case 2: // typeRefreshData
          //_msgStreamController.sink.add('REFRESH_DATA');
          break;
        case 3: // typeChatMessage
          //_msgStreamController.sink.add('CHAT_MESSAGE');
          navigatorKey.currentState?.pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (_) => ChatUsersScreen(idPaciente: paciente.toString()),
            ),
            (Route<dynamic> route) => false,
          );
          break;
        default:
      }
    });

    // Manejo de notificación que activa la app desde estado "terminado"
    RemoteMessage? initialMessage = await _firebaseMessaging.getInitialMessage();
    //   log('=============== getInitialMessage ====================');
    //   log('Message data: ${initialMessage.data}');
    
    if (initialMessage != null) {
      int tipo = _getNotificationType(initialMessage);
      SharedPreferences prefs = await _prefs;
      int paciente = int.parse(prefs.getString('id_paciente') ?? '0');

      switch (tipo) {
        case 1: // typeNotification
          //     String titulo = initialMessage.notification?.title ?? 'Sin título';
          //     _msgStreamController.sink.add(titulo);
          navigatorKey.currentState?.pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (_) => NotificacionesScreen(idPaciente: paciente.toString()),
            ),
            (Route<dynamic> route) => false,
          );
          break;
        case 2: // typeNotification
          //     _msgStreamController.sink.add('REFRESH_DATA');
          break;
        case 3: // typeChatMessage
          //     _msgStreamController.sink.add('CHAT_MESSAGE');
          navigatorKey.currentState?.pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (_) => ChatUsersScreen(idPaciente: paciente.toString()),
            ),
            (Route<dynamic> route) => false,
          );
          break;
        default:
      }
    }
  }

  // Método auxiliar para determinar el tipo de notificación
  int _getNotificationType(RemoteMessage message) {
    return int.tryParse(message.data['tipo'] ?? '0') ?? 0;
  }

  void dispose() {
    _msgStreamController.close();
  }
}
