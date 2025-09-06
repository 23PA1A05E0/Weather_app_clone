import 'package:flutter/material.dart';

class AdditionalInfoItems extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const AdditionalInfoItems({
    super.key,
    required this.icon,
    required this.label,
    required this.value 
    });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Column(
        children: [
          Icon(icon),
          SizedBox(height: 5),
          Text(label),
          SizedBox(height: 5),
          Text(value),
        ],
      ),
    );
  }
}
