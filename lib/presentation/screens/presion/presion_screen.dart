import 'dart:async';
import 'dart:convert';

import 'package:awesome_top_snackbar/awesome_top_snackbar.dart';
import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cupertino_datetime_picker/flutter_cupertino_datetime_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../../../constants/constants.dart';
import '../../widgets/dialogs.dart';
import '../../widgets/my_app_bar.dart';
import '../../widgets/side_menu.dart';

class PresionScreen extends StatefulWidget {
  static const String routeName = 'presion';

  final String idPaciente;

  const PresionScreen({
    Key? key, required this.idPaciente,
  }) : super(key: key);

  @override
  State<PresionScreen> createState() => _PresionScreenState();
}

class _PresionScreenState extends State<PresionScreen> {
  String? _tipoapp;
  String? _userapp;

  bool isLoading = false; 
  bool finalScreen = false;

  // presion arterial
  DateTime now = DateTime.now();
  late DateTime _dateTime;
  final String _value = '120';
  String _sistolica = '120';
  String _diastolica = '80';
  final TextEditingController _preController = TextEditingController();
  final TextEditingController _preController2 = TextEditingController();
  bool _preError = false;
  bool _preError2 = false;
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
          path: '/api/getPresion',
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
            path: '/api/getPresion',
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
              appBar: myAppBar(context, namePresion, widget.idPaciente),
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
                    padding: const EdgeInsets.all(10.0),
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
                          ? const Center(child: CircularProgressIndicator(color: myColor))
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
                                        padding: const EdgeInsets.all(16.0), 
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.start, 
                                          crossAxisAlignment: CrossAxisAlignment.center, 
                                          children: [
                                            CircleAvatar(
                                              backgroundColor: Colors.yellow[600], 
                                              radius: _size.width*0.07, 
                                              child: const Icon(Icons.favorite_border,
                                                color: Colors.black,
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
                                                              items[index]['sistolica'].toString()+" / "+items[index]['diastolica'].toString()+" mmHg", 
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
                                                            Text(items[index]['fechaLarga'].toString(), 
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
                                                            const Text("", 
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
              floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
              floatingActionButton: isFirstLoadRunning 
              ? const SizedBox.shrink()
              :  FloatingActionButton(
                  heroTag: null,
                  onPressed:() {
                    showModalSheet(Icons.wb_sunny_outlined);
                  },
                  backgroundColor: myColor,
                  child: const Icon(Icons.favorite, color: Colors.white),
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

  void showModalSheet(IconData icono) {
    final Size _size = MediaQuery.of(context).size;
    now = DateTime.now();

    String fechaBD = _fechaToBD(now);
    _preController.text = _value.toString();
    _preError = false;
    _preError2 = false;

    _preController.text = _sistolica;
    _preController2.text = _diastolica;

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
                    'Registrar presión arterial',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const Divider(),
                  SizedBox(height: _size.height * 0.05),
                  Row(
                    children: <Widget>[
                      Flexible(
                        child: TextField(
                          controller: _preController,
                          maxLength: 5,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              color: Colors.orangeAccent,
                              fontSize: 40,
                              fontWeight: FontWeight.bold),
                          decoration: InputDecoration(
                              hintText: 'mmHg',
                              errorText:
                                  _preError ? 'Ingrese la presión' : null,
                              helperText: 'mmHg',
                              labelText: 'Sistólica',
                              labelStyle: const TextStyle(
                                  color: Colors.orangeAccent,
                                  fontSize: 20,
                                  fontWeight: FontWeight.normal)),
                          onChanged: (newValue) {
                            setModalState(() {
                              _preError = false;
                              _sistolica = newValue;
                            });
                            setState(() {});
                          },
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          '/',
                          style: TextStyle(fontSize: 40),
                        ),
                      ),
                      Flexible(
                        child: TextField(
                          controller: _preController2,
                          maxLength: 5,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              color: Colors.lightBlueAccent,
                              fontSize: 40,
                              fontWeight: FontWeight.bold),
                          decoration: InputDecoration(
                              hintText: 'mmHg',
                              errorText:
                                  _preError2 ? 'Ingrese la presión' : null,
                              helperText: 'mmHg',
                              labelText: 'Diastólica',
                              labelStyle: const TextStyle(
                                  color: Colors.lightBlueAccent,
                                  fontSize: 20,
                                  fontWeight: FontWeight.normal)),
                          onChanged: (newValue) {
                            setModalState(() {
                              _preError2 = false;
                              _diastolica = newValue;
                            });
                            setState(() {});
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: _size.height * 0.05),
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
                                  setModalState(() {
                                    if (_preController.text.isEmpty) {
                                      _preError = true;
                                    } else if (_preController2.text.isEmpty) {
                                      _preError2 = true;
                                    } else {
                                      _sistolica = _preController.text;
                                      _diastolica = _preController2.text;
                                      //print(_sistolica+" | "+_diastolica);
                                      //print(fechaBD+" | "+hora);
                                      _savePresion(context, fechaBD, hora);
                                    }
                                  });
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

  void _savePresion(BuildContext context2, String fecha, String hora) async {
    Dialogs.showLoadingDialog(context2, _keyLoader);
    try {
      var data = {"paciente": widget.idPaciente, "fecha": fecha, "hora": hora, "sistolica": _sistolica, "diastolica": _diastolica};
      final response = await http.post(
        Uri( 
          scheme: 'https',
          host: 'v8.cadactopan.com.mx',
          path: '/api/addPresion',
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