import 'package:flutter/material.dart';
import 'default_image_widget.dart'; // Assurez-vous que le chemin d'importation est correct
import 'game_detail_page.dart'; // Assurez-vous que le chemin d'importation est correct

class AllGamesPage extends StatelessWidget {
  final String title;
  final List<Map<String, String>> games;

  const AllGamesPage({
    super.key,
    required this.title,
    required this.games,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: ListView.builder(
        itemCount: games.length,
        itemBuilder: (context, index) {
          final game = games[index];
          return ListTile(
            leading: DefaultImage(
              imagePath: game['image'] ?? 'assets/default.jpg',
              fit: BoxFit.cover,
              width: 50,
              height: 50,
            ),
            title: Text(game['title'] ?? 'Titre non disponible'),
            subtitle: Text(game['description'] ?? 'Description non disponible'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GameDetailPage(
                    image: game['image'] ?? 'assets/default.jpg',
                    title: game['title'] ?? 'Titre non disponible',
                    description:
                        game['description'] ?? 'Description non disponible',
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
