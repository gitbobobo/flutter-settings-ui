import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:settings_ui/src/tiles/platforms/tv_settings_tile.dart';

class TVSettingsSection extends StatelessWidget {
  const TVSettingsSection({
    required this.tiles,
    required this.margin,
    required this.title,
    Key? key,
  }) : super(key: key);

  final List<AbstractSettingsTile> tiles;
  final EdgeInsetsDirectional? margin;
  final Widget? title;

  @override
  Widget build(BuildContext context) {
    final theme = SettingsTheme.of(context);
    final isLastNonDescriptive = tiles.last is SettingsTile &&
        (tiles.last as SettingsTile).description == null;
    final scaleFactor = MediaQuery.of(context).textScaleFactor;
    final additionalInfo = SettingsSectionAdditionalInfo.of(context);

    return Padding(
      padding: margin ??
          EdgeInsets.only(
            top: 4.0 * scaleFactor,
            bottom: isLastNonDescriptive ? 27 * scaleFactor : 10 * scaleFactor,
            left: 16,
            right: 16,
          ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null)
            Padding(
              padding: EdgeInsetsDirectional.only(
                start: 18,
                bottom: 5 * scaleFactor,
              ),
              child: DefaultTextStyle(
                style: TextStyle(
                  color: theme.themeData.titleTextColor,
                  fontSize: 13,
                ),
                child: title!,
              ),
            ),
          buildTileList(additionalInfo),
        ],
      ),
    );
  }

  Widget buildTileList(SettingsSectionAdditionalInfo additionalInfo) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: tiles.length,
      padding: EdgeInsets.zero,
      physics: NeverScrollableScrollPhysics(),
      itemBuilder: (BuildContext context, int index) {
        final tile = tiles[index];

        return TVSettingsTileAdditionalInfo(
          sectionIndex: additionalInfo.sectionIndex,
          tileIndex: index,
          child: tile,
        );
      },
    );
  }
}
