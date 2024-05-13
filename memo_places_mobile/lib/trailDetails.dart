import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:memo_places_mobile/ObjectDetailsWidgets/sliderWithDots.dart';
import 'package:memo_places_mobile/Objects/trail.dart';
import 'package:memo_places_mobile/l10n/l10n.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

final List<String> demoImages = [
  'https://picsum.photos/250?image=3',
  'https://picsum.photos/250?image=6',
  'https://picsum.photos/250?image=9'
];

class TrailDetails extends StatelessWidget {
  const TrailDetails(this.trail, {super.key});
  final Trail trail;

  _launchMaps(BuildContext context) async {
    final url = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=${trail.coordinates[0].latitude},${trail.coordinates[0].longitude}');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw AppLocalizations.of(context)!.googleMapsError;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
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
                    Text(AppLocalizations.of(context)!.info),
                    Text(AppLocalizations.of(context)!
                        .typeInfo(trail.typeValue)),
                    Text(AppLocalizations.of(context)!
                        .periodInfo(trail.periodValue)),
                    Text(AppLocalizations.of(context)!
                        .dateInfo(trail.creationDate))
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
                      Text(AppLocalizations.of(context)!.description),
                      Text(trail.description),
                    ],
                  ),
                ),
              ),
            ),
            Center(
              child: ElevatedButton(
                onPressed: () => _launchMaps,
                child: Text(AppLocalizations.of(context)!.navigateTrail),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
    );
  }
}
