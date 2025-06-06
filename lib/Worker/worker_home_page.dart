import 'package:admin/Worker/issue_manager_task_page.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:admin/authentication/firebase_auth_service.dart';
import 'package:chewie/chewie.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
class WorkerHomePage extends StatefulWidget {
  const WorkerHomePage({super.key});
  @override
  State<WorkerHomePage> createState() => _WorkerPageState();
}
class _WorkerPageState extends State<WorkerHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          children: [
            SizedBox(height: 30,),
            AppBarLayout(),
            SizedBox(height: 10,),
            Expanded(child: WorkManagerScreen())
          ],
        ),
      ),
    );
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
                  " Electrician",

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



class WorkManagerScreen extends StatefulWidget {
  @override
  State<WorkManagerScreen> createState() => _WorkManagerScreenState();
}

class _WorkManagerScreenState extends State<WorkManagerScreen> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: (){
              Navigator.push(context, MaterialPageRoute(builder: (context)=>IssueManagerTaskPage()));
            },
            child: Card(
              color: const Color(0xFFECECEC),
              child: Padding(
                padding: const EdgeInsets.only(top: 20,bottom: 20,left: 10,right: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        SizedBox(width: 8),
                        Text(
                          'Issue Manager',
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
            'Admin Tasks',
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: "Poppins"
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
    return StreamBuilder<List<QueryDocumentSnapshot<Map<String, dynamic>>>>(
      stream: _authService.fetchAssignedMediaStream(), // updated stream returning List<QueryDocumentSnapshot>
      builder: (context, snapshot) {
        print("snapshot");
        print(snapshot);
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text('No data available', style: TextStyle(fontSize: 16)),
          );
        }

        final mediaData = snapshot.data!;
        print("MediaData");
        final filteredItems = mediaData.where((doc) {
          final mediaItem = doc.data();
          int completedCount = 0;
          for (var status in mediaItem['statusList']) {
            if (status['completed'] == true) completedCount++;
          }
          return completedCount > 2 && completedCount <= 3;
        }).toList();

        return CustomScrollView(
          slivers: [
            SliverList(
              delegate: SliverChildBuilderDelegate(
                    (context, index) {
                  final mediaItem = filteredItems[index].data();
                  int completedCount = 0;
                  for (var status in mediaItem['statusList']) {
                    if (status['completed'] == true) completedCount++;
                  }
                  return MediaItemCardScreen(
                    mediaItem: mediaItem,
                    cnt: completedCount - 1,
                  );
                },
                childCount: filteredItems.length,
              ),
            ),
          ],
        );
      },
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
    return Card(
      color: const Color(0xFFECECEC),
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 20),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("${widget.mediaItem['UserName']}",style: TextStyle(fontWeight: FontWeight.bold,fontFamily: 'Poppins',fontSize: 16),),
            const SizedBox(height: 5),
            if (isImage)
              Stack(
                children: [
                  Center(
                    child: Container(
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
            const SizedBox(height: 20),
            // Display description below the media file
            Text(
              "Date : ${widget.mediaItem['date']}",
              style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                  fontFamily: "Poppins"),
            ),
            const SizedBox(height: 2),
            Text("Time : ${widget.mediaItem['time']}",
                style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                    fontFamily: "Poppins")),
            const SizedBox(height: 15),
            Text("${widget.mediaItem['faultName']}",style: TextStyle(fontWeight: FontWeight.w500,fontFamily: 'Poppins',fontSize: 14)),
            const SizedBox(height: 5),
            Text("${widget.mediaItem['description']}",style: TextStyle(fontWeight: FontWeight.w500,fontFamily: 'Poppins',fontSize: 14)),
            const SizedBox(height: 10),
            GestureDetector(
              onTap:  _isLoading || _isAssigned ? null :()=> _onAssignTap(id),
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
                    "Accept Task",
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
    );
  }
}

// Card(
// elevation: 4,
// shape: RoundedRectangleBorder(
// borderRadius: BorderRadius.circular(8),
// ),
// child: Padding(
// padding: const EdgeInsets.all(16.0),
// child: if()Column(
// crossAxisAlignment: CrossAxisAlignment.start,
// children: [
// Stack(
// children: [
// ClipRRect(
// borderRadius: BorderRadius.circular(8),
// child: Image.network(
// downloadURL,
// fit: BoxFit.fill,
// height: 300,
// width: 180,
//
// loadingBuilder: (context, child, loadingProgress) {
// if (loadingProgress == null) return child;
// return Center(
// child: CircularProgressIndicator(
// value: loadingProgress.expectedTotalBytes != null
// ? loadingProgress.cumulativeBytesLoaded /
// (loadingProgress.expectedTotalBytes ?? 1)
//     : null,
// ),
// );
// },
// ),
// ),
// Positioned(
// top: 8,
// right: 8,
// child: Icon(
// Icons.location_pin,
// color: Colors.red,
// size: 24,
// ),
// ),
// ],
// ),
// SizedBox(height: 12),
// Text(
// 'Transformer Fire issue in this area\nwith dangerous effect',
// style: TextStyle(fontSize: 16),
// ),
// SizedBox(height: 12),
// Center(
// child: ElevatedButton(
// onPressed: () {
// // Add your button action here
// },
// child: Text('Assign'),
// ),
// ),
// ],
// ),
//
