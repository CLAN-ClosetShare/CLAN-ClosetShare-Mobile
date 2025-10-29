import 'dart:io';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/di/injection_container.dart' as di;
import '../../../../core/network/api_client.dart';
import '../../../../core/repositories/auth_repository.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/network_image.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class Post {
  final String id;
  final String title;
  final String content;
  final String authorId;
  final DateTime createdAt;
  final List<String>? _images;

  Post({
    required this.id,
    required this.title,
    required this.content,
    required this.authorId,
    required this.createdAt,
    List<String>? images,
  }) : _images = images;

  factory Post.fromJson(Map<String, dynamic> json) {
    // Try explicit images array first
    List<String>? imgs = (json['images'] as List<dynamic>?)
        ?.map((e) => e?.toString() ?? '')
        .where((s) => s.isNotEmpty)
        .toList();

    final content = json['content']?.toString() ?? '';

    // If no explicit images, try to extract image URLs from the content
    if ((imgs == null || imgs.isEmpty) && content.isNotEmpty) {
      final extracted = <String>[];

      // 1) Markdown image syntax: ![alt](https://...)
      final mdImgRE = RegExp(r'!\[.*?\]\((https?:\/\/[^)]+)\)', caseSensitive: false);
      for (final m in mdImgRE.allMatches(content)) {
        final url = m.group(1);
        if (url != null && url.isNotEmpty) extracted.add(url);
      }

      // 2) Plain image URLs (ending with common image extensions)
      final urlRE = RegExp(r'(https?:\/\/[^\s)]+\.(?:png|jpe?g|gif|webp))', caseSensitive: false);
      for (final m in urlRE.allMatches(content)) {
        final url = m.group(1);
        if (url != null && url.isNotEmpty && !extracted.contains(url)) extracted.add(url);
      }

      if (extracted.isNotEmpty) imgs = extracted;
    }

    return Post(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Không tiêu đề',
      content: content,
      authorId: json['author_id']?.toString() ?? '',
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
      images: imgs == null || imgs.isEmpty ? null : imgs,
    );
  }
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  final ApiClient _api = di.sl<ApiClient>();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _picker = ImagePicker();
  List<Post> _posts = [];
  bool _loading = false;
  String? _error;
  final Set<String> _liked = {};

  // Filter state
  RangeValues _priceRange = const RangeValues(0, 1000);
  double _minPrice = 0;
  double _maxPrice = 1000;
  Set<String> _selectedTags = {};

  // Heart animation
  bool _showHeart = false;
  Timer? _heartTimer;

  @override
  void initState() {
    super.initState();
    _fetchPosts();
  }

  @override
  void dispose() {
    _heartTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _showQuickLoginDialog() async {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Đăng nhập lại'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại để tiếp tục.',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: 'Mật khẩu'),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                final authRepo = di.sl<AuthRepository>();
                await authRepo.login(
                  emailController.text.trim(),
                  passwordController.text.trim(),
                );
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đăng nhập thành công!')),
                );
                if (!mounted) return;
              } catch (e) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('Lỗi đăng nhập: $e')));
              }
            },
            child: const Text('Đăng nhập'),
          ),
        ],
      ),
    );
  }

  Future<void> _fetchPosts() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final response = await _api.getPosts();
      final raw = response is Map<String, dynamic> ? response : {};
      final items = raw['posts'] as List<dynamic>?;
      if (items == null) {
        setState(() {
          _posts = [];
        });
      } else {
        final parsed = items
            .map((e) => Post.fromJson(e as Map<String, dynamic>))
            .toList();
        setState(() {
          _posts = parsed;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Lỗi khi tải dữ liệu: $e';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inSeconds < 60) return 'vừa xong';
    if (diff.inMinutes < 60) return '${diff.inMinutes} phút trước';
    if (diff.inHours < 24) return '${diff.inHours} giờ trước';
    if (diff.inDays < 7) return '${diff.inDays} ngày trước';
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  Widget _buildSearchFilterBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                // Could navigate to search page
              },
              child: Container(
                height: 44,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.search, color: Colors.grey.shade600),
                    const SizedBox(width: 8),
                    Text(
                      'Tìm kiếm outfit, thương hiệu...',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: _openFilterModal,
            child: Container(
              height: 44,
              width: 44,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.filter_list, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _openFilterModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (c) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.95,
          builder: (context, sc) => SingleChildScrollView(
            controller: sc,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      height: 4,
                      width: 40,
                      color: Colors.grey.shade300,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Bộ lọc',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  const Text('Tags'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children:
                        [
                              'Outfit',
                              'Vintage',
                              'Sale',
                              'Streetwear',
                              'Formal',
                              'Casual',
                            ]
                            .map(
                              (t) => FilterChip(
                                label: Text(t),
                                selected: _selectedTags.contains(t),
                                onSelected: (v) => setState(() {
                                  if (v)
                                    _selectedTags.add(t);
                                  else
                                    _selectedTags.remove(t);
                                }),
                              ),
                            )
                            .toList(),
                  ),
                  const SizedBox(height: 16),
                  const Text('Khoảng giá'),
                  const SizedBox(height: 8),
                  RangeSlider(
                    values: _priceRange,
                    min: _minPrice,
                    max: _maxPrice,
                    divisions: 20,
                    labels: RangeLabels(
                      '${_priceRange.start.toInt()}',
                      '${_priceRange.end.toInt()}',
                    ),
                    onChanged: (v) => setState(() => _priceRange = v),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setState(() {
                              _selectedTags.clear();
                              _priceRange = RangeValues(_minPrice, _maxPrice);
                            });
                            Navigator.of(context).pop();
                          },
                          child: const Text('Đặt lại'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            // TODO: apply filters to fetch
                            Navigator.of(context).pop();
                          },
                          child: const Text('Áp dụng'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPostCard(Post post) {
    final liked = _liked.contains(post.id);
    return GestureDetector(
      onDoubleTap: () {
        setState(() {
          _liked.add(post.id);
          _showHeart = true;
        });
        _heartTimer?.cancel();
        _heartTimer = Timer(
          const Duration(milliseconds: 700),
          () => setState(() => _showHeart = false),
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: avatar, username, menu
            ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              leading: CircleAvatar(
                radius: 20,
                backgroundColor: Colors.grey.shade300,
                child: Text(
                  post.authorId.isNotEmpty
                      ? post.authorId[0].toUpperCase()
                      : 'U',
                ),
              ),
              title: Text(
                post.authorId,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(_formatDate(post.createdAt)),
              trailing: PopupMenuButton<String>(
                onSelected: (v) async {
                  if (v == 'edit') _openCreateEditModal(editPost: post);
                  if (v == 'delete') {
                    await _deletePost(post);
                  }
                },
                itemBuilder: (_) => [
                  const PopupMenuItem(value: 'edit', child: Text('Sửa')),
                  const PopupMenuItem(value: 'delete', child: Text('Xóa')),
                ],
              ),
            ),

            // Image carousel (1:1)
            AspectRatio(
              aspectRatio: 1,
              child: Stack(
                children: [
                  PageView.builder(
                    itemCount: (post._images?.length ?? 1),
                    itemBuilder: (context, idx) {
                      String? url;
                      if (post._images != null && post._images.isNotEmpty) {
                        final imagePath = post._images[idx];
                        // Kiểm tra nếu là local file path hay URL
                        if (imagePath.startsWith('http')) {
                          url = imagePath;
                        } else {
                          url = 'file://$imagePath'; // Local file
                        }
                      } else {
                        // No images: return null so we render an empty container instead of a colored placeholder
                        url = null;
                      }
                      // Hiển thị ảnh từ local file hoặc network
                      if (url == null) {
                        return Container(color: Colors.transparent);
                      }
                      if (url.startsWith('file://')) {
                        return Image.file(
                          File(url.substring(7)), // Loại bỏ 'file://'
                          fit: BoxFit.cover,
                          width: double.infinity,
                        );
                      } else {
                        return SharedNetworkImage(
                          imageUrl: url,
                          fit: BoxFit.cover,
                          width: double.infinity,
                        );
                      }
                    },
                  ),
                  if (_showHeart)
                    Center(
                      child: AnimatedScale(
                        scale: _showHeart ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 350),
                        child: const Icon(
                          Icons.favorite,
                          size: 96,
                          color: Colors.white70,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Action row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            onPressed: () {},
                            icon: Icon(
                              Icons.favorite,
                              color: liked
                                  ? Colors.redAccent
                                  : Colors.grey.shade700,
                            ),
                          ),
                          IconButton(
                            onPressed: () {},
                            icon: Icon(
                              Icons.chat_bubble_outline,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          IconButton(
                            onPressed: () {},
                            icon: Icon(Icons.send, color: Colors.grey.shade700),
                          ),
                        ],
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: Icon(
                          Icons.bookmark_border,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),
                  // Caption (markdown preview)
                  MarkdownBody(
                    data: post.content,
                    styleSheet: MarkdownStyleSheet.fromTheme(
                      Theme.of(context),
                    ).copyWith(p: const TextStyle(fontSize: 14)),
                    shrinkWrap: true,
                  ),
                  const SizedBox(height: 8),
                  // Tags
                  Wrap(
                    spacing: 8,
                    children: [
                      for (var t in ['Outfit', 'Streetwear'])
                        Chip(label: Text(t)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () => _showPostDetail(post),
                        child: const Text('Xem tất cả'),
                      ),
                      Text(
                        '${_liked.contains(post.id) ? 1 : 0} lượt thích',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPostDetail(Post post) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) {
          return Scaffold(
            appBar: AppBar(
              title: Text(post.title),
              actions: [
                IconButton(onPressed: () {}, icon: const Icon(Icons.share)),
              ],
            ),
            body: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 380,
                    child: PageView.builder(
                      itemCount: (post._images?.length ?? 1),
                      itemBuilder: (context, idx) {
                        String? url;
                        if (post._images != null && post._images.isNotEmpty) {
                          final imagePath = post._images[idx];
                          if (imagePath.startsWith('http')) {
                            url = imagePath;
                          } else {
                            url = 'file://$imagePath';
                          }
                        } else {
                          url = null; // no fallback image
                        }

                        if (url == null) {
                          return Container(color: Colors.transparent);
                        }

                        if (url.startsWith('file://')) {
                          return Image.file(
                            File(url.substring(7)),
                            fit: BoxFit.cover,
                            width: double.infinity,
                          );
                        } else {
                          return SharedNetworkImage(
                            imageUrl: url,
                            fit: BoxFit.cover,
                            width: double.infinity,
                          );
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post.title,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _formatDate(post.createdAt),
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                        const SizedBox(height: 12),
                        // Price / actions
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  'Giá tham khảo',
                                  style: TextStyle(color: Colors.grey),
                                ),
                                SizedBox(height: 6),
                                Text(
                                  '₫1,250,000',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            ElevatedButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.shopping_bag),
                              label: const Text('Mua/Thuê'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Mô tả',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: MarkdownBody(data: post.content),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String? postImageUrl(Post p) {
    final imgs = p._images;
    if (imgs != null && imgs.isNotEmpty) {
      return imgs.first;
    }
    return null; // no default placeholder
  }

  Future<void> _openCreateEditModal({Post? editPost}) async {
    final isEdit = editPost != null;
    final titleCtrl = TextEditingController(text: editPost?.title ?? '');
    final contentCtrl = TextEditingController(text: editPost?.content ?? '');
    List<XFile> picked = [];

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateModal) {
            Future<void> pickImage() async {
              final List<XFile> imgs = await _picker.pickMultiImage(imageQuality: 80);
              if (imgs.isNotEmpty) {
                setStateModal(() => picked.addAll(imgs));
              }
            }

            Future<void> removePickedAt(int idx) async {
              setStateModal(() => picked.removeAt(idx));
            }

            return Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isEdit ? 'Sửa bài viết' : 'Tạo bài viết',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: titleCtrl,
                        decoration: const InputDecoration(labelText: 'Tiêu đề'),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: contentCtrl,
                        decoration: const InputDecoration(labelText: 'Nội dung (Markdown)'),
                        maxLines: 8,
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: [
                          ElevatedButton.icon(
                            onPressed: pickImage,
                            icon: const Icon(Icons.image),
                            label: const Text('Chọn ảnh'),
                          ),
                          if (picked.isNotEmpty)
                            ...picked.asMap().entries.map((e) {
                              final i = e.key;
                              final file = e.value;
                              return Stack(
                                alignment: Alignment.topRight,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                                    child: Image.file(
                                      File(file.path),
                                      width: 80,
                                      height: 80,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Positioned(
                                    right: 0,
                                    child: GestureDetector(
                                      onTap: () => removePickedAt(i),
                                      child: Container(
                                        decoration: BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                                        child: const Icon(Icons.close, size: 16, color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Hủy'),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () async {
                              final title = titleCtrl.text.trim();
                              final content = contentCtrl.text.trim();
                              if (title.isEmpty || content.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Vui lòng nhập tiêu đề và nội dung')),
                                );
                                return;
                              }

                              Navigator.of(context).pop();
                              await _createOrUpdatePost(
                                title: title,
                                content: content,
                                images: picked,
                                editPost: editPost,
                              );
                            },
                            child: Text(isEdit ? 'Lưu' : 'Đăng'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _createOrUpdatePost({
    required String title,
    required String content,
    List<XFile>? images,
    Post? editPost,
  }) async {
    if (editPost == null) {
      // Tạo bài viết mới với ảnh local trước
      List<String> localImagePaths = [];
      if (images != null && images.isNotEmpty) {
        localImagePaths = images.map((img) => img.path).toList();
      }

      final newPost = Post(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        title: title,
        content: content,
        authorId: 'Me',
        createdAt: DateTime.now(),
        images: localImagePaths,
      );
      setState(() => _posts.insert(0, newPost));

      try {
        // Đơn giản hóa: chỉ gửi title và content, bỏ images tạm thời
        final postData = <String, dynamic>{'title': title, 'content': content};

        await _api.createPost(postData);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã tạo bài viết thành công!')),
        );
      } catch (e) {
        if (e.toString().contains('401') ||
            e.toString().contains('Unauthorized')) {
          _showQuickLoginDialog();
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Lỗi khi tạo bài: $e')));
        }
      }
    } else {
      // Cập nhật bài viết
      List<String> updatedImagePaths = [];
      if (images != null && images.isNotEmpty) {
        updatedImagePaths = images.map((img) => img.path).toList();
      } else if (editPost._images != null) {
        updatedImagePaths = editPost._images;
      }

      final idx = _posts.indexWhere((p) => p.id == editPost.id);
      if (idx != -1) {
        final updated = Post(
          id: editPost.id,
          title: title,
          content: content,
          authorId: editPost.authorId,
          createdAt: editPost.createdAt,
          images: updatedImagePaths,
        );
        setState(() => _posts[idx] = updated);
      }
      try {
        // Đơn giản hóa: chỉ gửi title và content
        final postData = <String, dynamic>{'title': title, 'content': content};

        await _api.updatePost(int.tryParse(editPost.id) ?? 0, postData);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã cập nhật bài viết thành công!')),
        );
      } catch (e) {
        if (e.toString().contains('401') ||
            e.toString().contains('Unauthorized')) {
          _showQuickLoginDialog();
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Lỗi khi cập nhật bài: $e')));
        }
      }
    }
  }

  Future<void> _deletePost(Post post) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Xác nhận'),
        content: const Text('Bạn có muốn xóa bài viết này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(c).pop(false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.of(c).pop(true),
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    final old = List<Post>.from(_posts);
    setState(() => _posts.removeWhere((p) => p.id == post.id));
    try {
      await _api.deletePost(int.tryParse(post.id) ?? 0);
    } catch (e) {
      setState(() => _posts = old);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Xóa thất bại: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bảng tin'),
        centerTitle: true,
        automaticallyImplyLeading: false,
        elevation: 1,
        actions: [IconButton(icon: const Icon(Icons.search), onPressed: () {})],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 10),
            _buildSearchFilterBar(),
            const SizedBox(height: 6),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _fetchPosts,
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : _error != null
                    ? ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  size: 56,
                                  color: Colors.red.shade300,
                                ),
                                const SizedBox(height: 12),
                                Text(_error!, textAlign: TextAlign.center),
                                const SizedBox(height: 12),
                                CustomButton(
                                  text: 'Thử lại',
                                  onPressed: _fetchPosts,
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    : _posts.isEmpty
                    ? ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(32.0),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.chat_bubble_outline,
                                  size: 64,
                                  color: Colors.grey.shade400,
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  'Chưa có bài viết nào',
                                  style: TextStyle(fontSize: 16),
                                ),
                                const SizedBox(height: 12),
                                CustomButton(
                                  text: 'Tải lại',
                                  onPressed: _fetchPosts,
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        physics: const BouncingScrollPhysics(),
                        itemCount: _posts.length,
                        itemBuilder: (context, index) {
                          final post = _posts[index];
                          return _buildPostCard(post);
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openCreateEditModal(),
        backgroundColor: Theme.of(context).colorScheme.primary,
        label: const Text('Tạo'),
        icon: const Icon(Icons.camera_alt),
      ),
    );
  }
}
