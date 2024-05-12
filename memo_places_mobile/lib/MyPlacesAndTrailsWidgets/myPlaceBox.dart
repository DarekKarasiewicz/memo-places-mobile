import 'package:flutter/material.dart';
import 'package:memo_places_mobile/Objects/place.dart';

class MyPlaceBox extends StatelessWidget {
  final Place place;

  const MyPlaceBox({
    super.key,
    required this.place,
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.check_circle,
                color: !place.verified ? Colors.grey.shade500 : Colors.green,
              ),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                child: Text(
                  place.placeName,
                  style: TextStyle(
                      color: Colors.grey.shade700,
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
