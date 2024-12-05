import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:cadactopanapp/constants/constants.dart';
import 'package:cadactopanapp/presentation/screens/glucosa/glucosa_screen.dart';
import 'package:cadactopanapp/presentation/screens/presion/presion_screen.dart';
import '../screens/contacto/contacto_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/laboratorios/laboratorios_screen.dart';
import '../screens/receta/receta_screen.dart';

class SideMenu extends StatefulWidget {
  final String? user;
  final String? tipoapp;
  final String idPaciente;
  const SideMenu({
    Key? key,
    required this.user,
    this.tipoapp,
    required this.idPaciente,
  }) : super(key: key);

  @override
  State<SideMenu> createState() => _SideMenuState();
}

class _SideMenuState extends State<SideMenu> {
  int? navDrawerIndex;
  late Future<String> _versionFuture;

  @override
  void initState() {
    super.initState();
    _versionFuture = _checkVersion();
  }

  Future<String> _checkVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.version;
  }

  @override
  Widget build(BuildContext context) {
    final Size _size = MediaQuery.of(context).size;

    return NavigationDrawer(
      backgroundColor: Colors.white,
      selectedIndex: navDrawerIndex,
      onDestinationSelected: (value) {
        setState(() {
          navDrawerIndex = value;
          switch (navDrawerIndex) {
            case 0:
              Navigator.of(context).pushReplacement(
                _buildPageRoute(const HomeScreen()),
              );
              break;
            case 1:
              Navigator.of(context).pushReplacement(
                _buildPageRoute(GlucosaScreen(idPaciente: widget.idPaciente)),
              );
              break;
            case 2:
              Navigator.of(context).pushReplacement(
                _buildPageRoute(PresionScreen(idPaciente: widget.idPaciente)),
              );
              break;
            case 3:
              Navigator.of(context).pushReplacement(
                _buildPageRoute(RecetaScreen(idPaciente: widget.idPaciente)),
              );
              break;
            case 4:
              Navigator.of(context).pushReplacement(
                _buildPageRoute(const LaboratoriosScreen()),
              );
              break;
            case 5:
              Navigator.of(context).pushReplacement(
                _buildPageRoute(ContactoScreen(idPaciente: widget.idPaciente)),
              );
              break;
            default:
              Navigator.of(context).pushReplacement(
                _buildPageRoute(const HomeScreen()),
              );
              break;
          }
        });
      },
      children: [
        FutureBuilder<String>(
          future: _versionFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const DrawerHeader(
                decoration: BoxDecoration(color: Colors.white70),
                child: Center(child: CircularProgressIndicator()),
              );
            } else if (snapshot.hasError) {
              return const DrawerHeader(
                decoration: BoxDecoration(color: Colors.white70),
                child: Center(child: Text("Error al cargar la versión")),
              );
            } else {
              return DrawerHeader(
                decoration: const BoxDecoration(color: Colors.white70),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.asset(
                      myLogo,
                      height: _size.height * 0.06,
                      width: _size.width * 0.5,
                    ),
                    SizedBox(height: _size.width * 0.015),
                    Text(widget.user!,
                        style: const TextStyle(
                            color: Color.fromRGBO(0, 0, 77, 1), fontSize: 18)),
                    Text(nameVersion + snapshot.data!,
                        style: const TextStyle(
                            color: Color.fromRGBO(0, 0, 77, 0.5), fontSize: 16)),
                  ],
                ),
              );
            }
          },
        ),
        const NavigationDrawerDestination(
          icon: Icon(Icons.home_filled, color: myColor),
          label: Text("Inicio", style: TextStyle(color: myColor)),
        ),
        const Divider(
          height: 1,
          thickness: 0.1,
          indent: 20,
          endIndent: 20,
          color: myColor,
        ),
        const NavigationDrawerDestination(
          icon: Icon(Icons.water_drop_outlined, color: Colors.green),
          label: Text("Glucosa", style: TextStyle(color: myColor)),
        ),
        const Divider(
          height: 1,
          thickness: 0.1,
          indent: 20,
          endIndent: 20,
          color: myColor,
        ),
        NavigationDrawerDestination(
          icon: Icon(Icons.favorite_border, color: Colors.yellow[600]),
          label: const Text("Presión Arterial", style: TextStyle(color: myColor)),
        ),
        const Divider(
          height: 1,
          thickness: 0.1,
          indent: 20,
          endIndent: 20,
          color: myColor,
        ),
        const NavigationDrawerDestination(
          icon: Icon(Icons.medication, color: Colors.red),
          label: Text("Receta", style: TextStyle(color: myColor)),
        ),
        const Divider(
          height: 1,
          thickness: 0.1,
          indent: 20,
          endIndent: 20,
          color: myColor,
        ),
        const NavigationDrawerDestination(
          icon: Icon(Icons.assignment, color: Colors.deepPurple),
          label: Text("Laboratorios", style: TextStyle(color: myColor)),
        ),
        const Divider(
          height: 1,
          thickness: 0.1,
          indent: 20,
          endIndent: 20,
          color: myColor,
        ),
        const NavigationDrawerDestination(
          icon: Icon(Icons.contact_support_outlined, color: myColor),
          label: Text("Contacto", style: TextStyle(color: myColor)),
        ),
        const Divider(
          height: 1,
          thickness: 0.1,
          indent: 20,
          endIndent: 20,
          color: myColor,
        ),
      ],
    );
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
}
