import 'dart:convert';
import 'dart:ui';

import 'package:awesome_top_snackbar/awesome_top_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:future_progress_dialog/future_progress_dialog.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:cadactopanapp/presentation/screens/home/home_screen.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../../../constants/constants.dart';

class LoginScreen extends StatefulWidget {
  static const String routeName = 'login';

  final String? mensajeToast;

  const LoginScreen({
    Key? key, this.mensajeToast,
  }) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String _telefono = "";
  String _contrasena = "";
  bool _passwordVisible = true;
  var textController = TextEditingController();

  bool _toastShown = false;

  Future<void> requestPermission() async {
    var status = await Permission.notification.request();
    if (status == PermissionStatus.granted) {
      //print('Permiso otorgado');
    } else {
      //print('Permiso denegado');
    }
  }
  
  @override
  void initState() {
    super.initState();
    requestPermission();
    if (!_toastShown) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if(widget.mensajeToast == "Error, verificar conexión a Internet"){
          awesomeTopSnackbar(
            context,
            "Error, verificar conexión a Internet",
            textStyle: const TextStyle(
                color: Colors.white,
                fontStyle: FontStyle.normal,
                fontWeight: FontWeight.w400,
                fontSize: 16),
            backgroundColor:
                Colors.redAccent,
            icon: const Icon(Icons.error,
                color: Colors.black),
            iconWithDecoration: BoxDecoration(
              borderRadius:
                  BorderRadius.circular(20),
              border: Border.all(
                  color: Colors.black),
            ),
          );
        }else if(widget.mensajeToast == "No tiene app vigente"){
          awesomeTopSnackbar(
            context,
            "No tiene app vigente",
            textStyle: const TextStyle(
                color: Colors.white,
                fontStyle: FontStyle.normal,
                fontWeight: FontWeight.w400,
                fontSize: 16),
            backgroundColor:
                Colors.redAccent,
            icon: const Icon(Icons.error,
                color: Colors.black),
            iconWithDecoration: BoxDecoration(
              borderRadius:
                  BorderRadius.circular(20),
              border: Border.all(
                  color: Colors.black),
            ),
          );
        }
      });
    }
    _toastShown = true;
  }

  @override
  Widget build(BuildContext context) {
    final Size _size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment(0.0, 1.3),
              colors: <Color>[
                myColorBackground1,
                myColorBackground2,
              ],
              tileMode: TileMode.repeated,
            ),
          ),
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverFillRemaining(
                hasScrollBody: false,
                child: Padding(
                  padding: const EdgeInsets.only(left: 16, right: 16),
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 120,
                      ),
                      Image.asset(myLogo,
                          width: _size.width * 0.70),
                      SizedBox(
                        height: _size.height*0.12,
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            alignment: Alignment.center,
                            padding: const EdgeInsets.symmetric(horizontal: 40),
                            child: const Text(
                              "Inicio de Sesión",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: myColor,
                                  fontSize: 25),
                              textAlign: TextAlign.left,
                            ),
                          ),
                          SizedBox(height: _size.height * 0.02),
                          //////
                          Column(
                            children: <Widget>[
                              SizedBox(
                                height: _size.height*0.012,
                              ),
                              Theme(
                                data: Theme.of(context).copyWith(
                                  colorScheme: ThemeData().colorScheme.copyWith(
                                        primary: myColor,
                                      ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 10, right: 10),
                                  child: TextField(
                                    maxLength: 10,
                                    keyboardType: const TextInputType
                                              .numberWithOptions(
                                              decimal: false, signed: false),
                                          inputFormatters: <TextInputFormatter>[
                                            FilteringTextInputFormatter
                                                .digitsOnly
                                          ],
                                    cursorColor:
                                        myColor,
                                    onChanged: (valor) {
                                      setState(() {
                                        _telefono = valor;
                                      });
                                    },
                                    decoration: const InputDecoration(
                                        border: OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(10))),
                                        hintText: "Teléfono del usuario",
                                        labelText: "Teléfono",
                                        labelStyle: TextStyle(color: myColor),
                                        suffixIcon: Icon(
                                          Icons.numbers,
                                          size: 30,
                                          color: myColor,
                                        ),
                                        icon: Icon(
                                          Icons.numbers_outlined,
                                          color: myColor,
                                        )),
                                    textInputAction: TextInputAction.next,
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: _size.height*0.012,
                              ),
                              Theme(
                                data: Theme.of(context).copyWith(
                                  colorScheme: ThemeData().colorScheme.copyWith(
                                        primary: myColor,
                                      ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 10, right: 10),
                                  child: TextField(
                                    obscureText: _passwordVisible,
                                    enableSuggestions: false,
                                    autocorrect: false,
                                    cursorColor: myColor,
                                    onChanged: (valor) {
                                      setState(() {
                                        _contrasena = valor;
                                      });
                                    },
                                    decoration: InputDecoration(
                                        border: const OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(10))),
                                        hintText: "Contraseña del usuario",
                                        labelText: "Contraseña",
                                        labelStyle: const TextStyle(color: myColor),
                                        suffixIcon: IconButton(
                                            onPressed: () {
                                              setState(() {
                                                _passwordVisible =
                                                    !_passwordVisible;
                                              });
                                            },
                                            icon: Icon(
                                              _passwordVisible
                                                  ? Icons.visibility
                                                  : Icons.visibility_off,
                                              size: 30,
                                              color: myColor,
                                            )),
                                        icon: const Icon(
                                          Icons.bookmark,
                                          color: myColor,
                                        )),
                                    textInputAction: TextInputAction.done,
                                    onSubmitted: (value) async {
                                      if (_telefono != "" && _contrasena != "") {
                                        //bool isValid =
                                            //EmailValidator.validate(_telefono);
                                        //if (isValid) {
                                          if (_contrasena.length < 6) {
                                            awesomeTopSnackbar(
                                              context,
                                              "La contraseña debe incluir al menos 6 caracteres",
                                              textStyle: const TextStyle(
                                                  color: Colors.white,
                                                  fontStyle: FontStyle.normal,
                                                  fontWeight: FontWeight.w400,
                                                  fontSize: 20),
                                              backgroundColor:
                                                  Colors.orangeAccent,
                                              icon: const Icon(Icons.check,
                                                  color: Colors.black),
                                              iconWithDecoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                border: Border.all(
                                                    color: Colors.black),
                                              ),
                                            );
                                          } else {
                                            showProgress(
                                                context, _telefono, _contrasena);
                                          }
                                        // } else {
                                        //   awesomeTopSnackbar(
                                        //     context,
                                        //     "Debe ingresar un Email valido",
                                        //     textStyle: const TextStyle(
                                        //         color: Colors.white,
                                        //         fontStyle: FontStyle.normal,
                                        //         fontWeight: FontWeight.w400,
                                        //         fontSize: 20),
                                        //     backgroundColor:
                                        //         Colors.orangeAccent,
                                        //     icon: const Icon(Icons.check,
                                        //         color: Colors.black),
                                        //     iconWithDecoration: BoxDecoration(
                                        //       borderRadius:
                                        //           BorderRadius.circular(20),
                                        //       border: Border.all(
                                        //           color: Colors.black),
                                        //     ),
                                        //   );
                                        // }
                                      } else {
                                        awesomeTopSnackbar(
                                          context,
                                          "Debe ingrese email y contraseña",
                                          textStyle: const TextStyle(
                                              color: Colors.white,
                                              fontStyle: FontStyle.normal,
                                              fontWeight: FontWeight.w400,
                                              fontSize: 20),
                                          backgroundColor: Colors.orangeAccent,
                                          icon: const Icon(Icons.check,
                                              color: Colors.black),
                                          iconWithDecoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            border:
                                                Border.all(color: Colors.black),
                                          ),
                                        );
                                      }
                                    },
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: _size.height*0.02,
                              ),
                            ],
                          ),
                          //////
                          
                          // GestureDetector(
                          //   onTap: () {
                          //     Navigator.of(context).push(
                          //       PageRouteBuilder(
                          //         barrierColor: Colors.black.withOpacity(0.6),
                          //         opaque: false,
                          //         pageBuilder: (_, __, ___) =>
                          //             const RecuperarPage(),
                          //         transitionDuration:
                          //             const Duration(milliseconds: 800),
                          //         transitionsBuilder:
                          //             (_, animation, __, child) {
                          //           return BackdropFilter(
                          //             filter: ImageFilter.blur(
                          //               sigmaX: 10 * animation.value,
                          //               sigmaY: 10 * animation.value,
                          //             ),
                          //             child: FadeTransition(
                          //               opacity: animation,
                          //               child: child,
                          //             ),
                          //           );
                          //         },
                          //       ),
                          //     );
                          //   },
                          //   child: Container(
                          //     alignment: Alignment.centerRight,
                          //     margin: const EdgeInsets.symmetric(
                          //         horizontal: 40, vertical: 10),
                          //     child: const Text(
                          //       "¿Olvidaste tu contraseña?",
                          //       style: TextStyle(
                          //           fontSize: 12, color: Color(0XFF2661FA)),
                          //     ),
                          //   ),
                          // ),

                          ///
                          Container(
                            alignment: Alignment.centerRight,
                            margin: const EdgeInsets.only(
                                top: 10, right: 40, left: 40),
                            child: OutlinedButton(
                              onPressed: () async {
                                if (_telefono != "" && _contrasena != "") {
                                  if (_contrasena.length < 6) {
                                    awesomeTopSnackbar(
                                      context,
                                      "La contraseña debe incluir al menos 6 caracteres",
                                      textStyle: const TextStyle(
                                          color: Colors.white,
                                          fontStyle: FontStyle.normal,
                                          fontWeight: FontWeight.w400,
                                          fontSize: 16),
                                      backgroundColor:
                                          Colors.redAccent,
                                      icon: const Icon(Icons.error,
                                          color: Colors.black),
                                      iconWithDecoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(20),
                                        border: Border.all(
                                            color: Colors.black),
                                      ),
                                    );
                                  } else {
                                    showProgress(
                                        context, _telefono, _contrasena);
                                  }
                                } else {
                                  awesomeTopSnackbar(
                                    context,
                                    "Debe ingrese usuario y contraseña",
                                    textStyle: const TextStyle(
                                        color: Colors.white,
                                        fontStyle: FontStyle.normal,
                                        fontWeight: FontWeight.w400,
                                        fontSize: 16),
                                    backgroundColor:
                                        Colors.redAccent,
                                    icon: const Icon(Icons.error,
                                        color: Colors.black),
                                    iconWithDecoration: BoxDecoration(
                                      borderRadius:
                                          BorderRadius.circular(20),
                                      border: Border.all(
                                          color: Colors.black),
                                    ),
                                  );
                                }
                              },
                              child: const Text(
                                "Iniciar sesión",
                                style: TextStyle(
                                    color: myColor),
                              ),
                            ),
                          ),
                          Container(
                              color: Colors.transparent,
                              height: _size.height * 0.10),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
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
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('No'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Si'),
              ),
            ],
          ),
        )) ??
        false;
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
        // headers: <String, String>{
        //   'Content-Type': 'application/json; charset=UTF-8',
        //   'Access-Control-Allow-Origin': '*'
        // },
      );
    if (response.statusCode == 200) {
      String body3 = utf8.decode(response.bodyBytes);
      var jsonData = jsonDecode(body3);
      if(jsonData['success']==true){
        //print(jsonData);
        //print(jsonData['paciente']);
        if(jsonData['paciente']['admin']==true){
          return 'Acceso correcto,'+jsonData['paciente']['nombre']+",0,"+jsonData['paciente']['id_paciente']+","+jsonData['paciente']['next']+","+jsonData['paciente']['noti'];
        }else{
          return 'Acceso correcto,'+jsonData['paciente']['nombre']+",1,"+jsonData['paciente']['id_paciente']+","+jsonData['paciente']['next']+","+jsonData['paciente']['noti'];
        }
      }else{
        if(jsonData['mensaje']=="No tiene app vigente"){
          return "No tiene app vigente";
        }
        return 'Verifique sus datos';
      }
    } else {
      return 'Error, verificar conexión a Internet';
    }
  } catch (e) {
    return 'Error, verificar conexión a Internet';
  }
}

