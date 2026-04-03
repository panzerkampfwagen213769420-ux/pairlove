import 'dart:async';
import 'package:flutter/material.dart';
import './services/firebase_service.dart';
import '../features/shared/models/models.dart';

class AppState extends ChangeNotifier {
  User? _currentUser;
  User? _partner;
  String? _coupleCode;
  List<Message> _messages = [];
  List<SharedMedia> _media = [];
  List<Call> _calls = [];
  LocationData? _partnerLocation;
  bool _isLoading = true;
  String? _error;
  bool _isDarkMode = true;
  String _chatBackground = 'default';
  String? _mood;

  User? get currentUser => _currentUser;
  User? get partner => _partner;
  String? get coupleCode => _coupleCode;
  List<Message> get messages => _messages;
  List<SharedMedia> get media => _media;
  List<Call> get calls => _calls;
  LocationData? get partnerLocation => _partnerLocation;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isDarkMode => _isDarkMode;
  String get chatBackground => _chatBackground;
  String? get mood => _mood;

  bool get isLoggedIn => _currentUser != null;
  bool get hasPartner => _partner != null;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  void setChatBackground(String background) {
    _chatBackground = background;
    notifyListeners();
  }

  void setMood(String mood) {
    _mood = mood;
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(mood: mood);
    }
    notifyListeners();
  }

  Future<void> logout() async {
    await signOut();
  }

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      await FirebaseService.instance.initialize();
      final user = await FirebaseService.instance.getCurrentUser();

      if (user != null) {
        _currentUser = user;
        _coupleCode = user.partnerId;

        if (user.partnerId != null) {
          await _loadPartnerData(user.partnerId!);
        }
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signIn(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final credential =
          await FirebaseService.instance.signInWithEmail(email, password);
      if (credential.user != null) {
        _currentUser = await FirebaseService.instance.getCurrentUser();
        if (_currentUser?.partnerId != null) {
          _coupleCode = _currentUser!.coupleCode;
          await _loadPartnerData(_currentUser!.partnerId!);
        }
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signUp(String email, String password, String nickname) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final credential =
          await FirebaseService.instance.createUserWithEmail(email, password);
      if (credential.user != null) {
        final user = User(
          id: credential.user!.uid,
          nickname: nickname,
        );

        await FirebaseService.instance.db
            .collection('users')
            .doc(user.id)
            .set(user.toJson());
        _currentUser = user;
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    await FirebaseService.instance.signOut();
    _currentUser = null;
    _partner = null;
    _coupleCode = null;
    _messages = [];
    _media = [];
    _calls = [];
    notifyListeners();
  }

  Future<void> createUserWithNickname(
      String nickname, String? partnerCode) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final tempEmail =
          '${nickname.toLowerCase()}_${DateTime.now().millisecondsSinceEpoch}@pairlove.app';
      final tempPassword = 'temp_${DateTime.now().millisecondsSinceEpoch}';

      final credential = await FirebaseService.instance
          .createUserWithEmail(tempEmail, tempPassword);
      if (credential.user != null) {
        final user = User(
          id: credential.user!.uid,
          nickname: nickname,
        );

        await FirebaseService.instance.db
            .collection('users')
            .doc(user.id)
            .set(user.toJson());
        _currentUser = user;

        if (partnerCode != null && partnerCode.isNotEmpty) {
          await joinCouple(partnerCode);
        }
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> setPartner(String partnerCode) async {
    await joinCouple(partnerCode);
  }

  Future<String> createCouple() async {
    final code = FirebaseService.instance.generateCoupleCode();
    _coupleCode = code;

    if (_currentUser != null) {
      await FirebaseService.instance.db
          .collection('users')
          .doc(_currentUser!.id)
          .update({
        'coupleCode': code,
      });
    }

    notifyListeners();
    return code;
  }

  Future<void> joinCouple(String code) async {
    _isLoading = true;
    notifyListeners();

    try {
      await FirebaseService.instance.createCouplePair(code);
      _coupleCode = code;

      if (_currentUser != null && _currentUser!.partnerId != null) {
        await _loadPartnerData(_currentUser!.partnerId!);
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadPartnerData(String partnerId) async {
    final partnerDoc = await FirebaseService.instance.db
        .collection('users')
        .doc(partnerId)
        .get();
    if (partnerDoc.exists) {
      _partner = User.fromJson(partnerDoc.data()!);
      notifyListeners();
    }
  }

  void subscribeToMessages() {
    if (_coupleCode == null) return;

    FirebaseService.instance.messagesStream(_coupleCode!).listen((snapshot) {
      _messages = snapshot.docs
          .map((doc) => Message.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
      notifyListeners();
    });
  }

  void subscribeToMedia() {
    if (_coupleCode == null) return;

    FirebaseService.instance.mediaStream(_coupleCode!).listen((snapshot) {
      _media = snapshot.docs
          .map(
              (doc) => SharedMedia.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
      notifyListeners();
    });
  }

  void subscribeToCalls() {
    if (_coupleCode == null) return;

    FirebaseService.instance.callsStream(_coupleCode!).listen((snapshot) {
      _calls = snapshot.docs
          .map((doc) => Call.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
      notifyListeners();
    });
  }

  void subscribeToPartnerLocation() {
    if (_coupleCode == null || _partner == null) return;

    FirebaseService.instance.locationStream(_coupleCode!).listen((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        final data = snapshot.docs.first.data() as Map<String, dynamic>;
        if (data['userId'] != _currentUser?.id) {
          _partnerLocation = LocationData.fromJson(data);
          notifyListeners();
        }
      }
    });
  }

  Future<void> sendMessage(String content) async {
    if (_coupleCode == null || _currentUser == null) return;

    final message = Message(
      senderId: _currentUser!.id,
      receiverId: _partner!.id,
      type: MessageType.text,
      content: content,
      status: MessageStatus.sent,
    );

    await FirebaseService.instance.sendMessage(_coupleCode!, message);
  }

  Future<void> sendLocation(LocationData location) async {
    if (_coupleCode == null || _currentUser == null) return;

    await FirebaseService.instance
        .updateLocation(_coupleCode!, _currentUser!.id, location);
  }

  Future<void> addCall(Call call) async {
    if (_coupleCode == null) return;

    await FirebaseService.instance.addCall(_coupleCode!, call);
  }

  Future<void> uploadMedia(String filePath, String type) async {
    if (_coupleCode == null || _currentUser == null) return;

    final url = await FirebaseService.instance
        .uploadMedia(_coupleCode!, filePath, type);
    final media = SharedMedia(
      uploaderId: _currentUser!.id,
      type: type,
      url: url,
    );

    await FirebaseService.instance.addMedia(_coupleCode!, media);
  }
}
