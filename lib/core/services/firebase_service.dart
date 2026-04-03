import 'dart:io';
import 'dart:math';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../features/shared/models/models.dart';

class FirebaseService {
  static FirebaseService? _instance;
  static FirebaseService get instance => _instance ??= FirebaseService._();

  FirebaseService._();

  fb_auth.FirebaseAuth get firebaseAuth => fb_auth.FirebaseAuth.instance;
  FirebaseFirestore get db => FirebaseFirestore.instance;
  FirebaseStorage get storage => FirebaseStorage.instance;

  fb_auth.User? get currentUser => fb_auth.FirebaseAuth.instance.currentUser;

  Future<void> initialize() async {
    await Firebase.initializeApp();
  }

  Future<fb_auth.UserCredential> createUserWithEmail(
      String email, String password) async {
    return await fb_auth.FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<fb_auth.UserCredential> signInWithEmail(
      String email, String password) async {
    return await fb_auth.FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await fb_auth.FirebaseAuth.instance.signOut();
  }

  Future<void> createCouplePair(String coupleCode) async {
    final currentUser = fb_auth.FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final coupleDoc = db.collection('couples').doc(coupleCode);
    final coupleData = await coupleDoc.get();

    if (coupleData.exists) {
      final data = coupleData.data()!;
      final partnerId = data['user1Id'] == currentUser.uid
          ? data['user2Id']
          : data['user1Id'];

      await db.collection('users').doc(currentUser.uid).update({
        'partnerId': partnerId,
        'coupleCode': coupleCode,
      });
    } else {
      await coupleDoc.set({
        'user1Id': currentUser.uid,
        'createdAt': FieldValue.serverTimestamp(),
      });
      await db.collection('users').doc(currentUser.uid).update({
        'coupleCode': coupleCode,
      });
    }
  }

  Future<User?> getCurrentUser() async {
    final user = fb_auth.FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    final userDoc = await db.collection('users').doc(user.uid).get();
    if (!userDoc.exists) return null;

    return User.fromJson(userDoc.data()!);
  }

  Stream<DocumentSnapshot> userStream(String userId) {
    return db.collection('users').doc(userId).snapshots();
  }

  Stream<QuerySnapshot> messagesStream(String coupleCode) {
    return db
        .collection('couples')
        .doc(coupleCode)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  Future<void> sendMessage(String coupleCode, Message message) async {
    await db
        .collection('couples')
        .doc(coupleCode)
        .collection('messages')
        .doc(message.id)
        .set(message.toJson());
  }

  Stream<QuerySnapshot> locationStream(String coupleCode) {
    return db
        .collection('couples')
        .doc(coupleCode)
        .collection('locations')
        .orderBy('timestamp', descending: true)
        .limit(1)
        .snapshots();
  }

  Future<void> updateLocation(
      String coupleCode, String userId, LocationData location) async {
    await db
        .collection('couples')
        .doc(coupleCode)
        .collection('locations')
        .doc(userId)
        .set({
      ...location.toJson(),
      'userId': userId,
    });
  }

  Stream<QuerySnapshot> mediaStream(String coupleCode) {
    return db
        .collection('couples')
        .doc(coupleCode)
        .collection('media')
        .orderBy('uploadedAt', descending: true)
        .snapshots();
  }

  Future<String> uploadMedia(
      String coupleCode, String filePath, String type) async {
    final fileName = '${DateTime.now().millisecondsSinceEpoch}_$type';
    final ref = storage.ref().child('couples/$coupleCode/media/$fileName');

    await ref.putFile(File(filePath));
    return await ref.getDownloadURL();
  }

  Future<void> addMedia(String coupleCode, SharedMedia media) async {
    await db
        .collection('couples')
        .doc(coupleCode)
        .collection('media')
        .doc(media.id)
        .set(media.toJson());
  }

  Stream<QuerySnapshot> callsStream(String coupleCode) {
    return db
        .collection('couples')
        .doc(coupleCode)
        .collection('calls')
        .orderBy('startTime', descending: true)
        .snapshots();
  }

  Future<void> addCall(String coupleCode, Call call) async {
    await db
        .collection('couples')
        .doc(coupleCode)
        .collection('calls')
        .doc(call.id)
        .set(call.toJson());
  }

  Future<void> updateCallDuration(
      String coupleCode, String callId, int duration) async {
    await db
        .collection('couples')
        .doc(coupleCode)
        .collection('calls')
        .doc(callId)
        .update({
      'duration': duration,
      'endTime': DateTime.now().toIso8601String(),
      'status': CallStatus.ended.name,
    });
  }

  String generateCoupleCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return List.generate(6, (_) => chars[random.nextInt(chars.length)]).join();
  }
}
