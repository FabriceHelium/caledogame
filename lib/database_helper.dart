import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'games_database.db');
    return await openDatabase(
      path,
      version: 2, // Incrémentez la version ici
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE roles (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        role_name TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT,
        email TEXT,
        password TEXT,
        role_id INTEGER,
        FOREIGN KEY (role_id) REFERENCES roles (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE game_types (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        type_name TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE games (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        description TEXT,
        image TEXT,
        type_id INTEGER,
        FOREIGN KEY (type_id) REFERENCES game_types (id)
      )
    ''');

    await _insertDefaultRoles(db);
    await _insertDefaultAdmin(db);
    await _insertDefaultGameTypes(db);
    await _insertInitialData(db);
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE game_types (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          type_name TEXT
        )
      ''');

      await db.execute('''
        CREATE TABLE games (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT,
          description TEXT,
          image TEXT,
          type_id INTEGER,
          FOREIGN KEY (type_id) REFERENCES game_types (id)
        )
      ''');

      await _insertDefaultGameTypes(db);
      await _insertInitialData(db);
    }
  }

  Future<void> deleteDb() async {
    String path = join(await getDatabasesPath(), 'games_database.db');
    await deleteDatabase(path);
  }

  Future _insertInitialData(Database db) async {
    List<Map<String, String>> games = [
      {
        'title': 'Jeu 1',
        'description': 'Description du jeu 1',
        'image': 'assets/game1.jpg',
        'type_id': '1'
      },
      {
        'title': 'Jeu 2',
        'description': 'Description du jeu 2',
        'image': 'assets/game2.jpg',
        'type_id': '1'
      },
      {
        'title': 'Jeu 3',
        'description': 'Description du jeu 3',
        'image': 'assets/game3.jpg',
        'type_id': '1'
      },
      {
        'title': 'Jeu SMS 1',
        'description': 'Lots à gagner 1',
        'image': 'assets/prizes1.jpg',
        'type_id': '2'
      },
      {
        'title': 'Jeu SMS 2',
        'description': 'Lots à gagner 2',
        'image': 'assets/prizes2.jpg',
        'type_id': '2'
      },
      {
        'title': 'Jeu Facebook 1',
        'description': 'Description du jeu Facebook 1',
        'image': 'assets/facebook_game1.jpg',
        'type_id': '3'
      },
      {
        'title': 'Jeu Facebook 2',
        'description': 'Description du jeu Facebook 2',
        'image': 'assets/facebook_game2.jpg',
        'type_id': '3'
      },
      {
        'title': 'Jeu Mobile 1',
        'description': 'Description du jeu mobile 1',
        'image': 'assets/mobile_game1.jpg',
        'type_id': '4'
      },
      {
        'title': 'Jeu Mobile 2',
        'description': 'Description du jeu mobile 2',
        'image': 'assets/mobile_game2.jpg',
        'type_id': '4'
      },
      {
        'title': 'Jeu en Magasin 1',
        'description': 'Description du jeu en magasin 1',
        'image': 'assets/store_game1.jpg',
        'type_id': '5'
      },
      {
        'title': 'Jeu en Magasin 2',
        'description': 'Description du jeu en magasin 2',
        'image': 'assets/store_game2.jpg',
        'type_id': '5'
      },
    ];

    for (var game in games) {
      print('Inserting game: $game'); // Debugging line
      await db.insert('games', game);
    }
  }

  Future _insertDefaultRoles(Database db) async {
    await db.insert('roles', {'role_name': 'admin'});
    await db.insert('roles', {'role_name': 'user'});
  }

  Future _insertDefaultAdmin(Database db) async {
    int adminRoleId = await _getRoleId(db, 'admin');
    await db.insert('users', {
      'username': 'admin',
      'email': 'admin@admin.com',
      'password':
          'admin', // Vous pouvez hasher le mot de passe pour plus de sécurité
      'role_id': adminRoleId
    });
  }

  Future<int> _getRoleId(Database db, String roleName) async {
    final List<Map<String, dynamic>> result =
        await db.query('roles', where: 'role_name = ?', whereArgs: [roleName]);
    print('Role ID for $roleName: ${result.first['id']}'); // Debugging line
    return result.first['id'];
  }

  Future<void> insertUser(
      String username, String email, String password, String roleName) async {
    final db = await database;
    int roleId = await _getRoleId(db, roleName);
    await db.insert('users', {
      'username': username,
      'email': email,
      'password': password,
      'role_id': roleId
    });
  }

  Future _insertDefaultGameTypes(Database db) async {
    await db.insert('game_types', {'type_name': 'moment'});
    await db.insert('game_types', {'type_name': 'sms'});
    await db.insert('game_types', {'type_name': 'facebook'});
    await db.insert('game_types', {'type_name': 'mobile'});
    await db.insert('game_types', {'type_name': 'store'});
  }

  Future<int> _getGameTypeId(Database db, String typeName) async {
    final List<Map<String, dynamic>> result = await db
        .query('game_types', where: 'type_name = ?', whereArgs: [typeName]);
    print(
        'Game Type ID for $typeName: ${result.first['id']}'); // Debugging line
    return result.first['id'];
  }

  Future<void> insertGame(
      String title, String description, String image, String typeName) async {
    final db = await database;
    int typeId = await _getGameTypeId(db, typeName);
    await db.insert('games', {
      'title': title,
      'description': description,
      'image': image,
      'type_id': typeId
    });
  }

  Future<List<Map<String, String>>> getGamesByType(String typeName) async {
    final db = await database;
    int typeId = await _getGameTypeId(db, typeName);
    print('Type ID for $typeName: $typeId'); // Debugging line
    final List<Map<String, dynamic>> maps =
        await db.query('games', where: 'type_id = ?', whereArgs: [typeId]);
    print('Games for type $typeName: $maps'); // Debugging line

    return List<Map<String, String>>.from(maps.map(
        (game) => game.map((key, value) => MapEntry(key, value.toString()))));
  }
}
