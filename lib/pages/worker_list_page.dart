import 'package:flutter/material.dart';

class WorkerListPage extends StatelessWidget {
  const WorkerListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> contacts = [
      {'name': 'Vicky Kaushal', 'hasNotification': false},
      {'name': 'Kartik Aryan', 'hasNotification': false},
      {'name': 'Akhsay Kumar', 'hasNotification': true},
      {'name': 'John Doe', 'hasNotification': false},
      {'name': 'Jane Smith', 'hasNotification': false},
      {'name': 'Robert Johnson', 'hasNotification': false},
      {'name': 'Emily Davis', 'hasNotification': true},
      {'name': 'Michael Brown', 'hasNotification': false},
      {'name': 'Sarah Wilson', 'hasNotification': false},
      {'name': 'David Miller', 'hasNotification': false},
    ];

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios, size: 20),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Wireman',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 48), // To balance the back button
                ],
              ),
            ),

            // Contact List
            Expanded(
              child: ListView.builder(
                itemCount: contacts.length,
                itemBuilder: (context, index) {
                  final contact = contacts[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0F0F0),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                        child: Row(
                          children: [
                            // Avatar
                            Container(
                              width: 40,
                              height: 40,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                              ),
                              child: const Icon(
                                Icons.person_outline,
                                color: Colors.black54,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),

                            // Name
                            Expanded(
                              child: Text(
                                contact['name'],
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),

                            // Menu with optional notification dot
                            Stack(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.more_vert),
                                  onPressed: () {
                                    // Menu action
                                  },
                                ),
                                if (contact['hasNotification'])
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: Container(
                                      width: 8,
                                      height: 8,
                                      decoration: const BoxDecoration(
                                        color: Colors.green,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
