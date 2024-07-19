import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:settings_ui/settings_ui.dart';

class TVSettingsTile extends StatefulWidget {
  const TVSettingsTile({
    required this.tileType,
    required this.leading,
    required this.title,
    required this.description,
    required this.onPressed,
    required this.onArrowLeftPressed,
    required this.onArrowRightPressed,
    required this.onToggle,
    required this.onFocusChange,
    required this.value,
    required this.initialValue,
    required this.activeSwitchColor,
    required this.enabled,
    required this.trailing,
    Key? key,
  }) : super(key: key);

  final SettingsTileType tileType;
  final Widget? leading;
  final Widget? title;
  final Widget? description;
  final Function(BuildContext context)? onPressed;
  final Function(BuildContext context)? onArrowLeftPressed;
  final Function(BuildContext context)? onArrowRightPressed;
  final Function(bool value)? onToggle;
  final Function(FocusNode focusNode)? onFocusChange;
  final Widget? value;
  final bool? initialValue;
  final bool enabled;
  final Color? activeSwitchColor;
  final Widget? trailing;

  @override
  State<TVSettingsTile> createState() => _TVSettingsTileState();
}

class _TVSettingsTileState extends State<TVSettingsTile> {
  bool isPressed = false;

  List<int> get sectionTileIndex {
    final additionalInfo = TVSettingsTileAdditionalInfo.of(context);
    return [additionalInfo.sectionIndex, additionalInfo.tileIndex];
  }

  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      widget.onFocusChange?.call(_focusNode);
      if (_focusNode.hasFocus) {
        Scrollable.ensureVisible(context, alignment: 1.0);
      } else {
        // 焦点移走后重置按键状态
        isPressed = false;
      }
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final additionalInfo = TVSettingsTileAdditionalInfo.of(context);
    final theme = SettingsTheme.of(context);

