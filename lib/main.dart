import 'dart:convert';

import 'package:cadactopanapp/presentation/screens/chat/chat_users_screen.dart';
import 'package:cloudflare/cloudflare.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:cadactopanapp/constants/constants.dart';
import 'package:cadactopanapp/presentation/screens/home/home_screen.dart';
import 'package:cadactopanapp/presentation/screens/login/login_screen.dart';
import 'package:cadactopanapp/presentation/screens/splash/splash_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'config/theme/app_theme.dart';
import 'presentation/screens/notifications/notificaciones_screen.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Maneja mensajes en segundo plano
  //print('Mensaje en segundo plano: ${message.messageId}');
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// Cloudflare
late Cloudflare cloudflare;
String? cloudflareInitMessage;

void configEasyLoading() {
  EasyLoading.instance
    ..indicatorType = EasyLoadingIndicatorType.circle
    ..loadingStyle = EasyLoadingStyle.light
    ..maskColor = myColor
    ..progressColor = myColor
    ..textColor = myColor
    ..dismissOnTap = false
    ..userInteractions = false;
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Configura el manejador de mensajes en segundo plano
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  const InitializationSettings initializationSettings = InitializationSettings(
    android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    iOS: DarwinInitializationSettings(),
  );
  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (NotificationResponse response) async{  
      //log("Notificación interactuada: ${response.payload}");
      // Si tienes un payload (puedes usarlo para navegar o procesar algo)
      if (response.payload != null && response.payload!.isNotEmpty) {
        final data = jsonDecode(response.payload!);
        //log("Datos en el payload: $data");

        if (data['tipo'] == "CHAT_MESSAGE") {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          int paciente = int.parse(prefs.getString('id_paciente') ?? '0');
          navigatorKey.currentState?.pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (_) => ChatUsersScreen(idPaciente: paciente.toString()),
            ),
            (Route<dynamic> route) => false,
          );
        }else {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          int paciente = int.parse(prefs.getString('id_paciente') ?? '0');
          navigatorKey.currentState?.pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (_) => NotificacionesScreen(idPaciente: paciente.toString()),
            ),
            (Route<dynamic> route) => false,
          );
        }
      }

    });
    
  await initializeDateFormatting('es', null); // Inicializa para español
  Intl.defaultLocale = 'es'; // Configura el locale predeterminado

  // CloudFlare
  try {
    cloudflare = Cloudflare(
      apiUrl: apiUrl,
      accountId: accountId,
      token: tokenCloudflare,
      apiKey: apiKey,
      accountEmail: accountEmail,
      userServiceKey: userServiceKey,
    );
    await cloudflare.init();
  } catch (e) {
    cloudflareInitMessage = '''
    Check your environment definitions for Cloudflare.
    Make sure to run this app with:  
    
    flutter run
    --dart-define=CLOUDFLARE_API_URL=https://api.cloudflare.com/client/v4
    --dart-define=CLOUDFLARE_ACCOUNT_ID=xxxxxxxxxxxxxxxxxxxxxxxxxxx
    --dart-define=CLOUDFLARE_TOKEN=xxxxxxxxxxxxxxxxxxxxxxxxxxx
    --dart-define=CLOUDFLARE_API_KEY=xxxxxxxxxxxxxxxxxxxxxxxxxxx
    --dart-define=CLOUDFLARE_ACCOUNT_EMAIL=xxxxxxxxxxxxxxxxxxxxxxxxxxx
    --dart-define=CLOUDFLARE_USER_SERVICE_KEY=xxxxxxxxxxxxxxxxxxxxxxxxxxx
    
    Exception details:
    ${e.toString()}
    ''';
  }

  // Limpia la caché para evitar errores de migración
  await DefaultCacheManager().emptyCache();

  // Config progressdialog
  configEasyLoading();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return MaterialApp(
      title: nameApp,
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      theme: AppTheme(selectedColor: 0).getTheme(),
      builder: EasyLoading.init(),
      // localizationsDelegates: GlobalMaterialLocalizations.delegates,
      // supportedLocales: const [
      //   Locale('en', ''),
      //   Locale('es', ''),
      // ],
      initialRoute: SplashScreen.routeName,
      routes: {
        SplashScreen.routeName: (BuildContext context) => const SplashScreen(),
        LoginScreen.routeName: (BuildContext context) => const LoginScreen(),
        HomeScreen.routeName: (BuildContext context) => const HomeScreen(),
      },
    );
  }
}
