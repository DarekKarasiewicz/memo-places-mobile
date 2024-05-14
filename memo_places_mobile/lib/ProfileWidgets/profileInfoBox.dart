import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:memo_places_mobile/translations/locale_keys.g.dart';

class ProfileInfoBox extends StatelessWidget {
  final String username;
  final String email;

  const ProfileInfoBox(
      {super.key, required this.username, required this.email});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          CircleAvatar(
            radius: 58,
            backgroundColor: Colors.transparent,
            child: ClipOval(
              child: Image.network(
                'https://pbs.twimg.com/profile_images/794107415876747264/g5fWe6Oh_400x400.jpg',
              ),
            ),
          ),
          Flexible(
            child: Container(
              constraints: const BoxConstraints(
                minHeight: 80,
              ),
              padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    LocaleKeys.welcome.tr(namedArgs: {'username': username}),
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    email,
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
