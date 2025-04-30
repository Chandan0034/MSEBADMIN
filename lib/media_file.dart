// import 'package:admin/authentication/firebase_auth_service.dart';
// import 'package:chewie/chewie.dart';
// import 'package:video_player/video_player.dart';
// import 'package:flutter/material.dart';
//
// class MediaStreamBuilder extends StatelessWidget {
//   const MediaStreamBuilder({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     final FirebaseAuthService _authService = FirebaseAuthService();
//
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: StreamBuilder<List<Map<String, dynamic>>>(
//         stream: _authService.getMediaDataStream(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           } else if (snapshot.hasError) {
//             return Center(child: Text('Error: ${snapshot.error}'));
//           } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
//             return const Center(
//               child: Text(
//                 'No data available',
//                 style: TextStyle(color: Colors.black, fontSize: 16),
//               ),
//             );
//           } else {
//             final mediaData = snapshot.data!;
//             return ListView.builder(
//               itemCount: mediaData.length,
//               itemBuilder: (context, index) {
//                 final mediaItem = mediaData[index];
//                 return MediaItemCard(mediaItem: mediaItem);
//               },
//             );
//           }
//         },
//       ),
//     );
//   }
// }
//
// class MediaItemCard extends StatefulWidget {
//   final Map<String, dynamic> mediaItem;
//
//   const MediaItemCard({Key? key, required this.mediaItem}) : super(key: key);
//
//   @override
//   _MediaItemCardState createState() => _MediaItemCardState();
// }
//
// class _MediaItemCardState extends State<MediaItemCard>
//     with AutomaticKeepAliveClientMixin {
//   VideoPlayerController? _videoPlayerController;
//   ChewieController? _chewieController;
//
//   @override
//   bool get wantKeepAlive => true;
//
//   @override
//   void initState() {
//     super.initState();
//     if (widget.mediaItem['fileType'] == 'video') {
//       _initializeVideoPlayer(widget.mediaItem['downloadURL']);
//     }
//   }
//
//   Future<void> _initializeVideoPlayer(String videoUrl) async {
//     _videoPlayerController = VideoPlayerController.network(videoUrl);
//     await _videoPlayerController!.initialize();
//     _chewieController = ChewieController(
//       videoPlayerController: _videoPlayerController!,
//       autoPlay: false,
//       looping: false,
//       allowFullScreen: true,
//     );
//     setState(() {}); // Update the widget after initialization.
//   }
//
//   @override
//   void dispose() {
//     _chewieController?.dispose();
//     _videoPlayerController?.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     super.build(context); // Required for AutomaticKeepAliveClientMixin.
//
//     final isImage = widget.mediaItem['fileType'] == 'image';
//     final downloadURL = widget.mediaItem['downloadURL'] ?? '';
//
//     return Card(
//       elevation: 3,
//       margin: const EdgeInsets.all(12),
//       child: Padding(
//         padding: const EdgeInsets.all(10),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Display the media file at the top (Image or Video)
//             if (isImage)
//               Image.network(
//                 downloadURL,
//                 loadingBuilder: (context, child, loadingProgress) {
//                   if (loadingProgress == null) return child;
//                   return Center(
//                     child: CircularProgressIndicator(
//                       value: loadingProgress.expectedTotalBytes != null
//                           ? loadingProgress.cumulativeBytesLoaded /
//                           (loadingProgress.expectedTotalBytes ?? 1)
//                           : null,
//                     ),
//                   );
//                 },
//               )
//             else if (_chewieController != null &&
//                 _videoPlayerController!.value.isInitialized)
//               AspectRatio(
//                 aspectRatio: _videoPlayerController!.value.aspectRatio,
//                 child: Chewie(controller: _chewieController!),
//               )
//             else
//               const Center(child: CircularProgressIndicator()),
//
//             const SizedBox(height: 10),
//
//             // Display description below the media file
//             Text(
//               widget.mediaItem['description'] ?? 'No Description',
//               style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//             ),
//
//             const SizedBox(height: 8),
//
//             // Display location information below the description
//             Text(
//               'Latitude: ${widget.mediaItem['latitude']}, Longitude: ${widget.mediaItem['longitude']}',
//               style: const TextStyle(color: Colors.grey),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
// import 'package:admin/authentication/firebase_auth_service.dart';
// import 'package:chewie/chewie.dart';
// import 'package:video_player/video_player.dart';
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:visibility_detector/visibility_detector.dart'; // Import VisibilityDetector
//
// class MediaStreamBuilder extends StatelessWidget {
//   const MediaStreamBuilder({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     final FirebaseAuthService _authService = FirebaseAuthService();
//
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: StreamBuilder<List<Map<String, dynamic>>>(
//         stream: _authService.getMediaDataStream(), // Firestore stream for media data
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           } else if (snapshot.hasError) {
//             return Center(child: Text('Error: ${snapshot.error}'));
//           } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
//             return const Center(
//               child: Text(
//                 'No data available',
//                 style: TextStyle(color: Colors.black, fontSize: 16),
//               ),
//             );
//           } else {
//             final mediaData = snapshot.data!;
//             return ListView.builder(
//               itemCount: mediaData.length,
//               itemBuilder: (context, index) {
//                 final mediaItem = mediaData[index];
//                 return MediaItemCard(mediaItem: mediaItem, cardIndex: index);
//               },
//             );
//           }
//         },
//       ),
//     );
//   }
// }
//
// class MediaItemCard extends StatefulWidget {
//   final Map<String, dynamic> mediaItem;
//   final int cardIndex; // Add card index
//
//   const MediaItemCard({
//     Key? key,
//     required this.mediaItem,
//     required this.cardIndex,
//   }) : super(key: key);
//
//   @override
//   _MediaItemCardState createState() => _MediaItemCardState();
// }
//
// class _MediaItemCardState extends State<MediaItemCard> {
//   VideoPlayerController? _videoPlayerController;
//   ChewieController? _chewieController;
//   bool hasVisited = false; // Track whether the card was visited
//
//   @override
//   void initState() {
//     super.initState();
//     if (widget.mediaItem['fileType'] == 'video') {
//       _initializeVideoPlayer(widget.mediaItem['downloadURL']);
//     }
//   }
//
//   Future<void> _initializeVideoPlayer(String videoUrl) async {
//     _videoPlayerController = VideoPlayerController.network(videoUrl);
//     await _videoPlayerController!.initialize();
//     _chewieController = ChewieController(
//       videoPlayerController: _videoPlayerController!,
//       autoPlay: false,
//       looping: false,
//       allowFullScreen: true,
//     );
//     setState(() {}); // Update the widget after initialization.
//   }
//
//   @override
//   void dispose() {
//     _chewieController?.dispose();
//     _videoPlayerController?.dispose();
//     super.dispose();
//   }
//
//   // Function to update the status in Firestore when the card is viewed
//   Future<void> _updateCardStatus(String docId) async {
//
//     try {
//       // final user = FirebaseAuthService().currentUser;
//       // if (user == null) {
//       //   throw Exception("User not authenticated.");
//       // }
//
//       // Find the media item in Firestore based on its unique identifier (downloadURL or document ID)
//       final mediaDocRef = FirebaseFirestore.instance
//           .collection("MediaFileWithLocation")
//           .doc(docId); // You can use downloadURL or other unique field as docId
//
//       // Update the 'Admin has seemed your report' status
//       await mediaDocRef.update({
//         "statusList": FieldValue.arrayUnion([
//           {"message": "Admin has seemed your report", "completed": true}
//         ]),
//       });
//
//       print("Status updated: Admin has seemed your report");
//     } catch (e) {
//       print("Failed to update status: ${e.toString()}");
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final isImage = widget.mediaItem['fileType'] == 'image';
//     final downloadURL = widget.mediaItem['downloadURL'] ?? '';
//
//     return VisibilityDetector(
//       key: Key('card-${widget.cardIndex}'),
//       onVisibilityChanged: (visibilityInfo) {
//         // Check if the card is visible and hasn't been visited
//         if (visibilityInfo.visibleFraction > 0.5 && !hasVisited) {
//           setState(() {
//             hasVisited = true; // Mark the card as visited
//           });
//
//           // Update the status in Firestore (without tap)
//           print(widget.mediaItem['id']);
//           _updateCardStatus(widget.mediaItem['id'].toString());
//
//         }
//       },
//       child: Card(
//         elevation: 3,
//         margin: const EdgeInsets.all(12),
//         child: Padding(
//           padding: const EdgeInsets.all(10),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Display the media file at the top (Image or Video)
//               if (isImage)
//                 Image.network(
//                   downloadURL,
//                   loadingBuilder: (context, child, loadingProgress) {
//                     if (loadingProgress == null) return child;
//                     return Center(
//                       child: CircularProgressIndicator(
//                         value: loadingProgress.expectedTotalBytes != null
//                             ? loadingProgress.cumulativeBytesLoaded /
//                             (loadingProgress.expectedTotalBytes ?? 1)
//                             : null,
//                       ),
//                     );
//                   },
//                 )
//               else if (_chewieController != null &&
//                   _videoPlayerController!.value.isInitialized)
//                 AspectRatio(
//                   aspectRatio: _videoPlayerController!.value.aspectRatio,
//                   child: Chewie(controller: _chewieController!),
//                 )
//               else
//                 const Center(child: CircularProgressIndicator()),
//
//               const SizedBox(height: 10),
//
//               // Display description below the media file
//               Text(
//                 widget.mediaItem['description'] ?? 'No Description',
//                 style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//               ),
//
//               const SizedBox(height: 8),
//
//               // Display location information below the description
//               Text(
//                 'Latitude: ${widget.mediaItem['latitude']}, Longitude: ${widget.mediaItem['longitude']}',
//                 style: const TextStyle(color: Colors.grey),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
class AdminMediaScreen extends StatefulWidget {
  @override
  State<AdminMediaScreen> createState() => _AdminMediaScreenState();
}

class _AdminMediaScreenState extends State<AdminMediaScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fetch all user data for admin
  Stream<QuerySnapshot<Map<String, dynamic>>> fetchAllUserData() {
    return _firestore.collection("MediaFileWithLocation").snapshots();
  }

  // Update status in the statusList
  Future<void> updateStatus(DocumentSnapshot doc) async {
    print(doc);
    List<dynamic> statusList = doc['statusList'];

    for (int i = 0; i < statusList.length; i++) {
      if (statusList[i]['completed'] == false) {
        // Update the first status with 'false' to 'true'
        statusList[i]['completed'] = true;

        // Update the document in Firestore
        await _firestore
            .collection("MediaFileWithLocation")
            .doc(doc.id)
            .update({"statusList": statusList});

        break;  // Exit the loop once the first 'false' is updated to 'true'
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Media Screen"),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: fetchAllUserData(),
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
              itemCount: mediaData.length,
              itemBuilder: (context, index) {
                final mediaItem = mediaData[index].data();

                // Calculate the count of completed statuses
                int completedCount = 0;
                for (var status in mediaItem['statusList']) {
                  if (status['completed'] == true) {
                    completedCount++;
                  }
                }

                return ListTile(
                  title: Text(mediaItem['description']),
                  subtitle: Text('Status: $completedCount/5 completed'),
                  trailing: IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () async {
                      // Update status on button press
                      await updateStatus(mediaData[index]);
                    },
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
