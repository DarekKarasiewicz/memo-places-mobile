import 'package:flutter/material.dart';
import 'package:memo_places_mobile/ObjectDetailsWidgets/sliderWithDots.dart';
import 'package:memo_places_mobile/Objects/trail.dart';
import 'package:url_launcher/url_launcher.dart';

final List<String> demoImages = [
  'https://picsum.photos/250?image=3',
  'https://picsum.photos/250?image=6',
  'https://picsum.photos/250?image=9'
];

class TrailDetails extends StatelessWidget {
  const TrailDetails(this.trail, {super.key});
  final Trail trail;

  _launchMaps() async {
    final url = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=${trail.coordinates[0].latitude},${trail.coordinates[0].longitude}');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch Google Maps';
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.grey.shade700),
            onPressed: () => Navigator.of(context).pop(),
          ),
          backgroundColor: Colors.white,
          title: Text(trail.trailName),
        ),
        body: Center(
          child: Column(
            children: [
              SliderWithDots(images: demoImages),
              Container(
                margin: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(10.0),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 5.0,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Center(
                  child: Column(
                    children: [
                      const Text("Info:"),
                      Text("\u2022 Type - ${trail.typeValue}"),
                      Text("\u2022 Period - ${trail.periodValue}"),
                      Text("\u2022 found - ${trail.foundDate}")
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(10.0),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 5.0,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Column(
                      children: [
                        const Text("Description:"),
                        Text(trail.description),
                      ],
                    ),
                  ),
                ),
              ),
              Center(
                child: ElevatedButton(
                  onPressed: _launchMaps,
                  child: const Text("Navigate to trail"),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
