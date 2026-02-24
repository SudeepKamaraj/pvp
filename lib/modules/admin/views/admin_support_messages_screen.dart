import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class AdminSupportMessagesScreen extends StatelessWidget {
  const AdminSupportMessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Support Messages", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('support_messages').orderBy('createdAt', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   const Icon(Icons.inbox, size: 64, color: Colors.grey),
                   const SizedBox(height: 16),
                   Text("No messages yet", style: GoogleFonts.poppins(color: Colors.grey)),
                ],
              ),
            );
          }

          final messages = snapshot.data!.docs;

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: messages.length,
            separatorBuilder: (ctx, i) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final msg = messages[index].data() as Map<String, dynamic>;
              final docId = messages[index].id;
              final subject = msg['subject'] ?? 'No Subject';
              final message = msg['message'] ?? '';
              final email = msg['userEmail'] ?? 'Unknown Email';
              final timestamp = (msg['createdAt'] as Timestamp?)?.toDate();
              final dateStr = timestamp != null ? DateFormat('MMM d, y h:mm a').format(timestamp) : 'Just now';

              return Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(subject, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
                          ),
                          Text(dateStr, style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text("From: $email", style: GoogleFonts.poppins(fontSize: 12, color: Colors.blueGrey)),
                      const SizedBox(height: 12),
                      Text(message, style: GoogleFonts.poppins(fontSize: 14)),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton.icon(
                            icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                            label: const Text("Delete", style: TextStyle(color: Colors.red)),
                            onPressed: () {
                              Get.defaultDialog(
                                title: "Delete Message",
                                middleText: "Are you sure you want to delete this message?",
                                textConfirm: "Delete",
                                textCancel: "Cancel",
                                confirmTextColor: Colors.white,
                                buttonColor: Colors.red,
                                onConfirm: () {
                                  FirebaseFirestore.instance.collection('support_messages').doc(docId).delete();
                                  Get.back();
                                }
                              );
                            },
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.reply, size: 18),
                            label: const Text("Reply"),
                            onPressed: () async {
                              final Uri emailLaunchUri = Uri(
                                scheme: 'mailto',
                                path: email,
                                query: 'subject=Re: $subject&body=\n\nOriginal Message:\n$message',
                              );
                              if (await canLaunchUrl(emailLaunchUri)) {
                                await launchUrl(emailLaunchUri);
                              } else {
                                Get.snackbar("Error", "Could not launch email client");
                              }
                            },
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
