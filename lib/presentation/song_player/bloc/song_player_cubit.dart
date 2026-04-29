// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';
import 'package:spotify_app/common/helpers/parse_lyrics.dart';
import 'package:spotify_app/core/configs/constants/app_urls.dart';
import 'package:spotify_app/data/models/lyric/lyric.dart';
import 'package:spotify_app/domain/entities/song/song.dart';
import 'package:spotify_app/domain/usecases/song/add_recently_played_usecase.dart';
import 'package:spotify_app/presentation/song_player/bloc/song_player_state.dart';
import 'package:spotify_app/service_locator.dart';

// class SongPlayerCubit extends Cubit<SongPlayerState> {
//   AudioPlayer audioPlayer = AudioPlayer();
//   Duration songDuration = Duration.zero;
//   Duration songtPosition = Duration.zero;
//   List<LyricModel> lyricSong = <LyricModel>[];
//   int currentLyricIndex = 0;
//   List<SongEntity> songs = [];
//   SongEntity? currentSong;
//   int currentIndexSongs = 0;
//   StreamSubscription? _positionSubscription;
//   StreamSubscription? _durationSubscription;
//   StreamSubscription? _playerStateSubscription;
//   bool isRepeateSong = false;

//   SongPlayerCubit() : super(SongPlayerInitial()) {
//     _playerStateSubscription = audioPlayer.playerStateStream.listen((
//       playerState,
//     ) {
//       if (playerState.processingState == ProcessingState.completed) {
//         // Khi kết thúc bài hát:
//         // 1. Đưa vị trí nhạc về 0
//         audioPlayer.seek(Duration.zero);
//         // 2. Tạm dừng phát nhạc

//         if (isRepeateSong) {
//           print('Bài hát đã được phát lại');
//           audioPlayer.play();
//         } else {
//           print('Bài hát đã kết thúc ');
//           audioPlayer.stop();
//         }

//         // 3. Cập nhật State để UI chuyển sang trạng thái Stop/Play icon
//         // Đảm bảo songPosition được reset về zero để Slider quay lại đầu
//         songtPosition = Duration.zero;
//         emit(
//           SongPlayerLoaded(
//             lyrics: lyricSong,
//             songEntity: currentSong,
//             currentLyricIndex: 0,
//             isPlaying: true, // Tự động đổi icon sang Play
//           ),
//         );
//       }
//     });
//   }

//   void updateSongPlayer() {
//     emit(
//       SongPlayerLoaded(
//         lyrics: lyricSong,
//         songEntity: currentSong,
//         currentLyricIndex: currentLyricIndex,
//         isPlaying: audioPlayer.playing,
//       ),
//     );
//   }

//   Future<void> loadSongs(List<SongEntity> songList, int index) async {
//     songs = songList;
//     currentSong = songs[currentIndexSongs];
//     currentIndexSongs = index;
//     await _startPlay(songs[currentIndexSongs]);
//   }

//   Future<void> _startPlay(SongEntity song) async {
//     print(
//       '${AppUrls.songFirestorage}${song.artist} - ${song.title}.mp3?${AppUrls.mediaAlt}',
//     );
//     try {
//       emit(SongPlayerLoading());

//       // Reset các stream cũ trước khi sang bài mới
//       await _positionSubscription?.cancel();
//       print('cancel position');
//       await _durationSubscription?.cancel();
//       print('cancel duration');
//       await audioPlayer.setUrl(
//         '${AppUrls.songFirestorage}${song.artist} - ${song.title}.mp3?${AppUrls.mediaAlt}',
//       );

//       _durationSubscription = audioPlayer.durationStream.listen((duration) {
//         if (duration != null && !isClosed) {
//           songDuration = duration;
//         }
//       });

//       _positionSubscription = audioPlayer.positionStream.listen((position) {
//         songtPosition = position;
//         _updateLyricIndex(position, song);
//         emit(
//           SongPlayerLoaded(
//             lyrics: lyricSong,
//             songEntity: song,
//             currentLyricIndex: currentLyricIndex,
//             isPlaying: audioPlayer.playing,
//           ),
//         );
//       });

//       emit(
//         SongPlayerLoaded(
//           lyrics: lyricSong,
//           songEntity: song,
//           isPlaying: audioPlayer.playing,
//           currentLyricIndex: currentIndexSongs, // Reset lyric index về 0
//         ),
//       );
//     } catch (e) {
//       emit(SongPlayerFailure());
//     }
//   }

