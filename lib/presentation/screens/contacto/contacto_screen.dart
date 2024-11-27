import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../constants/constants.dart';
import '../../widgets/my_app_bar.dart';
import '../../widgets/side_menu.dart';

class ContactoScreen extends StatefulWidget {
  static const String routeName = 'contacto';

  final String idPaciente;

  const ContactoScreen({
    Key? key, required this.idPaciente,
  }) : super(key: key);

  @override
  State<ContactoScreen> createState() => _ContactoScreenState();
}

class _ContactoScreenState extends State<ContactoScreen> with SingleTickerProviderStateMixin {
  String? _tipoapp;
  String? _userapp;

  Future<bool?> getVariables() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _tipoapp = prefs.getString("tipo_app");
    _userapp = prefs.getString("user");
    return false;
  }

  final colors = <Color>[
    const Color.fromRGBO(255, 255, 255, 1.1),
    const Color.fromRGBO(55, 171, 204, 0.8),
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final Size _size = MediaQuery.of(context).size;
    return FutureBuilder(
      future: getVariables(),
      builder: (context, snapshot) {
        if (snapshot.data == false) {
          return WillPopScope(
            onWillPop: _onWillPop,
            child: Scaffold(
                backgroundColor: Colors.white.withOpacity(1),
                appBar: myAppBar(context, nameContacto),
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
                    padding: const EdgeInsets.all(15.0),
                    child: Center(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              elevation: 5,
                              child: Padding(
                                padding: const EdgeInsets.all(15.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                      "assets/icon/icon.png",
                                      height: _size.height*0.1
                                    ),
                                    SizedBox(height: _size.height * 0.01),
                                    const Text(
                                      sucursalActopan,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: _size.height * 0.01),
                                    const Text(direccionActopan, 
                                      style: TextStyle(color: Colors.black, fontSize: 16),
                                      textAlign: TextAlign.center,
                                    ),
                                    SizedBox(height: _size.height * 0.01),
                                    const Text(correoActopan, 
                                      style: TextStyle(color: Colors.black, fontSize: 16),
                                      textAlign: TextAlign.center,
                                    ),
                                    SizedBox(height: _size.height * 0.01),
                                    const Text("WhatsApp: "+whatsappActopan, 
                                      style: TextStyle(color: Colors.black, fontSize: 16),
                                      textAlign: TextAlign.center,
                                    ),
                                    SizedBox(height: _size.height * 0.01),
                                    const Text("Tel: "+telefonoActopan, 
                                      style: TextStyle(color: Colors.black, fontSize: 16),
                                      textAlign: TextAlign.center,
                                    ),
                                    SizedBox(height: _size.height * 0.04),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                      children: [
                                        IconButton.outlined(
                                          iconSize: _size.height*0.04,
                                          color: myColor,
                                          onPressed:() {
                                            _openGoogleMaps(longitudActopan,latitudActopan);
                                        }, icon: const FaIcon(FontAwesomeIcons.mapLocationDot)),
                                        IconButton.outlined(
                                          iconSize: _size.height*0.04,
                                          color: myColor,
                                          onPressed:() {
                                            _openMail(correoActopan);
                                        }, icon: const Icon(Icons.email_outlined)),
                                        IconButton.outlined(
                                          iconSize: _size.height*0.04,
                                          color: myColor,
                                          onPressed:() {
                                            _openWhatsApp(whatsappActopan, nameActopan);
                                        }, icon: const FaIcon(FontAwesomeIcons.whatsapp)),
                                        IconButton.outlined(
                                          iconSize: _size.height*0.04,
                                          color: myColor,
                                          onPressed:() {
                                            _makePhoneCall(telefonoActopan);
                                        }, icon: const Icon(Icons.phone)),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: _size.height*0.02),
                            Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              elevation: 5,
                              child: Padding(
                                padding: const EdgeInsets.all(15.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                      "assets/icon/icon.png",
                                      height: _size.height*0.1
                                    ),
                                    SizedBox(height: _size.height * 0.01),
                                    const Text(
                                      sucursalPachuca,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: _size.height * 0.01),
                                    const Text(direccionPachuca, 
                                      style: TextStyle(color: Colors.black, fontSize: 16),
                                      textAlign: TextAlign.center,
                                    ),
                                    SizedBox(height: _size.height * 0.01),
                                    const Text(correoPachuca, 
                                      style: TextStyle(color: Colors.black, fontSize: 16),
                                      textAlign: TextAlign.center,
                                    ),
                                    SizedBox(height: _size.height * 0.01),
                                    const Text("WhatsApp: "+whatsappPachuca, 
                                      style: TextStyle(color: Colors.black, fontSize: 16),
                                      textAlign: TextAlign.center,
                                    ),
                                    SizedBox(height: _size.height * 0.01),
                                    const Text("Tel: "+telefonoPachuca, 
                                      style: TextStyle(color: Colors.black, fontSize: 16),
                                      textAlign: TextAlign.center,
                                    ),
                                    SizedBox(height: _size.height*0.04),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                      children: [
                                        IconButton.outlined(
                                          iconSize: _size.height*0.04,
                                          color: myColor,
                                          onPressed:() {
                                            _openGoogleMaps(longitudPachuca, latitudPachuca);
                                        }, icon: const FaIcon(FontAwesomeIcons.mapLocationDot)),
                                        IconButton.outlined(
                                          iconSize: _size.height*0.04,
                                          color: myColor,
                                          onPressed:() {
                                            _openMail(correoPachuca);
                                        }, icon: const Icon(Icons.email_outlined)),
                                        IconButton.outlined(
                                          iconSize: _size.height*0.04,
                                          color: myColor,
                                          onPressed:() {
                                            _openWhatsApp(whatsappPachuca, namePachuca);
                                        }, icon: const FaIcon(FontAwesomeIcons.whatsapp)),
                                        IconButton.outlined(
                                          iconSize: _size.height*0.04,
                                          color: myColor,
                                          onPressed:() {
                                            _makePhoneCall(telefonoPachuca);
                                        }, icon: const Icon(Icons.phone)),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
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

  Future<void> _openGoogleMaps(String longitud, String latitud) async {
    // ignore: deprecated_member_use
    launch('https://www.google.com/maps/search/?api=1&query=$longitud,$latitud');
    // String googleUrl = 'https://www.google.com/maps/search/?api=1&query=$longitud,$latitud';
    // if (await canLaunchUrl(Uri.parse(googleUrl))) {
    //   await launchUrl(Uri.parse(googleUrl));
    // } else {
    //   throw 'Could not open the map.';
    // }
  }

  Future<void> _openMail(String email) async {
    // ignore: deprecated_member_use
    launch('mailto:$email');
  }

  Future<void> _openWhatsApp(String numero, String nombre) async {
    // ignore: deprecated_member_use
    await launch(
         "https://wa.me/$numero?text=Hola CAD "+nombre);

    /* // con QUERY_ALL_PACKAGES
    final whatsappUrl = "whatsapp://send?phone=$numero&text=${Uri.encodeComponent("Hola CAD "+nombre)}";
    final whatsappWebUrl = "https://wa.me/$numero?text=${Uri.encodeComponent("Hola CAD "+nombre)}"; 
    try {
      if (await canLaunchUrl(Uri.parse(whatsappUrl))) {
        await launchUrl(Uri.parse(whatsappUrl), mode: LaunchMode.externalApplication);
      } else {
        if (await canLaunchUrl(Uri.parse(whatsappWebUrl))) {
          await launchUrl(Uri.parse(whatsappWebUrl), mode: LaunchMode.externalApplication);
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error al abrir WhatsApp: $e');
      }
    }*/
  }

  Future<void> _makePhoneCall(String numero) async {
    // ignore: deprecated_member_use
    launch('tel://$numero');
  }
}