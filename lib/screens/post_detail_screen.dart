import 'package:flutter/material.dart';
import '/models/models.dart';
import '/services/services.dart';
import '/repositories/repositories.dart';
import '/app_styles.dart';
import '/utils/image_utils.dart';

class PostDetailScreen extends StatefulWidget {
  final Post post;
  final User? author;
  final Company? company;

  const PostDetailScreen({
    super.key,
    required this.post,
    this.author,
    this.company,
  });

  @override
  _PostDetailScreenState createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  final PostRepository _postRepository = PostRepository();
  final UserRepository _userRepository = UserRepository();
  
  bool _isLiked = false;
  int _likesCount = 0;
  final TextEditingController _commentController = TextEditingController();
  final List<Comment> _comments = [];
  Map<int, User> _commentAuthors = {};
  bool _isLoadingComments = true;
  bool _isSubmittingComment = false;

  @override
  void initState() {
    super.initState();
    _likesCount = widget.post.likesCount;
    _loadComments();
    _checkLikeStatus();
  }

  Future<void> _loadComments() async {
    try {
      if (mounted) {
        setState(() {
          _isLoadingComments = true;
        });
      }

      final comments = await _postRepository.getCommentsForPost(widget.post.id);
      
      // Загружаем данные авторов комментариев
      for (final comment in comments) {
        try {
          final author = await _userRepository.getUser(comment.userId);
          if (author != null && mounted) {
            _commentAuthors[comment.userId] = author;
          }
        } catch (e) {
          print('Ошибка загрузки автора комментария: $e');
        }
      }

      if (mounted) {
        setState(() {
          _comments.clear();
          _comments.addAll(comments);
          _isLoadingComments = false;
        });
      }
    } catch (e) {
      print('Ошибка загрузки комментариев: $e');
      if (mounted) {
        setState(() {
          _isLoadingComments = false;
        });
      }
    }
  }

  Future<void> _checkLikeStatus() async {
    try {
      final userId = await SessionService.getCurrentUserId();
      if (userId != null) {
        final isLiked = await _postRepository.isPostLikedByUser(widget.post.id, userId);
        if (mounted) {
          setState(() {
            _isLiked = isLiked;
          });
        }
      }
    } catch (e) {
      print('Ошибка проверки статуса лайка: $e');
    }
  }

  Future<void> _handleLike() async {
    try {
      final userId = await SessionService.getCurrentUserId();
      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Необходимо войти в систему')),
        );
        return;
      }

      bool success;
      if (_isLiked) {
        success = await _postRepository.unlikePost(widget.post.id, userId);
      } else {
        success = await _postRepository.likePost(widget.post.id, userId);
      }

      if (success && mounted) {
        setState(() {
          _isLiked = !_isLiked;
          _likesCount += _isLiked ? 1 : -1;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка: $e')),
      );
    }
  }

  Future<void> _handleComment() async {
    if (_commentController.text.trim().isEmpty) return;

    try {
      final userId = await SessionService.getCurrentUserId();
      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Необходимо войти в систему')),
        );
        return;
      }

      if (mounted) {
        setState(() {
          _isSubmittingComment = true;
        });
      }

      final comment = await _postRepository.createComment(
        postId: widget.post.id,
        userId: userId,
        content: _commentController.text.trim(),
      );

