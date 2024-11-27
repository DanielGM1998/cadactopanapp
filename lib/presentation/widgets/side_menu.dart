import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:recuperacion/constants/constants.dart';
import 'package:recuperacion/presentation/screens/glucosa/glucosa_screen.dart';
import 'package:recuperacion/presentation/screens/presion/presion_screen.dart';
import '../screens/contacto/contacto_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/laboratorios/laboratorios_screen.dart';
import '../screens/receta/receta_screen.dart';

class SideMenu extends StatefulWidget {
  final String? user;
  final String? tipoapp;
  final String idPaciente;
  const SideMenu({Key? key, required this.user, this.tipoapp, required this.idPaciente}) : super(key: key);

  @override
  State<SideMenu> createState() => _SideMenuState();
}

class _SideMenuState extends State<SideMenu> {
  int? navDrawerIndex;

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
              Navigator.of(context).push(
                PageRouteBuilder(
                  barrierColor: Colors.black.withOpacity(0.6),
                  opaque: false,
                  pageBuilder: (_, __, ___) => const HomeScreen(),
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
                ),
              );
              break;
            case 1:
              Navigator.of(context).push(
                PageRouteBuilder(
                  barrierColor: Colors.black.withOpacity(0.6),
                  opaque: false,
                  pageBuilder: (_, __, ___) => GlucosaScreen(idPaciente: widget.idPaciente),
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
                ),
              );
              break;
            case 2:
              Navigator.of(context).push(
                PageRouteBuilder(
                  barrierColor: Colors.black.withOpacity(0.6),
                  opaque: false,
                  pageBuilder: (_, __, ___) => PresionScreen(idPaciente: widget.idPaciente),
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
                ),
              );
              break;
            case 3:
              Navigator.of(context).push(
                PageRouteBuilder(
                  barrierColor: Colors.black.withOpacity(0.6),
                  opaque: false,
                  pageBuilder: (_, __, ___) => RecetaScreen(idPaciente: widget.idPaciente),
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
                ),
              );
              break;
            case 4:
              Navigator.of(context).push(
                PageRouteBuilder(
                  barrierColor: Colors.black.withOpacity(0.6),
                  opaque: false,
                  pageBuilder: (_, __, ___) => const LaboratoriosScreen(),
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
                ),
              );
              break;
            case 5:
              Navigator.of(context).push(
                PageRouteBuilder(
                  barrierColor: Colors.black.withOpacity(0.6),
                  opaque: false,
                  pageBuilder: (_, __, ___) => ContactoScreen(idPaciente: widget.idPaciente),
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
                ),
              );
              break;
            default:
              Navigator.of(context).push(
                PageRouteBuilder(
                  barrierColor: Colors.black.withOpacity(0.6),
                  opaque: false,
                  pageBuilder: (_, __, ___) => const HomeScreen(),
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
                ),
              );
              break;
          }
        });
      },
      children: [
        DrawerHeader(
          decoration: const BoxDecoration(
            color: Colors.white70,
          ),
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
              const Text(nameVersion,
                  style: TextStyle(
                      color: Color.fromRGBO(0, 0, 77, 0.5), fontSize: 16)),
            ],
          ),
        ),
        const NavigationDrawerDestination(
            icon: Icon(
              Icons.home_filled,
              color: myColor,
            ),
            label: Text(
              "Inicio",
              style: TextStyle(color: myColor),
            )),
        const Divider(
          height: 1,
          thickness: 0.1,
          indent: 20,
          endIndent: 20,
          color: myColor,
        ),
        const NavigationDrawerDestination(
            icon: Icon(
              Icons.water_drop_outlined,
              color: Colors.green,
            ),
            label: Text(
              "Glucosa",
              style: TextStyle(color: myColor),
            )),
        const Divider(
          height: 1,
          thickness: 0.1,
          indent: 20,
          endIndent: 20,
          color: myColor,
        ),
        NavigationDrawerDestination(
            icon: Icon(
              Icons.favorite_border,
              color: Colors.yellow[600],
            ),
            label: const Text(
              "Presión Arterial",
              style: TextStyle(color: myColor),
            )),
        const Divider(
          height: 1,
          thickness: 0.1,
          indent: 20,
          endIndent: 20,
          color: myColor,
        ),
        const NavigationDrawerDestination(
            icon: Icon(
              Icons.medication,
              color: Colors.red,
            ),
            label: Text(
              "Receta",
              style: TextStyle(color: myColor),
            )),
        const Divider(
          height: 1,
          thickness: 0.1,
          indent: 20,
          endIndent: 20,
          color: myColor,
        ),
        const NavigationDrawerDestination(
            icon: Icon(
              Icons.assignment,
              color: Colors.deepPurple,
            ),
            label: Text(
              "Laboratorios",
              style: TextStyle(color: myColor),
            )),
        const Divider(
          height: 1,
          thickness: 0.1,
          indent: 20,
          endIndent: 20,
          color: myColor,
        ),
        const NavigationDrawerDestination(
            icon: Icon(
              Icons.contact_support_outlined,
              color: myColor,
            ),
            label: Text(
              "Contacto",
              style: TextStyle(color: myColor),
            )),
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
}
