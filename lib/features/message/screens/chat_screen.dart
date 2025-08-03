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
  final List<DocumentSnapshot> _chatDocs = [];
  DocumentSnapshot? _lastDocument;
  bool _isLoading = false;
  bool _hasMore = true;
  static const int _limit = 10;

  @override
  void initState() {
    super.initState();
    _loadMessages();
    _setupScrollListener();
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      if (_scrollController.position.pixels <=
              _scrollController.position.minScrollExtent + 50 &&
          !_isLoading &&
          _hasMore) {
        _loadMessages();
      }
    });
  }

  Future<void> _loadMessages() async {
    if (_isLoading || !_hasMore) return;

    setState(() => _isLoading = true);

    try {
      // Sync with provider's local messages first
      final chatProvider = context.read<ChatProvider>();
      await chatProvider.syncNewMessagesFromFirestore();

      Query query = FirebaseFirestore.instance
          .collection('chats')
          .orderBy('ts', descending: true)
          .limit(_limit);

      if (_lastDocument != null) {
        query = query.startAfterDocument(_lastDocument!);
      }

      final querySnapshot = await query.get();

      if (querySnapshot.docs.isNotEmpty) {
        setState(() {
          _chatDocs.insertAll(0, querySnapshot.docs);
          _lastDocument = querySnapshot.docs.last;
        });

        if (querySnapshot.docs.length < _limit) {
          _hasMore = false;
        }
      } else {
        _hasMore = false;
      }
    } catch (e) {
      debugPrint('❌ Error loading messages: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
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
            appBar: _buildAppBar(chatProvider),
            body: Column(
              children: [
                _buildMetadataPreview(chatProvider),
                Expanded(child: _buildMessagesList(chatProvider)),
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

  PreferredSizeWidget _buildAppBar(ChatProvider chatProvider) {
    return AppBar(
      toolbarHeight: 0.09.sh,
      title: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          CircleAvatar(radius: 0.03.sh, child: Image.asset(AppAssets.logo)),
          SizedBox(width: 0.02.sw),
          if (chatProvider.isLoadingMetadata)
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
        ],
      ),
    );
  }

  Widget _buildMetadataPreview(ChatProvider chatProvider) {
    if (chatProvider.imageMetadata == null) {
      return const SizedBox.shrink();
    }

    return Container(
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
    );
  }

  Widget _buildMessagesList(ChatProvider chatProvider) {
    final providerMessages = chatProvider.messages;
    final hasProviderMessages = providerMessages.isNotEmpty;

    if (_chatDocs.isEmpty && !hasProviderMessages) {
      return const Center(child: Text('No messages yet.'));
    }

    return ListView.builder(
      controller: _scrollController,
      reverse: false,
      itemCount: _calculateItemCount(hasProviderMessages),
      itemBuilder: (context, index) =>
          _buildMessageItem(context, index, chatProvider, hasProviderMessages),
    );
  }

  int _calculateItemCount(bool hasProviderMessages) {
    // +1 for loading indicator at the top
    return _chatDocs.length + 1;
  }

  Widget _buildMessageItem(
    BuildContext context,
    int index,
    ChatProvider chatProvider,
    bool hasProviderMessages,
  ) {
    // Show loading indicator at the top
    if (index == 0) {
      return _isLoading
          ? const Padding(
              padding: EdgeInsets.all(8.0),
              child: Center(child: CircularProgressIndicator()),
            )
          : const SizedBox.shrink();
    }

    // Build message from Firestore docs
    final docIndex = index - 1;
    if (docIndex < _chatDocs.length) {
      final messageData = _chatDocs[docIndex].data() as Map<String, dynamic>;
      final chatMessage = _createChatMessage(messageData);

      return Padding(
        padding: const EdgeInsets.all(12.0),
        child: ChatBubble(chatMessage: chatMessage),
      );
    }

    return const SizedBox.shrink();
  }

  ChatMessageModel _createChatMessage(Map<String, dynamic> messageData) {
    final metadata = MetaModel.fromJson(messageData['metadata']);
    final senderId = messageData['id'];
    final timestamp =
        messageData['ts'] ?? DateTime.now().millisecondsSinceEpoch;

    return ChatMessageModel(
      metadata: metadata,
      senderId: senderId,
      createdAt: timestamp,
      name:
          context.readAuthProvider.user?.displayName ??
          context.readAuthProvider.userData?.username ??
          'Unknown',
    );
  }
}
