import 'package:dartz/dartz.dart';

abstract class ArtistRepository {
  Future<Either> getArtists();
  Future<Either> getArtistAlbums(String artistId);
  Future<Either> getArtistSongs(String artistId);
}
