import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:memo_places_mobile/place_form.dart';
import 'package:memo_places_mobile/trailRecordPage.dart';

class AddingButton extends StatefulWidget {
  const AddingButton(this.position, {super.key});
  final LatLng position;

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
                  heroTag: 'addPlace',
                  onPressed: () {
                    setState(() {
                      _expanded = false;
                    });
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => PlaceForm(widget.position)),
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
            heroTag: 'openClose',
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
                  heroTag: 'addTrail',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              TrailRecordPage(startLocation: widget.position)),
                    );
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
