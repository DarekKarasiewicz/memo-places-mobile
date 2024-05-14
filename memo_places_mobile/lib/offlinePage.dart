import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:memo_places_mobile/translations/locale_keys.g.dart';

class OfflinePage extends StatelessWidget {
  const OfflinePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.signal_wifi_connected_no_internet_4_rounded,
              size: 100,
            ),
            const SizedBox(
              height: 40,
            ),
            Text(
              LocaleKeys.no_internet.tr(),
              textAlign: TextAlign.center,
            )
          ],
        ),
      ),
    );
  }
}
