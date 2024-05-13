import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
              AppLocalizations.of(context)!.noInternet,
              textAlign: TextAlign.center,
            )
          ],
        ),
      ),
    );
  }
}