showProgress(BuildContext context, String telefono, String pass) async {
  var result = await showDialog(
    context: context,
    builder: (context) => FutureProgressDialog(_check(telefono, pass)),
  );
  showResultDialog(context, result, telefono, pass);
}

Future<void> showResultDialog(
    BuildContext context, String result, String telefono, String pass) async {
  var splitted = result.split(',');
  if (result == 'Error, verificar conexión a Internet') {
    awesomeTopSnackbar(
      context,
      "No tiene app vigente",
      textStyle: const TextStyle(
          color: Colors.white,
          fontStyle: FontStyle.normal,
          fontWeight: FontWeight.w400,
          fontSize: 16),
      backgroundColor:
          Colors.redAccent,
      icon: const Icon(Icons.error,
          color: Colors.black),
      iconWithDecoration: BoxDecoration(
        borderRadius:
            BorderRadius.circular(20),
        border: Border.all(
            color: Colors.black),
      ),
    );
  } else if (result == 'Verifique sus datos') {
    awesomeTopSnackbar(
      context,
      "Verifique sus datos",
      textStyle: const TextStyle(
          color: Colors.white,
          fontStyle: FontStyle.normal,
          fontWeight: FontWeight.w400,
          fontSize: 16),
      backgroundColor:
          Colors.redAccent,
      icon: const Icon(Icons.error,
          color: Colors.black),
      iconWithDecoration: BoxDecoration(
        borderRadius:
            BorderRadius.circular(20),
        border: Border.all(
            color: Colors.black),
      ),
    );
  } else if (result == 'No tiene app vigente') {
    awesomeTopSnackbar(
      context,
      "No tiene app vigente",
      textStyle: const TextStyle(
          color: Colors.white,
          fontStyle: FontStyle.normal,
          fontWeight: FontWeight.w400,
          fontSize: 16),
      backgroundColor:
          Colors.redAccent,
      icon: const Icon(Icons.error,
          color: Colors.black),
      iconWithDecoration: BoxDecoration(
        borderRadius:
            BorderRadius.circular(20),
        border: Border.all(
            color: Colors.black),
      ),
    );
  } else if (splitted[0] == 'Acceso correcto') {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('user', splitted[1]);
    prefs.setString('tipo_app', splitted[2]);
    prefs.setString('id_paciente', splitted[3]);
    prefs.setString('next_date', splitted[4]);
    prefs.setString('noti', splitted[5]);
    prefs.setString('telefono', telefono);
    prefs.setString('pass', pass);
    prefs.setBool('is_logged_in', true);
    Navigator.of(context).push(
      PageRouteBuilder(
        barrierColor: Colors.black.withOpacity(0.6),
        opaque: false,
        pageBuilder: (_, __, ___) => const HomeScreen(),
        transitionDuration: const Duration(milliseconds: 400),
        transitionsBuilder: (_, animation, __, child) {
          return BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: 10 * animation.value,
              sigmaY: 10 * animation.value,
            ),
            child: FadeTransition(
              opacity: animation,
              child: child,
            ),
          );
        },
      ),
    );
  }
}
