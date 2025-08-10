import 'package:flutter/material.dart';
import '/screens/home_screen.dart';
import '/screens/companies_screen.dart';
import '/screens/profile_screen.dart';
import '/screens/post_detail_screen.dart';
import '/screens/share_screen.dart';
import '/models/models.dart';
import '/services/services.dart';
import '/repositories/repositories.dart';
import '/app_styles.dart';
import '/utils/image_utils.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  _FeedScreenState createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final PostRepository _postRepository = PostRepository();
  final UserRepository _userRepository = UserRepository();
  final CompanyRepository _companyRepository = CompanyRepository();
  
  List<Post> _posts = [];
  Map<int, User> _authors = {};
  Map<int, Company> _companies = {};
  Map<int, bool> _likedPosts = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  Future<void> _loadPosts() async {
    try {
      final posts = await _postRepository.getPosts();
      setState(() {
        _posts = posts;
        _isLoading = false;
      });
      
      // Загружаем данные авторов и компаний
      for (final post in posts) {
        if (post.userId != null) {
          try {
            final author = await _userRepository.getUser(post.userId!);
            if (author != null) {
              _authors[post.userId!] = author;
            }
          } catch (e) {
            print('Ошибка загрузки автора: $e');
          }
        }
        
        if (post.companyId != null) {
          try {
            final company = await _companyRepository.getCompany(post.companyId!);
            if (company != null) {
              _companies[post.companyId!] = company;
            }
          } catch (e) {
            print('Ошибка загрузки компании: $e');
          }
        }
      }
      
      setState(() {});
    } catch (e) {
      print('Ошибка загрузки постов: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _handleLike(int index) async {
    final post = _posts[index];
    final isLiked = _likedPosts[post.id] ?? false;
    const currentUserId = 1; // TODO: Получить ID текущего пользователя
    
    try {
      if (isLiked) {
        await _postRepository.unlikePost(post.id, currentUserId);
      } else {
        await _postRepository.likePost(post.id, currentUserId);
      }
      
      setState(() {
        _likedPosts[post.id] = !isLiked;
        _posts[index] = post.copyWith(
          likesCount: post.likesCount + (isLiked ? -1 : 1),
        );
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _handleComment(int index) {
    final post = _posts[index];
    final author = _authors[post.userId];
    final company = post.companyId != null ? _companies[post.companyId] : null;
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PostDetailScreen(
          post: post,
          author: author,
          company: company,
        ),
      ),
    );
  }

  void _handleRepost(int index) {
    final post = _posts[index];
    final author = _authors[post.userId];
    final company = post.companyId != null ? _companies[post.companyId] : null;
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ShareScreen(
          post: post,
          author: author,
          company: company,
        ),
      ),
    );
  }

  void _openPostDetail(int index) {
    final post = _posts[index];
    final author = _authors[post.userId];
    final company = post.companyId != null ? _companies[post.companyId] : null;
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PostDetailScreen(
          post: post,
          author: author,
          company: company,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyles.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppStyles.primaryColor, width: 1),
          ),
          child: RichText(
            text: const TextSpan(
              children: [
                TextSpan(
                  text: 'co',
                  style: TextStyle(
                    color: Color(0xFFD33D3D),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(
                  text: 'Found',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _posts.length,
              itemBuilder: (context, index) {
                final post = _posts[index];
                final author = _authors[post.userId];
                final company = post.companyId != null ? _companies[post.companyId] : null;
                final isLiked = _likedPosts[post.id] ?? false;
                
                return Card(
                  elevation: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: InkWell(
                    onTap: () => _openPostDetail(index),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 20,
                                backgroundColor: AppStyles.primaryColor.withOpacity(0.1),
                                child: author?.avatarUrl != null
                                    ? ClipOval(
                                        child: ImageUtils.buildImage(
                                          imageUrl: author!.avatarUrl!,
                                          width: 40,
                                          height: 40,
                                          fit: BoxFit.cover,
                                          errorWidget: Icon(Icons.person, color: AppStyles.primaryColor, size: 20),
                                        ),
                                      )
                                    : Icon(Icons.person, color: AppStyles.primaryColor, size: 20),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      author?.name ?? 'Пользователь',
                                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    if (company != null)
                                      Text(
                                        company.name,
                                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          color: AppStyles.secondaryGrey,
                                        ),
                                      ),
                                    Text(
                                      _formatTimestamp(post.createdAt),
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: AppStyles.secondaryGrey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            post.content,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          if (post.imageUrl != null) ...[
                            const SizedBox(height: 12),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: ImageUtils.buildImage(
                                imageUrl: post.imageUrl!,
                                height: 200,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorWidget: Container(
                                  height: 200,
                                  decoration: BoxDecoration(
                                    color: AppStyles.secondaryGrey.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Center(child: Text('Изображение недоступно')),
                                ),
                              ),
                            ),
                          ],
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      isLiked ? Icons.favorite : Icons.favorite_border,
                                      color: isLiked ? AppStyles.secondaryColor : AppStyles.primaryColor,
                                    ),
                                    onPressed: () => _handleLike(index),
                                  ),
                                  Text('${post.likesCount}'),
                                  const SizedBox(width: 16),
                                  IconButton(
                                    icon: Icon(Icons.comment, color: AppStyles.secondaryColor),
                                    onPressed: () => _handleComment(index),
                                  ),
                                  Text('${post.commentsCount}'),
                                ],
                              ),
                              IconButton(
                                icon: Icon(Icons.share, color: AppStyles.secondaryColor),
                                onPressed: () => _handleRepost(index),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppStyles.primaryColor,
        unselectedItemColor: AppStyles.textColorLight,
        backgroundColor: Colors.white,
        currentIndex: 1,
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
              break;
            case 1:
              break; // Уже на FeedScreen
            case 2:
              Navigator.push(context, MaterialPageRoute(builder: (_) => const CompaniesScreen()));
              break;
            case 3:
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Главная',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.feed),
            label: 'Лента',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.business),
            label: 'Компании',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Профиль',
          ),
        ],
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
}