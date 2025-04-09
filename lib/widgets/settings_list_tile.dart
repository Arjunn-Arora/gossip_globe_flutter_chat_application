import 'dart:io';

import 'package:flutter/material.dart';

class SettingsListTile extends StatelessWidget {
  const SettingsListTile(
      {super.key,
      required this.title,
      required this.onTap,
      this.subtitle,
      required this.icon,
      required this.iconContainerColor});

  final String title;
  final String? subtitle;
  final IconData icon;
  final Color iconContainerColor;
  final Function() onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      contentPadding: EdgeInsets.zero,
      leading: Container(
        decoration: BoxDecoration(
          color: iconContainerColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(
            icon,
            color: Colors.white,
          ),
        ),
      ),
      onTap: onTap,
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            )
          : null,
      trailing: Icon(
          Platform.isAndroid ? Icons.arrow_forward : Icons.arrow_forward_ios),
    );
  }
}
