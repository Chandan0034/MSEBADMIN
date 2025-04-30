import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../authentication/firebase_auth_service.dart';

class BroadCastPage extends StatefulWidget {
  const BroadCastPage({super.key});

  @override
  State<BroadCastPage> createState() => _BroadCastPageState();
}

class _BroadCastPageState extends State<BroadCastPage> {
  File? _mediaFile;
  final ImagePicker _picker = ImagePicker();
  final FirebaseAuthService _firebaseService = FirebaseAuthService();
  String _uploadButtonText = "Video";
  bool _isUploading = false;
  bool _isLoading=false;
  final _formKey = GlobalKey<FormState>();
  TextEditingController _emailController=TextEditingController();
  Future<void> _capturePhoto() async {
    try {
      final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
      if (photo != null) {
        setState(() {
          _mediaFile = File(photo.path);
          _uploadButtonText = "Upload";
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error capturing photo: $e")),
      );
    }
  }

  Future<void> _captureVideo() async {
    try {
      final XFile? video = await _picker.pickVideo(source: ImageSource.camera);
      if (video != null) {
        setState(() {
          _mediaFile = File(video.path);
          _uploadButtonText = "Upload";
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error capturing video: $e")),
      );
    }
  }

  Future<void> _uploadMedia() async {
    if (_mediaFile == null) return;

    setState(() {
      _isUploading = true;
      _uploadButtonText = "Uploading...";
    });

    try {
      final String filePath = _mediaFile!.path;
      final String fileType = filePath.endsWith('.mp4') ? 'video' : 'image';
      final String fileName = filePath.split('/').last;

      final bool success = await _firebaseService.addMediaFile(
        fileType: fileType,
        fileName: fileName,
        fileUrl: filePath,
      );

      setState(() {
        _isUploading = false;
        _uploadButtonText = success ? "Uploaded!" : "Upload";
        if (success) {
          _mediaFile = null;
          _uploadButtonText = "Video";
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(success ? "File uploaded successfully!" : "Failed to upload file.")),
      );
    } catch (e) {
      setState(() {
        _isUploading = false;
        _uploadButtonText = "Upload";
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error uploading file: $e")),
      );
    }
  }
  void _sendAlertMessage() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true; // Show the progress indicator
      });

      // Call the method to upload the alert message
      bool result = await _firebaseService.uploadAlertMessage(_emailController.text.trim());

      setState(() {
        _isLoading = false; // Hide the progress indicator
      });

      // Show a SnackBar depending on the result of the upload
      if (result) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Alert message sent successfully'),
            backgroundColor: Colors.green,
          ),
        );
        // Clear the text field
        _emailController.clear();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to send the alert message'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid message'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned(
            top: 25,
            left: 0,
            right: 0,
            child: AppBarLayout()
          ),
          Positioned.fill(
            top: 100, // Adjust this value based on AppBar's height

            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(top: 16,left: 11,right: 11),
                child: Column(
                  children: [
                    ClipRect(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Card(
                          color: const Color(0xFFECECEC),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Send important alert',
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: Colors.white,
                                    ),
                                    child: TextFormField(
                                      controller: _emailController,
                                      keyboardType: TextInputType.emailAddress,
                                      cursorColor: Colors.black,
                                      decoration: InputDecoration(
                                        hintText: 'Write here ...',
                                        hintStyle: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 14,
                                          fontFamily: 'Poppins',
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(14),
                                          borderSide: BorderSide.none,
                                        ),
                                        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),

                                      ),
                                      style: const TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 14,
                                        color: Colors.black,
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter something';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: ElevatedButton(
                                      onPressed: _isLoading ? null : _sendAlertMessage,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color.fromARGB(255, 55, 113, 142),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 20,
                                          vertical: 5,
                                        ),
                                      ),
                                      child: _isLoading
                                          ? const CircularProgressIndicator(color: Colors.white)
                                          : const Text(
                                        'Send',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.white,
                                          fontFamily: "Poppins",
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Card(
                        elevation: 0,
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color(0xFFECECEC),
                            borderRadius: BorderRadius.circular(12),
                            // boxShadow: [
                            //   BoxShadow(
                            //     color: Colors.black.withOpacity(0.1),
                            //     blurRadius: 8,
                            //     offset: const Offset(0, 4),
                            //   ),
                            // ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'Upload Media',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 20,
                                ),
                              ),
                              const SizedBox(height: 20),
                              SizedBox(
                                height: 200,
                                width: 150,
                                child: _isUploading
                                    ? const CircularProgressIndicator()
                                    : (_mediaFile == null
                                    ? Image.asset("assets/Image/Upload_cloud.png")
                                    : (_mediaFile!.path.endsWith('.mp4')
                                    ? const Icon(
                                  Icons.videocam,
                                  size: 100,
                                  color: Colors.grey,
                                )
                                    : Image.file(_mediaFile!))),
                              ),
                              const SizedBox(height: 20),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  ElevatedButton(
                                    onPressed: _isUploading ? null : _capturePhoto,
                                    style: ElevatedButton.styleFrom(
                                      foregroundColor: Colors.black,
                                      backgroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      elevation: 4,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 50,
                                        vertical: 12,
                                      ),
                                    ),
                                    child: const Text('Photo'),
                                  ),
                                  const SizedBox(width: 10),
                                  ElevatedButton(
                                    onPressed: _isUploading
                                        ? null
                                        : _uploadButtonText == "Upload"
                                        ? _uploadMedia
                                        : _captureVideo,
                                    style: ElevatedButton.styleFrom(
                                      foregroundColor: Colors.black,
                                      backgroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      elevation: 4,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 50,
                                        vertical: 12,
                                      ),
                                    ),
                                    child: Text(_uploadButtonText),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}



// import 'package:flutter/material.dart';
// class BroadCastPage extends StatefulWidget {
//   const BroadCastPage({super.key});
//
//   @override
//   State<BroadCastPage> createState() => _BroadCastPageState();
// }
//
// class _BroadCastPageState extends State<BroadCastPage> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(
//         child: Column(
//           children: [
//             SizedBox(height: 25,),
//             AppBarLayout(),
//             SizedBox(height: 10,),
//             Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Center(
//                 child: Card(
//                   color: Color(0xFFECECEC),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   elevation: 2,
//                   child: Padding(
//                     padding: const EdgeInsets.all(16.0),
//                     child: Column(
//                       mainAxisSize: MainAxisSize.min,
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           'Send important alert',
//                           style: TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         SizedBox(height: 12),
//                         Container(
//                           decoration: BoxDecoration(
//                             borderRadius: BorderRadius.circular(10),
//                             color: Colors.white
//                           ),
//                           child: TextField(
//                             cursorColor: Colors.black,
//                             decoration: InputDecoration(
//                               hintText: 'Write here ...',
//                               border: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(8),
//                                 borderSide: BorderSide.none
//                               ),
//
//                               contentPadding: EdgeInsets.symmetric(
//                                 horizontal: 12,
//                                 vertical: 8,
//                               ),
//                             ),
//                             style: TextStyle(
//                               color: Colors.black,
//                             ),
//                           ),
//                         ),
//                         SizedBox(height: 12),
//                         Align(
//                           alignment: Alignment.centerRight,
//                           child: ElevatedButton(
//                             onPressed: () {
//                               // Add your button action here
//                             },
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: Color.fromARGB(255, 55, 113, 142),
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(8),
//                               ),
//                               padding: EdgeInsets.symmetric(
//                                 horizontal: 20,
//                                 vertical: 10,
//                               ),
//                             ),
//                             child: Text(
//                               'Send',
//                               style: TextStyle(
//                                 fontSize: 12,
//                                 color: Colors.white,
//                                 fontFamily: "Poppins",
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.only(left: 10,right: 10,top: 20,bottom: 20),
//               child: Card(
//                 elevation: 2,
//                 child: Container(
//                   padding: const EdgeInsets.only(left: 10,right: 10,top: 20,bottom: 20),
//                   decoration: BoxDecoration(
//                     color: const Color(0xFFECECEC),
//                     borderRadius: BorderRadius.circular(12),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black.withOpacity(0.1),
//                         blurRadius: 8,
//                         offset: const Offset(0, 4),
//                       ),
//                     ],
//                   ),
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       const Text(
//                         'Upload Media',
//                         style: TextStyle(
//                           fontWeight: FontWeight.bold,
//                           fontSize: 16,
//                         ),
//                       ),
//                       const SizedBox(height: 20),
//                       SizedBox(
//                         height: 150,
//                         width: 150,
//                         child: Image.asset("assets/Image/Upload_cloud.png"),
//                       ),
//                       const SizedBox(height: 20),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                         children: [
//                           ElevatedButton(
//                             onPressed: () {
//                               // Add action for Photo button
//                             },
//                             style: ElevatedButton.styleFrom(
//                               foregroundColor: Colors.black,
//                               backgroundColor: Colors.white,
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(8),
//                               ),
//                               elevation: 4,
//                               padding: const EdgeInsets.symmetric(
//                                 horizontal: 55,
//                                 vertical: 12,
//                               ),
//                             ),
//                             child: const Text('Photo'),
//                           ),
//                           ElevatedButton(
//                             onPressed: () {
//                               // Add action for Video button
//                             },
//                             style: ElevatedButton.styleFrom(
//                               foregroundColor: Colors.black,
//                               backgroundColor: Colors.white,
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(8),
//                               ),
//                               elevation: 4,
//                               padding: const EdgeInsets.symmetric(
//                                 horizontal: 55,
//                                 vertical: 12,
//                               ),
//                             ),
//                             child: const Text('Video'),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }



class AlertCard extends StatefulWidget {
  const AlertCard({super.key});

  @override
  State<AlertCard> createState() => _AlertCardState();
}

class _AlertCardState extends State<AlertCard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child:Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Send important alert',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 12),
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Write here ...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                  ),
                  SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: () {
                        // Add your button action here
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal, // Button color
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                      ),
                      child: Text('Send'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
    );
  }
}



class UploadMediaPage extends StatefulWidget {
  const UploadMediaPage({super.key});

  @override
  State<UploadMediaPage> createState() => _UploadMediaPageState();
}

class _UploadMediaPageState extends State<UploadMediaPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: const Color(0xFFECECEC),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          width: 300,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Upload Media',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 20),
              Icon(
                Icons.cloud_upload_outlined,
                size: 80,
                color: Colors.black,
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      // Add action for Photo button
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.black,
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 4,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                    child: const Text('Photo'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // Add action for Video button
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.black,
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 4,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                    child: const Text('Video'),
                  ),
                ],
              ),
            ],
          ),
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













