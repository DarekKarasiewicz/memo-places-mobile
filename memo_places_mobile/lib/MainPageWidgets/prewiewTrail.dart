import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:memo_places_mobile/Objects/trail.dart';
import 'package:memo_places_mobile/trailDetails.dart';
import 'package:memo_places_mobile/translations/locale_keys.g.dart';

class PreviewTrail extends StatelessWidget {
  final void Function() closePreview;
  final Trail trail;

  const PreviewTrail(this.closePreview, this.trail, {super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onVerticalDragEnd: (details) {
        if (details.primaryVelocity! > 0) {
          closePreview();
        } else if (details.primaryVelocity! < 0) {
          Navigator.push(
            context,
            MaterialPageRoute(
              fullscreenDialog: true,
              builder: (context) => TrailDetails(trail),
            ),
          );
        }
      },
      child: Center(
        child: SizedBox(
          height: 190,
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20)),
            child: Container(
              color: Theme.of(context).colorScheme.background,
              child: Column(
                children: [
                  const Center(
                    child: Icon(Icons.drag_handle),
                  ),
                  Expanded(
                    child: Row(
                      children: [
                        trail.images!.isNotEmpty
                            ? Container(
                                margin: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                                child: Image.network(
                                  'http://localhost:8000${trail.images![0]}',
                                  width: 150,
                                  height: 150,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : const SizedBox(
                                width: 10,
                              ),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                trail.trailName,
                                style: const TextStyle(
                                  overflow: TextOverflow.ellipsis,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                LocaleKeys.found_by.tr(
                                    namedArgs: {'username': trail.username}),
                                style: const TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                LocaleKeys.found.tr(
                                    namedArgs: {'date': trail.creationDate}),
                                style: const TextStyle(fontSize: 16),
                              ),
                              const SizedBox(
                                height: 5,
                              )
                            ],
                          ),
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
