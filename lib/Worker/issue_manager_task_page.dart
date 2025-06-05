import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chewie/chewie.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:video_player/video_player.dart';
import '../authentication/firebase_auth_service.dart';
class IssueManagerTaskPage extends StatefulWidget {
  const IssueManagerTaskPage({super.key});

  @override
  State<IssueManagerTaskPage> createState() => _IssueManagerTaskPageState();
}

class _IssueManagerTaskPageState extends State<IssueManagerTaskPage> {
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
            Expanded(child:IssueTask())
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
            margin: EdgeInsets.only(top: 5),
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


class IssueTask extends StatefulWidget {
  @override
  State<IssueTask> createState() => _IssueTaskState();
}

class _IssueTaskState extends State<IssueTask> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 15 , right: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                          String uploadFile=mediaItem['completedURL'];
                          for (var status in mediaItem['statusList']) {
                            if (status['completed'] == true) {
                              completedCount++;
                            }
                          }

                          // Apply the condition
                          if (completedCount > 3 || uploadFile.isNotEmpty) {
                            return MediaItemCardScreen(
                              mediaItem: mediaItem,
                              cnt: completedCount - 1,
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
  FirebaseAuthService firebaseAuthService= FirebaseAuthService();
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  File? _mediaFile;
  bool _isVideo = false;
  final ImagePicker _picker = ImagePicker();
  final FirebaseAuthService _authService=FirebaseAuthService();
  bool _isLoading = false;
  bool _isUploading = false;
  bool _isAssigned = false;
  // Call your updateByAdminAssignWorker function here


  // void _initializeVideoController() {
  //   if (_mediaFile != null) {
  //     _videoController = VideoPlayerController.file(_mediaFile!)
  //       ..initialize().then((_) {
  //         setState(() {});
  //       });
  //     _videoController!.addListener(() {
  //       setState(() {});
  //     });
  //   }
  // }

  Future<void> _pickImageFromCamera() async {
    _clearMedia();
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        _mediaFile = File(pickedFile.path);
        _isVideo = false;
      });
    }
  }

  void _clearMedia() {
    setState(() {
      _mediaFile = null;
    });
  }


  Future<void> _pickVideoFromCamera() async {
    _clearMedia();
    final pickedFile = await _picker.pickVideo(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        _mediaFile = File(pickedFile.path);
        _isVideo = true;
      });
    }
  }


  Future<void> _showMediaSourceSelectionDialog() async {
    try {
      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Choose Media Type'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ListTile(
                  leading: Icon(Icons.camera_alt),
                  title: Text('Camera (Image)'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImageFromCamera();
                  },
                ),
                ListTile(
                  leading: Icon(Icons.videocam),
                  title: Text('Camera (Video)'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickVideoFromCamera();
                  },
                ),
              ],
            ),
          );
        },
      );
    } catch (e) {
      print("Error: $e");
    }
  }


  Future<void> _uploadMedia(String id) async {
    if (_mediaFile == null) {
      _showSnackBar('Please select a media file', Colors.red);
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      bool success = await _authService.updateMediaWhenWorkDone(
        mediaFile: _mediaFile!,
        id: id,
        fileType: _isVideo ? 'video' : 'image',
      );

      if (!success) {
        throw Exception('Upload failed');
      }

      _showSnackBar('Data successfully uploaded.', Colors.green);
      _clearMedia();
    } catch (e) {
      print("Upload error: $e"); // <- This will help identify the problem
      _showSnackBar('Error uploading data.', Colors.red);
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }
  void _showSnackBar(String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      ),
    );
  }
  // Future<void> _onAssignTap(String id) async {
  //   // setState(() {
  //   //   _isLoading = true;
  //   // });
  //   _uploadMedia(id);
  //
  //   // try {
  //   //   // Call the updateByAdminAssignWorker function
  //   //   bool result = await _authService.updateByAdminAssignWorker(id);
  //   //
  //   //   setState(() {
  //   //     _isLoading = false;
  //   //     if (result) {
  //   //       _isAssigned = true; // Mark as assigned if successful
  //   //     }
  //   //   });
  //   //
  //   //   if (result) {
  //   //     ScaffoldMessenger.of(context).showSnackBar(
  //   //       SnackBar(
  //   //         content: const Text("Status updated successfully!"),
  //   //         backgroundColor: Colors.green,
  //   //       ),
  //   //     );
  //   //   } else {
  //   //     ScaffoldMessenger.of(context).showSnackBar(
  //   //       SnackBar(
  //   //         content: const Text("Failed to update status."),
  //   //         backgroundColor: Colors.red,
  //   //       ),
  //   //     );
  //   //   }
  //   // } catch (e) {
  //   //   setState(() {
  //   //     _isLoading = false;
  //   //   });
  //   //
  //   //   ScaffoldMessenger.of(context).showSnackBar(
  //   //     SnackBar(
  //   //       content: Text("Error: $e"),
  //   //       backgroundColor: Colors.red,
  //   //     ),
  //   //   );
  //   // }
  // }
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
                        child: _mediaFile==null?CachedNetworkImage(
                          imageUrl:downloadURL,
                          fit: BoxFit.fill,
                          height: 300,
                          width: double.infinity,
                          placeholder: (context, url) => Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                          errorWidget: (context, url, error) => Icon(Icons.error),
                        ):Image.file(_mediaFile!,fit: BoxFit.fill,height: 300,width: double.infinity,),
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
            Text(
              "Date : ${widget.mediaItem['date']}",
              style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  fontFamily: "Poppins"),
            ),
            const SizedBox(height: 2),
            Text("Time : ${widget.mediaItem['time']}",
                style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    fontFamily: "Poppins")),
            const SizedBox(height: 15),
            Text("${widget.mediaItem['faultName']}",style: TextStyle(fontWeight: FontWeight.w500,fontFamily: 'Poppins',fontSize: 14)),
            const SizedBox(height: 5),
            Text("${widget.mediaItem['description']}",style: TextStyle(fontWeight: FontWeight.w500,fontFamily: 'Poppins',fontSize: 14)),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap:(){
                      MapsLauncher.launchCoordinates(
                      widget.mediaItem['latitude'], widget.mediaItem['longitude'], desc);
                    },
                    child: Container(
                      margin: const EdgeInsets.all(10),
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
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
                          "Location",
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
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      if (_mediaFile == null && !_isUploading) {
                        await _showMediaSourceSelectionDialog();
                      } else {
                        await _uploadMedia(id);
                      }
                    },
                    child: Container(
                      margin: const EdgeInsets.all(6),
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
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
                        child: _isUploading
                            ? const CircularProgressIndicator()
                            : Text(
                          _mediaFile == null ? "Upload Media" : "Issue Solved",
                          style: const TextStyle(
                            fontFamily: "Poppins",
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),

                ),
              ],
            )

          ],
        ),
      ),
    );
  }
}

