import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class RecordMenu extends StatefulWidget {
  final String distance;
  final bool isRecording;
  final String time;
  final void Function() startRecording;
  final void Function() endRecording;

  const RecordMenu(
      {super.key,
      required this.distance,
      required this.isRecording,
      required this.time,
      required this.startRecording,
      required this.endRecording});

  @override
  State<StatefulWidget> createState() => _RecordMenuState();
}

class _RecordMenuState extends State<RecordMenu> {
  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 0,
      left: 0,
      bottom: 0,
      child: Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(10),
        decoration: const BoxDecoration(
          color: Color.fromARGB(202, 0, 0, 0),
          borderRadius: BorderRadius.all(
            Radius.circular(15),
          ),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.time,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold),
                ),
                Text(
                  AppLocalizations.of(context)!.distance(widget.distance),
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                )
              ],
            ),
            widget.isRecording
                ? ElevatedButton(
                    onPressed: widget.endRecording,
                    child: Text(AppLocalizations.of(context)!.stopSave))
                : ElevatedButton(
                    onPressed: widget.startRecording,
                    child: Text(AppLocalizations.of(context)!.save))
          ],
        ),
      ),
    );
  }
}
