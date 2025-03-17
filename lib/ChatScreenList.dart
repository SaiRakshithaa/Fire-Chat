import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'ChatScreen.dart';

class SearchUsersScreen extends StatefulWidget {
  const SearchUsersScreen({super.key});

  @override
  State<SearchUsersScreen> createState() => _SearchUsersScreenState();
}

class _SearchUsersScreenState extends State<SearchUsersScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  List<Map<String, dynamic>> _searchResults = [];
  List<Map<String, dynamic>> _chatUsers = [];
  String? currentUserId;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        currentUserId = user.uid;
      });
      fetchChatUsers();
    }
  }

  void fetchChatUsers() async {
    if (currentUserId == null) return;

    FirebaseFirestore firestore = FirebaseFirestore.instance;
    QuerySnapshot chatSnapshot = await firestore
        .collection('chats')
        .where('participants', arrayContains: currentUserId)
        .get();

    Set<String> userIds = {};
    for (var doc in chatSnapshot.docs) {
      List<dynamic> participants = doc['participants'];
      for (var id in participants) {
        if (id != currentUserId) {
          userIds.add(id);
        }
      }
    }

    List<Map<String, dynamic>> chatUsers = [];
    for (String userId in userIds) {
      DocumentSnapshot userDoc =
          await firestore.collection('users').doc(userId).get();
      if (userDoc.exists) {
        bool hasNewMessage = await checkForNewMessages(userId) ?? false;

        chatUsers.add({
          "name": userDoc["name"] ?? "Unknown",
          "email": userDoc["email"] ?? "No email",
          "uid": userDoc["uid"] ?? "",
          "profilePic": userDoc["profilePic"] ?? "",
          "hasNewMessage": hasNewMessage,
        });
      }
    }

    setState(() {
      _chatUsers = chatUsers;
    });
  }

  Future<bool> checkForNewMessages(String otherUserId) async {
    if (currentUserId == null) return false;

    QuerySnapshot newMessages = await FirebaseFirestore.instance
        .collection('chats')
        .where('participants', arrayContains: currentUserId)
        .get();

    for (var chat in newMessages.docs) {
      QuerySnapshot messageSnapshot = await chat.reference
          .collection('messages')
          .where('receiverId', isEqualTo: currentUserId)
          .where('senderId', isEqualTo: otherUserId)
          .where('seen', isEqualTo: false)
          .get();
      if (messageSnapshot.docs.isNotEmpty) return true;
    }
    return false;
  }

  void searchUsers(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults.clear();
      });
      return;
    }

    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where("name", isGreaterThanOrEqualTo: query)
        .where("name", isLessThanOrEqualTo: query + '\uf8ff')
        .get();

    List<Map<String, dynamic>> results = querySnapshot.docs.map((doc) {
      return {
        "name": doc["name"] ?? "Unknown",
        "email": doc["email"] ?? "No email",
        "uid": doc["uid"] ?? "",
        "profilePic": doc["profilePic"] ?? "",
        "hasNewMessage": false,  // Default to false
      };
    }).toList();

    setState(() {
      _searchResults = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF075E54),
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: "Search users...",
                  hintStyle: TextStyle(color: Colors.white70),
                  border: InputBorder.none,
                ),
                onChanged: searchUsers,
              )
            : const Text('Fire Chat', style: TextStyle(color: Colors.white)),
        actions: [
          _isSearching
              ? IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () {
                    setState(() {
                      _isSearching = false;
                      _searchController.clear();
                      _searchResults.clear();
                    });
                  },
                )
              : IconButton(
                  icon: const Icon(Icons.search, color: Colors.white),
                  onPressed: () {
                    setState(() {
                      _isSearching = true;
                    });
                  },
                ),
        ],
      ),
      body: _isSearching
          ? _searchResults.isEmpty
              ? const Center(child: Text("No users found"))
              : _buildUserList(_searchResults)
          : _chatUsers.isEmpty
              ? const Center(child: Text("No conversations yet"))
              : _buildUserList(_chatUsers),
    );
  }

  Widget _buildUserList(List<Map<String, dynamic>> users) {
    return ListView.builder(
      itemCount: users.length,
      itemBuilder: (context, index) {
        var user = users[index];
        return ListTile(
          leading: Stack(
            children: [
              CircleAvatar(
                backgroundImage: user["profilePic"].isNotEmpty
                    ? NetworkImage(user["profilePic"])
                    : const AssetImage("assets/default_profile.png")
                        as ImageProvider,
              ),
              if (user["hasNewMessage"] ?? false)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.green,
                    ),
                  ),
                ),
            ],
          ),
          title: Text(user["name"]),
          subtitle: Text(user["email"]),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatScreen(
                  userName: user["name"],
                  userId: user["uid"],
                  profilePic: user["profilePic"],
                ),
              ),
            ).then((_) => fetchChatUsers());
          },
        );
      },
    );
  }
}
