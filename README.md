# spotify_app

App này được tạo ra chỉ vì sở thích cá nhân là thích tiếng Trung và nghe nhạc Trung Quốc.
App này một phần làm theo youtube, một phần là sử dụng AI để điều chỉnh theo ý của bản thân,
cho nên app vẫn còn một số lỗi nhỏ.
Source được tổ chức theo kiến trúc Clean Architecture, State Management là Cubit (Bloc)

# <a id="mục-lục"></a>📌 Mục lục

- [📸 App Screenshots](#app-screenshots)
- [🚀 Hướng dẫn thiết lập (Setup)](#hướng-dẫn-thiết-lập-setup)
- [🎬 Demo App](#demo-app)

## <a id="app-screenshots"></a> [📸 App Screenshots](#mục-lục)

### ☀️ Light Mode

<p align="center">
  <table border="0">
    <tr>
        <td><img src="screenshots/light/light_splash.png" width="400"></td>
        <td><img src="screenshots/light/intro.png" width="400"></td>
        <td><img src="screenshots/light/light_choose_mode.png" width="400"></td>
        <td><img src="screenshots/light/light_signin_signup.png" width="400"></td>
    </tr>
    <tr>
        <td align="center">Splash</td>
        <td align="center">Intro</td>
        <td align="center">Choose Mode</td>
        <td align="center">Sign In And Register</td>
    </tr>

  </table>
</p>

<p align="center">
  <table border="0">
    <tr>
        <td><img src="screenshots/light/light_signin.png" width="400"></td>
        <td><img src="screenshots/light/light_register.png" width="400"></td>
        <td><img src="screenshots/light/light_home.png" width="400"></td>
        <td><img src="screenshots/light/light_player.png" width="400"></td>
    </tr>
    <tr>
        <td align="center">Sign In</td>
        <td align="center">Register</td>
        <td align="center">Home</td>
        <td align="center">Player</td>
    </tr>

  </table>
</p>

<p align="center">
  <table border="0">
    <tr>
        <td><img src="screenshots/light/light_lyric.png" width="400"></td>
        <td><img src="screenshots/light/light_search.png" width="400"></td>
        <td><img src="screenshots/light/light_artist.png" width="400"></td>
        <td><img src="screenshots/light/light_profile.png" width="400"></td>
    </tr>
    <tr>
        <td align="center">Lyric</td>
        <td align="center">Search</td>
        <td align="center">Artist</td>
        <td align="center">Profile</td>
    </tr>

  </table>
</p>

<p align="center">
  <table border="0">
    <tr>
        <td><img src="screenshots/light/light_favorite_song.png" width="400"></td>
        <td><img src="screenshots/light/light_playlist.png" width="400"></td>
        <td><img src="screenshots/light/light_album.png" width="400"></td>
        <td><img src="screenshots/light/light_profile_info.png" width="400"></td>
    </tr>
    <tr>
        <td align="center">Favorite Song</td>
        <td align="center">Playlist</td>
        <td align="center">Favorite Album</td>
        <td align="center">Profile Info</td>
    </tr>

  </table>
</p>

---

### 🌑 Dark Mode

<p align="center">
  <table border="0">
    <tr>
        <td><img src="screenshots/dark/dark_splash.png" width="400"></td>
        <td><img src="screenshots/dark/intro.png" width="400"></td>
        <td><img src="screenshots/dark/dark_choose_mode.png" width="400"></td>
        <td><img src="screenshots/dark/dark_signin_signup.png" width="400"></td>
    </tr>
    <tr>
        <td align="center">Splash</td>
        <td align="center">Intro</td>
        <td align="center">Choose Mode</td>
        <td align="center">Sign In And Register</td>
    </tr>

  </table>
</p>

<p align="center">
  <table border="0">
    <tr>
        <td><img src="screenshots/dark/dark_signin.png" width="400"></td>
        <td><img src="screenshots/dark/dark_register.png" width="400"></td>
        <td><img src="screenshots/dark/dark_home.png" width="400"></td>
        <td><img src="screenshots/dark/dark_player.png" width="400"></td>
    </tr>
    <tr>
        <td align="center">Sign In</td>
        <td align="center">Register</td>
        <td align="center">Home</td>
        <td align="center">Player</td>
    </tr>

  </table>
</p>

<p align="center">
  <table border="0">
    <tr>
        <td><img src="screenshots/dark/dark_lyric.png" width="400"></td>
        <td><img src="screenshots/dark/dark_search.png" width="400"></td>
        <td><img src="screenshots/dark/dark_artist.png" width="400"></td>
        <td><img src="screenshots/dark/dark_profile.png" width="400"></td>
    </tr>
    <tr>
        <td align="center">Lyric</td>
        <td align="center">Search</td>
        <td align="center">Artist</td>
        <td align="center">Profile</td>
    </tr>

  </table>
</p>

<p align="center">
  <table border="0">
    <tr>
        <td><img src="screenshots/dark/dark_favorite_song.png" width="400"></td>
        <td><img src="screenshots/dark/dark_playlist.png" width="400"></td>
        <td><img src="screenshots/dark/dark_album.png" width="400"></td>
        <td><img src="screenshots/dark/dark_profile_info.png" width="400"></td>
    </tr>
    <tr>
        <td align="center">Favorite Song</td>
        <td align="center">Playlist</td>
        <td align="center">Favorite Song</td>
        <td align="center">Profile Info</td>
    </tr>

  </table>
</p>

## <a id="hướng-dẫn-thiết-lập-setup"></a> [🚀 Hướng dẫn thiết lập (Setup)](#mục-lục)

### 1. Cấu hình Firebase

Dự án này sử dụng Firebase cho Authentication và Firestore. Để chạy dự án, bạn cần:

1. Tạo một dự án mới trên [Firebase Console](https://console.firebase.google.com/).
2. Cài đặt **FlutterFire CLI**:

   ```bash
   dart pub global activate flutterfire_cli

   ```

3. Cấu hình Firebase cho dự án:
   ```bash
   flutterfire configure
   ```
4. Đảm bảo file lib/firebase_options.dart đã được tạo (file này hiện đang được đưa vào .gitignore để bảo mật).
5. Cài đặt Dependencies
   ```bash
   flutter pub get
   ```
6. Chạy ứng dụng
   ```bash
   flutter run
   ```

### 2. Cấu hình Database

1.  Authentication

    ```
    Trên thanh menu bên trái --> Chọn Authentication -->
    Sign-in method --> Add new provider --> Select Email/Password

    ```

2.  Firestore

    ```
    Tất cả các Collection cần phải tạo
    <p align="center">
      <img src="screenshots/database/all_collection.png" width="1000">
    </p>

        Collection User:
          - Sẽ tự động tạo khi đăng ký
          - Bên trong mỗi user sẽ có 3 subcollection
            * Favorites : tự động tạo khi nhất nút thích bài hát trong app
            * FavoriteAlbums : sẽ tự động tạo khi nhất thích album trong app
            * RecentlyPlayed : sẽ tự động tạo khi nhấn vào nghe một bài hát bất kỳ

    <p align="center">
      <img src="screenshots/database/collection_user.png" width="1000">
    </p>

        Collection Playlists:
          - Sẽ tự động tạo khi tạo một playlist trong app
    ```

<p align="center">
  <img src="screenshots/database/collection_playlist.png" width="1000">
</p>

    Collection Artists:
      - Phải tự nhập thông tin

<p align="center">
  <img src="screenshots/database/collection_artist.png" width="1000">
</p>

    Collection Albums:
      - Phải tự nhập thông tin

<p align="center">
  <img src="screenshots/database/collection_album.png" width="1000">
</p>

    Collection Songs:
      - Phải tự nhập thông tin (Khá nhiều và rất lâu)

<p align="center">
  <img src="screenshots/database/collection_song.png" width="1000">
</p>

3.  Storage

    ```
    Tất cả các Storage cần phải tạo
    <p align="center">
      <img src="screenshots/database/collection_song.png" width="1000">
    </p>

        Mở tab Rules để thiết lập một số quyền hạn
    <p align="center">
      <img src="screenshots/database/rule_storage.png" width="1000">
    </p>

        Storage users:
          - Tạo trước một folder rỗng
          - Dùng để chứa avatar của mỗi user khi đổi avater trong app

    <p align="center">
      <img src="screenshots/database/storage_user.png" width="1000">
    </p>

        Storage artists:
          - Phải tự thêm dữ liệu
          - Tên hình ảnh phải giống với field "artist" của Songs
    <p align="center">
      <img src="screenshots/database/storage_artist.png" width="1000">
    </p>

        Storage albums:
          - Phải tự thêm dữ liệu
          - Tên album phải giống với field "title" của Albums
    <p align="center">
      <img src="screenshots/database/storage_artist.png" width="1000">
    </p>

        Storage covers:
          - Phải tự thêm dữ liệu
          - Tên cover phải đạt theo cấu trúc [artist] - [title].jpg tương ứng với các field trong Songs

    <p align="center">
      <img src="screenshots/database/storage_cover.png" width="1000">
    </p>

        Storage lyrics:
          - Phải tự thêm dữ liệu
          - Tên lyric phải đạt theo cấu trúc [artist] - [title].lrc.txt tương ứng với các field trong Songs

        Bạn muốn tạo file lrc thì dùng [LRC Generator](https://lrcgenerator.com/#google_vignette)

    <p align="center">
      <img src="screenshots/database/storage_lyric.png" width="1000">
    </p>


        Storage songs:
          - Phải tự thêm dữ liệu
          - Tên song phải đạt theo cấu trúc [artist] - [title].mp3 tương ứng với các field trong Songs
    <p align="center">
      <img src="screenshots/database/storage_song.png" width="1000">
    </p>
    ```

### 3. Cấu hình Firebase Storage

Để ứng dụng có dữ liệu nhạc và hình ảnh hiển thị ngay lập tức, bạn cần tải lên các tệp tin mẫu:

1.  **Tải dữ liệu mẫu:** [Tải file StorageData.zip tại đây](./storage_data/StorageData.zip) (hoặc link trực tiếp từ GitHub của bạn).
2.  Truy cập vào **Firebase Console** -> **Storage**.
3.  Tạo các thư mục tương ứng (ví dụ: `songs/`, `covers/`, `artists/`).
4.  Upload các file từ thư mục đã giải nén vào các thư mục tương ứng trên Firebase.
5.  **Lưu ý:** Đảm bảo bạn đã cấu hình Rules cho Storage để app có thể đọc được dữ liệu (Cấu hình như ảnh ở trên hoặc bạn tự cấu hình theo ý của bản thân).

## <a id="demo-app"></a> [🎬 Demo App](#mục-lục)

[Xem Demo Video](https://youtu.be/7EyEogCistA)