//   void nextSong() {
//     if (currentIndexSongs < songs.length - 1) {
//       currentIndexSongs++;
//       _startPlay(songs[currentIndexSongs]);
//     }
//   }

//   void previousSong() {
//     if (currentIndexSongs > 0) {
//       currentIndexSongs--;
//       _startPlay(songs[currentIndexSongs]);
//     }
//   }

//   void repeateSong() {
//     isRepeateSong = !isRepeateSong;
//     print('isRepeateSong $isRepeateSong');
//     // emit(
//     //   SongPlayerLoaded(
//     //     lyrics: lyricSong,
//     //     songEntity: currentSong,
//     //     currentLyricIndex: currentLyricIndex,
//     //     isPlaying: audioPlayer.playing,
//     //   ),
//     // );
//   }

//   ////////////////////

//   void playOrPauseSong(SongEntity songEntity) {
//     if (audioPlayer.playing) {
//       audioPlayer.pause();
//     } else {
//       // Nếu bài hát đã kết thúc, đảm bảo bắt đầu lại từ 0
//       if (audioPlayer.processingState == ProcessingState.completed) {
//         audioPlayer.seek(Duration.zero);
//       }
//       audioPlayer.play();
//     }
//     emit(
//       SongPlayerLoaded(
//         lyrics: lyricSong,
//         songEntity: songEntity,
//         currentLyricIndex: currentLyricIndex,
//         isPlaying: !audioPlayer.playing,
//       ),
//     );
//   }

//   // 1. Hàm tải Lyric từ Firebase bằng Firebase SDK hoặc http
//   Future<void> loadLyrics(String url, SongEntity songEntity) async {
//     try {
//       final response = await http.get(Uri.parse(url));
//       if (response.statusCode == 200) {
//         final lyrics = parseLyrics(utf8.decode(response.bodyBytes));
//         lyricSong = lyrics;
//         if (!isClosed) {
//           emit(
//             SongPlayerLoaded(
//               lyrics: lyrics,
//               songEntity: songEntity,
//               currentLyricIndex: currentLyricIndex,
//               isPlaying: audioPlayer.playing,
//             ),
//           );
//         }
//       }
//     } catch (e) {
//       print("Lỗi tải lyric: $e");
//     }
//   }

//   void _updateLyricIndex(Duration position, SongEntity songEntity) {
//     if (state is SongPlayerLoaded) {
//       final loadedState = state as SongPlayerLoaded;
//       int index = loadedState.lyrics.lastIndexWhere(
//         (l) => l.startTime <= position,
//       );
//       currentLyricIndex = index == -1 ? 0 : index;
//       if (index != -1 && index != loadedState.currentLyricIndex) {
//         emit(
//           SongPlayerLoaded(
//             lyrics: lyricSong,
//             songEntity: songEntity,
//             currentLyricIndex: currentLyricIndex,
//             isPlaying: audioPlayer.playing,
//           ),
//         );
//       }
//     }
//   }

//   @override
//   Future<void> close() {
//     _positionSubscription?.cancel();
//     _durationSubscription?.cancel();
//     _playerStateSubscription?.cancel();
//     audioPlayer.dispose();
//     return super.close();
//   }
// }

class SongPlayerCubit extends Cubit<SongPlayerState> {
  AudioPlayer audioPlayer = AudioPlayer();

  // Lưu trữ playlist hiện tại để tránh load lại vô ích
  List<SongEntity> songs = [];
  int currentIndexSongs = 0;
  List<LyricModel> lyricSong = <LyricModel>[];
  int currentLyricIndex = 0;
  SongEntity? currentSong;
  Duration songDuration = Duration.zero;
  Duration songtPosition = Duration.zero;
  // Các subscription để lắng nghe dữ liệu
  StreamSubscription? _positionSubscription;
  StreamSubscription? _durationSubscription;
  StreamSubscription? _sequenceSubscription;
  StreamSubscription? _processingStateStream;
  StreamSubscription? _currentIndexStream;

  bool isRepeate = false;
  bool isShuffle = false;
  String currentPlayListId = '';
  String? _lastSavedSongId;
  SongPlayerCubit() : super(SongPlayerInitial()) {
    _setupAudioPlayerListeners();
  }

