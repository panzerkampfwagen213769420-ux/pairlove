import 'package:uuid/uuid.dart';

class User {
  final String id;
  final String nickname;
  final String? avatarUrl;
  final String? partnerId;
  final String? coupleCode;
  final DateTime? togetherSince;
  final int batteryLevel;
  final bool isUsingPhone;
  final DateTime lastActive;
  final String? mood;
  final DateTime createdAt;

  User({
    String? id,
    required this.nickname,
    this.avatarUrl,
    this.partnerId,
    this.coupleCode,
    this.togetherSince,
    this.batteryLevel = 100,
    this.isUsingPhone = false,
    DateTime? lastActive,
    this.mood,
    DateTime? createdAt,
  })  : id = id ?? const Uuid().v4(),
        lastActive = lastActive ?? DateTime.now(),
        createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'nickname': nickname,
        'avatarUrl': avatarUrl,
        'partnerId': partnerId,
        'coupleCode': coupleCode,
        'togetherSince': togetherSince?.toIso8601String(),
        'batteryLevel': batteryLevel,
        'isUsingPhone': isUsingPhone,
        'lastActive': lastActive.toIso8601String(),
        'mood': mood,
        'createdAt': createdAt.toIso8601String(),
      };

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id'],
        nickname: json['nickname'],
        avatarUrl: json['avatarUrl'],
        partnerId: json['partnerId'],
        coupleCode: json['coupleCode'],
        togetherSince: json['togetherSince'] != null
            ? DateTime.parse(json['togetherSince'])
            : null,
        batteryLevel: json['batteryLevel'] ?? 100,
        isUsingPhone: json['isUsingPhone'] ?? false,
        lastActive: DateTime.parse(json['lastActive']),
        mood: json['mood'],
        createdAt: DateTime.parse(json['createdAt']),
      );

  User copyWith({
    String? nickname,
    String? avatarUrl,
    String? partnerId,
    String? coupleCode,
    DateTime? togetherSince,
    int? batteryLevel,
    bool? isUsingPhone,
    String? mood,
  }) =>
      User(
        id: id,
        nickname: nickname ?? this.nickname,
        avatarUrl: avatarUrl ?? this.avatarUrl,
        partnerId: partnerId ?? this.partnerId,
        coupleCode: coupleCode ?? this.coupleCode,
        togetherSince: togetherSince ?? this.togetherSince,
        batteryLevel: batteryLevel ?? this.batteryLevel,
        isUsingPhone: isUsingPhone ?? this.isUsingPhone,
        lastActive: lastActive,
        mood: mood ?? this.mood,
        createdAt: createdAt,
      );

  int get daysTogether {
    if (togetherSince == null) return 0;
    return DateTime.now().difference(togetherSince!).inDays;
  }
}

enum MessageType { text, image, video, audio, location }

enum MessageStatus { sending, sent, delivered, read }

class Message {
  final String id;
  final String senderId;
  final String receiverId;
  final MessageType type;
  final String content;
  final String? mediaUrl;
  final MessageStatus status;
  final DateTime timestamp;
  final Map<String, String>? reactions;
  final bool isEncrypted;

  Message({
    String? id,
    required this.senderId,
    required this.receiverId,
    required this.type,
    required this.content,
    this.mediaUrl,
    this.status = MessageStatus.sending,
    DateTime? timestamp,
    this.reactions,
    this.isEncrypted = true,
  })  : id = id ?? const Uuid().v4(),
        timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'senderId': senderId,
        'receiverId': receiverId,
        'type': type.name,
        'content': content,
        'mediaUrl': mediaUrl,
        'status': status.name,
        'timestamp': timestamp.toIso8601String(),
        'reactions': reactions,
        'isEncrypted': isEncrypted,
      };

  factory Message.fromJson(Map<String, dynamic> json) => Message(
        id: json['id'],
        senderId: json['senderId'],
        receiverId: json['receiverId'],
        type: MessageType.values.byName(json['type']),
        content: json['content'],
        mediaUrl: json['mediaUrl'],
        status: MessageStatus.values.byName(json['status']),
        timestamp: DateTime.parse(json['timestamp']),
        reactions: json['reactions'] != null
            ? Map<String, String>.from(json['reactions'])
            : null,
        isEncrypted: json['isEncrypted'] ?? true,
      );

  Message copyWith({
    MessageStatus? status,
    Map<String, String>? reactions,
  }) =>
      Message(
        id: id,
        senderId: senderId,
        receiverId: receiverId,
        type: type,
        content: content,
        mediaUrl: mediaUrl,
        status: status ?? this.status,
        timestamp: timestamp,
        reactions: reactions ?? this.reactions,
        isEncrypted: isEncrypted,
      );
}

