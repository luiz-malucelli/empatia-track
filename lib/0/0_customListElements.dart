import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class CustomSection extends StatelessWidget {
  final String sectionTitle;
  final List<Widget> children;
  final bool noLeftPadding;
  final bool noTopBottomPadding;
  final double bgOpacity;

  const CustomSection({
    super.key,
    required this.sectionTitle,
    required this.children,
    this.noLeftPadding = false,
    this.noTopBottomPadding = false,
    this.bgOpacity = 1.0
  });

  @override
  Widget build(BuildContext context) {
    var brightness = Theme.of(context).brightness;
    final bgBoxColor = Theme.of(context).colorScheme.surface.withValues(alpha: brightness == Brightness.dark ? 1.0 : 0.7);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (sectionTitle != '')
          Padding(
            padding: const EdgeInsets.only(left: 19),
            child: Text(
              sectionTitle.toUpperCase(),
              style: TextStyle(
                fontWeight: FontWeight.w400,
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 13,
              ),
            ),
          ),
        if (sectionTitle != '')
          const SizedBox(height: 3),
        Container(
          padding: EdgeInsets.only(left: noLeftPadding ? 0 : 20),
          decoration: BoxDecoration(
            color: bgBoxColor,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding: EdgeInsets.only(top: noTopBottomPadding ? 0 : 6, bottom: noTopBottomPadding ? 0 : 6),
            child: Column(
              children: children,
            ),
          ),
        ),
      ],
    );
  }
}


class CustomListItem extends StatelessWidget {
  final String listItemString;
  final List<Widget> children;
  final EdgeInsets padding;
  final bool isBold;
  final bool primaryColor;
  final double fontSize;

  const CustomListItem({
    super.key,
    required this.listItemString,
    required this.children,
    this.padding = const EdgeInsets.only(bottom: 10, top: 10, right: 20),
    this.isBold = true,
    this.primaryColor = false,
    this.fontSize = 15,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      child: Row(
        children: [
          Expanded( // Allow text to wrap if it doesn't fit in one line
            child:
            Padding(padding: const EdgeInsets.only(right: 5),
              child: Text(
                listItemString,
                style: TextStyle(
                  fontWeight: isBold ? FontWeight.w700 : FontWeight.w400,
                  color: primaryColor ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface,
                  fontSize: fontSize,
                ),
                overflow: TextOverflow.visible, // Allows text to wrap instead of ellipsis
              ),
            ),
          ),
          ...children, // Spreads the remaining children into the Row
        ],
      ),
    );
  }
}

class CustomListText extends StatelessWidget {
  final String text;
  final double opacity;
  final bool alignRight;
  final double fontSize;

  const CustomListText({
    super.key,
    required this.text,
    this.opacity = 1.0,
    this.alignRight = false,
    this.fontSize = 15,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text, textAlign: alignRight ? TextAlign.end : null,
      style: TextStyle(
        fontWeight: FontWeight.w400,
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: opacity),
        fontSize: fontSize,
      ),
    );
  }
}

class CustomListRichText extends StatelessWidget {
  final String text1;
  final String text2;
  final String text3;
  final double opacity;
  final bool alignRight;

  const CustomListRichText({
    super.key,
    required this.text1,
    required this.text2,
    required this.text3,
    this.opacity = 1.0,
    this.alignRight = true,
  });

  @override
  Widget build(BuildContext context) {
    return
      RichText(
        textAlign: alignRight ? TextAlign.end : TextAlign.start,
        text: TextSpan(
            children: [
              TextSpan(
                text: text1,
                style: TextStyle(
                    fontWeight: FontWeight.w400,
                    color: Theme.of(context).colorScheme.onSecondary.withValues(alpha: opacity),
                    fontSize: 15),
              ),
              TextSpan(
                text: text2,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.onSecondary.withValues(alpha: opacity),
                  fontSize: 15,
                ),
              ),
              TextSpan(
                text: text3,
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  color: Theme.of(context).colorScheme.onSecondary.withValues(alpha: opacity),
                  fontSize: 15,
                ),
              ),
            ]),
      );
  }
}


class CustomPickerIcon extends StatelessWidget {
  final double opacity;
  final bool noLeftPadding;

