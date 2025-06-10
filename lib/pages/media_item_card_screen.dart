import 'dart:io';

import 'package:admin/authentication/firebase_auth_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';

// import 'package:untitled1/home_page/work_show_page.dart';

import 'package:video_player/video_player.dart';

class MediaItemCardScreen extends StatefulWidget {
  final Map<String, dynamic> mediaItem;
  final int cnt;

  const MediaItemCardScreen({Key? key, required this.mediaItem, required this.cnt}) : super(key: key);

  @override
  _MediaItemCardScreenState createState() => _MediaItemCardScreenState();
}

class _MediaItemCardScreenState extends State<MediaItemCardScreen>
    with AutomaticKeepAliveClientMixin {
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  FirebaseAuthService _authService = FirebaseAuthService();
  // String downloadURL = "";
  bool isMediaReady = false;
  bool isUpdating = false;
  int count=0;

  final List<String> statuses = [
    "Work Assigned",
    "Work Started",
    "Issue has been solved."
  ];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    // print("Idx");
    // print(widget.mediaItem['id']);
    // _fetchMedia();
    // _fetchData();
  }

  // Future<void> _fetchMedia() async {
  //   try {
  //     final its=await LocalDatabase().fetchAllMedia();
  //     print("List of item");
  //     print(its);
  //     final List<Map<String, dynamic>> items =
  //     await LocalDatabase().fetchMediaById(widget.mediaItem['id']);
  //     if (items.isNotEmpty) {
  //       for (Map<String, dynamic> map in items) {
  //         if (map['id'] == widget.mediaItem['id']) {
  //           downloadURL = map['file_url'] ?? ""; // Fallback to an empty string if `file_url` is null.
  //           print("Fetched file URL: ${map['file_url']}");
  //           break;
  //         }
  //       }
  //     } else {
  //       debugPrint("No media found for ID: ${widget.mediaItem['id']}");
  //     }
  //     setState(() {}); // Update the UI with the fetched data.
  //   } catch (e) {
  //     debugPrint("Error fetching media: $e");
  //   }
  // }

  // Future<void> _fetchData()async {
  //   setState(() {
  //     downloadURL=widget.mediaItem['downloadURL'];
  //     print("Download Video");
  //     print(downloadURL);
  //   });
  // }
  Future<void> _initializeVideoPlayer(String videoUrl) async {
    try {
      _videoPlayerController = VideoPlayerController.network(videoUrl);
      await _videoPlayerController!.initialize();
      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController!,
        autoPlay: false,
        looping: false,
        allowFullScreen: true,
      );
      setState(() {
        isMediaReady = true;
      });
    } catch (e) {
      debugPrint("Error initializing video: $e");
    }
  }

  @override
  void dispose() {
    _chewieController?.dispose();
    _videoPlayerController?.dispose();
    super.dispose();
  }
  Future<bool> _updateFinally(String id) async {
    if(count>=1){
      return false;
    }
    setState(() {
      count++;
    });
    try {
      bool result = await _authService.updateByAdminAssignFinalWorker(id);
      if (result) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Issue has been solved"),
            backgroundColor: Colors.green,
          ),
        );
        return true;
      }
      return false;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("An error occurred"),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final isImage = widget.mediaItem['fileType'] == 'image';
    final downloadURL=widget.mediaItem['downloadURL']?? '';
    final currentStatus = widget.cnt;
    final allowMarkAsSolved=widget.mediaItem['isCompleted'];
    String completedUrl=widget.mediaItem['completedURL'];
    final inProcess=widget.mediaItem['inProcess'];
    print("AllowMarkAsSolved");
    print(currentStatus);
    return Card(
      color: const Color(0xFFECECEC),
      elevation: 0,
      margin: const EdgeInsets.only(left: 15,right: 15,bottom: 24),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("${widget.mediaItem['UserName']}",style: TextStyle(fontWeight: FontWeight.w500,fontFamily: 'Poppins',fontSize: 14)),
            const SizedBox(height: 5),
            // Display the media file at the top (Image or Video)
            if (isImage)
              Row(
                children: [
                  Container(
                    alignment: Alignment.topLeft,
                    height: 300,
                    width: 180,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: PageView(
                        children: [
                          CachedNetworkImage(
                            imageUrl: downloadURL,
                            fit: BoxFit.fill,
                            placeholder: (context, url) => Center(
                              child: CircularProgressIndicator(),
                            ),
                            errorWidget: (context, url, error) => Icon(Icons.error),
                          ),
                          if (completedUrl.isNotEmpty)
                            CachedNetworkImage(
                              imageUrl: completedUrl,
                              fit: BoxFit.fill,
                              placeholder: (context, url) => Center(
                                child: CircularProgressIndicator(),
                              ),
                              errorWidget: (context, url, error) => Icon(Icons.error),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: statuses.asMap().entries.map((entry) {
                        int index = entry.key;
                        String status = entry.value;

                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              children: [
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 500),
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: index <= currentStatus
                                        ? Colors.blue
                                        : Colors.white,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.blue),
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      Icons.check,
                                      color: Colors.white,
                                      size: 15,
                                    ),
                                  ),
                                ),
                                if (index < statuses.length - 1)
                                  AnimatedContainer(
                                    duration: const Duration(seconds: 1),
                                    width: 4,
                                    height: 40,
                                    color: index < currentStatus
                                        ? Colors.blue
                                        : Colors.grey,
                                  ),
                              ],
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: AnimatedDefaultTextStyle(
                                duration: const Duration(milliseconds: 500),
                                style: TextStyle(
                                  color: index <= currentStatus
                                      ? Colors.black
                                      : Colors.grey,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: "Poppins",
                                ),
                                child: Text(status),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
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
            Text("${widget.mediaItem['faultName']}",style: TextStyle(fontWeight: FontWeight.w500,fontFamily: 'Poppins',fontSize: 14)),
            const SizedBox(height: 5),
            Text("${widget.mediaItem['description']}",style: TextStyle(fontWeight: FontWeight.w500,fontFamily: 'Poppins',fontSize: 14)),

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
            const SizedBox(height: 8),

            GestureDetector(
              onTap: !completedUrl.isNotEmpty
                  ? null
                  : () async {
                setState(() => isUpdating = true);
                await _updateFinally(widget.mediaItem['id']);
                setState(() => isUpdating = false);
              },
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.only(top: 30, left: 20, right: 20, bottom: 2),
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                decoration: BoxDecoration(
                  color:completedUrl.isNotEmpty ? Colors.white:Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  //opacity
                  boxShadow: [
                    BoxShadow(
                      color:completedUrl.isNotEmpty?Colors.grey.withOpacity(0.5):Colors.grey.withOpacity(0.1),
                      blurRadius: 5,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: isUpdating
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                      : Text(currentStatus<=1
                     ? "Mark as solved" : "Completed",
                    style: TextStyle(
                      fontFamily: "Poppins",
                      color:completedUrl.isNotEmpty?Colors.black: Colors.black.withOpacity(0.1),
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
