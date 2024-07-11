import 'dart:io';

import 'package:alfred/alfred.dart';
import 'package:herenow_backend/utils/database_helper.dart';
import '../models/post.dart';

class PostController {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  PostController() {
    _dbHelper.init();
  }

  void registerRoutes(Alfred app) {
    app.get(
      '/posts',
      _getAllPosts,
    );
    app.get(
      '/posts/:id',
      _getPostById,
    );
    app.post(
      '/posts',
      _createPost,
    );
    app.put(
      '/posts/:id',
      _updatePost,
    );
    app.delete(
      '/posts/:id',
      _deletePost,
    );
  }

  Future<void> _getAllPosts(
    HttpRequest req,
    HttpResponse res,
  ) async {
    try {
      final results = _dbHelper.database.select(
        'SELECT * FROM posts',
      );
      final posts = results
          .map(
            (row) => Post.fromMap(row),
          )
          .toList();
      await res.json(
        posts
            .map(
              (post) => post.toJson(),
            )
            .toList(),
      );
    } catch (e) {
      res.statusCode = HttpStatus.internalServerError;
      await res.json(
        {
          'error': 'Error retrieving posts: $e',
        },
      );
    }
  }

  Future<void> _getPostById(
    HttpRequest req,
    HttpResponse res,
  ) async {
    try {
      final id = req.params['id'];
      final results = _dbHelper.database.select(
        'SELECT * FROM posts WHERE id = ?',
        [id],
      );
      if (results.isNotEmpty) {
        final post = Post.fromMap(results.first);
        await res.json(
          post.toJson(),
        );
      } else {
        res.statusCode = 404;
        await res.json(
          {
            'error': 'Post not found',
          },
        );
      }
    } catch (e) {
      res.statusCode = HttpStatus.internalServerError;
      await res.json(
        {
          'error': 'Error retrieving post: $e',
        },
      );
    }
  }

  Future<void> _createPost(HttpRequest req, HttpResponse res) async {
    try {
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

      _dbHelper.database.execute(
        '''
        INSERT INTO posts (id, title, address, category, image, content, createdAt)
        VALUES (?, ?, ?, ?, ?, ?, ?)
      ''',
        [
          post.id,
          post.title,
          post.address,
          post.category,
          post.image,
          post.content,
          post.createdAt.toIso8601String(),
        ],
      );

      await res.json(post.toJson());
    } catch (e) {
      res.statusCode = HttpStatus.internalServerError;
      await res.json(
        {'error': 'Error creating post: $e'},
      );
    }
  }

  Future<void> _updatePost(
    HttpRequest req,
    HttpResponse res,
  ) async {
    try {
      final id = req.params['id'];
      final body = await req.bodyAsJsonMap;

      final results = _dbHelper.database.select(
        'SELECT * FROM posts WHERE id = ?',
        [id],
      );
      if (results.isNotEmpty) {
        final post = Post(
          id: id,
          title: body['title'],
          address: body['address'],
          category: body['category'],
          image: body['image'],
          content: body['content'],
          createdAt: DateTime.parse(
            results.first['createdAt'],
          ),
        );

        _dbHelper.database.execute(
          '''
          UPDATE posts SET title = ?, address = ?, category = ?, image = ?, content = ?
          WHERE id = ?
        ''',
          [
            post.title,
            post.address,
            post.category,
            post.image,
            post.content,
            post.id,
          ],
        );

        await res.json(
          post.toJson(),
        );
      } else {
        res.statusCode = 404;
        await res.json(
          {
            'error': 'Post not found',
          },
        );
      }
    } catch (e) {
      res.statusCode = HttpStatus.internalServerError;
      await res.json(
        {
          'error': 'Error updating post: $e',
        },
      );
    }
  }

  Future<void> _deletePost(HttpRequest req, HttpResponse res) async {
    try {
      final id = req.params['id'];
      _dbHelper.database.execute(
        'DELETE FROM posts WHERE id = ?',
        [id],
      );
      await res.json(
        {
          'message': 'Post deleted',
        },
      );
    } catch (e) {
      res.statusCode = HttpStatus.internalServerError;
      await res.json(
        {
          'error': 'Error deleting post: $e',
        },
      );
    }
  }
}
