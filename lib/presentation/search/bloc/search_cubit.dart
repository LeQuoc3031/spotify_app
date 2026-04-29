// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotify_app/domain/entities/song/song.dart';
import 'package:spotify_app/domain/usecases/song/get_search_list_usecase.dart';
import 'package:spotify_app/presentation/search/bloc/search_state.dart';
import 'package:spotify_app/service_locator.dart';

class SearchSongCubit extends Cubit<SearchSongState> {
  SearchSongCubit() : super(SearchSongInitial());
  List<SongEntity> _allSongs = [];
  List<SongEntity> _filteredSongs = [];
  String searchId = '';
  TextEditingController searchController = TextEditingController();
  DocumentSnapshot? _lastDoc;
  bool _isFetchingMore = false;
  bool _hasMore = true;

  void searchSong(String query) async {
    if (query.isEmpty) {
      emit(SearchSongInitial());
      return;
    }
    if (_isFetchingMore) return;
    _allSongs = [];
    _lastDoc = null;
    _hasMore = true;
    _isFetchingMore = true;
    emit(SearchSongLoading());
    try {
      // Giả sử bạn lấy toàn bộ bài hát từ Firebase hoặc một Repo
      // Sau đó filter local dựa trên query
      var result = await sl<GetSearchListUseCase>().call(
        params: null,
      ); // Hoặc repo của bạn

      result.fold(
        (l) {
          _isFetchingMore = false;
          emit(SearchSongError());
        },
        (data) {
          _allSongs = data['songs'];
          _lastDoc = data['lastDoc'];
          _isFetchingMore = false;
          if (_allSongs.length < 10) {
            _hasMore = false;
          }
          _filteredSongs = _allSongs
              .where(
                (song) =>
                    song.title.toLowerCase().contains(query.toLowerCase()) ||
                    song.artist.toLowerCase().contains(query.toLowerCase()),
              )
              .toList();

          emit(SearchSongLoaded(songs: _filteredSongs, hasMore: _hasMore));
        },
      );
    } catch (e) {
      emit(SearchSongError());
    }
  }

  Future<void> getMoreSongs() async {
    // Nếu đang load hoặc đã hết dữ liệu thì không làm gì cả
    if (_isFetchingMore || !_hasMore) return;

    _isFetchingMore = true;
    emit(SearchSongLoaded(songs: _filteredSongs, isFetchingMore: true));
    // Gọi UseCase với tham số là _lastDoc hiện tại
    var result = await sl<GetSearchListUseCase>().call(params: _lastDoc);

    result.fold(
      (l) {
        _isFetchingMore = false;
        emit(SearchSongLoaded(songs: _filteredSongs, isFetchingMore: false));
        // Có thể emit một thông báo lỗi nhẹ ở đây nếu muốn
      },
      (data) {
        List<SongEntity> newSongs = data['songs'];
        _lastDoc = data['lastDoc'];
        _isFetchingMore = false;
        if (newSongs.isEmpty) {
          _hasMore = false;
          emit(
            SearchSongLoaded(
              songs: List.from(_filteredSongs),
              isFetchingMore: false,
              hasMore: _hasMore,
            ),
          );
        } else {
          // Cộng dồn vào danh sách cũ
          final filteredNewSongs = newSongs
              .where(
                (song) =>
                    song.title.toLowerCase().contains(searchId.toLowerCase()) ||
                    song.artist.toLowerCase().contains(searchId.toLowerCase()),
              )
              .toList();
          _filteredSongs.addAll(filteredNewSongs);

          // Emit lại state Loaded với danh sách mới (phải dùng List.from để Bloc nhận ra sự thay đổi)
          emit(
            SearchSongLoaded(
              songs: List.from(_filteredSongs),
              isFetchingMore: false,
              hasMore: _hasMore,
            ),
          );
        }
      },
    );
  }
}
