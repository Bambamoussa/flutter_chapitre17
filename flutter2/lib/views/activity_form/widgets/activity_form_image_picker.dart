import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:projet_dyma_end/providers/city_provider.dart';
import 'package:provider/provider.dart';

class ActivityFormImagePicker extends StatefulWidget {
  final Function updateUrl;

  ActivityFormImagePicker({required this.updateUrl});

  @override
  _ActivityFormImagePickerState createState() =>
      _ActivityFormImagePickerState();
}

class _ActivityFormImagePickerState extends State<ActivityFormImagePicker> {
  File? _deviceImage;

  Future<void> _pickImage(ImageSource source) async {
    try {
      XFile? pickedFile = await ImagePicker().pickImage(source: source);
      if (pickedFile != null) {
        _deviceImage = File(pickedFile.path);
        final url = await Provider.of<CityProvider>(context, listen: false)
            .uploadImage(_deviceImage!);
        widget.updateUrl(url);
        setState(() {});
      } else {}
    } catch (e) {
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextButton.icon(
              icon: Icon(Icons.photo),
              label: Text('Galerie'),
              onPressed: () => _pickImage(ImageSource.gallery),
            ),
            TextButton.icon(
              icon: Icon(Icons.photo_camera),
              label: Text('camera'),
              onPressed: () => _pickImage(ImageSource.camera),
            ),
          ],
        ),
        Container(
          width: double.infinity,
          child: _deviceImage != null
              ? Image.file(
                  _deviceImage!,
                  fit: BoxFit.cover,
                )
              : Text('Aucune image'),
        )
      ],
    );
  }
}
