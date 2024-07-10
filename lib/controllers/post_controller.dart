import 'package:alfred/alfred.dart';
import 'package:herenow_backend/utils/database_helper.dart';
import '../models/post.dart';

class PostController {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  PostController() {
    _dbHelper.init();
  }

  void registerRoutes(Alfred app) {
    app.get('/posts', _getAllPosts);
    app.get('/posts/:id', _getPostById);
    app.post('/posts', _createPost);
    app.put('/posts/:id', _updatePost);
    app.delete('/posts/:id', _deletePost);
  }

  Future<void> _getAllPosts(HttpRequest req, HttpResponse res) async {
    final results = _dbHelper.database.select('SELECT * FROM posts');
    final posts = results.map((row) => Post.fromMap(row)).toList();
    await res.json(posts.map((post) => post.toJson()).toList());
  }

  Future<void> _getPostById(HttpRequest req, HttpResponse res) async {
    final id = req.params['id'];
    final results = _dbHelper.database.select('SELECT * FROM posts WHERE id = ?', [id]);
    if (results.isNotEmpty) {
      final post = Post.fromMap(results.first);
      await res.json(post.toJson());
    } else {
      res.statusCode = 404;
      await res.json({'error': 'Post not found'});
    }
  }

  Future<void> _createPost(HttpRequest req, HttpResponse res) async {
    final body = await req.bodyAsJsonMap;

    final post = Post(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: body['title'],
      address: body['address'],
      category: body['category'],
      image: body['image'],
      content: body['content'],
      createdAt: DateTime.now(),
    );

    _dbHelper.database.execute('''
      INSERT INTO posts (id, title, address, category, image, content, createdAt)
      VALUES (?, ?, ?, ?, ?, ?, ?)
    ''', [post.id, post.title, post.address, post.category, post.image, post.content, post.createdAt.toIso8601String()]);

    await res.json(post.toJson());
  }

  Future<void> _updatePost(HttpRequest req, HttpResponse res) async {
    final id = req.params['id'];
    final body = await req.bodyAsJsonMap;

    final results = _dbHelper.database.select('SELECT * FROM posts WHERE id = ?', [id]);
    if (results.isNotEmpty) {
      final post = Post(
        id: id,
        title: body['title'],
        address: body['address'],
        category: body['category'],
        image: body['image'],
        content: body['content'],
        createdAt: DateTime.parse(results.first['createdAt']),
      );

      _dbHelper.database.execute('''
        UPDATE posts SET title = ?, address = ?, category = ?, image = ?, content = ?
        WHERE id = ?
      ''', [post.title, post.address, post.category, post.image, post.content, post.id]);

      await res.json(post.toJson());
    } else {
      res.statusCode = 404;
      await res.json({'error': 'Post not found'});
    }
  }

  Future<void> _deletePost(HttpRequest req, HttpResponse res) async {
    final id = req.params['id'];
    _dbHelper.database.execute('DELETE FROM posts WHERE id = ?', [id]);
    await res.json({'message': 'Post deleted'});
  }
}