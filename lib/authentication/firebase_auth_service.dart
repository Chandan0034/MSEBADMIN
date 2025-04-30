import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import 'dart:io';
class FirebaseAuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  final month=['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];

  Future<bool> registerUser(String email, String f_name, String l_name, String password,String type) async {
    try {
      UserCredential userCredential = await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);

      // Storing user's details without saving the password
      await _firestore.collection("Admin").doc(userCredential.user!.uid).set({
        "username": "$f_name $l_name",
        "email": email,
        "type":type,
        'createdAt': DateTime.now(),
      });
      return true;
    } catch (e) {
      if (e is FirebaseAuthException) {

      } else {

      }
      return false;
    }
  }

  /// Function to fetch user type based on email
  Future<String?> getUserType(String email) async {
    try {
      QuerySnapshot userSnapshot = await _firestore.collection("Admin").where("email", isEqualTo: email).get();
      if (userSnapshot.docs.isNotEmpty) {
        var doc = userSnapshot.docs.first;
        var data = doc.data() as Map<String, dynamic>;
        return data["type"]; // Returns the user type
      } else {
        return null; // No user found
      }
    } catch (e) {
      print("Error fetching user type: $e");
      return null; // Error occurred
    }
  }

  /// Checks if a user exists in Firestore based on their email.
  Future<bool> checkUserExists(String email,String type) async {
    QuerySnapshot userSnapshot = await _firestore.collection("Admin").where("email", isEqualTo: email).where("type",isEqualTo: type).get();
    return userSnapshot.docs.isNotEmpty;
  }

  /// Retrieves the password for a given email (not recommended to store passwords).
  Future<String?> getPassword(String email) async {
    QuerySnapshot user = await _firestore.collection("Admin").where("email", isEqualTo: email).get();
    if (user.docs.isNotEmpty) {
      var doc = user.docs.first;
      var data = doc.data() as Map<String, dynamic>;
      return data["password"]; // Consider removing this method for security reasons.
    }
    return null;
  }

  /// Logs in a user with email and password.
  Future<bool> loginUser(String email, String password) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
      return true;
    } catch (e) {
      if (e is FirebaseAuthException) {

      } else {

      }
      return false;
    }
  }
  Stream<QuerySnapshot<Map<String, dynamic>>> fetchUserData() {
    User? user = _firebaseAuth.currentUser;
    if (user == null) throw Exception("User not authenticated.");

    return FirebaseFirestore.instance
        .collection("MediaFileWithLocation")
        .where("userId", isEqualTo: user.uid)
        .orderBy("createdAt", descending: true)
        .snapshots();
  }
  Stream<List<Map<String, dynamic>>> getDataStream() {
    return _firestore
        .collection("Users")
        .orderBy("createdAt", descending: true) // Ascending order for "first come, first serve"
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => doc.data()).toList();
    });
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> fetchAllUserData() {
    return FirebaseFirestore.instance.collection("MediaFileWithLocation").snapshots();
  }
  Stream<List<Map<String, dynamic>>> getMediaDataStream() {
    return _firestore
        .collection("MediaFileWithLocation")
        .orderBy("createdAt", descending: true) // Orders by latest created
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => doc.data()).toList();
    });
  }

  Future<List<Map<String, dynamic>>> getDataOnce() async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
      await _firestore.collection("Users").get();

      List<Map<String, dynamic>> allUserData =
      querySnapshot.docs.map((doc) => doc.data()).toList();

      return allUserData;
    } catch (e) {
      print("Error fetching data: $e");
      return [];
    }
  }
  Future<bool> updateByAdminAssignWorker(String id) async {
    try {
      // Query the collection to find the document with the given id
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await _firestore
          .collection("MediaFileWithLocation")
          .where('id', isEqualTo: id)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Get the first document from the query result
        DocumentReference<Map<String, dynamic>> docRef = querySnapshot.docs.first.reference;

        // Get the current document data
        Map<String, dynamic>? docData = querySnapshot.docs.first.data();

        if (docData != null) {
          // Get the current statusList
          List<dynamic> statusList = docData['statusList'] ?? [];

          // Find the next incomplete status and mark it as completed
          for (int i = 0; i < statusList.length; i++) {
            if (statusList[i]['completed'] == false) {
              statusList[i]['completed'] = true; // Mark the next incomplete item as completed
              break; // Exit after updating the first incomplete item
            }
          }

          // Update the document with the modified statusList
          await docRef.update({
            'statusList': statusList,
          });

          print("Next status updated successfully for id: $id");
          return true; // Operation succeeded
        } else {
          print("No data found in the document for id: $id");
          return false; // Data not found
        }
      } else {
        print("Document with id $id does not exist.");
        return false; // Document not found
      }
    } catch (e) {
      print("Error updating status: $e");
      return false; // Error occurred
    }
  }
  Future<bool> addMediaFile({
    required String fileType,
    required String fileName,
    required String fileUrl,
  }) async {
    try {
      User? user = _firebaseAuth.currentUser;
      if (user == null) {
        print("No authenticated user.");
        return false;
      }

      await _firestore.collection("AdminMediaData").add({
        "fileType": fileType, // "image" or "video"
        "fileName": fileName,
        "fileUrl": fileUrl,
        "userId": user.uid,
        "uploadedAt": DateTime.now(),
      });
      print("Media file data added successfully.");
      return true;
    } catch (e) {
      print("Error adding media file data: $e");
      return false;
    }
  }
  Future<bool> updateMediaWhenWorkDone({
    required File mediaFile,
    required String id,
    required String fileType,
  }) async {
    try {
      String uuid = const Uuid().v4();
      String fileExtension = fileType == 'image' ? 'jpg' : 'mp4';
      String filePath = "media/$uuid/${DateTime.now().millisecondsSinceEpoch}.$fileExtension";

      // Upload the file
      TaskSnapshot uploadTask = await _storage.ref(filePath).putFile(mediaFile);

      // Get the download URL
      String downloadURL = await uploadTask.ref.getDownloadURL();

      // Update Firestore document with the download URL
      await _firestore.collection("MediaFileWithLocation").doc(id).update({
        'completedURL': downloadURL,
        'uploadedAt': DateTime.now(),
        'isCompleted':true,
        'completedURLType':fileType// Optional: to track when upload happened
      });

      return true;
    } catch (e) {
      print("Error updating media: $e");
      return false;
    }
  }
  Future<bool> uploadAlertMessage(String message) async{
    try{
      User? user = _firebaseAuth.currentUser;
      if (user == null) {
        print("No authenticated user.");
        return false;
      }
      await _firestore.collection("AdminAlert").add({
        "userId": user.uid,
        "alertMessage":message,
        "uploadedAt": DateTime.now(),
      });

      print("Media file data added successfully.");
      return true;

    }catch(e){
      print("Error adding media file data: $e");
      return false;
    }
  }

}
