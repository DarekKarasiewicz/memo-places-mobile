import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class HidePassword extends StatelessWidget {
  final bool isPasswordHidden;
  final void Function() onHiddenChange;

  const HidePassword(
      {super.key,
      required this.isPasswordHidden,
      required this.onHiddenChange});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onHiddenChange,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(children: [
          Icon(
            isPasswordHidden ? Icons.lock_open : Icons.lock,
            color: Colors.grey.shade700,
          ),
          Text(
            isPasswordHidden
                ? AppLocalizations.of(context)!.showPass
                : AppLocalizations.of(context)!.hidePass,
            style: TextStyle(
              color: Colors.grey.shade700,
            ),
          )
        ]),
      ),
    );
  }
}
