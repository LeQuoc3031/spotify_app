import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:spotify_app/domain/entities/playlist/play_list.dart';

class PlayListModel extends PlayListEntity {
  PlayListModel({
    required super.playlistId,
    required super.title,
    required super.creatorId,
    required super.songs,
    required super.createdAt,
  });

  // Chuyển từ Firebase Map sang Model
  factory PlayListModel.fromJson(Map<String, dynamic> json) {
    return PlayListModel(
      playlistId: json['playlistId'],
      title: json['title'],
      creatorId: json['creatorId'],
      songs: List<String>.from(json['songs'] ?? []),
      createdAt: json['createdAt'],
    );
  }

  // Chuyển từ Entity sang Model
  factory PlayListModel.fromEntity(PlayListEntity entity) {
    return PlayListModel(
      playlistId: entity.playlistId,
      title: entity.title,
      creatorId: entity.creatorId,
      songs: entity.songs,
      createdAt: entity.createdAt,
    );
  }
  // Chuyển từ Model sang Map để đẩy lên Firebase
  Map<String, dynamic> toJson() {
    return {
      'playlistId': playlistId,
      'title': title,
      'creatorId': creatorId,
      'songs': songs,
      'createdAt': createdAt,
    };
  }

  @override
  PlayListModel copyWith({
    String? playlistId,
    String? title,
    String? creatorId,
    List<String>? songs,
    Timestamp? createdAt,
  }) {
    return PlayListModel(
      playlistId: playlistId ?? this.playlistId,
      title: title ?? this.title,
      creatorId: creatorId ?? this.creatorId,
      songs: songs ?? this.songs,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
