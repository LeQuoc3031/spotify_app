// ignore_for_file: avoid_print

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotify_app/domain/entities/artist/artist.dart';
import 'package:spotify_app/domain/usecases/artist/get_artist_usecase.dart';
import 'package:spotify_app/presentation/artist/bloc/artist_search_state.dart';
import 'package:spotify_app/service_locator.dart';

class ArtistSearchCubit extends Cubit<ArtistSearchState> {
  ArtistSearchCubit() : super(ArtistSearchInitial());
  List<ArtistEntity> listArtists = [];
  TextEditingController artistSearchController = TextEditingController();
  void searchArtist(String query) async {
    if (query.isEmpty) {
      emit(ArtistSearchInitial());
      return;
    }
    emit(ArtistSearchLoading());
    try {
      // Giả sử bạn lấy toàn bộ ca sí từ Firebase hoặc một Repo
      // Sau đó filter local dựa trên query
      var artists = await sl<GetArtistsUseCase>().call(); 

      artists.fold((l) {}, (data) {
        listArtists = data;

        final filteredArrtists = listArtists
            .where(
              (song) =>
                  song.name.toLowerCase().contains(query.toLowerCase()) ||
                  song.nameVie.toLowerCase().contains(query.toLowerCase()),
            )
            .toList();

        emit(ArtistSearchLoaded(artists: filteredArrtists));
      });
    } catch (e) {
      emit(ArtistSearchError());
    }
  }
}
