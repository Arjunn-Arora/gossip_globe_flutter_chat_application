import 'package:flutter/material.dart';
import 'package:gossip_globe/constants.dart';

class GroupTypeListTile extends StatelessWidget {
  GroupTypeListTile(
      {super.key,
      required this.title,
      required this.value,
      this.groupValue,
      required this.onChanged});

  final String title;
  final GroupType value;
  GroupType? groupValue;
  final Function(GroupType?) onChanged;

  @override
  Widget build(BuildContext context) {
    final captitle = title[0].toUpperCase() + title.substring(1);
    return RadioListTile<GroupType>(
      title:
          Text(captitle, style: const TextStyle(fontWeight: FontWeight.bold)),
      dense: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      tileColor: Colors.grey[200],
      contentPadding: EdgeInsets.zero,
      value: value,
      groupValue: groupValue,
      onChanged: onChanged,
    );
  }
}
