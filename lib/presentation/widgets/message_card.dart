import 'package:cached_network_image/cached_network_image.dart';
import 'package:cadactopanapp/config/helper/my_date_util.dart';
import 'package:cadactopanapp/config/services/apis.dart';
import 'package:cadactopanapp/constants/constants.dart';
import 'package:cadactopanapp/models/message.dart';
import 'package:cadactopanapp/presentation/widgets/image_view';
import 'package:flutter/material.dart';

class MessageCard extends StatefulWidget {
  const MessageCard({Key? key, required this.idPaciente, required this.message}) : super(key: key);

  final String idPaciente;
  final Message message;

  @override
  State<MessageCard> createState() => _MessageCardState();
}

class _MessageCardState extends State<MessageCard> {
  @override
  Widget build(BuildContext context) {
    return widget.idPaciente == widget.message.fromId
    ? _greenMessage()
    : _blueMessage();
  }

  Widget _blueMessage(){
    final Size _size = MediaQuery.of(context).size;

    if(widget.message.read.isEmpty){
      APIs.updateMessageReadStatus(widget.message);
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Container(
            padding: EdgeInsets.all(_size.width * 0.04),
            margin: EdgeInsets.symmetric(horizontal: _size.width * 0.04, vertical: _size.height * 0.01),
            decoration: BoxDecoration(
              color: Colors.blue.shade100,
              border: Border.all(color: Colors.lightBlue),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
                bottomRight: Radius.circular(30)
              )
            ),
            child: 
            widget.message.type == Type.text
            ? Text(
              widget.message.msg,
              style: const TextStyle(fontSize: 15, color: Colors.black87),
            )
            : widget.message.type == Type.text
            ? Text(
              widget.message.msg,
              style: const TextStyle(fontSize: 15, color: Colors.black87),
            )
            : GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ImagePreview(imageUrl: widget.message.msg),
                    ),
                  );
                },
                child: CachedNetworkImage(
                  imageUrl: widget.message.msg,
                  imageBuilder: (context, imageProvider) => Container(
                    width: _size.width * 0.4,
                    height: _size.height * 0.2,
                    decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      image: DecorationImage(
                        image: imageProvider,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  placeholder: (context, url) => SizedBox(
                    width: _size.width * 0.35,
                    height: _size.height * 0.2,
                    child: const Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: myColor,
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    width: _size.width * 0.35,
                    height: _size.height * 0.2,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      shape: BoxShape.rectangle,
                    ),
                    child: Icon(
                      Icons.people,
                      color: Colors.grey,
                      size: _size.width * 0.1,
                    ),
                  ),
                ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(right: _size.height * 0.01),
          child: Text(MyDateUtil.getFormattedTime(context: context, time: widget.message.sent), style: const TextStyle(fontSize: 13, color: Colors.black54)),
        ),
      ],
    );
  }

  Widget _greenMessage(){
    final Size _size = MediaQuery.of(context).size;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            SizedBox(width: _size.width * 0.04),

            if(widget.message.read.isNotEmpty)
              const Icon(Icons.done_all_rounded, color: Colors.blue, size: 20),

            if(widget.message.read.isEmpty)
              Icon(Icons.done_all_rounded, color: Colors.grey.shade500, size: 20),
              
            SizedBox(width: _size.width * 0.01),
            Text(MyDateUtil.getFormattedTime(context: context, time: widget.message.sent), style: const TextStyle(fontSize: 13, color: Colors.black54)),
          ],
        ),
        Flexible(
          child: Container(
            padding: EdgeInsets.all(_size.width * 0.04),
            margin: EdgeInsets.symmetric(horizontal: _size.width * 0.04, vertical: _size.height * 0.01),
            decoration: BoxDecoration(
              color: Colors.green.shade100,
              border: Border.all(color: Colors.lightGreen),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
                bottomLeft: Radius.circular(30)
              )
            ),
            child: widget.message.type == Type.text
            ? Text(
              widget.message.msg,
              style: const TextStyle(fontSize: 15, color: Colors.black87),
            )
            : GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ImagePreview(imageUrl: widget.message.msg),
                    ),
                  );
                },
                child: CachedNetworkImage(
                  imageUrl: widget.message.msg,
                  imageBuilder: (context, imageProvider) => Container(
                    width: _size.width * 0.4,
                    height: _size.height * 0.2,
                    decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      image: DecorationImage(
                        image: imageProvider,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  placeholder: (context, url) => SizedBox(
                    width: _size.width * 0.35,
                    height: _size.height * 0.2,
                    child: const Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: myColor,
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    width: _size.width * 0.35,
                    height: _size.height * 0.2,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      shape: BoxShape.rectangle,
                    ),
                    child: Icon(
                      Icons.people,
                      color: Colors.grey,
                      size: _size.width * 0.1,
                    ),
                  ),
                ),
            ),
            // ClipRRect(
            //   borderRadius: BorderRadius.circular(_size.height * 0.05),
            //   child: CachedNetworkImage(
            //     width: _size.width * 0.5,
            //     height: _size.height * 0.3,
            //     imageUrl: "https://imagedelivery.net/ePBoP9V9vKs9ddFZCEIzDg/df56dcab-6c60-422a-c4bb-9658f08ec100/public",
            //     errorWidget:(context, url, error) {
            //       return const Icon(Icons.image, size: 70);
            //     },
            //   ),
            // ),
          ),
        ),
      ],
    );
  }
}