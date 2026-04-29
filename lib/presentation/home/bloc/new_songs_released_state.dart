import 'package:spotify_app/domain/entities/song/song.dart';

abstract class NewSongsReleasedState {
  const NewSongsReleasedState();
}

class NewSongsReleasedInitial extends NewSongsReleasedState {}

class NewSongsReleasedLoading extends NewSongsReleasedState {}

class NewSongsReleasedLoaded extends NewSongsReleasedState {
  final List<SongEntity> songs;
  NewSongsReleasedLoaded({required this.songs});
}

class NewSongsReleasedError extends NewSongsReleasedState {}
