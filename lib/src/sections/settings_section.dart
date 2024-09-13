import 'package:flutter/material.dart';
import 'package:settings_ui/src/sections/abstract_settings_section.dart';
import 'package:settings_ui/src/sections/platforms/android_settings_section.dart';
import 'package:settings_ui/src/sections/platforms/ios_settings_section.dart';
import 'package:settings_ui/src/sections/platforms/tv_settings_section.dart';
import 'package:settings_ui/src/sections/platforms/web_settings_section.dart';
import 'package:settings_ui/src/sections/platforms/windows_settings_section.dart';
import 'package:settings_ui/src/tiles/abstract_settings_tile.dart';
import 'package:settings_ui/src/utils/platform_utils.dart';
import 'package:settings_ui/src/utils/settings_theme.dart';

class SettingsSection extends AbstractSettingsSection {
  const SettingsSection({
    required this.tiles,
    this.margin,
    this.title,
    Key? key,
  }) : super(key: key);

  final List<AbstractSettingsTile> tiles;
  final EdgeInsetsDirectional? margin;
  final Widget? title;

  @override
  Widget build(BuildContext context) {
    final theme = SettingsTheme.of(context);

    switch (theme.platform) {
      case DevicePlatform.android:
      case DevicePlatform.fuchsia:
      case DevicePlatform.linux:
        return AndroidSettingsSection(
          title: title,
          tiles: tiles,
          margin: margin,
        );
      case DevicePlatform.windows:
        return WindowsSettingsSection(
          title: title,
          tiles: tiles,
          margin: margin,
        );
      case DevicePlatform.tv:
        return TVSettingsSection(
          title: title,
          tiles: tiles,
          margin: margin,
        );
      case DevicePlatform.iOS:
      case DevicePlatform.macOS:
        return IOSSettingsSection(
          title: title,
          tiles: tiles,
          margin: margin,
        );
      case DevicePlatform.web:
        return WebSettingsSection(
          title: title,
          tiles: tiles,
          margin: margin,
        );
      case DevicePlatform.device:
        throw Exception(
          'You can\'t use the DevicePlatform.device in this context. '
          'Incorrect platform: SettingsSection.build',
        );
    }
  }
}

class SettingsSectionAdditionalInfo extends InheritedWidget {
  final int sectionIndex;

  SettingsSectionAdditionalInfo({
    required this.sectionIndex,
    required Widget child,
  }) : super(child: child);

  @override
  bool updateShouldNotify(SettingsSectionAdditionalInfo old) => true;

  static SettingsSectionAdditionalInfo of(BuildContext context) {
    final SettingsSectionAdditionalInfo? result = context
        .dependOnInheritedWidgetOfExactType<SettingsSectionAdditionalInfo>();
    // assert(result != null, 'No IOSSettingsTileAdditionalInfo found in context');
    return result ??
        SettingsSectionAdditionalInfo(
          sectionIndex: -1,
          child: SizedBox(),
        );
  }
}
