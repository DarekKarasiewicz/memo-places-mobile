import 'package:flutter/material.dart';
import 'package:memo_places_mobile/Objects/trail.dart';

class MyTrailBox extends StatelessWidget {
  final Trail trail;

  const MyTrailBox({
    super.key,
    required this.trail,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onPrimary,
        border: Border(
          bottom: BorderSide(
              width: 4, color: Theme.of(context).colorScheme.tertiary),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  trail.trailName,
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.tertiary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      overflow: TextOverflow.ellipsis),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
