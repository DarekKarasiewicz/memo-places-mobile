import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:memo_places_mobile/ObjectDetailsWidgets/sliderWithDots.dart';
import 'package:memo_places_mobile/Objects/place.dart';
import 'package:url_launcher/url_launcher.dart';

final List<String> demoImages = [
  'https://picsum.photos/250?image=3',
  'https://picsum.photos/250?image=6',
  'https://picsum.photos/250?image=9'
];

class ObjectDetails extends StatelessWidget {
  const ObjectDetails(this.place, {super.key});
  final Place place;

  _launchMaps() async {
    final url = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=${place.lat},${place.lng}');
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
          backgroundColor: Colors.white,
          title: Text(place.placeName),
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
                      Text("Info:"),
                      Text("\u2022 Type - ${place.typeValue}"),
                      Text("\u2022 Period - ${place.periodValue}"),
                      Text("\u2022 Sortof - ${place.sortofValue}"),
                      Text("\u2022 found - ${place.foundDate}")
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
                        Text("Description:"),
                        Text("${place.description}"),
                      ],
                    ),
                  ),
                ),
              ),
              Center(
                child: ElevatedButton(
                  onPressed: _launchMaps,
                  child: const Text("Show on Google Maps"),
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
