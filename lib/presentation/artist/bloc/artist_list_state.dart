import 'package:spotify_app/domain/entities/artist/artist.dart';

abstract class ArtistListState {}

class ArtistListInitial extends ArtistListState {}

class ArtistListLoading extends ArtistListState {}

class ArtistListLoaded extends ArtistListState {
  final List<ArtistEntity> artists;

  ArtistListLoaded({required this.artists});
}

class ArtistListLoadFailure extends ArtistListState {}
