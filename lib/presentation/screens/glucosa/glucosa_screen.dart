import 'dart:async';
import 'dart:convert';

import 'package:awesome_top_snackbar/awesome_top_snackbar.dart';
import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cupertino_datetime_picker/flutter_cupertino_datetime_picker.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../../../constants/constants.dart';
import '../../widgets/dialogs.dart';
import '../../widgets/my_app_bar.dart';
import '../../widgets/side_menu.dart';

class GlucosaScreen extends StatefulWidget {
  static const String routeName = 'glucosa';

  final String idPaciente;

  const GlucosaScreen({
    Key? key, required this.idPaciente,
  }) : super(key: key);

  @override
  State<GlucosaScreen> createState() => _GlucosaScreenState();
}

class _GlucosaScreenState extends State<GlucosaScreen> {
  String? _tipoapp;
  String? _userapp;

  final _key = GlobalKey<ExpandableFabState>();

  List<dynamic> glucosas = [];
  bool isLoading = false; 
  bool finalScreen = false;

  // glucosa de 4 puntos
  DateTime now = DateTime.now();
  late DateTime _dateTime;
  String _value = '120';
  final TextEditingController _gluController = TextEditingController();
  bool _gluError = false;
  final GlobalKey<State> _keyModal = GlobalKey<State>();
  final GlobalKey<State> _keyLoader = GlobalKey<State>();
  List arrDia = ['dom', 'lun', 'mar', 'mie', 'jue', 'vie', 'sab'];
  List arrMes = [
    '',
    'enero',
    'febrero',
    'marzo',
    'abril',
    'mayo',
    'junio',
    'julio',
    'agosto',
    'septiembre',
    'octubre',
    'noviembre',
    'diciembre'
  ];

