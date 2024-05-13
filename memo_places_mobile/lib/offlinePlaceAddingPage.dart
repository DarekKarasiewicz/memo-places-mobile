import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:memo_places_mobile/offlinePlaceForm.dart';
import 'package:memo_places_mobile/offlineWidgets/offlinePlacesList.dart';

class OfflinePlaceAddingPage extends StatefulWidget {
  const OfflinePlaceAddingPage({super.key});

  @override
  State<OfflinePlaceAddingPage> createState() => _OfflinePlaceAddingPageState();
}

class _OfflinePlaceAddingPageState extends State<OfflinePlaceAddingPage> {
  late LatLng _position;

  @override
  initState() {
    super.initState();

    _getCurrentLocation().then((location) => {
          if (mounted)
            {
              setState(() {
                _position = LatLng(location.latitude, location.longitude);
              })
            }
        });
  }

  Future<Position> _getCurrentLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied');
    }

    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => OfflinePlaceForm(_position)),
                  );
                },
                child: Container(
                  width: 200.0,
                  height: 200.0,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(100),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.add_location_alt_outlined,
                      size: 100.0,
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              const OfflinePlacesList()
            ],
          ),
        ),
      ),
    );
  }
}
