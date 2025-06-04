import 'package:admin/authentication/firebase_auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class WorkerListPage extends StatefulWidget {
  const WorkerListPage({Key? key}) : super(key: key);

  @override
  State<WorkerListPage> createState() => _WorkerListPageState();
}

class _WorkerListPageState extends State<WorkerListPage> {
  FirebaseAuthService _authService = FirebaseAuthService();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF1FD), // light pink background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon:const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: (){
            Navigator.pop(context);
          },
        ),
        title: const Text(
          "Wireman",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _authService.fetchAllWorkerData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final workers = snapshot.data?.docs ?? [];

          if (workers.isEmpty) {
            return const Center(child: Text("No workers found."));
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: workers.length,
            itemBuilder: (context, index) {
              final data = workers[index].data();
              final name = data['username'] ?? 'Unnamed';
              // final isOnline = data['status'] == 'online'; // example logic

              return Container(
                margin: const EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F2F2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, color: Colors.black54),
                  ),
                  title: Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  // trailing: isOnline
                  //     ? const Icon(Icons.circle, color: Colors.green, size: 10)
                  //     : null,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
// SafeArea(
// child: Column(
// children: [
// // Header
// Padding(
// padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
// child: Row(
// children: [
// IconButton(
// icon: const Icon(Icons.arrow_back_ios, size: 20),
// onPressed: () {
// Navigator.pop(context);
// },
// ),
// const Expanded(
// child: Center(
// child: Text(
// 'Wireman',
// style: TextStyle(
// fontSize: 20,
// fontWeight: FontWeight.bold,
// ),
// ),
// ),
// ),
// const SizedBox(width: 48), // To balance the back button
// ],
// ),
// ),
//
// // Contact List
// Expanded(
// child: ListView.builder(
// itemCount: contacts.length,
// itemBuilder: (context, index) {
// final contact = contacts[index];
// return Padding(
// padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
// child: Container(
// decoration: BoxDecoration(
// color: const Color(0xFFF0F0F0),
// borderRadius: BorderRadius.circular(12),
// ),
// child: Padding(
// padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
// child: Row(
// children: [
// // Avatar
// Container(
// width: 40,
// height: 40,
// decoration: const BoxDecoration(
// shape: BoxShape.circle,
// color: Colors.white,
// ),
// child: const Icon(
// Icons.person_outline,
// color: Colors.black54,
// size: 24,
// ),
// ),
// const SizedBox(width: 16),
//
// // Name
// Expanded(
// child: Text(
// contact['name'],
// style: const TextStyle(
// fontSize: 16,
// fontWeight: FontWeight.w500,
// ),
// ),
// ),
//
// // Menu with optional notification dot
// Stack(
// children: [
// IconButton(
// icon: const Icon(Icons.more_vert),
// onPressed: () {
// // Menu action
// },
// ),
// if (contact['hasNotification'])
// Positioned(
// top: 8,
// right: 8,
// child: Container(
// width: 8,
// height: 8,
// decoration: const BoxDecoration(
// color: Colors.green,
// shape: BoxShape.circle,
// ),
// ),
// ),
// ],
// ),
// ],
// ),
// ),
// ),
// );
// },
// ),
// ),
// ],
// ),
// )
