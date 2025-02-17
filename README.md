# mdd_app

A cross-platform application to access the Mammal Diversity Database. It includes offline access and support to export a subset of the data to a Comma-Separated Values (CSV) file.

## Try it out 🚀

### Android, Linux, and Windows

You can download the beta release from the [releases page](https://github.com/mammaldiversity/mdd_app/releases).

### iOS, iPadOS, and macOS

Coming coon...
<!-- You will need to install the Apple TestFlight app and follow the instructions in this [link](https://testflight.apple.com/join/FXGXyw5e). -->

## Development Status

The app status is experimental. Expect bugs and incomplete features.

## Technologies

We develop the app using cross-platform, widely use technologies for mobile app development. The core technologies are:

- [Rust](https://www.rust-lang.org/): Mainly used for MDD data parsing and whenever high-performance computation is needed.
- [Flutter](https://flutter.dev/): Used for the app's user interface and to interact with the MDD data.
- [Fluter Rust Bridge](https://cjycode.com/flutter_rust_bridge/): Core package to simplify the communication between Rust and Flutter.
- [SQLite](https://www.sqlite.org/index.html): Used to store the MDD data locally and to provide offline access.

## Contributing

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