// class AssignWork extends StatefulWidget {
//   const AssignWork({super.key});
//
//   @override
//   State<AssignWork> createState() => _AssignWorkState();
// }
//
// class _AssignWorkState extends State<AssignWork> {
//   final FirebaseAuthService _authService = FirebaseAuthService();
//
//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
//       stream: _authService.fetchAllUserData(),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Center(child: CircularProgressIndicator());
//         } else if (snapshot.hasError) {
//           return Center(child: Text('Error: ${snapshot.error}'));
//         } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//           return const Center(
//             child: Text(
//               'No data available',
//               style: TextStyle(color: Colors.black, fontSize: 16),
//             ),
//           );
//         } else {
//           final mediaData = snapshot.data!.docs;
//           return ListView.builder( // Removed Expanded
//             itemCount: mediaData.length,
//             itemBuilder: (context, index) {
//               final mediaItem = mediaData[index].data();
//               int completedCount = 0;
//
//               for (var status in mediaItem['statusList']) {
//                 if (status['completed'] == true) {
//                   completedCount++;
//                 }
//               }
//
//               if (completedCount > 2) {
//                 return MediaItemCardScreen(
//                   mediaItem: mediaItem,
//                   cnt: completedCount - 1,
//                 );
//               } else {
//                 return const SizedBox.shrink();
//               }
//             },
//           );
//         }
//       },
//     );
//   }
// }
//
//
//
// class MediaItemCardScreen extends StatefulWidget {
//   final Map<String,dynamic> mediaItem;
//   final int cnt;
//   const MediaItemCardScreen({super.key,required this.mediaItem,required this.cnt});
//
//   @override
//   State<MediaItemCardScreen> createState() => _MediaItemCardScreenState();
// }
//
// class _MediaItemCardScreenState extends State<MediaItemCardScreen> {
//   VideoPlayerController? _videoPlayerController;
//   ChewieController? _chewieController;
//   final FirebaseAuthService _authService=FirebaseAuthService();
//   bool _isLoading = false;
//   bool _isAssigned = false;
//   // Call your updateByAdminAssignWorker function here
//   Future<void> _onAssignTap(String id) async {
//     setState(() {
//       _isLoading = true;
//     });
//
//     try {
//       // Call the updateByAdminAssignWorker function
//       bool result = await _authService.updateByAdminAssignWorker(id);
//
//       setState(() {
//         _isLoading = false;
//         if (result) {
//           _isAssigned = true; // Mark as assigned if successful
//         }
//       });
//
//       if (result) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: const Text("Status updated successfully!"),
//             backgroundColor: Colors.green,
//           ),
//         );
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: const Text("Failed to update status."),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     } catch (e) {
//       setState(() {
//         _isLoading = false;
//       });
//
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text("Error: $e"),
//           backgroundColor: Colors.red,
//         ),
//       );
//     }
//   }
//   @override
//   Widget build(BuildContext context) {
//     final id=widget.mediaItem['id']??'';
//     final downloadURL= widget.mediaItem['downloadURL'] ??'';
//     final isImage = widget.mediaItem['fileType'] == 'image';
//     final lat=widget.mediaItem['latitude']??'';
//     final long=widget.mediaItem['longitude']??'';
//     final desc=widget.mediaItem['description'] ??'';
//     return Card(
//       elevation: 4,
//       margin: const EdgeInsets.only(left: 4,right: 4,bottom: 20),
//       child: Padding(
//         padding: const EdgeInsets.all(15),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             if (isImage)
//               Stack(
//                 children: [
//                   Center(
//                     child: Container(
//                       alignment: Alignment.topLeft,
//                       child: ClipRRect(
//                         borderRadius: BorderRadius.circular(15), // Apply border radius here
//                         child: CachedNetworkImage(
//                           imageUrl: downloadURL,
//                           fit: BoxFit.fill,
//                           height: 300,
//                           width: 220,
//                           placeholder: (context, url) => Padding(
//                             padding: const EdgeInsets.all(8.0),
//                             child: Center(
//                               child: CircularProgressIndicator(),
//                             ),
//                           ),
//                           errorWidget: (context, url, error) => Icon(Icons.error),
//                         ),
//                       ),
//                     ),
//                   ),
//
//                 ],
//               )
//             else if (_chewieController != null &&
//                 _videoPlayerController!.value.isInitialized)
//               AspectRatio(
//                 aspectRatio: _videoPlayerController!.value.aspectRatio,
//                 child: Chewie(controller: _chewieController!),
//               )
//             else
//               const Center(child: CircularProgressIndicator()),
//             const SizedBox(height: 20),
//             // Display description below the media file
//             Text(
//               "Date : ${widget.mediaItem['date']}",
//               style: const TextStyle(
//                   fontWeight: FontWeight.w500,
//                   fontSize: 16,
//                   fontFamily: "Poppins"),
//             ),
//             const SizedBox(height: 2),
//             Text("Time : ${widget.mediaItem['time']}",
//                 style: const TextStyle(
//                     fontWeight: FontWeight.w500,
//                     fontSize: 16,
//                     fontFamily: "Poppins")),
//             const SizedBox(height: 15),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 GestureDetector(
//                   onTap: (){
//                     MapsLauncher.createCoordinatesUri(lat, long,desc);
//                   },
//                   child: Container(
//                     width: double.infinity,
//                     margin: const EdgeInsets.all(10),
//                     padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(8),
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.grey.withOpacity(0.5),
//                           blurRadius: 5,
//                           offset: const Offset(0, 4),
//                         ),
//                       ],
//                     ),
//                     child: Center(
//                       child: _isLoading
//                           ? const SizedBox(
//                         height: 20,
//                         width: 20,
//                         child: CircularProgressIndicator(
//                           strokeWidth: 2.5,
//                           color: Colors.black,
//                         ),
//                       )
//                           : Text(
//                         "Location",
//                         style: TextStyle(
//                           fontFamily: "Poppins",
//                           color: Colors.black,
//                           fontSize: 16,
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//                 SizedBox(width: 10,),
//                 GestureDetector(
//                   child: Container(
//                     width: double.infinity,
//                     margin: const EdgeInsets.all(10),
//                     padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(8),
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.grey.withOpacity(0.5),
//                           blurRadius: 5,
//                           offset: const Offset(0, 4),
//                         ),
//                       ],
//                     ),
//                     child: Center(
//                       child: _isLoading
//                           ? const SizedBox(
//                         height: 20,
//                         width: 20,
//                         child: CircularProgressIndicator(
//                           strokeWidth: 2.5,
//                           color: Colors.black,
//                         ),
//                       )
//                           : Text(
//                         "Issue Solved",
//                         style: TextStyle(
//                           fontFamily: "Poppins",
//                           color: Colors.black,
//                           fontSize: 16,
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }