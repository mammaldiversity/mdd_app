# mdd_app

![Test](https://github.com/mammaldiversity/mdd_app/actions/workflows/test.yml/badge.svg)

![Screenshot](/static/android-feature.png)

A cross-platform application to access the Mammal Diversity Database. It includes offline access and support to export a subset of the data to a Comma-Separated Values (CSV) file.

## Installation

### Android

Go to the [releases page](https://github.com/mammaldiversity/mdd_app/releases) and download the file ending in the appropriate name for your device:

*   **`arm64-v8a` (Recommended)**: Download this if you have a modern Android phone or tablet (released in 2016 or later). This includes almost all modern Samsung Galaxy, Google Pixel, OnePlus, Xiaomi, and other devices.
*   **`armeabi-v7a`**: Download this if you have an older or budget Android device (32-bit).
*   **`x86_64`**: This is for Android emulators running on a computer. Do not download this for a physical phone.

Once downloaded, open the `.apk` file on your device to install the app.

> [!TIP]
> **If you see "App not installed" or installation fails:**
> This usually happens if you already have a version of the app installed that was built/signed differently (e.g. from local development). To fix this, **completely uninstall the existing app** from your device first (ensuring it is removed for all user profiles, work profiles, or secure folders), then try installing the new file again.

### Linux
Download the `mdd-Linux-x86_64.tar.gz` archive from the releases page, extract the downloaded file, and run the `mdd` executable.

### Windows
Download the `mdd-Windows-x86_64.zip` archive from the releases page, extract it, and run `mdd.exe`.

### iOS, iPadOS, and macOS
You will need to install the Apple TestFlight app and follow the [installation instructions](https://testflight.apple.com/join/FXGXyw5e).

## Development Status

The app status is experimental. Expect bugs and incomplete features.

## Technologies

We develop the app using cross-platform, widely use technologies for mobile app development. The core technologies are:

- [Rust](https://www.rust-lang.org/): Mainly used for MDD data parsing and whenever high-performance computation is needed.
- [Flutter](https://flutter.dev/): Used for the app's user interface and to interact with the MDD data.
- [Fluter Rust Bridge](https://cjycode.com/flutter_rust_bridge/): Core package to simplify the communication between Rust and Flutter.
- [SQLite](https://www.sqlite.org/index.html): Used to store the MDD data locally and to provide offline access.

## Development

### Prerequisites

Make sure you have the following software installed. Follow the links for installation instructions.

- [Rust](https://www.rust-lang.org/tools/install)
- [Flutter](https://flutter.dev/docs/get-started/install)
- [Android Studio](https://developer.android.com/studio) or [Xcode](https://developer.apple.com/xcode/)
- An additional IDE. We recommend [Visual Studio Code](https://code.visualstudio.com/).

### Steps

- Clone the repository:

```bash
git clone https://github.com/mammaldiversity/mdd_app.git
```

0r if you are using [GitHub CLI](https://cli.github.com/):

```bash
gh repo clone mammaldiversity/mdd_app
```

- Change to the project directory:

```bash
cd mdd_app
```

- Create a `data` directory in the root of the project and place the latest `MDD.zip` and `MIL.tar.gz` inside it. This data is required to pre-generate the local SQLite database.

```bash
mkdir data
# Download MDD.zip and MIL data into the data/ directory
```

- Generate the SQLite database and run a build:

We provide a convenient bash script that builds the Rust parser, generates `assets/data/mdd.db`, and compiles Flutter for supported platforms.

```bash
./tools/build.sh
```

Alternatively, if you only want to generate the database manually without compiling Flutter release builds:
```bash
./tools/generate_prefilled_db.sh
```

- Try to run the app:

```bash
flutter run
```

### Troubleshooting

#### Fix Flutter Rust Bridge

- Check if the `flutter_rust_bridge_codegen` binary installation matches the version in the `pubspec.yaml` file in the app root directory and the `Cargo.toml` file in the `rust` directory.

- If the versions do not match, reinstall the `flutter_rust_bridge_codegen` binary and update the `pubspec.yaml` and `Cargo.toml` files.

#### Fix Xcode build issues

- Clean flutter build cache:

```bash
flutter clean
```

- Remove the `ios/Pods` or `macos/Pods` directory:

```bash
rm -rf ios/Pods
```

- Run flutter build outside Xcode:

```bash
flutter build ios
```
