
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'encryptions.dart'; // Import EncryptionHelper

class ChatScreen extends StatefulWidget {
  final String userName;
  final String userId;
  final String profilePic;

  const ChatScreen({
    super.key,
    required this.userName,
    required this.userId,
    required this.profilePic,
  });

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // Generate a unique chat ID (Ensures (a, b) == (b, a))
  String getChatId() {
    String currentUserId = FirebaseAuth.instance.currentUser!.uid;
    List<String> ids = [currentUserId, widget.userId];
    ids.sort(); // Sort to ensure consistency
    return ids.join("_");
  }

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    String currentUserId = FirebaseAuth.instance.currentUser!.uid;
    String messageText = _messageController.text.trim();
    String chatId = getChatId();

    String encryptedMessage = EncryptionHelper().encryptMessage(messageText); // Encrypt message

    DocumentReference chatRef =
        FirebaseFirestore.instance.collection('chats').doc(chatId);

    // Check if the chat exists, otherwise create it
    DocumentSnapshot chatSnapshot = await chatRef.get();
    if (!chatSnapshot.exists) {
      await chatRef.set({
        'participants': [currentUserId, widget.userId],
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    // Save encrypted message
    await chatRef.collection('messages').add({
      'senderId': currentUserId,
      'receiverId': widget.userId,
      'message': encryptedMessage, // Save encrypted text
      'timestamp': FieldValue.serverTimestamp(),
      'seen': false,
    });

    _messageController.clear();
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 300), () {
      _scrollController.jumpTo(_scrollController.position.minScrollExtent);
    });
  }

  void _markMessageAsSeen(DocumentSnapshot messageDoc) async {
    if (messageDoc['receiverId'] == FirebaseAuth.instance.currentUser!.uid &&
        !messageDoc['seen']) {
      String chatId = getChatId();
      await FirebaseFirestore.instance
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .doc(messageDoc.id)
          .update({'seen': true});
    }
  }

  @override
  Widget build(BuildContext context) {
    String chatId = getChatId();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF075E54),
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(widget.profilePic),
            ),
            const SizedBox(width: 10),
            Text(widget.userName),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chats')
                  .doc(chatId)
                  .collection('messages')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  print("Error fetching messages: ${snapshot.error}");
                  return const Center(child: Text("Something went wrong!"));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No messages yet."));
                }

                var messages = snapshot.data!.docs;

                return ListView.builder(
                  controller: _scrollController,
                  itemCount: messages.length,
                  reverse: true,
                  itemBuilder: (context, index) {
                    var messageData = messages[index];
                    bool isMe = messageData['senderId'] ==
                        FirebaseAuth.instance.currentUser!.uid;

                    _markMessageAsSeen(messageData);

                    return _buildMessageBubble(
                      messageData['message'], // Encrypted message
                      isMe,
                      messageData['seen'],
                      (messageData['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
                    );
                  },
                );
              },
            ),
          ),
          _buildMessageComposer(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(
      String encryptedMessage, bool isMe, bool seen, DateTime timestamp) {
    String decryptedMessage = EncryptionHelper().decryptMessage(encryptedMessage); // Decrypt message

    final bubbleColor = isMe ? const Color(0xFFDCF8C6) : Colors.white;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: bubbleColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(decryptedMessage, style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 5),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}",
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      if (isMe) const SizedBox(width: 5),
                      if (isMe)
                        Icon(
                          Icons.done_all,
                          size: 18,
                          color: seen ? Colors.blue : Colors.grey,
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

  Widget _buildMessageComposer() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: const InputDecoration(
                  hintText: 'Type a message', border: InputBorder.none),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send, color: Color(0xFF075E54)),
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

