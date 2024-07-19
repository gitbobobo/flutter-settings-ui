import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:settings_ui/src/sections/abstract_settings_section.dart';
import 'package:settings_ui/src/sections/settings_section.dart';
import 'package:settings_ui/src/utils/platform_utils.dart';
import 'package:settings_ui/src/utils/settings_theme.dart';
import 'package:settings_ui/src/utils/theme_provider.dart';

enum ApplicationType {
  /// Use this parameter is you are using the MaterialApp
  material,

  /// Use this parameter is you are using the CupertinoApp
  cupertino,

  /// Use this parameter is you are using the MaterialApp for Android
  /// and the CupertinoApp for iOS.
  both,
}

class SettingsList extends StatefulWidget {
  const SettingsList({
    required this.sections,
    this.shrinkWrap = false,
    this.physics,
    this.platform,
    this.lightTheme,
    this.darkTheme,
    this.brightness,
    this.contentPadding,
    this.applicationType = ApplicationType.material,
    Key? key,
  }) : super(key: key);

  final bool shrinkWrap;
  final ScrollPhysics? physics;
  final DevicePlatform? platform;
  final SettingsThemeData? lightTheme;
  final SettingsThemeData? darkTheme;
  final Brightness? brightness;
  final EdgeInsetsGeometry? contentPadding;
  final List<AbstractSettingsSection> sections;
  final ApplicationType applicationType;

  @override
  State<SettingsList> createState() => _SettingsListState();
}

class _SettingsListState extends State<SettingsList> {
  @override
  Widget build(BuildContext context) {
    DevicePlatform platform;
    if (widget.platform == null || widget.platform == DevicePlatform.device) {
      platform = PlatformUtils.detectPlatform(context);
    } else {
      platform = widget.platform!;
    }

    final brightness = calculateBrightness(context);

    final themeData = ThemeProvider.getTheme(
      context: context,
      platform: platform,
      brightness: brightness,
    ).merge(
        theme: brightness == Brightness.dark
            ? widget.darkTheme
            : widget.lightTheme);

    final sectionList = ListView.builder(
      physics: widget.physics,
      shrinkWrap: widget.shrinkWrap,
      itemCount: widget.sections.length,
      padding:
          widget.contentPadding ?? calculateDefaultPadding(platform, context),
      itemBuilder: (BuildContext context, int index) {
        return SettingsSectionAdditionalInfo(
          sectionIndex: index,
          child: widget.sections[index],
        );
      },
    );

    return Container(
      color: themeData.settingsListBackground,
      width: MediaQuery.of(context).size.width,
      alignment: Alignment.center,
      child: SettingsTheme(
        themeData: themeData,
        platform: platform,
        child: sectionList,
      ),
    );
  }

  EdgeInsets calculateDefaultPadding(
      DevicePlatform platform, BuildContext context) {
    if (MediaQuery.of(context).size.width > 810) {
      double padding = (MediaQuery.of(context).size.width - 810) / 2;
      switch (platform) {
        case DevicePlatform.android:
        case DevicePlatform.tv:
        case DevicePlatform.fuchsia:
        case DevicePlatform.linux:
        case DevicePlatform.iOS:
        case DevicePlatform.macOS:
        case DevicePlatform.windows:
          return EdgeInsets.symmetric(horizontal: padding);
        case DevicePlatform.web:
          return EdgeInsets.symmetric(vertical: 20, horizontal: padding);
        case DevicePlatform.device:
          throw Exception(
            'You can\'t use the DevicePlatform.device in this context. '
            'Incorrect platform: SettingsList.calculateDefaultPadding',
          );
        default:
          return EdgeInsets.symmetric(
            horizontal: padding,
          );
      }
    }
    switch (platform) {
      case DevicePlatform.android:
      case DevicePlatform.tv:
      case DevicePlatform.fuchsia:
      case DevicePlatform.linux:
      case DevicePlatform.iOS:
      case DevicePlatform.macOS:
      case DevicePlatform.windows:
        return EdgeInsets.symmetric(vertical: 0);
      case DevicePlatform.web:
        return EdgeInsets.symmetric(vertical: 20);
      case DevicePlatform.device:
        throw Exception(
          'You can\'t use the DevicePlatform.device in this context. '
          'Incorrect platform: SettingsList.calculateDefaultPadding',
        );
    }
  }

  Brightness calculateBrightness(BuildContext context) {
    final materialBrightness = Theme.of(context).brightness;
    final cupertinoBrightness = CupertinoTheme.of(context).brightness ??
        MediaQuery.of(context).platformBrightness;

    switch (widget.applicationType) {
      case ApplicationType.material:
        return materialBrightness;
      case ApplicationType.cupertino:
        return cupertinoBrightness;
      case ApplicationType.both:
        return widget.platform != DevicePlatform.iOS
            ? materialBrightness
            : cupertinoBrightness;
    }
  }
}
