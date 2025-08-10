import 'package:flutter/material.dart';
import '/models/models.dart';
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
  bool _isLiked = false;
  int _likesCount = 0;
  final TextEditingController _commentController = TextEditingController();
  final List<Comment> _comments = [];

  @override
  void initState() {
    super.initState();
    _likesCount = widget.post.likesCount;
    // TODO: Загрузить комментарии и статус лайка
  }

  void _handleLike() {
    setState(() {
      _isLiked = !_isLiked;
      _likesCount += _isLiked ? 1 : -1;
    });
    // TODO: Отправить лайк на сервер
  }

  void _handleComment() {
    if (_commentController.text.trim().isEmpty) return;

    final newComment = Comment(
      id: DateTime.now().millisecondsSinceEpoch,
      postId: widget.post.id,
      userId: 1, // TODO: Получить ID текущего пользователя
      content: _commentController.text.trim(),
      createdAt: DateTime.now(),
    );

    setState(() {
      _comments.insert(0, newComment);
    });

    _commentController.clear();
    // TODO: Отправить комментарий на сервер
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
                    decoration: InputDecoration(
                      hintText: 'Написать комментарий...',
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
                  onPressed: _handleComment,
                  icon: Icon(Icons.send, color: AppStyles.secondaryColor),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Список комментариев
            if (_comments.isNotEmpty) ...[
              Text(
                'Комментарии',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              ..._comments.map((comment) => _buildCommentCard(comment)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCommentCard(Comment comment) {
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
              child: Icon(Icons.person, color: AppStyles.primaryColor, size: 16),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Пользователь', // TODO: Получить имя пользователя
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