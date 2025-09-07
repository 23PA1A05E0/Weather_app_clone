import 'package:flutter/material.dart';

class HourlyShownCard extends StatelessWidget {
  final String time;
  final IconData icon;
  final String value;
  const HourlyShownCard({
    super.key,
    required this.time,
    required this.icon,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 90,
      height: 110,
      child: Card(
        elevation: 10,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            10,
          ), // Fixed: Use BorderRadius instead of BorderRadiusGeometry
        ),
        surfaceTintColor: Colors.grey,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(
            5,
          ), // Fixed: Use BorderRadius instead of BorderRadiusGeometry
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: [
                Text(time),
                SizedBox(height: 4),
                Icon(
                  icon,
                  color: icon == Icons.cloud
                      ? Colors.grey
                      : Colors.yellowAccent, // Conditional color
                ),
                SizedBox(height: 4),
                Text(value),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
