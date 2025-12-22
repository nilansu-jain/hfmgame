class FinalScoreModel {
  final int userId;
  final String fullName;
  final int totalScore;
  final String profilePhoto;

  FinalScoreModel({
    required this.userId,
    required this.fullName,
    required this.totalScore,
    required this.profilePhoto,

  });

  factory FinalScoreModel.fromJson(Map<String, dynamic> json) {
    return FinalScoreModel(
      userId: json["user_id"],
      fullName: json["full_name"] ?? "",
      totalScore: json["totalScore"] ?? 0,
      profilePhoto: json["profile_photo"] ?? 0,

    );
  }
}
