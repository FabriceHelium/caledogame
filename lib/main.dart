import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'database_helper.dart';
import 'default_image_widget.dart';
import 'game_detail_page.dart';
import 'all_games_page.dart';
import 'account_creation_page.dart';
import 'account_list_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Les jeux calédoniens',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 183, 58, 58),
        ),
        useMaterial3: true,
      ),
      home: const MyHomePage(
          title: 'Tous les jeux calédoniens à un seul endroit'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static const double _bannerHeight = 100;
  static const double _sliderHeight = 200;
  static const double _gameItemWidth = 160;
  static const double _gameItemHeight = 200;
  static const EdgeInsetsGeometry _padding = EdgeInsets.all(16);

  late DatabaseHelper dbHelper;
  bool _isDbInitialized = false;

  @override
  void initState() {
    super.initState();
    dbHelper = DatabaseHelper();
    _deleteAndInitializeDatabase();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showIntroDialog(context);
    });
  }

  Future<void> _deleteAndInitializeDatabase() async {
    await dbHelper
        .deleteDb(); // Ajoutez cette ligne pour supprimer la base de données existante
    await dbHelper.database;
    setState(() {
      _isDbInitialized = true;
    });
  }

  void _showIntroDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Bienvenue !'),
          content: Text(
            'Bienvenue sur l\'application Les jeux calédoniens. '
            'Cette application vous permet de découvrir tous les jeux disponibles en Nouvelle-Calédonie.',
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Fermer'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<List<Map<String, String>>> _getGamesByType(String type) async {
    try {
      return await dbHelper.getGamesByType(type);
    } catch (e) {
      print('Error fetching games by type: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isDbInitialized) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(80.0),
        child: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Row(
            children: [
              Image.asset(
                'assets/logo.png',
                height: 40,
              ),
              SizedBox(width: 16),
              Expanded(
                child: Text(
                  widget.title,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.person_add),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AccountCreationPage(),
                  ),
                );
              },
            ),
            IconButton(
              icon: Icon(Icons.list),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AccountListPage(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            const SizedBox(height: 20),
            _buildSlider(context),
            const SizedBox(height: 16),
            _buildGamesSection('Les jeux du moment calédoniens', 'moment'),
            const SizedBox(height: 16),
            _buildAdBanner(context),
            const SizedBox(height: 16),
            _buildGamesSection(
                'Tous les jeux SMS en Nouvelle-Calédonie', 'sms'),
            const SizedBox(height: 16),
            _buildAdBanner(context),
            const SizedBox(height: 16),
            _buildGamesSection('Jeux Facebook NC', 'facebook'),
            const SizedBox(height: 16),
            _buildAdBanner(context),
            const SizedBox(height: 16),
            _buildGamesSection('Jeux Application Mobile NC', 'mobile'),
            const SizedBox(height: 16),
            _buildAdBanner(context),
            const SizedBox(height: 16),
            _buildGamesSection('Jeux dans les Magasins NC', 'store'),
          ],
        ),
      ),
    );
  }

  Widget _buildSlider(BuildContext context) {
    final sliderImages = [
      'assets/banner1.jpg',
      'assets/banner2.jpg',
      'assets/banner3.jpg',
    ];

    return CarouselSlider(
      options: CarouselOptions(
        height: _sliderHeight,
        autoPlay: true,
        enlargeCenterPage: true,
      ),
      items: sliderImages.map((imagePath) {
        return Builder(
          builder: (BuildContext context) {
            return Container(
              width: MediaQuery.of(context).size.width,
              margin: const EdgeInsets.symmetric(horizontal: 5.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
              ),
              child: DefaultImage(
                imagePath: imagePath,
                fit: BoxFit.cover,
              ),
            );
          },
        );
      }).toList(),
    );
  }

  Widget _buildAdBanner(BuildContext context) {
    return Container(
      height: _bannerHeight,
      color: Colors.grey[300],
      child: Center(
        child: Text(
          'Espace Publicitaire',
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
    );
  }

  Widget _buildGamesSection(String title, String type) {
    return FutureBuilder<List<Map<String, String>>>(
      future: _getGamesByType(type),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Erreur de chargement des jeux'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('Aucun jeu disponible'));
        }

        List<Map<String, String>> games = snapshot.data!;
        return Container(
          padding: _padding,
          child: Column(
            children: [
              Center(
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge ??
                      const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: _gameItemHeight,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: games.length,
                  itemBuilder: (context, index) {
                    final game = games[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => GameDetailPage(
                              image: game['image'] ?? 'assets/default.jpg',
                              title: game['title'] ?? 'Titre non disponible',
                              description: game['description'] ??
                                  'Description non disponible',
                            ),
                          ),
                        );
                      },
                      child: Container(
                        width: _gameItemWidth,
                        margin: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Card(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                height: _gameItemHeight * 0.6,
                                child: DefaultImage(
                                  imagePath:
                                      game['image'] ?? 'assets/default.jpg',
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      game['title'] ?? 'Titre non disponible',
                                      style: Theme.of(context)
                                              .textTheme
                                              .titleMedium ??
                                          const TextStyle(fontSize: 16),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      game['description'] ??
                                          'Description non disponible',
                                      style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium ??
                                          const TextStyle(fontSize: 14),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AllGamesPage(
                        title: title,
                        games: games,
                      ),
                    ),
                  );
                },
                child: Text('Voir tous les jeux'),
              ),
            ],
          ),
        );
      },
    );
  }
}