  const CustomPickerIcon({
    super.key,
    this.opacity = 1.0,
    this.noLeftPadding = false,// Default opacity is 1.0 (fully opaque)
  });

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      if(!noLeftPadding)
        const SizedBox(width: 3),
      Icon(
        CupertinoIcons.chevron_up_chevron_down,
        size: 15,
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: opacity),
      ),
    ]
    );
  }
}

class CustomNavigationIcon extends StatelessWidget {
  final double opacity;
  final Color? color;

  const CustomNavigationIcon({
    super.key,
    this.opacity = 1.0,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    Color finalColor = color ?? Theme.of(context).colorScheme.onSurface;

    return Row(children: [
      const SizedBox(width: 3),
      Icon(
        CupertinoIcons.chevron_right,
        size: 15,
        color: finalColor.withValues(alpha: opacity),
      ),
    ]
    );
  }
}


class PopupItem extends PopupMenuItem {
  final VoidCallback? onTap;

  const PopupItem({
    required Widget super.child,
    required this.onTap,
    super.key,
    super.value,
  });

  @override
  PopupItemState createState() => PopupItemState();
}

class PopupItemState extends PopupMenuItemState {
  @override
  void handleTap() {
    if (widget.onTap != null) {
      widget.onTap!();
    }
  }
}


class CustomPopupMenuButton<T> extends StatefulWidget {
  final List<PopupMenuEntry<T>> menuItems;
  final String popupMenuItemString;
  final void Function(T value) onSelected; // Adjusted to take the selected value
  final double initialOpacity;
  final bool richText;
  final String text1;
  final String text2;
  final String text3;
  final double fontSize;

  const CustomPopupMenuButton({
    super.key,
    required this.menuItems,
    required this.popupMenuItemString,
    required this.onSelected,
    this.initialOpacity = 1.0,
    this.richText = false,
    this.text1 = '',
    this.text2 = '',
    this.text3 = '',
    this.fontSize = 15,
  });

  @override
  CustomPopupMenuButtonState<T> createState() => CustomPopupMenuButtonState<T>();
}

class CustomPopupMenuButtonState<T> extends State<CustomPopupMenuButton<T>> {
  late double opacity;

  @override
  void initState() {
    super.initState();
    opacity = widget.initialOpacity;
  }

  void _setOpacity(double newOpacity) {
    setState(() {
      opacity = newOpacity;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<T>(
      key: ValueKey(widget.popupMenuItemString),
      offset: const Offset(13, 22),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      color: Theme.of(context).colorScheme.surface,
      elevation: 2,
      shadowColor: Colors.black,
      onOpened: () => _setOpacity(0.5),
      onCanceled: () => _setOpacity(1.0),
      itemBuilder: (BuildContext context) => widget.menuItems,
      child: Row(
        children: [
          if (!widget.richText)
            CustomListText(
              text: widget.popupMenuItemString,
              opacity: opacity,
              alignRight: true,
              fontSize: widget.fontSize,
            ),
          if (widget.richText)
            CustomListRichText(text1: widget.text1, text2: widget.text2, text3: widget.text3, opacity: opacity),
          CustomPickerIcon(opacity: opacity),
        ],
      ),
      onSelected: (value) {
        widget.onSelected(value);
        _setOpacity(1.0);
      },
    );
  }
}

class CustomSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color? activeTrackColor;
  final Color? inactiveTrackColor;
  final Color? activeThumbColor;
  final Color? inactiveThumbColor;

  const CustomSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.activeTrackColor,
    this.inactiveTrackColor,
    this.activeThumbColor,
    this.inactiveThumbColor,
  });

  @override
  Widget build(BuildContext context) {
    return Switch(
      trackOutlineColor:WidgetStateProperty.resolveWith<Color>(
            (Set<WidgetState> states) {
          if (states.contains(WidgetState.selected)) {
            return Theme.of(context).colorScheme.surface; // Thumb color when active
          }
          return Theme.of(context).colorScheme.surface; // Thumb color when inactive
        },
      ),
      value: value,
      onChanged: onChanged,
      activeTrackColor: activeTrackColor ?? Colors.green[700],
      inactiveTrackColor: inactiveTrackColor ?? Colors.grey[500],
      activeThumbColor: activeThumbColor ?? Colors.white,
      inactiveThumbColor: inactiveThumbColor ?? Colors.white,
    );
  }
}
