import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/voice_command_controller.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({required this.text, required this.isUser, DateTime? timestamp})
      : timestamp = timestamp ?? DateTime.now();
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [
    ChatMessage(text: "Hello! I am EasyLens. How can I help you today?", isUser: false),
  ];

  void _handleSend() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(text: text, isUser: true));
      _textController.clear();
    });
    _scrollToBottom();

    final controller = Provider.of<VoiceCommandController>(context, listen: false);
    
    String response;
    if (controller.isInitializing) {
      response = "I am currently preparing my local brain model: ${controller.statusMessage}. Please try again shortly!";
    } else {
      response = await controller.generateResponseFromText(text);
    }

    setState(() {
      _messages.add(ChatMessage(text: response, isUser: false));
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<VoiceCommandController>();
    final isInitializing = controller.isInitializing;

    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(25, 20, 25, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'AI Assistant',
                style: TextStyle(
                  fontFamily: 'HeaderFont',
                  fontWeight: FontWeight.w900,
                  fontSize: 34,
                  color: Color(0xFF0D1724),
                ),
              ),
              const SizedBox(height: 5),
              Text(
                'Chat with EasyLens',
                style: TextStyle(
                  fontFamily: 'DescriptionFont',
                  fontSize: 16,
                  color: Colors.black.withOpacity(0.5),
                ),
              ),
              if (isInitializing) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F2F8),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blueAccent.withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF08209A)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          controller.statusMessage,
                          style: const TextStyle(
                            fontFamily: 'DescriptionFont',
                            fontSize: 12,
                            color: Color(0xFF08209A),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ]
            ],
          ),
        ),

        // Chat List
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(20),
            itemCount: _messages.length,
            itemBuilder: (context, index) {
              final msg = _messages[index];
              return _buildMessageBubble(msg);
            },
          ),
        ),

        // Input Area
        Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))
            ],
          ),
          child: SafeArea(
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F2F8),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: TextField(
                      controller: _textController,
                      style: const TextStyle(fontFamily: 'DescriptionFont'),
                      decoration: const InputDecoration(
                        hintText: "Type a message...",
                        border: InputBorder.none,
                      ),
                      onSubmitted: (_) => _handleSend(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: _handleSend,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      color: Color(0xFF08209A),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.send, color: Colors.white, size: 24),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMessageBubble(ChatMessage msg) {
    return Align(
      alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: msg.isUser ? const Color(0xFF08209A) : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(msg.isUser ? 20 : 0),
            bottomRight: Radius.circular(msg.isUser ? 0 : 20),
          ),
          boxShadow: [
            if (!msg.isUser)
              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5, offset: const Offset(0, 2))
          ],
        ),
        child: Text(
          msg.text,
          style: TextStyle(
            fontFamily: 'DescriptionFont',
            fontSize: 16,
            color: msg.isUser ? Colors.white : Colors.black87,
            height: 1.4,
          ),
        ),
      ),
    );
  }
}
