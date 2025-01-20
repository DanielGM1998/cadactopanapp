import 'dart:convert';

import 'package:cadactopanapp/config/services/apis.dart';
import 'package:easy_splash_screen/easy_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:cadactopanapp/presentation/screens/home/home_screen.dart';
import 'package:cadactopanapp/presentation/screens/login/login_screen.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../../../constants/constants.dart';

class SplashScreen extends StatefulWidget {
  static const String routeName = 'splash';
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String? userIsLoggedIn;
  // ignore: prefer_typing_uninitialized_variables
  var result;

  getLoggedInState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if(prefs.getString('telefono') != null || prefs.getString('pass') != null){
      showProgress(context, prefs.getString('telefono'), prefs.getString('pass'));
    }else{
      if (mounted) {
        setState(() {
          userIsLoggedIn = "login";
        });
      }
    }
  }

  Future<String> _check(telefono, pass) async {
  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  String _version = '0.0.0';
  _version = packageInfo.version;
  try {
    var data = {"telefono": telefono, "password": pass, "version": _version};
    final response = await http.post(
        Uri( 
          scheme: 'https',
          host: 'v8.cadactopan.com.mx',
          path: '/api/login',
        ),
        body: data,
      );
    if (response.statusCode == 200) {
      String body3 = utf8.decode(response.bodyBytes);
      var jsonData = jsonDecode(body3);
      if(jsonData['success']==true){
        //print(jsonData);
        //print(jsonData['paciente']);

        if(await APIs.userExists(jsonData['paciente']['id_paciente'])){
        }else{
          await APIs.createUser(jsonData['paciente']['id_paciente'], jsonData['paciente']['nombre']+" "+jsonData['paciente']['apellidos']);
        }

        if(jsonData['paciente']['admin']==true){
          return 'Acceso correcto,'+jsonData['paciente']['nombre']+",0,"+jsonData['paciente']['id_paciente']+","+jsonData['paciente']['next']+","+jsonData['paciente']['noti']+","+jsonData['paciente']['apellidos'];
        }else{
          return 'Acceso correcto,'+jsonData['paciente']['nombre']+",1,"+jsonData['paciente']['id_paciente']+","+jsonData['paciente']['next']+","+jsonData['paciente']['noti']+","+jsonData['paciente']['apellidos'];
        }
      }else{
        //print(jsonData['mensaje']);
        if(jsonData['mensaje']=="No tiene app vigente"){
          return "No tiene app vigente";
        }
      }
    }
    return 'Error, verificar conexión a Internet';
  } catch (e) {
    return 'Error, verificar conexión a Internet';
  }
}

showProgress(BuildContext context, String? telefono, String? pass) async {
  result = await _check(telefono, pass);
  showResultDialog(context, result, telefono!, pass!);
}

Future<void> showResultDialog(
    BuildContext context, String result, String telefono, String pass) async {
    var splitted = result.split(',');
    if (result == 'Error, verificar conexión a Internet') {
      if (mounted) {
        setState(() {
          userIsLoggedIn = "login";
        });
      }
    } else if (result == 'No tiene app vigente') {
      if (mounted) {
        setState(() {
          userIsLoggedIn = "login";
        });
      }
    } else if (splitted[0] == 'Acceso correcto') {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('user', splitted[1]);
      prefs.setString('tipo_app', splitted[2]);
      prefs.setString('id_paciente', splitted[3]);
      prefs.setString('next_date', splitted[4]);
      prefs.setString('noti', splitted[5]);
      prefs.setString('telefono', telefono);
      prefs.setString('pass', pass);
      prefs.setString('user_last_name', splitted[6]);
      prefs.setBool('is_logged_in', true);
      if (mounted) {
        setState(() {
          userIsLoggedIn = "inicio";
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final Size _size = MediaQuery.of(context).size;
    return FutureBuilder(
      future: getLoggedInState(),
      builder: (context, snapshot) {
        if (userIsLoggedIn == "inicio") {
          return EasySplashScreen(
            gradientBackground: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment(0.0, 1.3),
              colors: <Color>[
                myColorBackground1,
                myColorBackground2
              ],
              tileMode: TileMode.repeated,
            ),
            logo: Image.asset(myLogo),
            logoWidth: _size.height*0.2,
            showLoader: true,
            loaderColor: myColor,
            navigator: const HomeScreen(),
            durationInSeconds: 2,
          );
        } else if (userIsLoggedIn == "login") {
          return EasySplashScreen(
            gradientBackground: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment(0.0, 1.3),
              colors: <Color>[
                myColorBackground1,
                myColorBackground2
              ],
              tileMode: TileMode.repeated,
            ),
            logo: Image.asset(myLogo),
            logoWidth: _size.height*0.2,
            showLoader: true,
            loaderColor: myColor,
            navigator: LoginScreen(mensajeToast: result),
            durationInSeconds: 2,
          );
        }
        return const SizedBox(height: 0, width: 0);
      }
    );
  }
}
