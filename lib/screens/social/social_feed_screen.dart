import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../providers/user_provider.dart';
import '../../providers/social_provider.dart';
import '../../models/post_model.dart';
import '../../widgets/post_card.dart';

class SocialFeedScreen extends StatefulWidget {
  const SocialFeedScreen({Key? key}) : super(key: key);

  @override
  State<SocialFeedScreen> createState() => _SocialFeedScreenState();
}

class _SocialFeedScreenState extends State<SocialFeedScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final socialProvider = context.read<SocialProvider>();
      socialProvider.loadPublicPosts();
      
      final userProvider = context.read<UserProvider>();
      if (userProvider.currentUser != null) {
        socialProvider.loadFriendsPosts(userProvider.currentUser!.friends);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final currentUser = userProvider.currentUser;

    if (currentUser == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.community_feed),
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Public', icon: Icon(Icons.public)),
            Tab(text: 'Amis', icon: Icon(Icons.people)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPublicFeed(currentUser.id),
          _buildFriendsFeed(currentUser.id),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreatePostDialog(currentUser),
        backgroundColor: AppColors.accent,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildPublicFeed(String userId) {
    return Consumer<SocialProvider>(
      builder: (context, socialProvider, child) {
        final posts = socialProvider.publicPosts;

        if (posts.isEmpty) {
          return _buildEmptyState('Aucun post pour le moment');
        }

        return RefreshIndicator(
          onRefresh: () async {
            socialProvider.loadPublicPosts();
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
              return PostCard(
                post: post,
                currentUserId: userId,
                onLike: (postId, userId) => _handleLike(postId, userId),
                onComment: (postId) => _showCommentsDialog(postId),
                onDelete: (postId, userId) => _handleDelete(postId, userId),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildFriendsFeed(String userId) {
    return Consumer<SocialProvider>(
      builder: (context, socialProvider, child) {
        final posts = socialProvider.friendsPosts;

        if (posts.isEmpty) {
          return _buildEmptyState(
            'Aucun post de vos amis\nCommencez par ajouter des amis !',
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            final userProvider = context.read<UserProvider>();
            if (userProvider.currentUser != null) {
              socialProvider.loadFriendsPosts(userProvider.currentUser!.friends);
            }
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
              return PostCard(
                post: post,
                currentUserId: userId,
                onLike: (postId, userId) => _handleLike(postId, userId),
                onComment: (postId) => _showCommentsDialog(postId),
                onDelete: (postId, userId) => _handleDelete(postId, userId),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.feed,
            size: 64,
            color: AppColors.textHint,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Future<void> _handleLike(String postId, String userId) async {
    final socialProvider = context.read<SocialProvider>();
    await socialProvider.toggleLike(postId, userId);
  }

  Future<void> _handleDelete(String postId, String userId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer le post'),
        content: const Text('Êtes-vous sûr de vouloir supprimer ce post ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final socialProvider = context.read<SocialProvider>();
      await socialProvider.deletePost(postId, userId);
    }
  }

  void _showCommentsDialog(String postId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return _buildCommentsSection(postId, scrollController);
        },
      ),
    );
  }

  Widget _buildCommentsSection(String postId, ScrollController scrollController) {
    final userProvider = context.watch<UserProvider>();
    final currentUser = userProvider.currentUser;

    if (currentUser == null) return const SizedBox.shrink();

    final TextEditingController commentController = TextEditingController();

    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Text(
                'Commentaires',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
        const Divider(height: 1),

        // Comments list (placeholder - would need to load comments)
        Expanded(
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.all(16),
            children: const [
              Center(
                child: Text(
                  'Les commentaires seront affichés ici',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
            ],
          ),
        ),

        // Comment input
        Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: AppColors.divider)),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: commentController,
                  decoration: InputDecoration(
                    hintText: 'Ajouter un commentaire...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.send, color: AppColors.primary),
                onPressed: () async {
                  if (commentController.text.isNotEmpty) {
                    final socialProvider = context.read<SocialProvider>();
                    await socialProvider.addComment(
                      postId: postId,
                      userId: currentUser.id,
                      userName: currentUser.name,
                      text: commentController.text,
                    );
                    commentController.clear();
                  }
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showCreatePostDialog(currentUser) {
    final TextEditingController contentController = TextEditingController();
    PostVisibility selectedVisibility = PostVisibility.public;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Créer un post'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: contentController,
                decoration: const InputDecoration(
                  hintText: 'Quoi de neuf ?',
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<PostVisibility>(
                value: selectedVisibility,
                decoration: const InputDecoration(
                  labelText: 'Visibilité',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                    value: PostVisibility.public,
                    child: Row(
                      children: [
                        Icon(Icons.public, size: 18),
                        SizedBox(width: 8),
                        Text('Public'),
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                    value: PostVisibility.friends,
                    child: Row(
                      children: [
                        Icon(Icons.people, size: 18),
                        SizedBox(width: 8),
                        Text('Amis uniquement'),
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                    value: PostVisibility.private,
                    child: Row(
                      children: [
                        Icon(Icons.lock, size: 18),
                        SizedBox(width: 8),
                        Text('Privé'),
                      ],
                    ),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => selectedVisibility = value);
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (contentController.text.isNotEmpty) {
                  final socialProvider = context.read<SocialProvider>();
                  await socialProvider.createPost(
                    userId: currentUser.id,
                    userName: currentUser.name,
                    userPhotoURL: currentUser.photoUrl,
                    type: PostType.custom,
                    content: contentController.text,
                    visibility: selectedVisibility,
                  );
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('✅ Post publié avec succès !'),
                        backgroundColor: AppColors.success,
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                }
              },
              child: const Text('Publier'),
            ),
          ],
        ),
      ),
    );
  }
}
