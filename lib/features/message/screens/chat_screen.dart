import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:skin_app_migration/core/constants/app_assets.dart';
import 'package:skin_app_migration/core/extensions/provider_extensions.dart';
import 'package:skin_app_migration/core/widgets/k_background_scaffold.dart';
import 'package:skin_app_migration/features/message/models/chat_message_model.dart';
import 'package:skin_app_migration/features/message/models/meta_model.dart';
import 'package:skin_app_migration/features/message/provider/chat_provider.dart';
import 'package:skin_app_migration/features/message/widgets/chat_bubble.dart';
import 'package:skin_app_migration/features/message/widgets/message_text_field.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessageModel> _messages = [];
  final List<DocumentSnapshot> _documents = []; // Track documents for pagination
  bool _isLoadingMore = false;
  bool _hasMoreMessages = true;
  static const int _pageSize = 20;
  StreamSubscription<List<ChatMessageModel>>? _messagesStream;

  @override
  void initState() {
    super.initState();
    _initializeStreamPagination();
    _setupScrollListener();
  }

  void _initializeStreamPagination() {
    // Start listening to real-time messages using provider
    _startMessagesStream();
    
    // Load initial messages
    _loadInitialMessages();
  }

  void _startMessagesStream() {
    final chatProvider = context.read<ChatProvider>();
    
    _messagesStream = chatProvider.getMessagesStream(limit: _pageSize).listen(
      (List<ChatMessageModel> messages) {
        _handleStreamUpdate(messages);
      },
      onError: (error) {
        debugPrint('❌ Stream error: $error');
      },
    );
  }

  void _handleStreamUpdate(List<ChatMessageModel> messages) {
    if (!mounted) return;

    setState(() {
      _messages.clear();
      _messages.addAll(messages);
      
      // Update pagination state based on message count
      _hasMoreMessages = messages.length >= _pageSize;
    });
  }

  Future<void> _loadInitialMessages() async {
    if (!mounted) return;

    setState(() => _isLoadingMore = true);

    try {
      // Sync with provider's local messages first
      final chatProvider = context.read<ChatProvider>();
      await chatProvider.syncNewMessagesFromFirestore();

      // Load initial batch using provider method with document tracking
      final result = await chatProvider.getPaginatedMessagesWithDocs(limit: _pageSize);

      if (mounted) {
        setState(() {
          _messages.clear();
          _messages.addAll(result['messages'] as List<ChatMessageModel>);
          _documents.clear();
          _documents.addAll(result['documents'] as List<DocumentSnapshot>);
          _hasMoreMessages = result['hasMore'] as bool;
        });
      }
    } catch (e) {
      debugPrint('❌ Error loading initial messages: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoadingMore = false);
      }
    }
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          !_isLoadingMore &&
          _hasMoreMessages) {
        _loadMoreMessages();
      }
    });
  }

  Future<void> _loadMoreMessages() async {
    if (_isLoadingMore || !_hasMoreMessages || _documents.isEmpty) return;

    setState(() => _isLoadingMore = true);

    try {
      final chatProvider = context.read<ChatProvider>();
      
      // Use the last document for pagination
      final lastDocument = _documents.last;
      
      final result = await chatProvider.getPaginatedMessagesWithDocs(
        startAfter: lastDocument,
        limit: _pageSize,
      );

      if (mounted && (result['messages'] as List<ChatMessageModel>).isNotEmpty) {
        setState(() {
          _messages.addAll(result['messages'] as List<ChatMessageModel>);
          _documents.addAll(result['documents'] as List<DocumentSnapshot>);
          _hasMoreMessages = result['hasMore'] as bool;
        });
      } else if (mounted) {
        setState(() => _hasMoreMessages = false);
      }
    } catch (e) {
      debugPrint('❌ Error loading more messages: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoadingMore = false);
      }
    }
  }

  @override
  void dispose() {
    _messagesStream?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Consumer<ChatProvider>(
        builder: (context, chatProvider, child) {
          return KBackgroundScaffold(
            margin: const EdgeInsets.all(0),
            showDrawer: true,
            appBar: AppBar(
              toolbarHeight: 0.09.sh,
              title: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  CircleAvatar(
                    radius: 0.03.sh,
                    child: Image.asset(AppAssets.logo),
                  ),
                  SizedBox(width: 0.02.sw),
                  if (chatProvider.isLoadingMetadata)
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                ],
              ),
            ),
            body: Column(
              children: [
                // Show metadata preview if available
                if (chatProvider.imageMetadata != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Shared: ${chatProvider.imageMetadata}',
                            style: Theme.of(context).textTheme.bodySmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          onPressed: chatProvider.clearMetadata,
                          icon: const Icon(Icons.close, size: 16),
                        ),
                      ],
                    ),
                  ),
                Expanded(child: _buildMessagesList()),
                MessageTextField(
                  messageController: chatProvider.messageController,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMessagesList() {
    if (_messages.isEmpty && !_isLoadingMore) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No messages yet',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      reverse: true, // Show newest messages at the bottom
      itemCount: _messages.length + (_hasMoreMessages ? 1 : 0),
      itemBuilder: (context, index) {
        // Show loading indicator at the top when loading more
        if (index == _messages.length) {
          return _hasMoreMessages
              ? const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(child: CircularProgressIndicator()),
                )
              : const SizedBox();
        }

        // Show message
        final message = _messages[index];
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
          child: ChatBubble(chatMessage: message),
        );
      },
    );
  }
}
