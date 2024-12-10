import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // Configura el manejador de mensajes en segundo plano
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );
  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (NotificationResponse response) async{
      // Aquí puedes manejar la navegación si el id se manda desde el push
      //final String? payload = response.payload;

      SharedPreferences prefs = await SharedPreferences.getInstance();
      int paciente = int.parse(prefs.getString('id_paciente') ?? '0');

      //if (payload != null && payload.isNotEmpty) {
        navigatorKey.currentState?.pushReplacement(
          MaterialPageRoute(
            //builder: (_) => NotificacionesScreen(idPaciente: payload),
            builder: (_) => NotificacionesScreen(idPaciente: paciente.toString()),
          ),
        );
      //}
    });
  await initializeDateFormatting('es', null); // Inicializa para español
  Intl.defaultLocale = 'es'; // Configura el locale predeterminado
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
