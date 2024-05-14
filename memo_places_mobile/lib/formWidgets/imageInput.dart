import 'dart:io';

import 'package:flutter/material.dart';

class ImageInput extends StatefulWidget {
  final List<File> selectedImages;
  final void Function() onImageAdd;
  const ImageInput(
      {super.key, required this.selectedImages, required this.onImageAdd});

  @override
  State<ImageInput> createState() => _ImageInputState();
}

class _ImageInputState extends State<ImageInput> {
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      width: double.infinity,
      child: TextButton.icon(
        onPressed: widget.onImageAdd,
        icon: const Icon(Icons.photo_size_select_actual_rounded),
        label: const Text('Select Pictures'),
      ),
    );
  }
}
