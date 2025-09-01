import 'dart:ui'; // Needed for blur effect

import 'package:chat_bubbles/chat_bubbles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/message_controller.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final MessageController chatMessageController = Get.put(MessageController());
  final TextEditingController messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    // Auto-scroll when new messages are added
    chatMessageController.messages.listen((_) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          scrolledUnderElevation: 0,
          excludeHeaderSemantics: true,
          backgroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              chatMessageController.resetChat(); // Reset chat
              Navigator.pop(context);
            },
          ),
          title: const Text('HAS', style: TextStyle(color: Colors.black)),
        ),
        body: Stack(
          children: [
            // Background Image with optional blur
            Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(
                    'assets/images/ChatBG.jpg',
                  ), // Add your image here
                  fit: BoxFit.cover,
                ),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: 4,
                  sigmaY: 4,
                ), // Adjust blur as needed
                child: Container(
                  color: Colors.black.withOpacity(0), // keep chat visible
                ),
              ),
            ),

            // Chat content
            Column(
              children: [
                Expanded(
                  child: Obx(
                    () => ListView.builder(
                      shrinkWrap: true,
                      controller: _scrollController,
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.all(16),
                      itemCount: chatMessageController.messages.length,
                      itemBuilder: (context, index) {
                        final message = chatMessageController.messages[index];
                        final isUser = message['isUser'];
                        final time = message['time'];

                        return Align(
                          alignment: isUser
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Column(
                            crossAxisAlignment: isUser
                                ? CrossAxisAlignment.end
                                : CrossAxisAlignment.start,
                            children: [
                              BubbleSpecialTwo(
                                isSender: isUser,
                                color: isUser
                                    ? const Color(0XFF25D366)
                                    : const Color(0XFFE5E5E5),
                                seen: true,
                                text: message['text'],
                                textStyle: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0XFF000000),
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                  right: 10,
                                  left: 20,
                                ),
                                child: Text(
                                  time,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Color(0XFF808080),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),

                // Typing indicator
                Obx(
                  () => chatMessageController.isTypeing.value
                      ? Padding(
                          padding: const EdgeInsets.all(8),
                          child: Row(
                            children: [
                              Text(
                                chatMessageController.responseText.value,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        )
                      : const SizedBox.shrink(),
                ),

                // Input field and send button
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: messageController,
                          decoration: InputDecoration(
                            hintText: 'Type a message...',
                            hintStyle: const TextStyle(color: Colors.grey),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: Colors.grey),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                color: Colors.green,
                                width: 2,
                              ),
                            ),
                            suffixIcon: IconButton(
                              onPressed: () {},
                              icon: const Icon(Icons.emoji_emotions_outlined),
                            ),
                          ),
                          style: const TextStyle(color: Colors.black),
                        ),
                      ),
                      const SizedBox(width: 10),
                      FloatingActionButton(
                        heroTag: 'send_button',
                        onPressed: () {
                          if (messageController.text.isNotEmpty) {
                            chatMessageController.sendMessage(
                              messageController.text.trim(),
                            );
                            messageController.clear();
                          }
                        },
                        backgroundColor: const Color(0XFF25D366),
                        foregroundColor: Colors.white,
                        child: const Icon(Icons.send),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ],
        ),
      );
}
