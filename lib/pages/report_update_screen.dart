import 'package:admin/authentication/firebase_auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'media_item_card_screen.dart';

class ReportUpdateScreen extends StatefulWidget {
  const ReportUpdateScreen({super.key});

  @override
  State<ReportUpdateScreen> createState() => _ReportUpdateScreenState();
}

class _ReportUpdateScreenState extends State<ReportUpdateScreen> {
  final FirebaseAuthService _authService = FirebaseAuthService();
  String selectedFilter = ''; // Global variable

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
        slivers: [
          // Collapsible AppBar with an image
          SliverAppBar(
            expandedHeight: 180,
            pinned: false, // Keeps the app bar visible at the top
            flexibleSpace: FlexibleSpaceBar(
              background: Image.asset(
                "assets/Image/header.png",
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Fixed header below the collapsible image
          SliverToBoxAdapter(
            child: Container(
              alignment: Alignment.topLeft,
              margin: const EdgeInsets.only(left: 15,top: 14), // Left margin only
              padding: EdgeInsets.zero, // Ensure no extra padding
              child: Container(
                margin: EdgeInsets.only(left: 8,right: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Report Updates",
                      style: TextStyle(
                        fontSize: 18,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    GestureDetector(
                      onTapDown: (TapDownDetails details) async {
                        final selected = await showMenu<String>(
                          context: context,
                          position: RelativeRect.fromLTRB(
                            details.globalPosition.dx,
                            details.globalPosition.dy,
                            details.globalPosition.dx,
                            details.globalPosition.dy,
                          ),
                          items: const [
                            PopupMenuItem(
                              value: 'In Process',
                              child: Text('In Process'),
                            ),
                            PopupMenuItem(
                              value: 'Completed',
                              child: Text('Completed'),
                            ),
                          ],
                        );

                        if (selected != null) {
                          selectedFilter = selected; // update global variable
                          print("Global filter selected: $selectedFilter");
                          // Optionally trigger UI updates here if needed
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8.0),
                        width: 24,
                        height: 24,
                        child: Image.asset("assets/Image/filter.png", width: 24, height: 24),
                      ),
                    ),


                  ],
                ),
              ),
            ),
          ),

          SliverList(
            delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                return Padding(
                  padding: const EdgeInsets.only(left: 12, right: 12), // Only horizontal padding
                  child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: _authService.fetchAllUserData1(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(
                          child: Text(
                            'No data available',
                            style: TextStyle(color: Colors.black, fontSize: 16),
                          ),
                        );
                      } else {
                        final mediaData = snapshot.data!.docs;

                        return ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: mediaData.length,
                          itemBuilder: (context, index) {
                            final mediaItem = mediaData[index].data();
                            int completedCount = 0;

                            // Calculate completed items count
                            for (var status in mediaItem['statusList']) {
                              if (status['completed'] == true) {
                                completedCount++;
                              }
                            }

                            // Handle condition for `completedCount > 2`
                            if (completedCount > 2) {
                              return MediaItemCardScreen(
                                mediaItem: mediaItem,
                                cnt: completedCount - 3, // Adjusted count as per your logic
                              );
                            } else {
                              return const SizedBox.shrink(); // Skip items with `completedCount <= 2`
                            }
                          },
                        );
                      }
                    },
                  ),
                );
              },
              childCount: 1,
            ),
          ),
        ],
    );
  }
}