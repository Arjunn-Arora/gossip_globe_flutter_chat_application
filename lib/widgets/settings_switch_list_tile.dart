import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SettingsSwitchListTile extends StatelessWidget {
  const SettingsSwitchListTile(
      {super.key,
      required this.title,
      required this.subtitle,
      required this.value,
      required this.onChanged,
      required this.icon,
      required this.iconContainerColor});

  final String title;
  final String subtitle;
  final bool value;
  final Function(bool) onChanged;
  final IconData icon;
  final Color iconContainerColor;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: SwitchListTile(
        title: Text(title),
        subtitle: Text(subtitle),
        value: value,
        onChanged: (value) {
          onChanged(value);
        },
        secondary: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: iconContainerColor,
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(
              icon,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