  Future<bool?> getVariables() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _tipoapp = prefs.getString("tipo_app");
    _userapp = prefs.getString("user");
    return false;
  }

  bool isFirstLoadRunning = false;
  bool hasNextPage = true;
  bool isLoadMoreRunning = false;
  int page = 1;
  final int limit = 50;
  List items = [];
  late ScrollController controller;

  final colors = <Color>[
    const Color.fromRGBO(255, 255, 255, 1.1),
    const Color.fromRGBO(55, 171, 204, 0.8),
  ];

  void fistLoad() async {
    setState(() {
      isFirstLoadRunning = true;
    });
    try {
      var data = {"paciente": widget.idPaciente, "page": page.toString()};
      final response = await http.post(
        Uri(
          scheme: 'https',
          host: 'v8.cadactopan.com.mx',
          path: '/api/getGlucosa',
        ),
        body: data,
      );

      if (response.statusCode == 200) {
        List newItems = jsonDecode(response.body);
        setState(() {
          items = newItems;
        });
      } else {
        if (kDebugMode) {
          print("Error en la respuesta: ${response.statusCode}");
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error al cargar datos');
      }
    }

    setState(() {
      isFirstLoadRunning = false;
    });
  }

  void loadMore() async {
    if (hasNextPage == true &&
        isFirstLoadRunning == false &&
        isLoadMoreRunning == false) {
      setState(() {
        isLoadMoreRunning = true;
      });

      page += 1;

      try {
        var data = {"paciente": widget.idPaciente, "page": page.toString()};
        final response = await http.post(
          Uri(
            scheme: 'https',
            host: 'v8.cadactopan.com.mx',
            path: '/api/getGlucosa',
          ),
          body: data,
        );

        if (response.statusCode == 200) {
          List newItems = jsonDecode(response.body);

          if (newItems.isNotEmpty) {
            setState(() {
              items.addAll(newItems); 
            });
          } else {
            // verifica que sea el final de paginacion y agrega sizedbox
            finalScreen = true;
            setState(() {
              hasNextPage = false;
            });
          }
        } else {
          if (kDebugMode) {
            print("Error en la respuesta: ${response.statusCode}");
          }
        }
      } catch (e) {
        if (kDebugMode) {
          print('Error al cargar más datos');
        }
      }

      setState(() {
        isLoadMoreRunning = false;
      });
    }
  }
  
  @override
  void initState() {
    super.initState();
    fistLoad();
    controller = ScrollController()..addListener(loadMore);
  }

  @override
  Widget build(BuildContext context) {
    final Size _size = MediaQuery.of(context).size;
    return FutureBuilder(
      future: getVariables(),
      builder: (context, snapshot) {
        if (snapshot.data == false) {
          return PopScope(
            canPop: false,
            onPopInvokedWithResult: (didPop, result) async {
              if (didPop) { return; }
              bool value = await _onWillPop();
              if (value) {
                Navigator.of(context).pop(value);
              }
            },
            child: Scaffold(
              backgroundColor: Colors.white.withOpacity(1),
              appBar: myAppBar(context, nameGlucosa, widget.idPaciente),
              drawer: SideMenu(user: _userapp, tipoapp: _tipoapp, idPaciente: widget.idPaciente),
              resizeToAvoidBottomInset: false,
              body: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: const Alignment(0.0, 1.3),
                        colors: colors,
                        tileMode: TileMode.repeated,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal:10.0),
                    child: CustomRefreshIndicator(
                      builder: MaterialIndicatorDelegate(
                        builder: (context, controller) {
                          return Icon(
                            Icons.refresh_outlined,
                            color: myColor,
                            size: _size.width*0.1,
                          );
                        },
                      ),
                      onRefresh: () async {
                        isFirstLoadRunning = false;
                        hasNextPage = true;
                        isLoadMoreRunning = false;
                        items = [];
                        page = 1;
                        fistLoad();
                        controller = ScrollController()..addListener(loadMore);
                        return setState(() {});
                      },
                      child: isFirstLoadRunning
                          ? const Center(child: CircularProgressIndicator(color: myColor,))
                          : Column(children: [
                            if(items.isEmpty)
                              const Expanded(child: Center(child: Text("No existen registros", style: TextStyle(color: myColor, fontSize: 18)))),
                              
                              SizedBox(height: _size.height*0.01),
                              Expanded(
                                  child: ListView.builder(
                                  controller: controller,
                                  itemCount: items.length,
                                  itemBuilder: (context, index) {
                                    return Card(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20.0), 
                                      ), 
                                      elevation: 5, 
                                      child: Padding(
                                        padding: const EdgeInsets.all(12.0), 
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.start, 
                                          crossAxisAlignment: CrossAxisAlignment.center, 
                                          children: [
                                            CircleAvatar(
                                              backgroundColor: Colors.green, 
                                              radius: _size.width*0.07, 
                                              child: Icon(
                                                items[index]['tipo'].toString() == "4"
                                                      ? Icons.mode_night_outlined
                                                      : items[index]['tipo'].toString() == "3" 
                                                        ? Icons.dinner_dining_outlined
                                                        : items[index]['tipo'].toString() == "2"
                                                          ? Icons.free_breakfast
                                                          : Icons.wb_sunny_outlined, 
                                                color: Colors.white,
                                              ), 
                                            ), 
                                            SizedBox(width: _size.width*0.02), 
                                            Expanded( 
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.start, 
                                                crossAxisAlignment: CrossAxisAlignment.start, 
                                                children: [ 
                                                  Padding(
                                                    padding: const EdgeInsets.only(left: 10),
                                                    child: Column(
                                                      children: [
                                                        Row(
                                                          mainAxisAlignment: MainAxisAlignment.start,
                                                          children: [
                                                            Text(
                                                              items[index]['valor'].toString()+" mg/dl", 
                                                              style: const TextStyle(
                                                                fontSize: 16, 
                                                                fontWeight: FontWeight.bold, 
                                                              ), 
                                                            ),
                                                          ],
                                                        ),
                                                        Row(
                                                          mainAxisAlignment: MainAxisAlignment.start,
                                                          children: [
                                                            Text(
                                                              items[index]['tipo'].toString() == "4"
                                                                ? "2 hr después de Cena"
                                                                : items[index]['tipo'].toString() == "3" 
                                                                  ? "2 hr después de Comida"
                                                                  : items[index]['tipo'].toString() == "2"
                                                                    ? "2 hr después de Desayuno"
                                                                    : "Ayuno", 
                                                              style: const TextStyle(
                                                                fontSize: 16, 
                                                              ), 
                                                            ),
                                                          ],
                                                        ),
                                                        SizedBox(height: _size.height*0.01), 
                                                        Row(
                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                          children: [
                                                            Text(
                                                              items[index]['fecha'].toString(), 
                                                              textAlign: TextAlign.center, 
                                                            ),
                                                            Text(
                                                              items[index]['hora'].toString(), 
                                                              textAlign: TextAlign.center, 
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),  
                                                ], 
                                              ), 
                                            ), 
                                          ], 
                                        ), 
                                      ), 
                                    ); 
                                  },
                                ),
                              ),
                              if(finalScreen)
                                SizedBox(height: _size.height*0.06),
                              if (isLoadMoreRunning)
                                const Padding(
                                  padding: EdgeInsets.all(10),
                                  child: Center(child: CircularProgressIndicator(
                                    color: myColor,
                                  )),
                                )
                            ]),
                    ),
                  ),
                ],
              ),
              floatingActionButtonLocation: ExpandableFab.location,
              floatingActionButton: isFirstLoadRunning 
              ? const SizedBox.shrink()
              : ExpandableFab(
                  key: _key,
                  type: ExpandableFabType.up,
                  childrenAnimation: ExpandableFabAnimation.none,
                  distance: 70,
                  overlayStyle: ExpandableFabOverlayStyle(
                    color: Colors.black12.withOpacity(0.4),
                  ),
                  openButtonBuilder: RotateFloatingActionButtonBuilder(
                    child: const Icon(Icons.water_drop_outlined),
                    fabSize: ExpandableFabSize.regular,
                    foregroundColor: Colors.white,
                    backgroundColor: myColor,
                    shape: const CircleBorder(),
                  ),
                  closeButtonBuilder: 
                  RotateFloatingActionButtonBuilder(
                    child: const Icon(Icons.close_sharp),
                    fabSize: ExpandableFabSize.regular,
                    foregroundColor: Colors.white,
                    backgroundColor: myColor,
                    shape: const CircleBorder(),
                  ),
                  children: [
                    Row(
                      children: [
                        const Text('2 hr después de Cena', style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                        SizedBox(width: _size.width*0.05),
                        FloatingActionButton.small(
                          heroTag: null,
                          onPressed: () {
                            _key.currentState?.toggle();
                            showModalSheet("2 hr después de Cena", 4, Icons.mode_night_outlined);
                          },
                          backgroundColor: myColor,
                          child: const Icon(Icons.mode_night_outlined, color: Colors.white),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const Text('2 hr después de Comida', style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                        SizedBox(width: _size.width*0.05),
                        FloatingActionButton.small(
                          heroTag: null,
                          onPressed:() {
                            _key.currentState?.toggle();
                            showModalSheet("2 hr después de Comida", 3, Icons.dinner_dining_outlined);
                          },
                          backgroundColor: myColor,
                          child: const Icon(Icons.dinner_dining_outlined, color: Colors.white),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const Text('2 hr después de Desayuno', style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                        SizedBox(width: _size.width*0.05),
                        FloatingActionButton.small(
                          heroTag: null,
                          onPressed:() {
                            _key.currentState?.toggle();
                            showModalSheet("2 hr después de Desayuno", 2, Icons.free_breakfast);
                          },
                          backgroundColor: myColor,
                          child: const Icon(Icons.free_breakfast, color: Colors.white),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const Text('Ayuno', style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                        SizedBox(width: _size.width*0.05),
                        FloatingActionButton.small(
                          heroTag: null,
                          onPressed:() {
                            _key.currentState?.toggle();
                            showModalSheet("Ayuno", 1, Icons.wb_sunny_outlined);
                          },
                          backgroundColor: myColor,
                          child: const Icon(Icons.wb_sunny_outlined, color: Colors.white),
                        ),
                      ],
                    ),
                  ],
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

  void showModalSheet(String nombre, int tipo, IconData icono) {
    final Size _size = MediaQuery.of(context).size;
    now = DateTime.now();

    String fechaBD = _fechaToBD(now);
    _gluController.text = _value.toString();
    _gluError = false;

    String hora = _horaToStr(now);
    String fecha = _fechaToStr(now) + ' ' + hora;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              key: _keyModal, 
              height: _size.height*0.75,
              padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  const Text(
                    'Registrar glucosa en la sangre',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const Divider(),
                  Padding(
                    padding: const EdgeInsets.only(
                        top: 0, bottom: 8.0, left: 70, right: 70),
                    child: TextField(
                      controller: _gluController,
                      maxLength: 4,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      //autofocus: true,
                      style: const TextStyle(
                          color: myColor,
                          fontSize: 40,
                          fontWeight: FontWeight.bold),
                      decoration: InputDecoration(
                        hintText: 'mg/dl',
                        errorText: _gluError ? 'Ingrese la glucosa' : null,
                        helperText: 'mg/dl',
                      ),
                      onChanged: (newValue) {
                        setModalState(() {
                          _gluError = false;
                          _value = newValue;
                        });
                        setState(() {});
                      },
                    ),
                  ),
                  SizedBox(height: _size.height * 0.02),
                  Column(
                    children: <Widget>[
                      FloatingActionButton(
                          backgroundColor: myColor,
                          child: Icon(
                            icono,
                            color: Colors.white,
                          ),
                          onPressed: () {}
                      ),
                      SizedBox(height: _size.height*0.02),
                      Text(
                        nombre,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                  SizedBox(height: _size.height * 0.02),
                  Center(
                      child: InkWell(
                    child: Chip(
                      label: Text(fecha),
                    ),
                    onTap: () {
                      String minDateTime = '2024-07-01 01:00:00';
                      String _format = 'yyyy-MM-dd  HH:mm:ss';
                      DateTimePickerLocale? _locale = DateTimePickerLocale.es;
                      _dateTime = now;

                      DatePicker.showDatePicker(
                        context,
                        minDateTime: DateTime.parse(minDateTime),
                        maxDateTime: now,
                        initialDateTime: _dateTime,
                        dateFormat: _format,
                        locale: _locale,
                        pickerTheme: const DateTimePickerTheme(
                          showTitle: true,
                        ),
                        pickerMode: DateTimePickerMode.datetime,
                        onChange: (dateTime, List<int> index) {
                          setModalState(() {
                            _dateTime = dateTime;
                          });
                        },
                        onConfirm: (dateTime, List<int> index) {
                          setModalState(() {
                            _dateTime = dateTime;
                          });
                          hora = _horaToStr(dateTime);
                          fecha = _fechaToStr(dateTime) + ' ' + hora;
                          fechaBD = _fechaToBD(dateTime);
                        },
                      );

                    },
                  )),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            TextButton(
                                child: const Text(
                                  'Cancelar',
                                  style: TextStyle(fontSize: 18),
                                ),
                                onPressed: () {
                                  Navigator.pop(context);
                                }),
                            TextButton(
                                child: const Text(
                                  'Guardar',
                                  style: TextStyle(fontSize: 18),
                                ),
                                onPressed: () {
                                  if (_gluController.text.isEmpty) {
                                    setModalState(() {
                                      _gluError = true;
                                    });
                                  } else {
                                    _value = _gluController.text;
                                    _saveGlucosa(context, fechaBD, hora, _value, tipo);
                                  }
                                }),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10), topRight: Radius.circular(10)),
      ),
    );
  }

  String _fechaToBD(DateTime date) {
    String fechaBD = date.year.toString() + '-';
    fechaBD += (date.month < 10
            ? '0' + date.month.toString()
            : date.month.toString()) +
        '-';
    fechaBD +=
        (date.day < 10 ? '0' + date.day.toString() : date.day.toString());
    return fechaBD;
  }

  String _fechaToStr(DateTime date) {
    String fecha = arrDia[date.weekday] +
        ', ' +
        date.day.toString() +
        ' de ' +
        arrMes[date.month] +
        ' de ' +
        date.year.toString();
    return fecha;
  }

  String _horaToStr(DateTime date) {
    String hora =
        date.hour < 10 ? '0' + date.hour.toString() : date.hour.toString();
    hora += ':' +
        (date.minute < 10
            ? '0' + date.minute.toString()
            : date.minute.toString());
    return hora;
  }

  void _saveGlucosa(BuildContext context2, String fecha, String hora, String valor, int tipo) async {
    Dialogs.showLoadingDialog(context2, _keyLoader);
    try {
      var data = {"paciente": widget.idPaciente, "fecha": fecha, "hora": hora, "valor": valor, "tipo": tipo.toString()};
      final response = await http.post(
          Uri( 
            scheme: 'https',
            host: 'v8.cadactopan.com.mx',
            path: '/api/addGlucosa',
          ),
          body: data,
        );
      if (response.statusCode == 200) {
        String body3 = utf8.decode(response.bodyBytes);
        var jsonData = jsonDecode(body3);
        if(jsonData['success']==true){
          Navigator.of(_keyLoader.currentContext!, rootNavigator: true).pop();
          isFirstLoadRunning = false;
          hasNextPage = true;
          isLoadMoreRunning = false;
          items = [];
          page = 1;
          fistLoad();
          controller = ScrollController()..addListener(loadMore);
          setState(() {});
          awesomeTopSnackbar(
            context,
            "Se ha agregado correctamente",
            textStyle: const TextStyle(
                color: Colors.white,
                fontStyle: FontStyle.normal,
                fontWeight: FontWeight.w400,
                fontSize: 20),
            backgroundColor:
                Colors.green,
            icon: const Icon(Icons.check,
                color: Colors.black),
            iconWithDecoration: BoxDecoration(
              borderRadius:
                  BorderRadius.circular(20),
              border: Border.all(
                  color: Colors.black),
            ),
          );
        }else{
          Navigator.of(_keyLoader.currentContext!, rootNavigator: true).pop();
          isFirstLoadRunning = false;
          hasNextPage = true;
          isLoadMoreRunning = false;
          items = [];
          page = 1;
          fistLoad();
          controller = ScrollController()..addListener(loadMore);
          setState(() {});
        }
      } else {
        Navigator.of(_keyLoader.currentContext!, rootNavigator: true).pop();
        isFirstLoadRunning = false;
        hasNextPage = true;
        isLoadMoreRunning = false;
        items = [];
        page = 1;
        fistLoad();
        controller = ScrollController()..addListener(loadMore);
        setState(() {});
      }
    } catch (e) {
      Navigator.of(_keyLoader.currentContext!, rootNavigator: true).pop();
      isFirstLoadRunning = false;
      hasNextPage = true;
      isLoadMoreRunning = false;
      items = [];
      page = 1;
      fistLoad();
      controller = ScrollController()..addListener(loadMore);
      setState(() {});
    }

    Navigator.pop(context);
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

}