import '../models/post.dart';
import '../models/comment.dart';
import '../services/post_service.dart';

class PostRepository {
  final PostService _postService = PostService();

  // ==================== ОСНОВНЫЕ ОПЕРАЦИИ ====================

  Future<List<Post>> getPosts() async {
    return await _postService.getPosts();
  }

  Future<Post?> getPost(int id) async {
    return await _postService.getLocalPost(id);
  }

  Future<Post?> createPost({
    required int userId,
    required String content,
    int? companyId,
    String? imageUrl,
  }) async {
    return await _postService.createPost(
      userId: userId,
      content: content,
      companyId: companyId,
      imageUrl: imageUrl,
    );
  }

  Future<Comment?> createComment({
    required int postId,
    required int userId,
    required String content,
  }) async {
    return await _postService.createComment(
      postId: postId,
      userId: userId,
      content: content,
    );
  }

  Future<List<Comment>> getCommentsForPost(int postId) async {
    return await _postService.getCommentsForPost(postId);
  }

  Future<bool> likePost(int postId, int userId) async {
    return await _postService.likePost(postId, userId);
  }

  Future<bool> unlikePost(int postId, int userId) async {
    return await _postService.unlikePost(postId, userId);
  }

  // ==================== ДОПОЛНИТЕЛЬНЫЕ ОПЕРАЦИИ ====================

  Future<Post?> getPostWithDetails(int postId) async {
    return await _postService.getPostWithDetails(postId);
  }

  Future<List<Post>> getPostsByUser(int userId) async {
    return await _postService.getPostsByUser(userId);
  }

  Future<List<Post>> getPostsByCompany(int companyId) async {
    return await _postService.getPostsByCompany(companyId);
  }

  Future<void> refreshPosts() async {
    await _postService.refreshPosts();
  }

  Future<bool> isPostLikedByUser(int postId, int userId) async {
    return await _postService.isPostLikedByUser(postId, userId);
  }

  // ==================== ЛОКАЛЬНЫЕ ОПЕРАЦИИ ====================

  Future<List<Post>> getLocalPosts() async {
    return await _postService.getLocalPosts();
  }

  Future<Post?> getLocalPost(int id) async {
    return await _postService.getLocalPost(id);
  }

  Future<int> savePostLocally(Post post) async {
    return await _postService.savePostLocally(post);
  }

  Future<int> updatePostLocally(Post post) async {
    return await _postService.updatePostLocally(post);
  }

  Future<List<Comment>> getLocalCommentsForPost(int postId) async {
    return await _postService.getLocalCommentsForPost(postId);
  }

  Future<int> saveCommentLocally(Comment comment) async {
    return await _postService.saveCommentLocally(comment);
  }

  Future<int> likePostLocally(int postId, int userId) async {
    return await _postService.likePostLocally(postId, userId);
  }

  Future<int> unlikePostLocally(int postId, int userId) async {
    return await _postService.unlikePostLocally(postId, userId);
  }
} 