    return Column(
      children: [
        IgnorePointer(
          ignoring: !widget.enabled,
          child: buildTitle(
            context: context,
            theme: theme,
            additionalInfo: additionalInfo,
          ),
        ),
      ],
    );
  }

  Widget buildTitle({
    required BuildContext context,
    required SettingsTheme theme,
    required TVSettingsTileAdditionalInfo additionalInfo,
  }) {
    Widget content = buildTileContent(context, theme, additionalInfo);
    return Material(
      color: Colors.transparent,
      child: content,
    );
  }

  // Widget buildDescription({
  //   required BuildContext context,
  //   required SettingsTheme theme,
  //   required TVSettingsTileAdditionalInfo additionalInfo,
  // }) {
  //   final scaleFactor = MediaQuery.of(context).textScaleFactor;

  //   return Container(
  //     width: MediaQuery.of(context).size.width,
  //     padding: EdgeInsets.only(
  //       left: 18,
  //       right: 18,
  //       top: 8 * scaleFactor,
  //       bottom: additionalInfo.needToShowDivider ? 24 : 8 * scaleFactor,
  //     ),
  //     decoration: BoxDecoration(
  //       color: theme.themeData.settingsListBackground,
  //     ),
  //     child: DefaultTextStyle(
  //       style: TextStyle(
  //         color: theme.themeData.titleTextColor,
  //         fontSize: 13,
  //       ),
  //       child: widget.description!,
  //     ),
  //   );
  // }

  Widget buildTrailing({
    required BuildContext context,
    required SettingsTheme theme,
  }) {
    final scaleFactor = MediaQuery.of(context).textScaleFactor;

    var trailingColor = theme.themeData.inactiveTitleColor;
    if (widget.enabled) {
      if (_focusNode.hasFocus) {
        trailingColor = Colors.grey[800];
      } else {
        trailingColor = theme.themeData.trailingTextColor;
      }
    }

    return Row(
      children: [
        if (widget.trailing != null)
          DefaultTextStyle(
              style: TextStyle(color: trailingColor), child: widget.trailing!),
        if (widget.tileType == SettingsTileType.switchTile)
          CupertinoSwitch(
            value: widget.initialValue ?? true,
            onChanged: widget.onToggle,
            activeColor: widget.enabled
                ? widget.activeSwitchColor
                : theme.themeData.inactiveTitleColor,
          ),
        if (widget.tileType == SettingsTileType.navigationTile &&
            widget.value != null)
          DefaultTextStyle(
            style: TextStyle(
              color: trailingColor,
              fontSize: 17,
            ),
            child: widget.value!,
          ),
        if (widget.tileType == SettingsTileType.navigationTile)
          Padding(
            padding: const EdgeInsetsDirectional.only(start: 6, end: 2),
            child: IconTheme(
              data: IconTheme.of(context)
                  .copyWith(color: theme.themeData.leadingIconsColor),
              child: Icon(
                widget.enabled
                    ? CupertinoIcons.chevron_forward
                    : CupertinoIcons.lock_fill,
                size: 18 * scaleFactor,
              ),
            ),
          ),
      ],
    );
  }

  void changePressState({bool isPressed = false}) {
    if (mounted) {
      setState(() {
        this.isPressed = isPressed;
      });
    }
  }

  Widget buildTileContent(
    BuildContext context,
    SettingsTheme theme,
    TVSettingsTileAdditionalInfo additionalInfo,
  ) {
    final scaleFactor = MediaQuery.of(context).textScaleFactor;
    var titleColor = theme.themeData.inactiveTitleColor;
    if (widget.enabled) {
      if (isPressed) {
        titleColor = Colors.grey;
      } else if (_focusNode.hasFocus) {
        titleColor = Colors.black;
      } else {
        titleColor = theme.themeData.settingsTileTextColor;
      }
    }

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: widget.onPressed == null
          ? null
          : () {
              changePressState(isPressed: true);

              widget.onPressed!.call(context);

              Future.delayed(
                Duration(milliseconds: 100),
                () => changePressState(isPressed: false),
              );
            },
      onTapDown: (_) =>
          widget.onPressed == null ? null : changePressState(isPressed: true),
      onTapUp: (_) =>
          widget.onPressed == null ? null : changePressState(isPressed: false),
      onTapCancel: () =>
          widget.onPressed == null ? null : changePressState(isPressed: false),
      child: Focus(
        focusNode: _focusNode,
        onKeyEvent: (node, event) {
          if (event.logicalKey == LogicalKeyboardKey.select ||
              event.logicalKey == LogicalKeyboardKey.enter) {
            if (event is KeyUpEvent && widget.enabled) {
              widget.onPressed?.call(context);
              if (widget.tileType == SettingsTileType.switchTile) {
                widget.onToggle?.call(!(widget.initialValue ?? true));
              }
            }

            changePressState(isPressed: event is KeyDownEvent);
            return KeyEventResult.ignored;
          } else if (widget.onArrowLeftPressed != null &&
              event.logicalKey == LogicalKeyboardKey.arrowLeft) {
            if (event is KeyUpEvent) {
              widget.onArrowLeftPressed!.call(context);
            }
            return KeyEventResult.handled;
          } else if (widget.onArrowRightPressed != null &&
              event.logicalKey == LogicalKeyboardKey.arrowRight) {
            if (event is KeyUpEvent) {
              widget.onArrowRightPressed!.call(context);
            }
            return KeyEventResult.handled;
          }
          return KeyEventResult.ignored;
        },
        child: AnimatedContainer(
          duration: kThemeAnimationDuration,
          decoration: BoxDecoration(
            color: isPressed || _focusNode.hasFocus
                ? Colors.white
                : theme.themeData.settingsSectionBackground,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(12),
              bottom: Radius.circular(12),
            ),
            boxShadow: _focusNode.hasFocus
                ? [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.1),
                      spreadRadius: 2,
                      blurRadius: 4,
                      offset: Offset(-2, 6),
                    ),
                  ]
                : [],
          ),
          padding: isPressed || !_focusNode.hasFocus
              ? EdgeInsets.only(left: 18)
              : EdgeInsets.fromLTRB(18, 2, 0, 2),
          margin: isPressed || !_focusNode.hasFocus
              ? EdgeInsets.symmetric(vertical: 4, horizontal: 8)
              : EdgeInsets.symmetric(vertical: 2, horizontal: 4),
          child: Row(
            children: [
              if (widget.leading != null)
                Padding(
                  padding: const EdgeInsetsDirectional.only(end: 12.0),
                  child: IconTheme.merge(
                    data: IconThemeData(
                      color: widget.enabled
                          ? theme.themeData.leadingIconsColor
                          : theme.themeData.inactiveTitleColor,
                    ),
                    child: widget.leading!,
                  ),
                ),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsetsDirectional.only(end: 16),
                      child: Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: EdgeInsetsDirectional.only(
                                top: 12.5 * scaleFactor,
                                bottom: 12.5 * scaleFactor,
                              ),
                              child: DefaultTextStyle(
                                style: TextStyle(
                                  color: titleColor,
                                  fontSize: 16,
                                ),
                                child: widget.title!,
                              ),
                            ),
                          ),
                          buildTrailing(context: context, theme: theme),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TVSettingsTileAdditionalInfo extends InheritedWidget {
  final int sectionIndex;
  final int tileIndex;

  TVSettingsTileAdditionalInfo({
    required this.sectionIndex,
    required this.tileIndex,
    required Widget child,
  }) : super(child: child);

  @override
  bool updateShouldNotify(TVSettingsTileAdditionalInfo old) => true;

  static TVSettingsTileAdditionalInfo of(BuildContext context) {
    final TVSettingsTileAdditionalInfo? result = context
        .dependOnInheritedWidgetOfExactType<TVSettingsTileAdditionalInfo>();
    // assert(result != null, 'No IOSSettingsTileAdditionalInfo found in context');
    return result ??
        TVSettingsTileAdditionalInfo(
          sectionIndex: -1,
          tileIndex: -1,
          child: SizedBox(),
        );
  }
}
