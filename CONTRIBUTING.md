# Contributing to mdd_app

Thanks for helping improve the Mammal Diversity Database app. This guide covers setting up a development environment, generating the offline data, building each platform, and preparing a release.

Please report bugs and request features on the [issue tracker](https://github.com/mammaldiversity/mdd_app/issues).

## Technologies

- [Rust](https://www.rust-lang.org/): MDD and MIL data parsing, database generation, and other performance-sensitive work.
- [Flutter](https://flutter.dev/): The user interface and access to the MDD data.
- [Flutter Rust Bridge](https://cjycode.com/flutter_rust_bridge/): Communication between Rust and Flutter.
- [SQLite](https://www.sqlite.org/index.html) via [Drift](https://drift.simonbinder.eu/): Local storage for offline access.

## Prerequisites

- [Rust](https://www.rust-lang.org/tools/install) via `rustup`. The toolchain and cross-compilation targets are pinned in `rust/rust-toolchain.toml`, and `rustup` installs them automatically on first build.
- [Flutter](https://flutter.dev/docs/get-started/install) 3.44 or newer.
- [Android Studio](https://developer.android.com/studio) for Android, or [Xcode](https://developer.apple.com/xcode/) for iOS and macOS.
- `curl`, used by the data scripts to download the latest MDD and MIL releases.
- For Linux builds: `clang cmake ninja-build pkg-config libgtk-3-dev liblzma-dev libstdc++-12-dev`.
- For snap builds: [snapcraft](https://snapcraft.io/docs/snapcraft-overview).
- An editor. We recommend [Visual Studio Code](https://code.visualstudio.com/).

## Getting started

Clone the repository:

```bash
git clone https://github.com/mammaldiversity/mdd_app.git
cd mdd_app
```

Or with the [GitHub CLI](https://cli.github.com/):

```bash
gh repo clone mammaldiversity/mdd_app
cd mdd_app
```

Generate the offline data (see [Offline data](#offline-data)), then run the app:

```bash
./tools/generate_prefilled_db.sh
flutter run
```

The Rust library is compiled by the Native Assets build hook in `hook/build.dart` during `flutter run` and `flutter build`. There is no separate Rust build step or CocoaPods integration; iOS and macOS use Swift Package Manager.

## Offline data

The app ships a prefilled database and the Mammal Images Library (MIL) images. They are generated, not committed, and must exist before you run or build the app:

| File | Contents |
| --- | --- |
| `assets/data/mdd.db` | Prefilled SQLite database with MDD and MIL data |
| `assets/data/mil.json` | MIL metadata used by the home screen carousel |
| `assets/mil-images/` | MIL images (540 px WebP) |
| `assets/data/data_version.json` | Stamp of the MIL release and MDD.zip checksum the data was built from |

Generate them with:

```bash
./tools/generate_prefilled_db.sh
```

```powershell
.\tools\generate_prefilled_db.ps1
```

By default the scripts:

1. Download the latest `MDD.zip` from [mammaldiversity.org](https://www.mammaldiversity.org/) and the latest MIL release tarball from [asm-mil](https://github.com/mammaldiversity/asm-mil/releases) into `data/` (`tools/fetch_latest_data.sh` / `.ps1`). Older MIL tarballs and stray `data/mil.json` files are removed.
2. Build and install the `rust_lib_mdd` CLI from `rust/`.
3. Clear `assets/mil-images/` and regenerate the database, `mil.json`, images, and stamp.

To skip the download and use data already in `data/`:

```bash
./tools/generate_prefilled_db.sh --offline
./tools/generate_prefilled_db.sh data/mil-v2026-10-31.2.tar.gz
```

```powershell
.\tools\generate_prefilled_db.ps1 -Offline
.\tools\generate_prefilled_db.ps1 -MilPath data\mil-v2026-10-31.2.tar.gz
```

With `--offline` / `-Offline`, the newest tarball is chosen by release date and point release, so `mil-v2026-10-31.2` wins over `mil-v2026-10-31`.

The app replaces a user's installed database whenever the app version or the bundled data stamp changes, so regenerate the data before every release build.

### Taxonomy change summary

The home screen shows species-level taxonomy changes per MDD release from `assets/data/release_changes.json`, which is committed. Update it from an MDD release diff:

```bash
python3 tools/release_changes.py path/to/diffs.json.gz
```

## Building

The build scripts generate the latest data, then compile release builds. Android is built as split-per-ABI APKs.

On Linux or macOS (builds Android, iOS, macOS, and, on a Linux host, Linux):

```bash
./tools/build.sh
```

On Windows (builds Android and Windows):

```powershell
.\tools\build.ps1
```

If PowerShell blocks the scripts because of the execution policy, run them with `powershell -ExecutionPolicy Bypass -File .\tools\build.ps1`.

`scripts.py` offers finer-grained commands (`build`, `utils`, `frb`); run `python3 scripts.py --help` for details.

### Snap

```bash
./tools/build_snap.sh
```

This fetches the latest data, regenerates it, does a clean `flutter build linux --release`, and runs `snapcraft pack`. Extra arguments are passed to snapcraft.

`snap/snapcraft.yaml` packages the existing bundle in `build/linux/x64/release/bundle`. Before packing, it checks the bundle against the latest upstream data and fails if:

- `mdd.db`, `mil.json`, or `data_version.json` is missing,
- the bundled MIL release is not the latest asm-mil release,
- the bundled `MDD.zip` checksum differs from the current upstream file, or
- the number of MIL images differs from the stamp.

Running `snapcraft` directly on an old bundle therefore fails; rebuild with `tools/build_snap.sh`. For host or destructive-mode builds only, `MDD_SKIP_DATA_CHECK=1` bypasses the check.

## Testing

```bash
flutter analyze
flutter test
```

Rust tests:

```bash
cd rust
cargo test
```

CI (`.github/workflows/test.yml`) runs analysis and tests on Linux, macOS, and Windows for pushes and pull requests to `main` and `dev`.

## Releasing

1. Bump `version` in `pubspec.yaml`.
2. Update `CHANGELOG.md` and the "What's new" section of `README.md`. The release workflow uses the "What's new" section as the GitHub release notes.
3. Push a `v*` tag. `.github/workflows/release.yml` generates the latest data, builds the Linux tarball, snap, and Windows zip, and attaches them to a GitHub release.

## Troubleshooting

### Flutter Rust Bridge

- Check that the installed `flutter_rust_bridge_codegen` version matches `flutter_rust_bridge` in `pubspec.yaml` and `rust/Cargo.toml`.
- If the versions differ, reinstall `flutter_rust_bridge_codegen` and update `pubspec.yaml` and `rust/Cargo.toml`.
- Regenerate the bindings with `python3 scripts.py frb --generate`.

### Xcode builds

Clean the Flutter build cache, then build outside Xcode:

```bash
flutter clean
flutter build ios
```

### Missing images or empty carousel

Regenerate the offline data with `./tools/generate_prefilled_db.sh`. The app reads `assets/data/mil.json` and `assets/mil-images/`, which only exist after generation.
