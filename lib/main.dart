import 'package:flutter/material.dart';

import 'image_gallery.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      color: Colors.blue.shade400,
      title: 'Pixabay Image Gallery',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const ImageGallery(),
    );
  }
}
