import 'package:flutter/material.dart';
import 'package:memo_places_mobile/placeDetails.dart';
import 'package:memo_places_mobile/Objects/place.dart';

class PreviewPlace extends StatelessWidget {
  final void Function() closePreview;
  final Place place;

  const PreviewPlace(this.closePreview, this.place, {super.key});

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
              builder: (context) => PlaceDetails(place),
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
              color: Colors.white,
              child: Column(
                children: [
                  // This code contains icons for functions now handeled by gestures, may be used in future for easy accesability.
                  // Container(
                  //   margin:
                  //       const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                  //   child: Row(
                  //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //     children: [
                  //       IconButton(
                  //         icon: const Icon(Icons.close),
                  //         onPressed: () {
                  //           closePreview();
                  //         },
                  //       ),
                  //       const Icon(Icons.drag_handle),
                  //       IconButton(
                  //           onPressed: () {
                  //             Navigator.push(
                  //               context,
                  //               MaterialPageRoute(
                  //                   builder: (context) => const PlaceForm()),
                  //             );
                  //           },
                  //           icon: const Icon(Icons.arrow_forward))
                  //     ],
                  //   ),
                  // ),
                  const Center(
                    child: Icon(Icons.drag_handle),
                  ),
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          margin: const EdgeInsets.all(5),
                          child: Image.network(
                            'https://picsum.photos/250?image=9',
                            width: 150,
                            height: 150,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  place.placeName,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              Align(
                                alignment: Alignment.centerRight,
                                child: Text(
                                  place.creationDate,
                                ),
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