enum CallType { voice, video }

enum CallStatus { calling, ringing, connected, ended, missed, declined }

class Call {
  final String id;
  final String callerId;
  final String receiverId;
  final CallType type;
  final CallStatus status;
  final DateTime startTime;
  final DateTime? endTime;
  final int? duration;

  Call({
    String? id,
    required this.callerId,
    required this.receiverId,
    required this.type,
    this.status = CallStatus.calling,
    DateTime? startTime,
    this.endTime,
    this.duration,
  })  : id = id ?? const Uuid().v4(),
        startTime = startTime ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'callerId': callerId,
        'receiverId': receiverId,
        'type': type.name,
        'status': status.name,
        'startTime': startTime.toIso8601String(),
        'endTime': endTime?.toIso8601String(),
        'duration': duration,
      };

  factory Call.fromJson(Map<String, dynamic> json) => Call(
        id: json['id'],
        callerId: json['callerId'],
        receiverId: json['receiverId'],
        type: CallType.values.byName(json['type']),
        status: CallStatus.values.byName(json['status']),
        startTime: DateTime.parse(json['startTime']),
        endTime:
            json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
        duration: json['duration'],
      );

  Call copyWith({
    CallStatus? status,
    DateTime? endTime,
    int? duration,
  }) =>
      Call(
        id: id,
        callerId: callerId,
        receiverId: receiverId,
        type: type,
        status: status ?? this.status,
        startTime: startTime,
        endTime: endTime ?? this.endTime,
        duration: duration ?? this.duration,
      );
}

class LocationData {
  final double latitude;
  final double longitude;
  final double? speed;
  final double? direction;
  final DateTime timestamp;
  final int? accuracy;
  final String? address;

  LocationData({
    required this.latitude,
    required this.longitude,
    this.speed,
    this.direction,
    DateTime? timestamp,
    this.accuracy,
    this.address,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'latitude': latitude,
        'longitude': longitude,
        'speed': speed,
        'direction': direction,
        'timestamp': timestamp.toIso8601String(),
        'accuracy': accuracy,
        'address': address,
      };

  factory LocationData.fromJson(Map<String, dynamic> json) => LocationData(
        latitude: json['latitude'],
        longitude: json['longitude'],
        speed: json['speed'],
        direction: json['direction'],
        timestamp: DateTime.parse(json['timestamp']),
        accuracy: json['accuracy'],
        address: json['address'],
      );

  String get speedString {
    if (speed == null || speed! < 0) return '0 km/h';
    return '${speed!.toStringAsFixed(1)} km/h';
  }

  String get directionString {
    if (direction == null) return 'N';
    if (direction! >= 337.5 || direction! < 22.5) return 'N';
    if (direction! >= 22.5 && direction! < 67.5) return 'NE';
    if (direction! >= 67.5 && direction! < 112.5) return 'E';
    if (direction! >= 112.5 && direction! < 157.5) return 'SE';
    if (direction! >= 157.5 && direction! < 202.5) return 'S';
    if (direction! >= 202.5 && direction! < 247.5) return 'SW';
    if (direction! >= 247.5 && direction! < 292.5) return 'W';
    return 'NW';
  }
}

class SharedMedia {
  final String id;
  final String uploaderId;
  final String type;
  final String url;
  final String? thumbnail;
  final DateTime uploadedAt;
  final String? caption;

  SharedMedia({
    String? id,
    required this.uploaderId,
    required this.type,
    required this.url,
    this.thumbnail,
    DateTime? uploadedAt,
    this.caption,
  })  : id = id ?? const Uuid().v4(),
        uploadedAt = uploadedAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'uploaderId': uploaderId,
        'type': type,
        'url': url,
        'thumbnail': thumbnail,
        'uploadedAt': uploadedAt.toIso8601String(),
        'caption': caption,
      };

  factory SharedMedia.fromJson(Map<String, dynamic> json) => SharedMedia(
        id: json['id'],
        uploaderId: json['uploaderId'],
        type: json['type'],
        url: json['url'],
        thumbnail: json['thumbnail'],
        uploadedAt: DateTime.parse(json['uploadedAt']),
        caption: json['caption'],
      );
}
