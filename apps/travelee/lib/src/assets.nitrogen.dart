import 'package:nitrogen_types/nitrogen_types.dart';

// GENERATED CODE - DO NOT MODIFY BY HAND
//
// **************************************************************************
// nitrogen
// **************************************************************************
//
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use

/// Contains the assets and nested directories in the `assets` directory.
///
/// Besides the assets and nested directories, it also provides a [contents] for querying the assets in the current
/// directory.
///
/// To convert an asset into a widget, [call the asset like a function](https://dart.dev/language/callable-objects].
/// ```dart
/// final widget = Assets.path.to.asset();
/// ```
///
/// The `call(...)` functions are provided by extensions. By default, only the [ImageAsset] extension is bundled.
///
/// 3rd party packages are supported via 'extension' packages. `extension` packages contain an `extension` that provide a
/// `call(...)` function that transforms an `Asset` into a 3rd party type.
///
/// | Type              | Package       | Extension Package      | Version                                                                                                        |
/// |-------------------|---------------|------------------------|----------------------------------------------------------------------------------------------------------------|
/// | SVG images        | `flutter_svg` | `nitrogen_flutter_svg` | [![Pub Dev](https://img.shields.io/pub/v/nitrogen_flutter_svg)](https://pub.dev/packages/nitrogen_flutter_svg) |
/// | Lottie animations | `lottie`      | `nitrogen_lottie`      | [![Pub Dev](https://img.shields.io/pub/v/nitrogen_lottie)](https://pub.dev/packages/nitrogen_lottie)           |
class Assets {
  const Assets();

  /// The `assets/icons` directory.
  static $AssetsIcons get icons => const $AssetsIcons();

  /// The `assets/images` directory.
  static $AssetsImages get images => const $AssetsImages();

  /// The contents of this directory.
  static Map<String, Asset> get contents => const {};
}

/// Contains the assets and nested directories in the `assets/icons` directory.
///
/// Besides the assets and nested directories, it also provides a [contents] for querying the assets in the current
/// directory.
///
/// To convert an asset into a widget, [call the asset like a function](https://dart.dev/language/callable-objects].
/// ```dart
/// final widget = $AssetsIcons.path.to.asset();
/// ```
///
/// The `call(...)` functions are provided by extensions. By default, only the [ImageAsset] extension is bundled.
///
/// 3rd party packages are supported via 'extension' packages. `extension` packages contain an `extension` that provide a
/// `call(...)` function that transforms an `Asset` into a 3rd party type.
///
/// | Type              | Package       | Extension Package      | Version                                                                                                        |
/// |-------------------|---------------|------------------------|----------------------------------------------------------------------------------------------------------------|
/// | SVG images        | `flutter_svg` | `nitrogen_flutter_svg` | [![Pub Dev](https://img.shields.io/pub/v/nitrogen_flutter_svg)](https://pub.dev/packages/nitrogen_flutter_svg) |
/// | Lottie animations | `lottie`      | `nitrogen_lottie`      | [![Pub Dev](https://img.shields.io/pub/v/nitrogen_lottie)](https://pub.dev/packages/nitrogen_lottie)           |
class $AssetsIcons {
  const $AssetsIcons();

  /// The `assets/icons/back.svg`.
  SvgAsset get back => const SvgAsset(
        null,
        'back',
        'assets/icons/back.svg',
      );

  /// The `assets/icons/bytesize_close.svg`.
  SvgAsset get bytesizeClose => const SvgAsset(
        null,
        'bytesize_close',
        'assets/icons/bytesize_close.svg',
      );

  /// The `assets/icons/bytesize_plus.svg`.
  SvgAsset get bytesizePlus => const SvgAsset(
        null,
        'bytesize_plus',
        'assets/icons/bytesize_plus.svg',
      );

  /// The `assets/icons/icon.svg`.
  SvgAsset get icon => const SvgAsset(
        null,
        'icon',
        'assets/icons/icon.svg',
      );

  /// The `assets/icons/logo.svg`.
  SvgAsset get logo => const SvgAsset(
        null,
        'logo',
        'assets/icons/logo.svg',
      );

  /// The contents of this directory.
  Map<String, Asset> get contents => const {
        'back': const SvgAsset(
          null,
          'back',
          'assets/icons/back.svg',
        ),
        'bytesize_close': const SvgAsset(
          null,
          'bytesize_close',
          'assets/icons/bytesize_close.svg',
        ),
        'bytesize_plus': const SvgAsset(
          null,
          'bytesize_plus',
          'assets/icons/bytesize_plus.svg',
        ),
        'icon': const SvgAsset(
          null,
          'icon',
          'assets/icons/icon.svg',
        ),
        'logo': const SvgAsset(
          null,
          'logo',
          'assets/icons/logo.svg',
        ),
      };
}

/// Contains the assets and nested directories in the `assets/images` directory.
///
/// Besides the assets and nested directories, it also provides a [contents] for querying the assets in the current
/// directory.
///
/// To convert an asset into a widget, [call the asset like a function](https://dart.dev/language/callable-objects].
/// ```dart
/// final widget = $AssetsImages.path.to.asset();
/// ```
///
/// The `call(...)` functions are provided by extensions. By default, only the [ImageAsset] extension is bundled.
///
/// 3rd party packages are supported via 'extension' packages. `extension` packages contain an `extension` that provide a
/// `call(...)` function that transforms an `Asset` into a 3rd party type.
///
/// | Type              | Package       | Extension Package      | Version                                                                                                        |
/// |-------------------|---------------|------------------------|----------------------------------------------------------------------------------------------------------------|
/// | SVG images        | `flutter_svg` | `nitrogen_flutter_svg` | [![Pub Dev](https://img.shields.io/pub/v/nitrogen_flutter_svg)](https://pub.dev/packages/nitrogen_flutter_svg) |
/// | Lottie animations | `lottie`      | `nitrogen_lottie`      | [![Pub Dev](https://img.shields.io/pub/v/nitrogen_lottie)](https://pub.dev/packages/nitrogen_lottie)           |
class $AssetsImages {
  const $AssetsImages();

  /// The `assets/images/bg.png`.
  ImageAsset get bg => const ImageAsset(
        null,
        'bg',
        'assets/images/bg.png',
      );

  /// The contents of this directory.
  Map<String, Asset> get contents => const {
        'bg': const ImageAsset(
          null,
          'bg',
          'assets/images/bg.png',
        ),
      };
}
