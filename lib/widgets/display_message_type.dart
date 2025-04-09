import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gossip_globe/constants.dart';
import 'package:gossip_globe/widgets/audio_player_widget.dart';

class DisplayMessageType extends StatelessWidget {
  const DisplayMessageType(
      {super.key,
      required this.message,
      required this.type,
      required this.color,
      required this.overFlow,
      required this.maxLines,
      required this.viewOnly,});
  // required this.isReply});

  final String message;
  final MessageEnum type;
  final Color color;
  final TextOverflow overFlow;
  final int? maxLines;
  final bool viewOnly;
  // final bool isReply;

  @override
  Widget build(BuildContext context) {
    Widget messageToShow() {
      switch (type) {
        case MessageEnum.text:
          return Text(
            message,
            style: TextStyle(
              color: color,
              fontSize: 16.0,
            ),
            maxLines: maxLines,
            overflow: overFlow,
          );
        case MessageEnum.image:
          return CachedNetworkImage(
            imageUrl: message,
            fit: BoxFit.cover,
          );
        // case MessageEnum.video:
        //   return isReply
        //       ? const Icon(Icons.video_collection)
        //       : VideoPlayerWidget(
        //           videoUrl: message,
        //           color: color,
        //           viewOnly: viewOnly,
        //         );
        case MessageEnum.audio:
          return AudioPlayerWidget(audioUrl: message);
        default:
          return Text(
            message,
            style: TextStyle(
              color: color,
              fontSize: 16.0,
            ),
            maxLines: maxLines,
            overflow: overFlow,
          );
      }
    }

    return messageToShow();
  }
}
