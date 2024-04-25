import 'package:flutter/material.dart';
import 'package:memo_places_mobile/place_form.dart';

class AddingButton extends StatefulWidget {
  const AddingButton({super.key});

  @override
  _AddingButtonState createState() => _AddingButtonState();
}

class _AddingButtonState extends State<AddingButton> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 16.0,
      right: MediaQuery.of(context).size.width / 2 - (_expanded ? 100 : 28),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          if (_expanded)
            Row(
              children: [
                FloatingActionButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const PlaceForm()),
                    );
                  },
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28.0),
                  ),
                  child: const Icon(Icons.place),
                ),
                const SizedBox(width: 16),
              ],
            ),
          FloatingActionButton(
            onPressed: () {
              setState(() {
                _expanded = !_expanded;
              });
            },
            backgroundColor: Colors.blue,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28.0),
            ),
            child: _expanded ? const Icon(Icons.close) : const Icon(Icons.add),
          ),
          if (_expanded)
            Row(
              children: [
                const SizedBox(width: 16),
                FloatingActionButton(
                  onPressed: () {
                    // TODO add logic for redirecting to trail form
                  },
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28.0),
                  ),
                  child: const Icon(Icons.navigation),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
