import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import 'dart:io';
import 'package:rxdart/rxdart.dart';
class FirebaseAuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  String? get currentUserEmail => _firebaseAuth.currentUser?.email;

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
        "isAssign":false,
        "assignedIds":[],
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

  Stream<List<QueryDocumentSnapshot<Map<String, dynamic>>>> fetchAssignedMediaStream() async* {
    final email = FirebaseAuth.instance.currentUser?.email;
    if (email == null) {
      print("No current user");
      yield [];
      return;
    }

    final adminSnapshot = await FirebaseFirestore.instance
        .collection('Admin')
        .where('email', isEqualTo: email)
        .where('type', isEqualTo: 'worker')
        .get();

    if (adminSnapshot.docs.isEmpty) {
      print("No matching admin user");
      yield [];
      return;
    }

    final assignedIdsRaw = adminSnapshot.docs.first.data()['assignedIds'];
    if (assignedIdsRaw == null || !(assignedIdsRaw is List)) {
      print("assignedIds missing or invalid");
      yield [];
      return;
    }

    final assignedIds = List<String>.from(assignedIdsRaw);
    if (assignedIds.isEmpty) {
      print("assignedIds list is empty");
      yield [];
      return;
    }

    const int chunkSize = 10;

    // Split assignedIds into chunks of max chunkSize (because Firestore 'whereIn' supports max 10)
    List<List<String>> chunks = [];
    for (var i = 0; i < assignedIds.length; i += chunkSize) {
      chunks.add(
        assignedIds.sublist(
          i,
          i + chunkSize > assignedIds.length ? assignedIds.length : i + chunkSize,
        ),
      );
    }

    // Create a list of streams, each querying one chunk of IDs
    final streams = chunks.map((chunk) {
      return FirebaseFirestore.instance
          .collection('MediaFileWithLocation')
          .where('id', whereIn: chunk)
          .snapshots();
    }).toList();

    // Combine all snapshot streams into one stream that emits a combined list of documents
    yield* Rx.combineLatestList(streams).map((listOfSnapshots) {
      return listOfSnapshots.expand((snap) => snap.docs).toList();
    });
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> fetchAssignedMediaStream1() async* {
    print("🔍 Starting fetchAssignedMediaStream...");

    final email = currentUserEmail;
    print("📧 Current user email: $email");

    if (email == null) {
      print("⚠️ No user email found. Returning empty stream.");
      yield* const Stream.empty();
      return;
    }

    final adminSnapshot = await FirebaseFirestore.instance
        .collection('Admin')
        .where('email', isEqualTo: email)
        .where('type', isEqualTo: 'worker')
        .get();

    print("📄 Admin snapshot docs count: ${adminSnapshot.docs.length}");

    if (adminSnapshot.docs.isEmpty) {
      print("⚠️ No admin/worker found for email: $email. Returning empty stream.");
      yield* const Stream.empty();
      return;
    }

    final rawAssignedIds = adminSnapshot.docs.first.data()['assignedIds'];
    print("🗂️ Raw assignedIds from Firestore: $rawAssignedIds");

    final assignedIds = List<String>.from(rawAssignedIds ?? []);
    print("✅ Parsed assignedIds list: $assignedIds");

    if (assignedIds.isEmpty) {
      print("⚠️ assignedIds list is empty. Returning empty stream.");
      yield* const Stream.empty();
      return;
    }

    final limitedIds = assignedIds.length > 10 ? assignedIds.sublist(0, 10) : assignedIds;
    print("🔢 limitedIds used in query: $limitedIds");

    final query = FirebaseFirestore.instance
        .collection('MediaFileWithLocation')
        .where(FieldPath.documentId, whereIn: limitedIds);

    print("📡 Fetching MediaFileWithLocation snapshots with document IDs: $limitedIds");
    print(query.snapshots());
    yield* query.snapshots();
  }



  Stream<QuerySnapshot<Map<String, dynamic>>> fetchAllUserData() {

    return FirebaseFirestore.instance.collection("MediaFileWithLocation").where('isCompleted',isEqualTo: false).snapshots();
  }
  Stream<QuerySnapshot<Map<String, dynamic>>> fetchAllUserData1({required String selectFilter}) {
    print("Selected");
    print(selectFilter);

    final collection = FirebaseFirestore.instance.collection("MediaFileWithLocation");

    if (selectFilter == "new") {
      // ✅ Requires composite index: isCompleted == false + orderBy createdAt DESC
      return collection
          .where('isCompleted', isEqualTo: false)
          .orderBy('createdAt', descending: true)
          .snapshots();
    } else if (selectFilter == 'inProcess') {
      // ✅ Filter by isCompleted == false AND inProcess == true
      return collection
          .where('isCompleted', isEqualTo: false)
          .where('inProcess', isEqualTo: true)
          .snapshots();
    } else if (selectFilter == 'completed') {
      // ✅ Filter by isCompleted == true
      return collection
          .where('isCompleted', isEqualTo: true)
          .snapshots();
    } else {
      // Default fallback to 'new' logic
      return collection
          .where('isCompleted', isEqualTo: false)
          .orderBy('createdAt', descending: true)
          .snapshots();
    }
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
  // update in admin panel to assign worker isAssign true or false whenever click on this function make all false of worker then assign true comming from email of worker
  Future<void> assignWorkersByEmailList(List<String> selectedEmails, String id) async {
    final adminCollection = FirebaseFirestore.instance.collection('Admin');
    print("Collection");
    print(adminCollection);
    for (String email in selectedEmails) {
      final querySnapshot = await adminCollection
          .where('type', isEqualTo: 'worker')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final docId = querySnapshot.docs.first.id;

        await adminCollection.doc(docId).update({
          'assignedIds': FieldValue.arrayUnion([id]), // Only add, do not overwrite or reset
        });

        print('Added ID "$id" to assignedIds of worker: $email');
      } else {
        print('Worker with email "$email" not found.');
      }
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
  Future<bool> updateByAdminAssignFinalWorker(String id) async {
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
            'inProcess':false,
            'completed':true
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
    required String id,         // This is the value of the 'id' field inside the document
    required String fileType,
  }) async {
    try {
      String uuid = const Uuid().v4();
      String fileExtension = fileType == 'image' ? 'jpg' : 'mp4';
      String filePath = "media/$uuid/${DateTime.now().millisecondsSinceEpoch}.$fileExtension";

      // Upload media to Firebase Storage
      TaskSnapshot uploadTask = await _storage.ref(filePath).putFile(mediaFile);
      String downloadURL = await uploadTask.ref.getDownloadURL();

      // 🔍 Find document where 'id' field matches the given ID
      final querySnapshot = await _firestore
          .collection("MediaFileWithLocation")
          .where("id", isEqualTo: id) // 'id' is the field inside the doc
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        print("Document with id = $id not found.");
        return false;
      }

      // 📝 Update the found document
      String docId = querySnapshot.docs.first.id;
      await _firestore.collection("MediaFileWithLocation").doc(docId).update({
        'completedURL': downloadURL,
        'uploadedAt': DateTime.now(),
        'isCompleted': true,
        'completedURLType': fileType,
      });

      return true;
    } catch (e) {
      print("Error updating media: $e");
      return false;
    }
  }
  //find all worker data and return it if type equal to worker
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
  Future<List<Map<String, dynamic>>> getAllWorkerData() async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await _firestore
          .collection("Admin")
          .where("type", isEqualTo: "worker")
          .get();
      List<Map<String, dynamic>> workerData = querySnapshot.docs.map((doc) =>
          doc.data()).toList();
      return workerData;
    } catch (e) {
      print("Error fetching worker data: $e");
      return [];
    }
  }

}
