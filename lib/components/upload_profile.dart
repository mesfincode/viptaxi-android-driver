import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class ProfileUploadComp extends StatefulWidget {
  @override
  _ProfileUploadCompState createState() => _ProfileUploadCompState();
}

class _ProfileUploadCompState extends State<ProfileUploadComp> {
  File? _imageFile;

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: source);

    if (pickedImage != null) {
      setState(() {
        _imageFile = File(pickedImage.path);
      });
    }
  }

  Future<void> _uploadImage() async {
    if (_imageFile == null) {
      print('No image selected');
      return;
    }

    final url = 'http://your-parse-server-url/parse/classes/ProfileImage';
    final headers = {
      'X-Parse-Application-Id': 'YOUR_APP_ID',
      'X-Parse-REST-API-Key': 'YOUR_REST_API_KEY',
      'Content-Type': 'application/json',
    };

    List<int> imageBytes = await _imageFile!.readAsBytes();
    String base64Image = base64Encode(imageBytes);

    final jsonPayload = jsonEncode({
      'imageData': base64Image,
    });

    final response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: jsonPayload,
    );

    if (response.statusCode == 201) {
      print('Image uploaded successfully');
    } else {
      print('Failed to upload image. StatusCode: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Image Upload'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_imageFile != null) ...[
              Image.file(_imageFile!),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _uploadImage,
                child: Text('Upload Image'),
              ),
            ] else ...[
              Text('No image selected'),
            ],
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _pickImage(ImageSource.gallery),
              child: Text('Pick Image'),
            ),
          ],
        ),
      ),
    );
  }
}
