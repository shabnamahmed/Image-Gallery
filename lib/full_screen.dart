import 'package:flutter/material.dart';
import 'package:transparent_image/transparent_image.dart';

// A page that displays an image in full screen with an animation.

// The image is loaded using the [FadeInImage] widget for a smooth transition.
class FullScreenImage extends StatelessWidget {
  // The URL of the image to display.
  final String image;

  // Creates a [FullScreenImage] widget with the given [image].
  const FullScreenImage({super.key, required this.image});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: () => Navigator.of(context).pop(), // Close on tap
        child: Center(
          child: Hero(
            tag: image,
            child: FadeInImage.memoryNetwork(
              placeholder: kTransparentImage,
              image: image,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}
