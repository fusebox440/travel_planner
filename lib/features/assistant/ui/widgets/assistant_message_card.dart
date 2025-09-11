import 'package:flutter/material.dart';
import '../../models/chat_message.dart';

class AssistantMessageCard extends StatelessWidget {
  final ChatMessage message;
  final VoidCallback? onDelete;
  final VoidCallback? onReadAloud;

  const AssistantMessageCard({
    super.key,
    required this.message,
    this.onDelete,
    this.onReadAloud,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: Theme.of(context).primaryColor,
            child: const Icon(Icons.assistant, color: Colors.white),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(16),
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        message.text,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      if (message.attachments?.isNotEmpty == true) ...[
                        const SizedBox(height: 8),
                        ...message.attachments!.map((attachment) {
                          // TODO: Implement attachment rendering
                          return const SizedBox.shrink();
                        }).toList(),
                      ],
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.volume_up),
                      onPressed: onReadAloud,
                      iconSize: 16,
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy),
                      onPressed: () {
                        // TODO: Implement copy to clipboard
                      },
                      iconSize: 16,
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: onDelete,
                      iconSize: 16,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
