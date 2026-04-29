import 'package:spotify_app/domain/entities/playlist/play_list.dart';
import 'package:spotify_app/domain/entities/song/song.dart';

abstract class PlayListState {}

class PlayListInitial extends PlayListState {}

class PlayListLoading extends PlayListState {}

class PlayListLoaded extends PlayListState {
  final List<PlayListEntity> playLists;
  PlayListLoaded({required this.playLists});
}

class PlayListLoadFailure extends PlayListState {}

class AddSongToPlaylistSuccess extends PlayListState {
  final String message;
  AddSongToPlaylistSuccess(this.message);
}

class AddSongToPlaylistFailure extends PlayListState {
  final String errorMessage;
  AddSongToPlaylistFailure(this.errorMessage);
}

class LoadedSongInPlayList extends PlayListState {
  final List<SongEntity> songs;
  LoadedSongInPlayList({required this.songs});
}

class LoadingSongInPlayList extends PlayListState {}

class FailureSongInPlayList extends PlayListState {}
