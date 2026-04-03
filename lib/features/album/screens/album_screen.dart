import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../main.dart';
import '../../shared/models/models.dart';

class AlbumScreen extends StatefulWidget {
  const AlbumScreen({super.key});

  @override
  State<AlbumScreen> createState() => _AlbumScreenState();
}

class _AlbumScreenState extends State<AlbumScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<SharedMedia> _photos = [];
  final List<SharedMedia> _videos = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadDemoMedia();
  }

  void _loadDemoMedia() {
    for (int i = 1; i <= 6; i++) {
      _photos.add(SharedMedia(
        uploaderId: i % 2 == 0 ? 'me' : 'partner',
        type: 'image',
        url: 'https://picsum.photos/300/300?random=$i',
        uploadedAt: DateTime.now().subtract(Duration(days: i)),
      ));
    }
    for (int i = 1; i <= 3; i++) {
      _videos.add(SharedMedia(
        uploaderId: i % 2 == 0 ? 'me' : 'partner',
        type: 'video',
        url: 'https://example.com/video$i.mp4',
        uploadedAt: DateTime.now().subtract(Duration(days: i * 2)),
      ));
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wspólny Album'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_photo_alternate),
            onPressed: _showAddMediaOptions,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.primaryColor,
          labelColor: AppTheme.primaryColor,
          unselectedLabelColor: Colors.grey,
          tabs: [
            Tab(
              icon: const Icon(Icons.photo),
              text: 'Zdjęcia (${_photos.length})',
            ),
            Tab(
              icon: const Icon(Icons.videocam),
              text: 'Wideo (${_videos.length})',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPhotoGrid(),
          _buildVideoGrid(),
        ],
      ),
    );
  }

  Widget _buildPhotoGrid() {
    if (_photos.isEmpty) {
      return _buildEmptyState(
        icon: Icons.photo_library,
        title: 'Brak zdjęć',
        subtitle: 'Dodaj pierwsze wspólne zdjęcie!',
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      ),
      itemCount: _photos.length,
      itemBuilder: (context, index) {
        final photo = _photos[index];
        return _buildMediaTile(photo, index);
      },
    );
  }

  Widget _buildVideoGrid() {
    if (_videos.isEmpty) {
      return _buildEmptyState(
        icon: Icons.videocam_off,
        title: 'Brak wideo',
        subtitle: 'Dodaj pierwsze wspólne wideo!',
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      ),
      itemCount: _videos.length,
      itemBuilder: (context, index) {
        final video = _videos[index];
        return _buildMediaTile(video, index, isVideo: true);
      },
    );
  }

  Widget _buildMediaTile(SharedMedia media, int index, {bool isVideo = false}) {
    return GestureDetector(
      onTap: () => _showMediaViewer(index, isVideo),
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: media.type == 'image'
                ? Image.network(
                    media.url,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: Colors.grey.shade800,
                      child: const Icon(Icons.image, color: Colors.white54),
                    ),
                  )
                : Container(
                    color: Colors.grey.shade800,
                    child: const Icon(Icons.play_circle, color: Colors.white54, size: 40),
                  ),
          ),
          if (media.uploaderId == 'me')
            Positioned(
              top: 4,
              right: 4,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Icon(Icons.person, color: Colors.white, size: 12),
              ),
            ),
          Positioned(
            bottom: 4,
            left: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                _formatDate(media.uploadedAt),
                style: const TextStyle(color: Colors.white, fontSize: 10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: Colors.grey.shade600),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _showAddMediaOptions,
            icon: const Icon(Icons.add),
            label: const Text('Dodaj'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  void _showMediaViewer(int index, bool isVideo) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MediaViewerScreen(
          mediaList: isVideo ? _videos : _photos,
          initialIndex: index,
          isVideo: isVideo,
        ),
      ),
    );
  }

  void _showAddMediaOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surfaceDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt, color: AppTheme.primaryColor),
                title: const Text('Zrób zdjęcie', style: TextStyle(color: Colors.white)),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: AppTheme.primaryColor),
                title: const Text('Wybierz z galerii', style: TextStyle(color: Colors.white)),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.videocam, color: AppTheme.primaryColor),
                title: const Text('Nagraj wideo', style: TextStyle(color: Colors.white)),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}.${date.month}';
  }
}

class MediaViewerScreen extends StatefulWidget {
  final List<SharedMedia> mediaList;
  final int initialIndex;
  final bool isVideo;

  const MediaViewerScreen({
    super.key,
    required this.mediaList,
    required this.initialIndex,
    this.isVideo = false,
  });

  @override
  State<MediaViewerScreen> createState() => _MediaViewerScreenState();
}

class _MediaViewerScreenState extends State<MediaViewerScreen> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text('${_currentIndex + 1} / ${widget.mediaList.length}'),
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.mediaList.length,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        itemBuilder: (context, index) {
          final media = widget.mediaList[index];
          return Center(
            child: widget.isVideo
                ? const Icon(Icons.play_circle, color: Colors.white, size: 80)
                : InteractiveViewer(
                    child: Image.network(
                      media.url,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.broken_image,
                        color: Colors.white54,
                        size: 80,
                      ),
                    ),
                  ),
          );
        },
      ),
    );
  }
}