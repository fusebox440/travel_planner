import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../models/chat_message.dart';
import '../../providers/chat_provider.dart';
import '../widgets/assistant_message_card.dart';
import '../widgets/user_message_card.dart';
import '../widgets/voice_pulse.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  bool _showScrollToBottom = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    setState(() {
      _showScrollToBottom = (maxScroll - currentScroll) > 100;
    });
  }

  void _scrollToBottom() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  Future<void> _handleSubmit() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    _textController.clear();
    await ref.read(chatProvider.notifier).sendUserMessage(text);
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(chatProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Assistant'),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: _showOptions,
          ),
        ],
      ),
      body: state.when(
        data: (data) => Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    itemCount: data.currentSession?.messages.length ?? 0,
                    itemBuilder: (context, index) {
                      final message = data.currentSession!.messages[index];
                      return _buildMessageWidget(message);
                    },
                  ),
                  if (_showScrollToBottom)
                    Positioned(
                      right: 16,
                      bottom: 16,
                      child: FloatingActionButton.small(
                        onPressed: _scrollToBottom,
                        child: const Icon(Icons.keyboard_arrow_down),
                      ),
                    ),
                ],
              ),
            ),
            if (data.suggestions.isNotEmpty)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: data.suggestions.map((suggestion) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: ActionChip(
                        label: Text(suggestion),
                        onPressed: () {
                          _textController.text = suggestion;
                          _handleSubmit();
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
            _buildInputArea(data),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error: $error'),
        ),
      ),
    );
  }

  Widget _buildMessageWidget(ChatMessage message) {
    if (message.isUser) {
      return UserMessageCard(
        key: ValueKey(message.id),
        message: message,
        onDelete: () => _deleteMessage(message),
      );
    } else {
      return AssistantMessageCard(
        key: ValueKey(message.id),
        message: message,
        onDelete: () => _deleteMessage(message),
        onReadAloud: () => _readAloud(message),
      );
    }
  }

  Widget _buildInputArea(ChatState state) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _textController,
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                ),
                maxLines: null,
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.newline,
                onSubmitted: (_) => _handleSubmit(),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.send),
              onPressed: _handleSubmit,
            ),
            GestureDetector(
              onTapDown: (_) => _startVoice(),
              onTapUp: (_) => _stopVoice(),
              onTapCancel: _stopVoice,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: state.isListening
                      ? Theme.of(context).primaryColor
                      : Colors.grey.shade200,
                ),
                child: state.isListening
                    ? const VoicePulse()
                    : const Icon(Icons.mic),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _startVoice() async {
    final status = await Permission.microphone.request();
    if (status.isGranted) {
      await ref.read(chatProvider.notifier).startVoice();
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Microphone permission is required for voice input'),
          ),
        );
      }
    }
  }

  Future<void> _stopVoice() async {
    await ref.read(chatProvider.notifier).stopVoice();
  }

  Future<void> _deleteMessage(ChatMessage message) async {
    // TODO: Implement delete message
  }

  Future<void> _readAloud(ChatMessage message) async {
    await ref.read(chatProvider.notifier).readAloudLastResponse();
  }

  void _showOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.add),
                title: const Text('New Chat'),
                onTap: () {
                  Navigator.pop(context);
                  ref.read(chatProvider.notifier).newSession();
                },
              ),
              ListTile(
                leading: const Icon(Icons.list),
                title: const Text('Chat History'),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Navigate to chat history screen
                },
              ),
              if (ref.read(chatProvider).value?.currentSession != null) ...[
                ListTile(
                  leading: const Icon(Icons.edit),
                  title: const Text('Rename Chat'),
                  onTap: () {
                    Navigator.pop(context);
                    _showRenameDialog();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.delete),
                  title: const Text('Delete Chat'),
                  onTap: () {
                    Navigator.pop(context);
                    _showDeleteConfirmation();
                  },
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Future<void> _showRenameDialog() async {
    final session = ref.read(chatProvider).value?.currentSession;
    if (session == null) return;

    final controller = TextEditingController(text: session.title);
    final newTitle = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Rename Chat'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Chat Name',
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, controller.text),
              child: const Text('Rename'),
            ),
          ],
        );
      },
    );

    if (newTitle != null && newTitle.trim().isNotEmpty) {
      await ref
          .read(chatProvider.notifier)
          .renameSession(session.id, newTitle.trim());
    }
  }

  Future<void> _showDeleteConfirmation() async {
    final session = ref.read(chatProvider).value?.currentSession;
    if (session == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Chat'),
          content: const Text(
            'Are you sure you want to delete this chat? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await ref.read(chatProvider.notifier).deleteSession(session.id);
    }
  }
}
