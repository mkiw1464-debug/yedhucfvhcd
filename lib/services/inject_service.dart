import 'package:flutter/services.dart';

enum GameTarget { freeFire, freeFireMax }

enum FeatureKey {
  aimBody,
  aimNeck,
  aimDrag,
  magicBullet,
  antena,
  hologram,
}

extension FeatureKeyExt on FeatureKey {
  String get folderName {
    switch (this) {
      case FeatureKey.aimBody:
        return 'Aimbody';
      case FeatureKey.aimNeck:
        return 'Aimneck';
      case FeatureKey.aimDrag:
        return 'Aimdrag';
      case FeatureKey.magicBullet:
        return 'Magic Bullet';
      case FeatureKey.antena:
        return 'Antena';
      case FeatureKey.hologram:
        return 'Hologram';
    }
  }

  String get displayName {
    switch (this) {
      case FeatureKey.aimBody:
        return 'AimBody';
      case FeatureKey.aimNeck:
        return 'AimNeck';
      case FeatureKey.aimDrag:
        return 'AimDrag';
      case FeatureKey.magicBullet:
        return 'Magic Bullet';
      case FeatureKey.antena:
        return 'Antena';
      case FeatureKey.hologram:
        return 'Hologram';
    }
  }
}

extension GameTargetExt on GameTarget {
  String get bundleId {
    switch (this) {
      case GameTarget.freeFire:
        return 'com.dts.freefireth';
      case GameTarget.freeFireMax:
        return 'com.dts.freefiremax';
    }
  }

  String get displayName {
    switch (this) {
      case GameTarget.freeFire:
        return 'Free Fire';
      case GameTarget.freeFireMax:
        return 'Free Fire Max';
    }
  }
}

class InjectService {
  static const MethodChannel _channel =
      MethodChannel('com.ffexternal.inject');

  /// Check if the cheat file for this feature + game exists on GitHub/bundle
  static Future<bool> isFeatureAvailable(
      GameTarget game, FeatureKey feature) async {
    try {
      final result = await _channel.invokeMethod<bool>('checkFeatureAvailable',
          {'game': game.bundleId, 'feature': feature.folderName});
      return result ?? false;
    } on PlatformException {
      return false;
    }
  }

  /// Inject: backup original + replace with cheat file
  static Future<void> inject(GameTarget game, FeatureKey feature) async {
    await _channel.invokeMethod('inject', {
      'game': game.bundleId,
      'feature': feature.folderName,
    });
  }

  /// Restore: put original file back
  static Future<void> restore(GameTarget game, FeatureKey feature) async {
    await _channel.invokeMethod('restore', {
      'game': game.bundleId,
      'feature': feature.folderName,
    });
  }

  /// Check if currently injected
  static Future<bool> isInjected(GameTarget game, FeatureKey feature) async {
    try {
      final result = await _channel.invokeMethod<bool>('isInjected',
          {'game': game.bundleId, 'feature': feature.folderName});
      return result ?? false;
    } on PlatformException {
      return false;
    }
  }
}
