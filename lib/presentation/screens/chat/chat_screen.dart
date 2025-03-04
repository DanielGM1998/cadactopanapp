import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:cadactopanapp/config/helper/my_date_util.dart';
import 'package:cadactopanapp/config/services/apis.dart';
import 'package:cadactopanapp/main.dart';
import 'package:cadactopanapp/models/chat_user.dart';
import 'package:cadactopanapp/models/message.dart';
import 'package:cadactopanapp/presentation/screens/chat/chat_users_screen.dart';
import 'package:cadactopanapp/presentation/widgets/message_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloudflare/cloudflare.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:image_picker/image_picker.dart';
import '../../../constants/constants.dart';

class ChatScreen extends StatefulWidget {
  static const String routeName = 'chat';

  final ChatUser userContacto;
  final String idPaciente;
  final String userapp;
  final String userLastName;

  const ChatScreen({
    Key? key, required this.userContacto, required this.idPaciente, required this.userapp, required this.userLastName,
  }) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with SingleTickerProviderStateMixin {
  //String? _tipoapp;

  List<Message> _list = [];
  List<ChatUser> _list2 = [];
  final _textcontroller = TextEditingController();
  bool _showEmoji = false;

  List<String> imagePaths = [];

  late final Stream<QuerySnapshot> _messageStream;

  final colors = <Color>[
    const Color.fromRGBO(255, 255, 255, 1.1),
    const Color.fromRGBO(55, 171, 204, 0.8),
  ];

  Future<bool?> getVariables() async {
    //SharedPreferences prefs = await SharedPreferences.getInstance();
    //_tipoapp = prefs.getString("tipo_app");
    return false;
  }

  handleImageFromGallery1() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.camera, imageQuality: 50);

      // Mostrar el Progress Dialog
      EasyLoading.show(
        //status: 'Enviando imagen...',
        status: 'Cargando...',
        maskType: EasyLoadingMaskType.clear,
      );

