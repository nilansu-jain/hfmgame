class UserModel {
  UserModel({
    this.status,
    this.message,
    this.authToken,
    this.user,
    this.gameDetails,
  });

  final String? status;
  final String? message;
  final String? authToken;
  final User? user;
  final GameDetails? gameDetails;

  UserModel copyWith({
    String? status,
    String? message,
    String? authToken,
    User? user,
    GameDetails? gameDetails,
  }) {
    return UserModel(
      status: status ?? this.status,
      message: message ?? this.message,
      authToken: authToken ?? this.authToken,
      user: user ?? this.user,
      gameDetails: gameDetails ?? this.gameDetails,
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json){
    return UserModel(
      status: json["status"],
      message: json["message"],
      authToken: json["auth_token"],
      user: json["user"] == null ? null : User.fromJson(json["user"]),
      gameDetails: json["game_details"] == null ? null : GameDetails.fromJson(json["game_details"]),
    );
  }

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "auth_token": authToken,
    "user": user?.toJson(),
    "game_details": gameDetails?.toJson(),
  };

  @override
  String toString(){
    return "$status, $message, $authToken, $user, $gameDetails, ";
  }
}

class GameDetails {
  GameDetails({
    required this.id,
    required this.gameTitle,
    required this.noOfClips,
    required this.eventDate,
    required this.eventInfo,
    required this.gameName,
    required this.thumbnail,
    required this.status,
    required this.clipLevels,
    required this.decades,
  });

  final int? id;
  final String? gameTitle;
  final num? noOfClips;
  final dynamic eventDate;
  final String? eventInfo;
  final String? gameName;
  final String? thumbnail;
  final num? status;
  final String? clipLevels;
  final String? decades;

  GameDetails copyWith({
    int? id,
    String? gameTitle,
    num? noOfClips,
    dynamic? eventDate,
    String? eventInfo,
    String? gameName,
    String? thumbnail,
    num? status,
    String? clipLevels,
    String? decades,
  }) {
    return GameDetails(
      id: id ?? this.id,
      gameTitle: gameTitle ?? this.gameTitle,
      noOfClips: noOfClips ?? this.noOfClips,
      eventDate: eventDate ?? this.eventDate,
      eventInfo: eventInfo ?? this.eventInfo,
      gameName: gameName ?? this.gameName,
      thumbnail: thumbnail ?? this.thumbnail,
      status: status ?? this.status,
      clipLevels: clipLevels ?? this.clipLevels,
      decades: decades ?? this.decades,
    );
  }

  factory GameDetails.fromJson(Map<String, dynamic> json){
    return GameDetails(
      id: json["id"],
      gameTitle: json["game_title"],
      noOfClips: json["noOfClips"],
      eventDate: json["event_date"],
      eventInfo: json["event_info"],
      gameName: json["game_name"],
      thumbnail: json["thumbnail"],
      status: json["status"],
      clipLevels: json["clipLevels"],
      decades: json["decades"],
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "game_title": gameTitle,
    "noOfClips": noOfClips,
    "event_date": eventDate,
    "event_info": eventInfo,
    "game_name": gameName,
    "thumbnail": thumbnail,
    "status": status,
    "clipLevels": clipLevels,
    "decades": decades,
  };

  @override
  String toString(){
    return "$id, $gameTitle, $noOfClips, $eventDate, $eventInfo, $gameName, $thumbnail, $status, $clipLevels, $decades, ";
  }
}

class User {
  User({
    required this.id,
    required this.userName,
    required this.email,
    required this.gameCode,
    required this.profilePhoto,
    required this.authToken,
    required this.createdAt,
    required this.updatedAt,
  });

  final int? id;
  final String? userName;
  final String? email;
  final String? gameCode;
  final String? profilePhoto;
  final String? authToken;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  User copyWith({
    int? id,
    String? userName,
    String? email,
    String? gameCode,
    String? profilePhoto,
    String? authToken,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      userName: userName ?? this.userName,
      email: email ?? this.email,
      gameCode: gameCode ?? this.gameCode,
      profilePhoto: profilePhoto ?? this.profilePhoto,
      authToken: authToken ?? this.authToken,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory User.fromJson(Map<String, dynamic> json){
    return User(
      id: json["id"],
      userName: json["user_name"],
      email: json["email"],
      gameCode: json["game_code"],
      profilePhoto: json["profile_photo"],
      authToken: json["auth_token"],
      createdAt: DateTime.tryParse(json["created_at"] ?? ""),
      updatedAt: DateTime.tryParse(json["updated_at"] ?? ""),
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "user_name": userName,
    "email": email,
    "game_code": gameCode,
    "profile_photo": profilePhoto,
    "auth_token": authToken,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
  };

  @override
  String toString(){
    return "$id, $userName, $email, $gameCode, $profilePhoto, $authToken, $createdAt, $updatedAt, ";
  }
}