  // Thiết lập lắng nghe các sự kiện của Player nga
  //y từ đầu
  void _setupAudioPlayerListeners() async {
    _processingStateStream = audioPlayer.processingStateStream.listen((
      processingState,
    ) {
      if (processingState == ProcessingState.loading) {
        // Trường hợp này là đang tải bài hát mới hoàn toàn -> Hiện Loading
        emit(SongPlayerLoading());
      } else if (processingState == ProcessingState.buffering) {
        // CHỖ QUAN TRỌNG:
        // Nếu app ĐÃ LOAD XONG (đang ở màn hình Player) thì KHÔNG emit Loading nữa
        // để tránh bị đơ/nháy màn hình khi nhấn Repeat hoặc mạng hơi lag.
        if (state is! SongPlayerLoaded) {
          emit(SongPlayerLoading());
        }
      } else if (processingState == ProcessingState.ready) {
        if (currentSong != null) {
          _emitLoadedState();
        }
      }
    });
    // 1. Lắng nghe thay đổi bài hát trong Playlist
    _sequenceSubscription = audioPlayer.sequenceStateStream.listen((
      sequenceState,
    ) {
      if (sequenceState != null) {
        final currentSource = sequenceState.currentSource;
        if (currentSource != null) {
          // Lấy object SongEntity từ tag chúng ta đã gắn lúc load
          final song = currentSource.tag as SongEntity;
          currentIndexSongs = sequenceState.currentIndex;

          // Mỗi khi đổi bài, load lại lyric cho bài mới
          if (currentSong?.title != song.title) {
            _onSongChanged(song);
          }
        }
      }
    });

    audioPlayer.playingStream.listen((playing) {
      if (state is SongPlayerLoaded) {
        updateSongPlayer();
      }
    });

    // 2. Lắng nghe vị trí (Position) để chạy Lyric
    _positionSubscription = audioPlayer.positionStream.listen((position) {
      // songtPosition = position;
      // print('position: $songtPosition');
      // _updateLyricIndex(position);
      // final s = state as SongPlayerLoaded;
      // emit(s.copyWith()); // Emit lại state cũ để trigger UI rebuild

      if (state is SongPlayerLoaded) {
        songtPosition = position;
        _updateLyricIndex(position);

        // Ép kiểu an toàn sau khi đã check 'is'
        final s = state as SongPlayerLoaded;
        emit(s.copyWith());
      }
    });

    _durationSubscription = audioPlayer.durationStream.listen((duration) {
      if (duration != null && !isClosed) {
        songDuration = duration;
        if (state is SongPlayerLoaded) {
          emit((state as SongPlayerLoaded).copyWith());
        }
        // emit((state as SongPlayerLoaded).copyWith(songDuration: d));
      }
    });

    // 3. Lắng nghe trạng thái kết thúc (Sửa lại phần Repeat của bạn)
    audioPlayer.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        // just_audio đã có chế độ LoopMode nên không cần check thủ công nhiều
        print('Bài hát đã kết thúc hoàn toàn');

        // Đưa kim nhạc về 0 để slider quay lại đầu
        audioPlayer.seek(Duration.zero);
        audioPlayer.stop();

        // Cập nhật UI
        emit(
          SongPlayerLoaded(
            lyrics: lyricSong,
            songEntity: currentSong,
            currentLyricIndex: 0,
            isPlaying: false, // Chắc chắn là false vì đã stop
          ),
        );
      }
    });
  }

  void _emitLoadedState() {
    emit(
      SongPlayerLoaded(
        lyrics: lyricSong,
        songEntity: currentSong,
        currentLyricIndex: currentLyricIndex,
        isPlaying: audioPlayer.playing,
      ),
    );
  }

  // Hàm chính để nạp nhạc
  Future<void> loadSongs(
    List<SongEntity> songList,
    int index,
    String newPlayListId,
  ) async {
    isRepeate = false;
    isShuffle = false;
    audioPlayer.setLoopMode(isRepeate ? LoopMode.one : LoopMode.off);
    audioPlayer.setShuffleModeEnabled(isShuffle);
    // if (_lastSavedSongId == songList[index].songId) return;
    try {
      emit(SongPlayerLoading());

      // Lưu bài hát hiện tại vào Recently Played ngay khi nhấn
      _updateRecentlyPlayed(songList[index]);
      // Kiểm tra nếu id mới khác với id cũ thì mới load lại playlist
      bool isNewPlaylist = currentPlayListId != newPlayListId;
      if (isNewPlaylist) {
        songs = songList;
        currentPlayListId = newPlayListId;
        // BIẾN ĐỔI LIST SANG AUDIO SOURCE CÓ CACHE
        final playlist = ConcatenatingAudioSource(
          useLazyPreparation: true,
          children: songs.map((song) {
            final url =
                '${AppUrls.songFirestorage}${song.artist} - ${song.title}.mp3?${AppUrls.mediaAlt}';

            // ĐÂY LÀ CHỖ CACHE:
            return AudioSource.uri(
              Uri.parse(url),
              tag: song, // Gắn kèm data bài hát vào tag để dùng sau này
            );
          }).toList(),
        );

        await audioPlayer.setAudioSource(
          playlist,
          initialIndex: index,
          initialPosition: Duration.zero,
        );
      } else {
        print(audioPlayer.toString());
        // Nếu cùng playlist, chỉ cần nhảy đến đúng vị trí bài hát đó
        await audioPlayer.seek(Duration.zero, index: index);
      }
      await audioPlayer.setLoopMode(LoopMode.all);

      audioPlayer.play();
      _currentIndexStream = audioPlayer.currentIndexStream.listen((index) {
        if (index != null && index < songs.length) {
          final currentSong = songs[index];
          _updateRecentlyPlayed(currentSong);
        }
      });
    } catch (e) {
      emit(SongPlayerFailure());
    }
  }

  void _onSongChanged(SongEntity song) {
    currentSong = song; // Cập nhật bài hát hiện tại
    currentLyricIndex = 0; // Reset index về đầu
    lyricSong = []; // Clear lyric cũ để tránh hiện nhầm lời bài cũ
    final lyricUrl =
        "${AppUrls.lyricFirestorage}${song.artist} - ${song.title}.lrc.txt?${AppUrls.mediaAlt}";
    loadLyrics(lyricUrl, song);
    // Gọi hàm load lyric từ Firebase của bạn
    // emit(
    //   SongPlayerLoaded(
    //     lyrics: [],
    //     songEntity: song,
    //     currentLyricIndex: 0,
    //     isPlaying: audioPlayer.playing,
    //   ),
    // );
  }

  // ... Các hàm điều hướng tối ưu bằng lệnh của AudioPlayer ...
  void nextSong() async {
    // Kiểm tra nếu đang ở chế độ lặp 1 bài
    if (audioPlayer.loopMode == LoopMode.one) {
      // Bước 1: Tạm thời chuyển sang lặp tất cả hoặc tắt lặp để có thể "thoát" khỏi bài hiện tại
      await audioPlayer.setLoopMode(LoopMode.all);

      // Bước 2: Nhảy sang bài kế tiếp
      await audioPlayer.seekToNext();

      // Bước 3: Sau khi đã sang bài mới, bật lại chế độ lặp 1 bài cho bài mới này
      await audioPlayer.setLoopMode(LoopMode.one);
    } else {
      // Nếu không lặp 1 bài thì cứ nhấn Next bình thường
      await audioPlayer.seekToNext();
    }
  }

  void previousSong() async {
    if (audioPlayer.loopMode == LoopMode.one) {
      // Bước 1: Tạm thời chuyển sang lặp tất cả hoặc tắt lặp để có thể "thoát" khỏi bài hiện tại
      await audioPlayer.setLoopMode(LoopMode.all);

      // Bước 2: Nhảy sang bài trước đó
      await audioPlayer.seekToPrevious();

      // Bước 3: Sau khi đã sang bài mới, bật lại chế độ lặp 1 bài cho bài mới này
      await audioPlayer.setLoopMode(LoopMode.one);
    } else {
      // Nếu không lặp 1 bài thì cứ nhấn Previous bình thường
      await audioPlayer.seekToPrevious();
    }
  }

  void repeateSong() {
    isRepeate = !isRepeate;
    // Sử dụng tính năng có sẵn của thư viện cực tiện lợi
    audioPlayer.setLoopMode(isRepeate ? LoopMode.one : LoopMode.off);
    if (state is SongPlayerLoaded) {
      emit((state as SongPlayerLoaded).copyWith());
    }
  }

  void shuffleSong() {
    isShuffle = !isShuffle;
    audioPlayer.setShuffleModeEnabled(isShuffle);
    if (isShuffle) audioPlayer.shuffle();

    if (state is SongPlayerLoaded) {
      emit((state as SongPlayerLoaded).copyWith());
    }
  }

  void playOrPauseSong(SongEntity songEntity) {
    if (audioPlayer.playing) {
      audioPlayer.pause();
    } else {
      audioPlayer.play();
    }
    updateSongPlayer();
  }

  void updateSongPlayer() {
    // if (state is SongPlayerLoaded) {
    //   final s = state as SongPlayerLoaded;
    //   emit(s.copyWith(isPlaying: audioPlayer.playing));
    // }

    final currentState = state; // Lưu vào biến cục bộ để ổn định kiểu dữ liệu
    if (currentState is SongPlayerLoaded) {
      emit(currentState.copyWith(isPlaying: audioPlayer.playing));
    }
  }

  void _updateLyricIndex(Duration position) {
    // Chỉ xử lý nếu State hiện tại đã load xong và có lyric
    if (state is SongPlayerLoaded && lyricSong.isNotEmpty) {
      final loadedState = state as SongPlayerLoaded;

      // Tìm index cuối cùng mà thời gian bắt đầu nhỏ hơn hoặc bằng vị trí hiện tại
      int index = lyricSong.lastIndexWhere((l) => l.startTime <= position);

      // Nếu không tìm thấy thì mặc định là 0
      index = index == -1 ? 0 : index;

      // QUAN TRỌNG: Chỉ emit khi index thực sự thay đổi để tránh lag UI
      if (index != currentLyricIndex) {
        currentLyricIndex = index;

        emit(
          SongPlayerLoaded(
            lyrics: lyricSong,
            songEntity:
                currentSong ??
                loadedState.songEntity, // Lấy từ biến member hoặc state cũ
            currentLyricIndex: currentLyricIndex,
            isPlaying: audioPlayer.playing,
          ),
        );
      }
    }
  }

  Future<void> loadLyrics(String url, SongEntity songEntity) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final lyrics = parseLyrics(utf8.decode(response.bodyBytes));
        lyricSong = lyrics;
        if (!isClosed) {
          emit(
            SongPlayerLoaded(
              lyrics: lyrics,
              songEntity: songEntity,
              currentLyricIndex: currentLyricIndex,
              isPlaying: audioPlayer.playing,
            ),
          );
        }
      }
    } catch (e) {
      print("Lỗi tải lyric: $e");
    }
  }

  Future<void> _updateRecentlyPlayed(SongEntity song) async {
    // Nếu bài hát định lưu trùng với bài vừa lưu xong thì bỏ qua
    if (_lastSavedSongId == song.songId) return;
    _lastSavedSongId = song.songId;
    await sl<AddRecentlyPlayedUseCase>().call(params: song);
  }

  void seek(Duration position) {
    audioPlayer.seek(position);
  }

  // void stop() async {
  //   audioPlayer.stop();
  //   emit(SongPlayerInitial());
  // }

  @override
  Future<void> close() {
    _positionSubscription?.cancel();
    _durationSubscription?.cancel();
    _sequenceSubscription?.cancel();
    audioPlayer.dispose();
    return super.close();
  }

  Future<void> resetPlayer() async {
    // 1. Dừng và hủy hoàn toàn đối tượng máy phát cũ
    currentPlayListId = '';
    await audioPlayer.stop();
    await audioPlayer.dispose();

    await _positionSubscription?.cancel();
    await _durationSubscription?.cancel();
    await _sequenceSubscription?.cancel();
    await _processingStateStream?.cancel();
    await _currentIndexStream?.cancel();

    // 2. Hủy các Subscription trước để tránh lỗi lắng nghe một máy phát đã bị dispose
    // await _positionSubscription?.cancel();
    // _positionSubscription = null;

    // await _durationSubscription?.cancel();
    // _durationSubscription = null;

    // await _sequenceSubscription?.cancel();
    // _sequenceSubscription = null;

    // 3. Khởi tạo một đối tượng máy phát mới hoàn toàn "sạch sẽ"
    // Vì Cubit của bạn ở main, biến audioPlayer sẽ được thay thế bằng cái mới
    audioPlayer = AudioPlayer();
    // 4. Đưa trạng thái về ban đầu
    _setupAudioPlayerListeners();
    emit(SongPlayerInitial());

    print("All music subscriptions have been cancelled.");
  }
}
