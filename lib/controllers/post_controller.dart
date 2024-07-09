import 'package:alfred/alfred.dart';
import '../models/post.dart';

class PostController {
  final List<Post> posts = [];

  PostController();

  void registerRoutes(Alfred app) {
    app.get('/posts', _getAllPosts);
    app.get('/posts/:id', _getPostById);
    app.post('/posts', _createPost);
    app.put('/posts/:id', _updatePost);
    app.delete('/posts/:id', _deletePost);
  }

  Future<void> _getAllPosts(HttpRequest req, HttpResponse res) async {
    await res.json(posts.map((post) => post.toJson()).toList());
  }

  Future<void> _getPostById(HttpRequest req, HttpResponse res) async {
    final id = req.params['id'];
    Post? post;
    for (var p in posts) {
      if (p.id == id) {
        post = p;
        break;
      }
    }

    if (post != null) {
      // JSON 형식으로 반환함
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
    posts.add(post);
    await res.json(post.toJson());
  }

  Future<void> _updatePost(HttpRequest req, HttpResponse res) async {
    final id = req.params['id'];
    final body = await req.bodyAsJsonMap;
    final index = posts.indexWhere((post) => post.id == id);
    if (index != -1) {
      posts[index] = Post(
        id: id,
        title: body['title'],
        address: body['address'],
        category: body['category'],
        image: body['image'],
        content: body['content'],
        createdAt: posts[index].createdAt,
      );
      await res.json(posts[index].toJson());
    } else {
      res.statusCode = 404;
      await res.json({'error': 'Post not found'});
    }
  }

  Future<void> _deletePost(HttpRequest req, HttpResponse res) async {
    final id = req.params['id'];
    posts.removeWhere((post) => post.id == id);
    await res.json({'message': 'Post deleted'});
  }
}