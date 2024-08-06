import 'package:flutter/material.dart';
import 'default_image_widget.dart'; // Assurez-vous que ce chemin est correct

class GameDetailPage extends StatelessWidget {
  final String image;
  final String title;
  final String description;

  const GameDetailPage({
    Key? key,
    required this.image,
    required this.title,
    required this.description,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 200, // Hauteur fixe pour éviter les contraintes infinies
              width: double.infinity,
              child: DefaultImage(
                imagePath: image,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            Text(
              description,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
