import 'package:dartz/dartz.dart';
import 'package:spotify_app/data/sources/artist/artist_firebase_service.dart';
import 'package:spotify_app/domain/repository/artist/artist_repository.dart';
import 'package:spotify_app/service_locator.dart';

class ArtistRepositoryImpl implements ArtistRepository {
  @override
  Future<Either> getArtists()async {
    return await sl<ArtistFirebaseService>().getArtists();
    
  }
  
  @override
  Future<Either> getArtistAlbums(String artistId) {
    return sl<ArtistFirebaseService>().getArtistAlbums(artistId);
  }
  

  @override
  Future<Either> getArtistSongs(String artistId) {
    return sl<ArtistFirebaseService>().getArtistSongs(artistId);
  }
}
