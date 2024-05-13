import 'package:flutter/material.dart';

class OfflinePlaceBox extends StatelessWidget {
  final String name;

  const OfflinePlaceBox({
    super.key,
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(width: 4, color: Colors.grey.shade700),
        ),
      ),
      child: Center(
        child: Text(
          name,
          style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              overflow: TextOverflow.ellipsis),
        ),
      ),
    );
  }
}