      if (image != null) {
        //log(image.path);

        String customFileName = "CAD_${DateTime.now().millisecondsSinceEpoch}.jpg";

        String dirImage = "";
      
        CloudflareHTTPResponse<CloudflareImage?> responseFromPath =
          await cloudflare.imageAPI.upload(
          fileName: customFileName,
          contentFromPath: DataTransmit<String>(
            data: image.path,
            progressCallback: (counter, total) {
              // Actualizar progreso
              EasyLoading.showProgress(
                counter / total,
                status: '${((counter / total) * 100).toStringAsFixed(0)}%',
              );
              //log('Upload progress: $counter/$total');
            })
          );

        //log(responseFromPath.body!.toString());

        if(responseFromPath.body!.variants[0].substring(responseFromPath.body!.variants[0].length-6) =="public"){
          dirImage += responseFromPath.body!.variants[0];
        }else{
          dirImage += responseFromPath.body!.variants[1];
        }

        //log(dirImage);

        APIs.sendMessage(widget.userContacto, widget.idPaciente, widget.userapp+" "+widget.userLastName, dirImage, Type.image);

        // await _sendNotification(id, _postText!);

        HapticFeedback.heavyImpact();
      }
    } catch (e) {
      return;
    } finally {
      // Ocultar el Progress Dialog
      EasyLoading.dismiss();
    }
  }

  handleImageFromGallery2() async {
    try {
      final ImagePicker picker = ImagePicker();
      List<XFile?> imagesFiles = await picker.pickMultiImage(imageQuality: 50);

      // Mostrar el Progress Dialog
      EasyLoading.show(
        //status: 'Enviando imagen...',
        status: 'Cargando...',
        maskType: EasyLoadingMaskType.clear,
      );

      // ignore: unnecessary_null_comparison
      if (imagesFiles != null) {
        List<String> paths = imagesFiles.map((image) => image!.path).toList();
        setState(() {
          imagePaths = paths;
          // log(imagePaths.length.toString());
          // log(imagePaths.first);
        });

        String customFileName = "CAD_${DateTime.now().millisecondsSinceEpoch}.jpg";

        String dirImages = "";

        // multiImage
        for (String image in imagePaths) {
          //From path
          CloudflareHTTPResponse<CloudflareImage?> responseFromPath =
            await cloudflare.imageAPI.upload(
              fileName: customFileName,
              contentFromPath: DataTransmit<String>(
                data: image,
                progressCallback: (counter, total) {
                  // log('Upload progress: $counter/$total');
                }
              )
            );

          // log(responseFromPath.body!.toString());

          if(responseFromPath.body!.variants[0].substring(responseFromPath.body!.variants[0].length-6) =="public"){
            dirImages = responseFromPath.body!.variants[0];
          }else{
            dirImages = responseFromPath.body!.variants[1];
          }

          // log(dirImages);
          APIs.sendMessage(widget.userContacto, widget.idPaciente, widget.userapp+" "+widget.userLastName, dirImages, Type.image);
        }
        // await _sendNotification(id, _postText!);
        HapticFeedback.heavyImpact();
      }
    } catch (e) {
      return;
    } finally {
      // Asegurarse de cerrar el indicador de carga
      EasyLoading.dismiss();
    }
  }

  @override
  void initState() {
    super.initState();
    _messageStream = APIs.firestore
        .collection('conversaciones/${APIs.getConversationID(widget.idPaciente, widget.userContacto.id)}/mensajes/')
        .orderBy('sent', descending: true)
        .snapshots();
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
              if(_showEmoji){
                setState(() {
                  _showEmoji = !_showEmoji;
                });
              }else{
                Navigator.of(context).pushReplacement(
                  _buildPageRoute(ChatUsersScreen(idPaciente: widget.idPaciente)),
                );
              }
            },
            child: Scaffold(
                backgroundColor: Colors.white.withOpacity(1),
                resizeToAvoidBottomInset: true,
                appBar: AppBar(
                  elevation: 1,
                  shadowColor: myColor,
                  automaticallyImplyLeading: false,
                  backgroundColor: Colors.white,
                  iconTheme: const IconThemeData(color: myColor),
                  leading: Row(
                    children: [
                      SizedBox(width: _size.width * 0.02),
                      IconButton(
                        icon: const Icon(CupertinoIcons.clear_circled), 
                        onPressed: () {
                          Navigator.of(context).pushReplacement(
                            _buildPageRoute(ChatUsersScreen(idPaciente: widget.idPaciente)),
                          );
                        },
                      ),
                      Expanded(
                        child: InkWell(
                          onTap: () {},
                          child: StreamBuilder(
                            stream: APIs.getUserInfo(widget.userContacto.id),
                            builder:(context, snapshot) {
                              switch (snapshot.connectionState) {

                                // Si los datos están cargando
                                case ConnectionState.waiting:
                                  return Row(
                                        children: [
                                          const CircleAvatar(
                                            child: Icon(CupertinoIcons.person),
                                          ),
                                          SizedBox(width: _size.width * 0.02),
                                          Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                widget.userContacto.name,
                                                style: const TextStyle(
                                                  color: Colors.black,
                                                ),
                                              ),
                                              const Text("",
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.black54,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      );
                  
                                case ConnectionState.none:
                                  return const Center(
                                    child: Text("",
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  );
                                              
                                // Si los datos están cargados
                                case ConnectionState.active:
                                  // El stream está emitiendo datos
                                  if (snapshot.hasData) {
                                    // Hay datos disponibles
                                    final QuerySnapshot querySnapshot = snapshot.data as QuerySnapshot;
                                    final data = querySnapshot.docs;
                                    _list2 = data.map((e) {
                                      final mapData = e.data() as Map<String, dynamic>; 
                                      return ChatUser.fromJson(mapData);
                                    }).toList();
                                    if (_list2.isNotEmpty) {
                                      // log(jsonEncode(data.first.data()));
                                      return Row(
                                        children: [
                                          const CircleAvatar(
                                            child: Icon(CupertinoIcons.person),
                                          ),
                                          SizedBox(width: _size.width * 0.02),
                                          Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                widget.userContacto.name,
                                                style: const TextStyle(
                                                  color: Colors.black,
                                                ),
                                              ),
                                              Text(
                                                _list2.isNotEmpty 
                                                ? _list2.first.isOnline
                                                  ? 'En linea'
                                                  : MyDateUtil.getLastActiveTime(context: context, lastActive: _list2.first.lastActive)
                                                : MyDateUtil.getLastActiveTime(context: context, lastActive: widget.userContacto.lastActive),
                                                style: const TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.black54,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      );
                                    }else{
                                      return const Center(
                                        child: Text("",
                                          style: TextStyle(fontSize: 16),
                                        ),
                                      );
                                    }
                                  } else if (snapshot.hasError) {
                                    // Ocurrió un error en el stream
                                    return const Center(
                                      child: Text("",
                                        style: TextStyle(color: Colors.red, fontSize: 16),
                                      ),
                                    );
                                  } else {
                                    // El stream está activo pero no tiene datos
                                    return const Center(
                                      child: Text("",
                                        style: TextStyle(fontSize: 16),
                                      ),
                                    );
                                  }
                  
                                case ConnectionState.done:
                                  return const Center(
                                    child: Text("",
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  );
                              }
                            },
                          )
                          
                        ),
                      ),
                    ],
                  ),
                  leadingWidth: _size.width,
                ),
                body: Container(
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: const Alignment(0.0, 1.3),
                        colors: colors,
                        tileMode: TileMode.repeated,
                      ),
                    ),
                  child: Column(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                          child: Column(
                            children: [
                              Expanded(
                                child: StreamBuilder(
                                  stream: _messageStream,
                                  builder: (context, snapshot) {
                        
                                    switch (snapshot.connectionState) {
                                      
                                      // Si los datos están cargando
                                      case ConnectionState.waiting:
                                        return const SizedBox(height: 10);
                        
                                      case ConnectionState.none:
                                        return const Center(
                                          child: Text(
                                            "Verificar conexión de internet",
                                            style: TextStyle(fontSize: 16),
                                          ),
                                        );
                                                    
                                      // Si los datos están cargados
                                      case ConnectionState.active:
                                        // El stream está emitiendo datos
                                        if (snapshot.hasData) {
                                          // log("snaps");
                                          // Hay datos disponibles
                                          final QuerySnapshot querySnapshot = snapshot.data as QuerySnapshot;
                                          final data = querySnapshot.docs;
                                          _list = data.map((e) {
                                            final mapData = e.data() as Map<String, dynamic>; 
                                            return Message.fromJson(mapData);
                                          }).toList();
                                          if (_list.isNotEmpty) {
                                            //log(jsonEncode(data.first.data()));
                                            return ListView.builder(
                                              reverse: true,
                                              itemCount: _list.length,
                                              padding: const EdgeInsets.only(top: 10),
                                              physics: const BouncingScrollPhysics(),
                                              itemBuilder: (context, index) {
                                                //log(_list[index].msg);
                                                return MessageCard(idPaciente: widget.idPaciente, message: _list[index]);
                                              },
                                            );
                                          } else {
                                            return const Center(
                                              child: Text(
                                                "Bienvenid@ al Chat\nCAD Actopan 👋",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  color: myColor,
                                                  fontSize: 18,
                                                ),
                                              ),
                                            );
                                          }
                        
                                        } else if (snapshot.hasError) {
                                          // Ocurrió un error en el stream
                                          return Center(
                                            child: Text(
                                              "Error: ${snapshot.error}",
                                              style: const TextStyle(color: Colors.red, fontSize: 16),
                                            ),
                                          );
                                        } else {
                                          // El stream está activo pero no tiene datos
                                          return const Center(
                                            child: Text(
                                              "No hay datos disponibles",
                                              style: TextStyle(fontSize: 16),
                                            ),
                                          );
                                        }
                        
                                      case ConnectionState.done:
                                        return const Center(
                                          child: Text(
                                            "El stream ha terminado",
                                            style: TextStyle(fontSize: 16),
                                          ),
                                        );
                                    }
                                  },
                                ),
                              ),
                              // Campo de entrada de mensaje
                              Row(
                                children: [
                                  Expanded(
                                    child: Card(
                                      shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(Radius.circular(25)),
                                      ),
                                      child: Row(
                                        children: [
                                          IconButton(
                                            onPressed: () {
                                              setState(() {
                                                FocusScope.of(context).unfocus();
                                                _showEmoji = !_showEmoji;
                                              });
                                            },
                                            icon: const Icon(Icons.emoji_emotions, color: myColor, size: 25),
                                          ),
                                          Expanded(
                                            child: TextField(
                                              controller: _textcontroller,
                                              keyboardType: TextInputType.multiline,
                                              maxLines: null,
                                              onTap: () {
                                                if(_showEmoji){
                                                  setState(() {
                                                  _showEmoji = !_showEmoji;
                                                });
                                                }
                                              },
                                              decoration: const InputDecoration(
                                                hintText: 'Escribe algo...',
                                                hintStyle: TextStyle(color: myColor),
                                                border: InputBorder.none,
                                              ),
                                            ),
                                          ),
                                          IconButton(
                                            onPressed: () async{
                                              handleImageFromGallery2();
                                            },
                                            icon: const Icon(Icons.image, color: myColor, size: 26),
                                          ),
                                          IconButton(
                                            onPressed: () async{
                                              handleImageFromGallery1();
                                            },
                                            icon: const Icon(Icons.camera_alt_rounded, color: myColor, size: 26),
                                          ),
                                          SizedBox(width: _size.width * .02),
                                        ],
                                      ),
                                    ),
                                  ),
                                  MaterialButton(
                                    onPressed: () {
                                      if(_textcontroller.text.isNotEmpty){
                                        APIs.sendMessage(widget.userContacto, widget.idPaciente, widget.userapp+" "+widget.userLastName, _textcontroller.text, Type.text);
                                        _textcontroller.text = '';
                                      }
                                    },
                                    minWidth: 0,
                                    padding: const EdgeInsets.all(10),
                                    shape: const CircleBorder(),
                                    color: myColor,
                                    child: const Icon(Icons.send, color: Colors.white, size: 28),
                                  ),
                                ],
                              ),    
                            ],
                          ),
                        ),
                      ),
                      if (_showEmoji)
                        SizedBox(
                          height: _size.height * 0.3,
                          child: EmojiPicker(
                            textEditingController: _textcontroller,
                            config: Config(
                              height: 256,
                              checkPlatformCompatibility: true,
                              emojiViewConfig: EmojiViewConfig(
                                emojiSizeMax: 28 * (Platform.isIOS ? 1.2 : 1.0),
                              ),
                              swapCategoryAndBottomBar: false,
                              skinToneConfig: const SkinToneConfig(),
                              categoryViewConfig: const CategoryViewConfig(),
                              bottomActionBarConfig: const BottomActionBarConfig(),
                              searchViewConfig: const SearchViewConfig(),
                            ),
                          ),
                        ),
                    ],
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