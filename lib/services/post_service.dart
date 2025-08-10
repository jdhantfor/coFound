import 'package:dio/dio.dart';
import '../models/post.dart';
import '../models/comment.dart';
import 'database_helper.dart';

class PostService {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  final Dio _dio = Dio();
  final String _baseUrl = 'http://62.113.37.96:8000';

  // ==================== ЛОКАЛЬНЫЕ ОПЕРАЦИИ ====================

  Future<List<Post>> getLocalPosts() async {
    return await _databaseHelper.getAllPosts();
  }

  Future<Post?> getLocalPost(int id) async {
    return await _databaseHelper.getPost(id);
  }

  Future<int> savePostLocally(Post post) async {
    return await _databaseHelper.insertPost(post);
  }

  Future<int> updatePostLocally(Post post) async {
    return await _databaseHelper.updatePost(post);
  }

  Future<List<Comment>> getLocalCommentsForPost(int postId) async {
    return await _databaseHelper.getCommentsForPost(postId);
  }

  Future<int> saveCommentLocally(Comment comment) async {
    return await _databaseHelper.insertComment(comment);
  }

  Future<bool> isPostLikedByUser(int postId, int userId) async {
    return await _databaseHelper.isPostLikedByUser(postId, userId);
  }

  Future<int> likePostLocally(int postId, int userId) async {
    return await _databaseHelper.insertLike(postId, userId);
  }

  Future<int> unlikePostLocally(int postId, int userId) async {
    return await _databaseHelper.removeLike(postId, userId);
  }

  // ==================== СЕТЕВЫЕ ОПЕРАЦИИ ====================

  Future<List<Post>> getPosts() async {
    try {
      final response = await _dio.get('$_baseUrl/posts');

      if (response.statusCode == 200) {
        final List<dynamic> postsData = response.data;
        final List<Post> posts = postsData.map((json) => Post.fromJson(json)).toList();

        // Сохраняем посты локально
        for (final post in posts) {
          await savePostLocally(post);
        }

        return posts;
      }
    } catch (e) {
      print('Ошибка получения постов: $e');
      // Возвращаем локальные данные
      return await getLocalPosts();
    }
    return [];
  }

  Future<Post?> createPost({
    required int userId,
    required String content,
    int? companyId,
    String? imageUrl,
  }) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/posts',
        data: {
          'content': content,
          'company_id': companyId,
          'image_url': imageUrl,
        },
        queryParameters: {'user_id': userId},
      );

      if (response.statusCode == 200) {
        final postId = response.data['post_id'];
        final post = Post(
          id: postId,
          userId: userId,
          companyId: companyId,
          content: content,
          imageUrl: imageUrl,
          likesCount: 0,
          commentsCount: 0,
          createdAt: DateTime.now(),
        );

        // Сохраняем пост локально
        await savePostLocally(post);
        return post;
      }
    } catch (e) {
      print('Ошибка создания поста: $e');
      rethrow;
    }
    return null;
  }

  Future<Comment?> createComment({
    required int postId,
    required int userId,
    required String content,
  }) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/posts/$postId/comments',
        data: {
          'content': content,
        },
        queryParameters: {'user_id': userId},
      );

      if (response.statusCode == 200) {
        final comment = Comment(
          id: 0, // ID будет присвоен сервером
          postId: postId,
          userId: userId,
          content: content,
          createdAt: DateTime.now(),
        );

        // Сохраняем комментарий локально
        await saveCommentLocally(comment);
        return comment;
      }
    } catch (e) {
      print('Ошибка создания комментария: $e');
      rethrow;
    }
    return null;
  }

  Future<List<Comment>> getCommentsForPost(int postId) async {
    try {
      final response = await _dio.get('$_baseUrl/posts/$postId/comments');

      if (response.statusCode == 200) {
        final List<dynamic> commentsData = response.data;
        final List<Comment> comments = commentsData.map((json) => Comment.fromJson(json)).toList();

        // Сохраняем комментарии локально
        for (final comment in comments) {
          await saveCommentLocally(comment);
        }

        return comments;
      }
    } catch (e) {
      print('Ошибка получения комментариев: $e');
      // Возвращаем локальные данные
      return await getLocalCommentsForPost(postId);
    }
    return [];
  }

  Future<bool> likePost(int postId, int userId) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/posts/$postId/like',
        queryParameters: {'user_id': userId},
      );

      if (response.statusCode == 200) {
        // Обновляем локальное состояние
        await likePostLocally(postId, userId);
        return true;
      }
    } catch (e) {
      print('Ошибка лайка поста: $e');
      return false;
    }
    return false;
  }

  Future<bool> unlikePost(int postId, int userId) async {
    try {
      // Удаляем лайк локально
      await unlikePostLocally(postId, userId);
      return true;
    } catch (e) {
      print('Ошибка удаления лайка: $e');
      return false;
    }
  }

  // ==================== ДОПОЛНИТЕЛЬНЫЕ МЕТОДЫ ====================

  Future<Post?> getPostWithDetails(int postId) async {
    try {
      final post = await getLocalPost(postId);
      if (post != null) {
        // Получаем комментарии для поста
        final comments = await getCommentsForPost(postId);
        // Здесь можно добавить логику для получения пользователя и компании
        return post;
      }
    } catch (e) {
      print('Ошибка получения деталей поста: $e');
    }
    return null;
  }

  Future<List<Post>> getPostsByUser(int userId) async {
    final allPosts = await getLocalPosts();
    return allPosts.where((post) => post.userId == userId).toList();
  }

  Future<List<Post>> getPostsByCompany(int companyId) async {
    final allPosts = await getLocalPosts();
    return allPosts.where((post) => post.companyId == companyId).toList();
  }

  Future<void> refreshPosts() async {
    // Обновляем посты с сервера
    await getPosts();
  }
} 