      if (comment != null && mounted) {
        // Загружаем данные автора для нового комментария
        try {
          final author = await _userRepository.getUser(userId);
          if (author != null) {
            _commentAuthors[userId] = author;
          }
        } catch (e) {
          print('Ошибка загрузки автора: $e');
        }

        setState(() {
          _comments.insert(0, comment);
          _commentController.clear();
          _isSubmittingComment = false;
        });
      } else {
        if (mounted) {
          setState(() {
            _isSubmittingComment = false;
          });
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ошибка создания комментария')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSubmittingComment = false;
        });
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyles.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppStyles.primaryColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            'coFound',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Заголовок поста
            Row(
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundColor: AppStyles.primaryColor.withOpacity(0.1),
                  child: widget.author?.avatarUrl != null
                      ? ClipOval(
                          child: ImageUtils.buildImage(
                            imageUrl: widget.author!.avatarUrl!,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            errorWidget: Icon(Icons.person, color: AppStyles.primaryColor, size: 30),
                          ),
                        )
                      : Icon(Icons.person, color: AppStyles.primaryColor, size: 30),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.author?.name ?? 'Пользователь',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (widget.company != null)
                        Text(
                          widget.company!.name,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppStyles.secondaryGrey,
                          ),
                        ),
                      Text(
                        _formatTimestamp(widget.post.createdAt),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppStyles.secondaryGrey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Содержимое поста
            Text(
              widget.post.content,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            
            // Изображение поста
            if (widget.post.imageUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: ImageUtils.buildImage(
                  imageUrl: widget.post.imageUrl!,
                  width: double.infinity,
                  height: 250,
                  fit: BoxFit.cover,
                  errorWidget: Container(
                    height: 250,
                    decoration: BoxDecoration(
                      color: AppStyles.secondaryGrey.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(child: Text('Изображение недоступно')),
                  ),
                ),
              ),
            const SizedBox(height: 16),
            
            // Действия с постом
            Row(
              children: [
                IconButton(
                  icon: Icon(
                    _isLiked ? Icons.favorite : Icons.favorite_border,
                    color: _isLiked ? AppStyles.secondaryColor : AppStyles.primaryColor,
                  ),
                  onPressed: _handleLike,
                ),
                Text('$_likesCount'),
                const SizedBox(width: 16),
                IconButton(
                  icon: Icon(Icons.comment, color: AppStyles.secondaryColor),
                  onPressed: () {
                    // Фокус на поле комментария
                    FocusScope.of(context).requestFocus(FocusNode());
                    Future.delayed(const Duration(milliseconds: 100), () {
                      FocusScope.of(context).requestFocus(FocusNode());
                    });
                  },
                ),
                Text('${widget.post.commentsCount + _comments.length}'),
                const Spacer(),
                IconButton(
                  icon: Icon(Icons.share, color: AppStyles.secondaryColor),
                  onPressed: () {
                    // TODO: Реализовать шаринг
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Функция шаринга в разработке')),
                    );
                  },
                ),
              ],
            ),
            const Divider(),
            
            // Поле для комментария
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    enabled: !_isSubmittingComment,
                    decoration: InputDecoration(
                      hintText: _isSubmittingComment ? 'Отправка...' : 'Написать комментарий...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _isSubmittingComment ? null : _handleComment,
                  icon: _isSubmittingComment 
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(AppStyles.secondaryColor),
                          ),
                        )
                      : Icon(Icons.send, color: AppStyles.secondaryColor),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Список комментариев
            if (_isLoadingComments) ...[
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                ),
              ),
            ] else if (_comments.isNotEmpty) ...[
              Text(
                'Комментарии (${_comments.length})',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              ..._comments.map((comment) => _buildCommentCard(comment)),
            ] else ...[
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Пока нет комментариев',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppStyles.secondaryGrey,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCommentCard(Comment comment) {
    final author = _commentAuthors[comment.userId];
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: AppStyles.primaryColor.withOpacity(0.1),
              child: author?.avatarUrl != null
                  ? ClipOval(
                      child: ImageUtils.buildImage(
                        imageUrl: author!.avatarUrl!,
                        width: 32,
                        height: 32,
                        fit: BoxFit.cover,
                        errorWidget: Icon(Icons.person, color: AppStyles.primaryColor, size: 16),
                      ),
                    )
                  : Icon(Icons.person, color: AppStyles.primaryColor, size: 16),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        author?.name ?? 'Пользователь',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _formatTimestamp(comment.createdAt),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppStyles.secondaryGrey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(comment.content),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    if (difference.inDays > 0) {
      return '${difference.inDays} дн. назад';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ч. назад';
    } else {
      return '${difference.inMinutes} мин. назад';
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }
} 