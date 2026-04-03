import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/app_state.dart';
import '../../shared/models/models.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Message> _messages = [];
  final ImagePicker _imagePicker = ImagePicker();
  bool _showEmojiPicker = false;
  String? _selectedReaction;

  @override
  void initState() {
    super.initState();
    _loadDemoMessages();
  }

  void _loadDemoMessages() {
    _messages.addAll([
      Message(
        senderId: 'partner',
        receiverId: 'me',
        type: MessageType.text,
        content: 'Hej kochanie! ❤️',
        status: MessageStatus.read,
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      Message(
        senderId: 'me',
        receiverId: 'partner',
        type: MessageType.text,
        content: 'Cześć! Jak tam dzień?',
        status: MessageStatus.read,
        timestamp:
            DateTime.now().subtract(const Duration(hours: 1, minutes: 55)),
      ),
      Message(
        senderId: 'partner',
        receiverId: 'me',
        type: MessageType.text,
        content: 'Super! Właśnie skończyłam pracę. A ty co robisz?',
        status: MessageStatus.read,
        timestamp:
            DateTime.now().subtract(const Duration(hours: 1, minutes: 50)),
      ),
    ]);
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    final message = Message(
      senderId: 'me',
      receiverId: 'partner',
      type: MessageType.text,
      content: _messageController.text.trim(),
      status: MessageStatus.sent,
    );

    setState(() {
      _messages.add(message);
    });

    _messageController.clear();
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    final image =
        await _imagePicker.pickImage(source: source, imageQuality: 80);
    if (image != null) {
      final message = Message(
        senderId: 'me',
        receiverId: 'partner',
        type: MessageType.image,
        content: '',
        mediaUrl: image.path,
        status: MessageStatus.sent,
      );
      setState(() {
        _messages.add(message);
      });
      _scrollToBottom();
    }
  }

  void _showImageSourceDialog() {
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
                leading:
                    const Icon(Icons.camera_alt, color: AppTheme.primaryColor),
                title:
                    const Text('Aparat', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library,
                    color: AppTheme.primaryColor),
                title: const Text('Galeria',
                    style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading:
                    const Icon(Icons.videocam, color: AppTheme.primaryColor),
                title:
                    const Text('Wideo', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  _pickVideo();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickVideo() async {
    final video = await _imagePicker.pickVideo(
        source: ImageSource.gallery, maxDuration: const Duration(minutes: 2));
    if (video != null) {
      final message = Message(
        senderId: 'me',
        receiverId: 'partner',
        type: MessageType.video,
        content: '',
        mediaUrl: video.path,
        status: MessageStatus.sent,
      );
      setState(() {
        _messages.add(message);
      });
      _scrollToBottom();
    }
  }

  void _showReactionPicker(Message message) {
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
              const Text(
                'Szybkie reakcje',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: AppConstants.quickReactions.map((reaction) {
                  return GestureDetector(
                    onTap: () {
                      _addReaction(message, reaction);
                      Navigator.pop(context);
                    },
                    child: Text(reaction, style: const TextStyle(fontSize: 32)),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _addReaction(Message message, String reaction) {
    setState(() {
      final index = _messages.indexWhere((m) => m.id == message.id);
      if (index != -1) {
        final updatedReactions =
            Map<String, String>.from(message.reactions ?? {});
        updatedReactions['me'] = reaction;
        _messages[index] = message.copyWith(reactions: updatedReactions);
      }
    });
  }

  void _onMessageDoubleTap(Message message) {
    if (message.senderId == 'partner') {
      _addReaction(message, '❤️');
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return Scaffold(
      appBar: AppBar(
        title: Text(appState.partner?.nickname ?? 'Czat'),
        actions: [
          IconButton(
            icon: const Icon(Icons.call),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.videocam),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isMe = message.senderId == 'me';
                return _buildMessageBubble(message, isMe);
              },
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Message message, bool isMe) {
    return GestureDetector(
      onDoubleTap: () => _onMessageDoubleTap(message),
      onLongPress: () => _showReactionPicker(message),
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75,
          ),
          decoration: BoxDecoration(
            color: isMe ? AppTheme.primaryColor : AppTheme.surfaceDark,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(20),
              topRight: const Radius.circular(20),
              bottomLeft: Radius.circular(isMe ? 20 : 4),
              bottomRight: Radius.circular(isMe ? 4 : 20),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildMessageContent(message),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _formatTime(message.timestamp),
                    style: TextStyle(
                      color: isMe ? Colors.white70 : Colors.white54,
                      fontSize: 11,
                    ),
                  ),
                  if (isMe) ...[
                    const SizedBox(width: 4),
                    Icon(
                      message.status == MessageStatus.read
                          ? Icons.done_all
                          : message.status == MessageStatus.delivered
                              ? Icons.done_all
                              : Icons.done,
                      size: 14,
                      color: message.status == MessageStatus.read
                          ? Colors.lightBlue
                          : Colors.white70,
                    ),
                  ],
                ],
              ),
              if (message.reactions != null &&
                  message.reactions!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    message.reactions!.values.first,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessageContent(Message message) {
    if (message.type == MessageType.image && message.mediaUrl != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.file(
          File(message.mediaUrl!),
          width: 200,
          height: 200,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            width: 200,
            height: 200,
            color: Colors.grey.shade800,
            child: const Icon(Icons.image, color: Colors.white54),
          ),
        ),
      );
    }

    if (message.type == MessageType.video) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.play_circle_fill, color: Colors.white, size: 40),
          const SizedBox(width: 8),
          const Text('Wideo', style: TextStyle(color: Colors.white)),
        ],
      );
    }

    return Text(
      message.content,
      style: const TextStyle(color: Colors.white, fontSize: 15),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              color: AppTheme.primaryColor,
              onPressed: _showImageSourceDialog,
            ),
            Expanded(
              child: TextField(
                controller: _messageController,
                maxLines: 4,
                minLines: 1,
                decoration: InputDecoration(
                  hintText: 'Wiadomość...',
                  hintStyle: TextStyle(color: Colors.grey.shade500),
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            IconButton(
              icon: Icon(
                _showEmojiPicker
                    ? Icons.keyboard
                    : Icons.emoji_emotions_outlined,
              ),
              color: AppTheme.primaryColor,
              onPressed: () {
                setState(() {
                  _showEmojiPicker = !_showEmojiPicker;
                });
              },
            ),
            Container(
              decoration: const BoxDecoration(
                color: AppTheme.primaryColor,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.send, color: Colors.white),
                onPressed: _sendMessage,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}
