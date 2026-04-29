import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotify_app/domain/entities/song/song.dart';
import 'package:spotify_app/domain/usecases/song/get_search_list_usecase.dart';
import 'package:spotify_app/presentation/search/bloc/search_list_state.dart';
import 'package:spotify_app/service_locator.dart';

class SearchListCubit extends Cubit<SearchListState> {
  SearchListCubit() : super(SearchListInitial());

  // Future<void> getPlayList() async {
  //   emit(PlayListLoading());

  //   final returnedSongs = await sl<GetPlayListUseCase>().call();

  //   returnedSongs.fold((l) => emit(PlayListLoadFailure()), (data) {
  //     if (!isClosed) {
  //       emit(PlayListLoaded(songs: data));
  //     }
  //   });
  // }

  List<SongEntity> _allSongs = []; // Lưu trữ toàn bộ bài hát đã load
  DocumentSnapshot? _lastDoc; // Lưu dấu mốc cuối cùng
  bool _isFetchingMore = false; // Tránh việc gọi load more nhiều lần cùng lúc
  bool _hasMore = true; // Kiểm tra xem còn dữ liệu trong database không

  // 1. Hàm load 10 bài đầu tiên
  Future<void> getPlayList() async {
    if (_isFetchingMore) return;
    _allSongs = [];
    _lastDoc = null;
    _hasMore = true;
    _isFetchingMore = true; // Khóa lại ngay lập tức
    emit(SearchListLoading());

    var result = await sl<GetSearchListUseCase>().call(params: null);

    result.fold(
      (l) {
        _isFetchingMore = false; // Mở khóa khi lỗi
        emit(SearchListLoadFailure());
      },
      (data) {
        // 'data' bây giờ là một Map chứa 'songs' và 'lastDoc'
        _allSongs = data['songs'];
        _lastDoc = data['lastDoc'];
        _isFetchingMore = false; // Mở khóa khi xong
        // Nếu số lượng bài lấy về ít hơn 10, nghĩa là đã hết dữ liệu
        if (_allSongs.length < 10) {
          _hasMore = false;
        }
        if(isClosed) return;
        emit(SearchListLoaded(songs: _allSongs, hasMore: _hasMore));
      },
    );
  }

  // 2. Hàm load thêm 10 bài tiếp theo khi kéo xuống
  Future<void> getMoreSongs() async {
    // Nếu đang load hoặc đã hết dữ liệu thì không làm gì cả
    if (_isFetchingMore || !_hasMore) return;

    _isFetchingMore = true;
    emit(SearchListLoaded(songs: _allSongs, isFetchingMore: true));
    // Gọi UseCase với tham số là _lastDoc hiện tại
    var result = await sl<GetSearchListUseCase>().call(params: _lastDoc);

    result.fold(
      (l) {
        _isFetchingMore = false;
        emit(SearchListLoaded(songs: _allSongs, isFetchingMore: false));
        // Có thể emit một thông báo lỗi nhẹ ở đây nếu muốn
      },
      (data) {
        List<SongEntity> newSongs = data['songs'];
        _lastDoc = data['lastDoc'];
        _isFetchingMore = false;
        if (newSongs.isEmpty) {
          _hasMore = false;

          if (isClosed) return;
          emit(
            SearchListLoaded(
              songs: List.from(_allSongs),
              isFetchingMore: false,
              hasMore: _hasMore,
            ),
          );
        } else {
          // Cộng dồn vào danh sách cũ
          _allSongs.addAll(newSongs);

          // Emit lại state Loaded với danh sách mới (phải dùng List.from để Bloc nhận ra sự thay đổi)
          if (isClosed) return;
          emit(
            SearchListLoaded(
              songs: List.from(_allSongs),
              isFetchingMore: false,
              hasMore: _hasMore,
            ),
          );
        }
      },
    );
  }
}
