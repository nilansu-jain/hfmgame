import 'dart:convert';

class GetGameDataModel {
  Score? score;
  List<Clip>? clips;
  String? gameSound;

  GetGameDataModel({
    this.score,
    this.clips,
    this.gameSound
  });

  GetGameDataModel copyWith({
    Score? score,
    List<Clip>? clips,
    String? gameSound
  }) =>
      GetGameDataModel(
        score: score ?? this.score,
        clips: clips ?? this.clips,
         gameSound: gameSound ?? this.gameSound
      );

  factory GetGameDataModel.fromRawJson(String str) => GetGameDataModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory GetGameDataModel.fromJson(Map<String, dynamic> json) => GetGameDataModel(
    score: json["score"] == null ? null : Score.fromJson(json["score"]),
    clips: json["clips"] == null ? [] : List<Clip>.from(json["clips"]!.map((x) => Clip.fromJson(x))),
    gameSound: json["gameSound"],

  );

  Map<String, dynamic> toJson() => {
    "score": score?.toJson(),
    "clips": clips == null ? [] : List<dynamic>.from(clips!.map((x) => x.toJson())),
    "gameSound": gameSound,

  };
}

class Clip {
  int? clipId;
  String? clipLevel;
  String? clipLength;
  int? timerLength;
  String? clipFileName;
  int? clipOrderNo;
  int? adId;
  int? isDemoClip;
  List<Option>? options;

  Clip({
    this.clipId,
    this.clipLevel,
    this.clipLength,
    this.timerLength,
    this.clipFileName,
    this.clipOrderNo,
    this.adId,
    this.isDemoClip,
    this.options,
  });

  Clip copyWith({
    int? clipId,
    String? clipLevel,
    String? clipLength,
    int? timerLength,
    String? clipFileName,
    int? clipOrderNo,
    int? adId,
    int? isDemoClip,
    List<Option>? options,
  }) =>
      Clip(
        clipId: clipId ?? this.clipId,
        clipLevel: clipLevel ?? this.clipLevel,
        clipLength: clipLength ?? this.clipLength,
        timerLength: timerLength ?? this.timerLength,
        clipFileName: clipFileName ?? this.clipFileName,
        clipOrderNo: clipOrderNo ?? this.clipOrderNo,
        adId: adId ?? this.adId,
        isDemoClip: isDemoClip ?? this.isDemoClip,
        options: options ?? this.options,
      );

  factory Clip.fromRawJson(String str) => Clip.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Clip.fromJson(Map<String, dynamic> json) => Clip(
    clipId: json["clip_id"],
    clipLevel: json["ClipLevel"],
    clipLength: json["ClipLength"],
    timerLength: json["TimerLength"],
    clipFileName: json["ClipFileName"],
    clipOrderNo: json["clip_order_no"],
    adId: json["ad_id"],
    isDemoClip: json["is_demo_clip"],
    options: json["options"] == null ? [] : List<Option>.from(json["options"]!.map((x) => Option.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "clip_id": clipId,
    "ClipLevel": clipLevel,
    "ClipLength": clipLength,
    "TimerLength": timerLength,
    "ClipFileName": clipFileName,
    "clip_order_no": clipOrderNo,
    "ad_id": adId,
    "is_demo_clip": isDemoClip,
    "options": options == null ? [] : List<dynamic>.from(options!.map((x) => x.toJson())),
  };
}

class Option {
  int? id;
  int? clipId;
  String? clipOptionDesc;
  String? clipCorrectOption;

  Option({
    this.id,
    this.clipId,
    this.clipOptionDesc,
    this.clipCorrectOption,
  });

  Option copyWith({
    int? id,
    int? clipId,
    String? clipOptionDesc,
    String? clipCorrectOption,
  }) =>
      Option(
        id: id ?? this.id,
        clipId: clipId ?? this.clipId,
        clipOptionDesc: clipOptionDesc ?? this.clipOptionDesc,
        clipCorrectOption: clipCorrectOption ?? this.clipCorrectOption,
      );

  factory Option.fromRawJson(String str) => Option.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Option.fromJson(Map<String, dynamic> json) => Option(
    id: json["id"],
    clipId: json["clip_id"],
    clipOptionDesc: json["ClipOptionDesc"],
    clipCorrectOption: json["ClipCorrectOption"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "clip_id": clipId,
    "ClipOptionDesc": clipOptionDesc,
    "ClipCorrectOption": clipCorrectOption,
  };
}

class Score {
  int? sa;
  int? re;
  int? ga;
  int? ma;
  int? pa;

  Score({
    this.sa,
    this.re,
    this.ga,
    this.ma,
    this.pa,
  });

  Score copyWith({
    int? sa,
    int? re,
    int? ga,
    int? ma,
    int? pa,
  }) =>
      Score(
        sa: sa ?? this.sa,
        re: re ?? this.re,
        ga: ga ?? this.ga,
        ma: ma ?? this.ma,
        pa: pa ?? this.pa,
      );

  factory Score.fromRawJson(String str) => Score.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Score.fromJson(Map<String, dynamic> json) => Score(
    sa: json["Sa"],
    re: json["Re"],
    ga: json["Ga"],
    ma: json["Ma"],
    pa: json["Pa"],
  );

  Map<String, dynamic> toJson() => {
    "Sa": sa,
    "Re": re,
    "Ga": ga,
    "Ma": ma,
    "Pa": pa,
  };
}
