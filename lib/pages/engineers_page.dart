import 'package:admin/authentication/firebase_auth_service.dart';
import 'package:admin/pages/worker_list_page.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chewie/chewie.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:video_player/video_player.dart';

class EngineersPage extends StatefulWidget {
  const EngineersPage({super.key});

  @override
  State<EngineersPage> createState() => _EngineersPageState();
}

class _EngineersPageState extends State<EngineersPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          children: [
            SizedBox(height: 25,),
            AppBarLayout(),
            SizedBox(height: 10,),
            Expanded(child: WorkManagerScreen())
          ],
        ),
      ),
    );
  }
}



class WorkManagerScreen extends StatefulWidget {
  @override
  State<WorkManagerScreen> createState() => _WorkManagerScreenState();
}

class _WorkManagerScreenState extends State<WorkManagerScreen> {
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(17.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (context)=>WorkerListPage()));
              },
              child: Card(
                color: const Color(0xFFECECEC),
                elevation: 0,
                child: Padding(
                  padding: const EdgeInsets.only(top: 20,bottom: 20,left: 10,right: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.account_circle, size: 24),
                          SizedBox(width: 8),
                          Text(
                            'Manage Electricians',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Icon(Icons.chevron_right),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 16),
            Text(
              ' Work Manager',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Expanded(child: AssignWork()),
          ],
        ),
    );
  }
}
class AssignWork extends StatefulWidget {
  const AssignWork({super.key});

  @override
  State<AssignWork> createState() => _AssignWorkState();
}

class _AssignWorkState extends State<AssignWork> {
  final FirebaseAuthService _authService =FirebaseAuthService();
  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverList(
          delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
              return Padding(
                padding: const EdgeInsets.only(left: 12, right: 12), // Only horizontal padding
                child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: _authService.fetchAllUserData(),
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

                          for (var status in mediaItem['statusList']) {
                            if (status['completed'] == true) {
                              completedCount++;
                            }
                          }

                          // Apply the condition
                          if (completedCount < 2) {
                            return MediaItemCardScreen(
                              mediaItem: mediaItem,
                              cnt: completedCount,
                            );
                          } else {
                            return const SizedBox.shrink(); // Empty widget if condition not met
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

class MediaItemCardScreen extends StatefulWidget {
  final Map<String,dynamic> mediaItem;
  final int cnt;
  const MediaItemCardScreen({super.key,required this.mediaItem,required this.cnt});

  @override
  State<MediaItemCardScreen> createState() => _MediaItemCardScreenState();
}

class _MediaItemCardScreenState extends State<MediaItemCardScreen> {
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  final FirebaseAuthService _authService=FirebaseAuthService();
  bool _isLoading = false;
  bool _isAssigned = false;
  // Call your updateByAdminAssignWorker function here
  Future<void> _onAssignTap(String id) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Call the updateByAdminAssignWorker function
      bool result = await _authService.updateByAdminAssignWorker(id);

      setState(() {
        _isLoading = false;
        if (result) {
          _isAssigned = true; // Mark as assigned if successful
        }
      });

      if (result) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Status updated successfully!"),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Failed to update status."),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    final id=widget.mediaItem['id']??'';
    final downloadURL= widget.mediaItem['downloadURL'] ??'';
    final isImage = widget.mediaItem['fileType'] == 'image';
    final desc=widget.mediaItem['description'] ??'';
    final lat=widget.mediaItem['latitude']??'';
    final long=widget.mediaItem['longitude'] ?? '';
    return widget.cnt<=2 ? Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 20),
      color: const Color(0xFFECECEC),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isImage)
              Stack(
                children: [
                  Container(
                    alignment: Alignment.topLeft,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15), // Apply border radius here
                      child: CachedNetworkImage(
                        imageUrl: downloadURL,
                        fit: BoxFit.fill,
                        height: 300,
                        width: 220,
                        placeholder: (context, url) => Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                        errorWidget: (context, url, error) => Icon(Icons.error),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 6,
                    right: 50,
                    child: InkWell(
                      onTap: () {
                        MapsLauncher.launchCoordinates(lat, long, desc);
                      },
                      child: Card(
                        color: Colors.white,
                        elevation: 3,
                        child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Icon(
                            Icons.location_pin,
                            color: Colors.black,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              )
            else if (_chewieController != null &&
                _videoPlayerController!.value.isInitialized)
              AspectRatio(
                aspectRatio: _videoPlayerController!.value.aspectRatio,
                child: Chewie(controller: _chewieController!),
              )
            else
              const Center(child: CircularProgressIndicator()),
            const SizedBox(height: 10),
            Text(" "+ desc,
                style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                    fontFamily: "Poppins")),

            GestureDetector(
              onTap: _isLoading || _isAssigned ? null :()=> _onAssignTap(id),
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.all(10),
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      blurRadius: 5,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: _isLoading
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.black,
                    ),
                  )
                      : Text(
                    _isAssigned ? "Assigned" : "Assign",
                    style: TextStyle(
                      fontFamily: "Poppins",
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ):Container();
  }
}

class AppBarLayout extends StatelessWidget {
  const AppBarLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(

      decoration: BoxDecoration(
        color: Colors.white, // Background color of the container
        borderRadius: BorderRadius.circular(10), // Optional: Rounded corners
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2), // Shadow color with opacity
            spreadRadius: 2, // Spread radius (how far the shadow spreads)
            blurRadius: 10, // Blur radius (how soft the shadow is)
            offset: Offset(0, 3), // Offset (x, y): x -> horizontal, y -> vertical
          ),
        ],
      ),
      height: 70,
      // Height of the custom app bar
      // color: Colors.white,
      // Background color
      padding: const EdgeInsets.symmetric(horizontal: 20),
      // Side padding
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        // Spacing between elements
        crossAxisAlignment: CrossAxisAlignment.center,
        // Vertical alignment
        children: [
          // Leading icon (e.g., a globe icon for language)
          // Container(
          //   margin: EdgeInsets.only(top: 8),
          //   width: 32,
          //   height: 32,
          //   decoration: BoxDecoration(
          //     color: const Color(0xFFF1F9FF),
          //     borderRadius: BorderRadius.circular(8),
          //   ),
          //   child: IconButton(
          //     icon: const Icon(Icons.language, color: Colors.black),
          //     iconSize: 18,
          //     onPressed: () {
          //       // Add action for leading icon
          //     },
          //   ),
          // ),
          // Title (Image + Text)
          Container(
            margin: EdgeInsets.only(top: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/Image/logo.png',
                  height: 37,
                  width: 37,
                  fit: BoxFit.contain,
                ),
                const Text(
                  " Admin",

                  style: TextStyle(
                    fontFamily: "Poppins",
                    fontWeight: FontWeight.w900,
                    fontSize: 23,

                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          // Action icon (e.g., notification button)
          Container(
            margin: EdgeInsets.only(top: 10),
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F9FF),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: IconButton(
                icon: const Icon(Icons.language, color: Colors.black),
                iconSize: 25,
                onPressed: () {
                  // Add action for notifications
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
