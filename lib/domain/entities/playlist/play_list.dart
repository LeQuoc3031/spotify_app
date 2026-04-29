import 'package:cloud_firestore/cloud_firestore.dart';

class PlayListEntity {
  final String playlistId;
  final String title;
  final String creatorId;
  final List<String> songs;
  final Timestamp createdAt;

  PlayListEntity({
    required this.playlistId,
    required this.title,
    required this.creatorId,
    required this.songs,
    required this.createdAt,
  });


  PlayListEntity copyWith({
    String? playlistId,
    String? title,
    String? creatorId,
    List<String>? songs,
    Timestamp? createdAt,
  }) {
    return PlayListEntity(
      playlistId: playlistId ?? this.playlistId,
      title: title ?? this.title,
      creatorId: creatorId ?? this.creatorId,
      songs: songs ?? this.songs,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}