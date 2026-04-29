import 'package:spotify_app/domain/entities/artist/artist.dart';

abstract class ArtistSearchState {}
class ArtistSearchInitial extends ArtistSearchState {}
class ArtistSearchLoading extends ArtistSearchState {}
class ArtistSearchLoaded extends ArtistSearchState {
  final List<ArtistEntity> artists;
  ArtistSearchLoaded({required this.artists});
}
class ArtistSearchError extends ArtistSearchState {}