import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hams/general/consts/consts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:velocity_x/velocity_x.dart';

class ChatView extends StatefulWidget {
  final String doctorId;
  final String doctorName;
  final String userId;

  const ChatView({
    super.key,
    required this.doctorId,
    required this.doctorName,
    required this.userId,
  });

  @override
  _ChatViewState createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _picker = ImagePicker();
  bool isDoctor = false;
  bool isUploading = false;

  @override
  void initState() {
    super.initState();
    _checkUserRole();
  }

  // Check if the logged-in user is a doctor
  Future<void> _checkUserRole() async {
    String? currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null) return;

    setState(() {
      isDoctor = currentUserId == widget.doctorId;
    });
  }

  // Generate a unique chat ID based on user and doctor IDs
  String get chatId => "${widget.userId}_${widget.doctorId}";

  // Send a text message to Firestore
  Future<void> sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    String? currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null) {
      Get.snackbar("Error", "User not authenticated",
          backgroundColor: AppColors.primeryColor,
          colorText: AppColors.whiteColor);
      return;
    }

    await FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add({
      'senderId': currentUserId,
      'senderType': isDoctor ? 'doctor' : 'user',
      'message': _messageController.text.trim(),
      'timestamp': FieldValue.serverTimestamp(),
      'isFile': false, // No file attached
      'fileData': null, // No file data
      'fileType': null, // No file type
    });

    _messageController.clear();
    _scrollToBottom();
  }

  // Pick an image and store it in Firestore as a Base64 string
  Future<void> sendFile() async {
    String? currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null) {
      Get.snackbar("Error", "User not authenticated",
          backgroundColor: AppColors.primeryColor,
          colorText: AppColors.whiteColor);
      return;
    }

    try {
      // Pick an image from the gallery
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image == null) return;

      setState(() {
        isUploading = true;
      });

      // Read the file as bytes
      final File file = File(image.path);
      final int fileSizeInBytes = await file.length();
      const int maxSizeInBytes = 900 * 1024; // 900 KB to be safe (Firestore limit is 1 MB)

      if (fileSizeInBytes > maxSizeInBytes) {
        Get.snackbar("Error", "File is too large. Maximum size is 900 KB.",
            backgroundColor: AppColors.primeryColor,
            colorText: AppColors.whiteColor);
        return;
      }

      final List<int> fileBytes = await file.readAsBytes();
      final String base64File = base64Encode(fileBytes);
      final String fileType = image.mimeType ?? 'image/jpeg';

      // Send the message with the Base64 file data
      await FirebaseFirestore.instance
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .add({
        'senderId': currentUserId,
        'senderType': isDoctor ? 'doctor' : 'user',
        'message': 'Document', // Generic message for all files
        'timestamp': FieldValue.serverTimestamp(),
        'isFile': true, // Indicate this message contains a file
        'fileData': base64File, // Store the Base64 string
        'fileType': fileType, // Store the file type
      });

      _scrollToBottom();
    } catch (e) {
      Get.snackbar("Error", "Failed to upload file: $e",
          backgroundColor: AppColors.primeryColor,
          colorText: AppColors.whiteColor);
    } finally {
      setState(() {
        isUploading = false;
      });
    }
  }

  // Scroll to the bottom of the chat
  void _scrollToBottom() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    String? currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null) {
      return Scaffold(
        body: Center(
          child: Text(
            "User not authenticated",
            style: TextStyle(color: AppColors.whiteColor),
          ),
        ),
      );
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primeryColor, AppColors.greenColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Custom AppBar
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back, color: AppColors.whiteColor),
                      onPressed: () => Get.back(),
                    ),
                    Expanded(
                      child: "Chat with ${widget.doctorName}"
                          .text
                          .size(AppFontSize.size18)
                          .color(AppColors.whiteColor)
                          .bold
                          .makeCentered(),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              // Chat Messages
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('chats')
                      .doc(chatId)
                      .collection('messages')
                      .orderBy('timestamp', descending: false)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return "Start a conversation!"
                          .text
                          .color(AppColors.whiteColor)
                          .makeCentered();
                    }

                    var messages = snapshot.data!.docs;

                    return ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(8),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        var message = messages[index];
                        bool isSender = message['senderId'] == currentUserId;

                        // Safely check for isFile, fileData, and fileType fields
                        final messageData = message.data() as Map<String, dynamic>?;
                        bool isFile = messageData?.containsKey('isFile') == true && messageData!['isFile'] == true;
                        String? fileData = messageData?.containsKey('fileData') == true ? messageData!['fileData'] : null;
                        String? fileType = messageData?.containsKey('fileType') == true ? messageData!['fileType'] : null;

                        return Align(
                          alignment: isSender
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 5),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isSender
                                  ? AppColors.primeryColor
                                  : AppColors.whiteColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              crossAxisAlignment: isSender
                                  ? CrossAxisAlignment.end
                                  : CrossAxisAlignment.start,
                              children: [
                                if (isFile && fileData != null && fileType != null)
                                  GestureDetector(
                                    onTap: () {
                                      // Open the image in a full-screen view
                                      Get.to(() => FullScreenImageView(
                                        base64File: fileData,
                                        fileType: fileType,
                                      ));
                                    },
                                    child: Image.memory(
                                      base64Decode(fileData),
                                      width: 150,
                                      height: 150,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return "Failed to load image"
                                            .text
                                            .color(isSender
                                            ? AppColors.whiteColor
                                            : AppColors.textcolor)
                                            .make();
                                      },
                                    ),
                                  )
                                else
                                  Text(
                                    message['message'] ?? 'No message content',
                                    style: TextStyle(
                                      color: isSender
                                          ? AppColors.whiteColor
                                          : AppColors.textcolor,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              // Message Input
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        decoration: InputDecoration(
                          hintText: "Type a message...",
                          filled: true,
                          fillColor: AppColors.whiteColor,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    10.widthBox,
                    IconButton(
                      icon: Icon(Icons.send, color: AppColors.whiteColor),
                      onPressed: () => sendMessage(),
                    ),
                    // Document upload button (replacing the prescription button)
                    IconButton(
                      icon: isUploading
                          ? const CircularProgressIndicator()
                          : Icon(Icons.attach_file, color: AppColors.whiteColor),
                      onPressed: isUploading ? null : () => sendFile(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
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

// Full-screen image view for Base64 images
class FullScreenImageView extends StatelessWidget {
  final String base64File;
  final String fileType;

  const FullScreenImageView({
    super.key,
    required this.base64File,
    required this.fileType,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primeryColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.whiteColor),
          onPressed: () => Get.back(),
        ),
      ),
      body: Center(
        child: Image.memory(
          base64Decode(base64File),
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return "Failed to load image"
                .text
                .color(AppColors.textcolor)
                .make();
          },
        ),
      ),
    );
  }
}