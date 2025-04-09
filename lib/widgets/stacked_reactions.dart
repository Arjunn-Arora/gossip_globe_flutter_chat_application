import 'package:flutter/material.dart';
import 'package:gossip_globe/models/message_model.dart';

class StackedReactionsWidget extends StatelessWidget {
  const StackedReactionsWidget({super.key, required this.message, required this.size, required this.onTap});

  final MessageModel message;
  final double size;
  final Function() onTap;

  @override
  Widget build(BuildContext context) {
    final messageReactions = message.reactions.map((e) => e.split('=')[1]).toList();
    final reactionsToShow = messageReactions.length > 5 ? messageReactions.sublist(0, 5) : messageReactions;
    final remainingReactions = messageReactions.length - reactionsToShow.length;
    final allReactions = reactionsToShow.asMap().map((index, reaction){
      final value = Container(
        margin: EdgeInsets.only(left: index * 20.0),
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade400,
              spreadRadius: 1,
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: ClipOval(child: Text(reaction, style: TextStyle(fontSize: size),)),
      );
      return MapEntry(index, value);
    }).values.toList();
    return GestureDetector(
      onTap: onTap(),
      child: Row(
        children: [
          Stack(
          children: allReactions,
        ),
        if(remainingReactions > 0) ...[
          Positioned(left: 100,
          child: Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(blurRadius: 2, spreadRadius: 1, offset: const Offset(0, 1), color: Colors.grey.shade500),
                ],
            ),
            child: ClipOval(
              child: Padding(padding: const EdgeInsets.all(2.0),
              child: Text('+$remainingReactions', style: const TextStyle(fontSize: 16, color: Colors.black),
              ),
            ),
          ),
          ),
          ),
        ],
        ], 
      ),
    );
  }
}