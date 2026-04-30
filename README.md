# spotify_app

## 📸 App Screenshots

### ☀️ Light Mode

<p align="center">
  <table border="0">
    <tr>
        <td><img src="screenshots/light/light_splash.png" width="200"></td>
        <td><img src="screenshots/light/intro.png" width="200"></td>
        <td><img src="screenshots/light/light_choose_mode.png" width="200"></td>
        <td><img src="screenshots/light/light_signin_signup.png" width="200"></td>
        <td><img src="screenshots/light/light_signin.png" width="200"></td>
    </tr>
    <tr>
        <td align="center">Splash</td>
        <td align="center">Intro</td>
        <td align="center">Choose Mode</td>
        <td align="center">Sign In And Register</td>
        <td align="center">Sign In</td>
    </tr>

  </table>
</p>

<p align="center">
  <table border="0">
    <tr>
        <td><img src="screenshots/light/light_register.png" width="400"></td>
        <td><img src="screenshots/light/light_home.png" width="400"></td>
        <td><img src="screenshots/light/light_search.png" width="400"></td>
    </tr>
    <tr>
        <td align="center">Register</td>
        <td align="center">Home</td>
        <td align="center">Search</td>
    </tr>

  </table>
</p>

<p align="center">
  <table border="0">
    <tr>
        <td><img src="screenshots/light/light_artist.png" width="400"></td>
        <td><img src="screenshots/light/light_profile.png" width="400"></td>
        <td><img src="screenshots/light/light_profile_info.png" width="400"></td>
    </tr>
    <tr>
        <td align="center">Artist</td>
        <td align="center">Profile</td>
        <td align="center">Profile Info</td>
    </tr>

  </table>
</p>

---

### 🌑 Dark Mode

<p align="center">
  <table border="0">
    <tr>
        <td><img src="screenshots/dark/dark_splash.png" width="200"></td>
        <td><img src="screenshots/dark/intro.png" width="200"></td>
        <td><img src="screenshots/dark/dark_choose_mode.png" width="200"></td>
        <td><img src="screenshots/dark/dark_signin_signup.png" width="200"></td>
        <td><img src="screenshots/dark/dark_signin.png" width="200"></td>
    </tr>
    <tr>
        <td align="center">Splash</td>
        <td align="center">Intro</td>
        <td align="center">Choose Mode</td>
        <td align="center">Sign In And Register</td>
        <td align="center">Sign In</td>
    </tr>

  </table>
</p>

<p align="center">
  <table border="0">
    <tr>
        <td><img src="screenshots/dark/dark_register.png" width="400"></td>
        <td><img src="screenshots/dark/dark_home.png" width="400"></td>
        <td><img src="screenshots/dark/dark_search.png" width="400"></td>
    </tr>
    <tr>
        <td align="center">Register</td>
        <td align="center">Home</td>
        <td align="center">Search</td>
    </tr>

  </table>
</p>

<p align="center">
  <table border="0">
    <tr>
        <td><img src="screenshots/dark/dark_artist.png" width="400"></td>
        <td><img src="screenshots/dark/dark_profile.png" width="400"></td>
        <td><img src="screenshots/dark/dark_profile_info.png" width="400"></td>
    </tr>
    <tr>
        <td align="center">Artist</td>
        <td align="center">Profile</td>
        <td align="center">Profile Info</td>
    </tr>

  </table>
</p>


## 🚀 Hướng dẫn thiết lập (Setup)

### 1. Cấu hình Firebase
Dự án này sử dụng Firebase cho Authentication và Firestore. Để chạy dự án, bạn cần:

1. Tạo một dự án mới trên [Firebase Console](https://console.firebase.google.com/).
2. Cài đặt **FlutterFire CLI**:
   ```bash
   dart pub global activate flutterfire_cli

3. Cấu hình Firebase cho dự án:
   ```bash
   flutterfire configure
4. Đảm bảo file lib/firebase_options.dart đã được tạo (file này hiện đang được đưa vào .gitignore để bảo mật).
5. Cài đặt Dependencies
   ```bash
   flutter pub get
6. Chạy ứng dụng
7. ```bash
   flutter run

### 2. Cấu hình Database
1. Authentication
   ```
   Trên thanh menu bên trái --> Chọn Authentication -->
   Sign-in method --> Add new provider --> Select Email/Password
