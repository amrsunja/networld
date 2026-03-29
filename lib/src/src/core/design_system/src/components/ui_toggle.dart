import 'package:cupertino_native/components/switch.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;
import '../../app_ui.dart';

/// Design-system toggle: native [CNSwitch] on iOS/macOS (Liquid Glass via
/// [cupertino_native](https://pub.dev/packages/cupertino_native)), [CupertinoSwitch] elsewhere.
class UIToggle extends StatefulWidget {
  const UIToggle({
    super.key,
    this.checked = false,
    this.disabled = false,
    this.changeOpacity = true,
    this.onCheck,
  });

  final bool checked;
  final ValueChanged<bool>? onCheck;
  final bool disabled;
  final bool changeOpacity;

  static bool get _useNativePlatformSwitch {
    return defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS;
  }

  @override
  State<UIToggle> createState() => _UIToggleState();
}

class _UIToggleState extends State<UIToggle> {
  late bool _checked;

  @override
  void initState() {
    super.initState();
    _checked = widget.checked;
  }

  @override
  void didUpdateWidget(covariant UIToggle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.checked != widget.checked) {
      setState(() => _checked = widget.checked);
    }
  }

  void _onChange(bool isChecked) {
    setState(() => _checked = isChecked);
    widget.onCheck?.call(_checked);
  }

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: widget.disabled && widget.changeOpacity ? 0.5 : 1,
      child: //UIToggle._useNativePlatformSwitch
          //? _buildNativeSwitch()
          //: 
          _buildCupertinoSwitch(),
    );
  }

  Widget _buildNativeSwitch() {
    return CNSwitch(
      value: _checked,
      enabled: !widget.disabled,
      onChanged: _onChange,
      color: UIColorsToken.pri500,
      height: 31,
    );
  }

  Widget _buildCupertinoSwitch() {
    return Transform.scale(
      scale: 0.8,
      alignment: Alignment.center,
      child: CupertinoSwitch(
        value: _checked,
        onChanged: widget.disabled ? null : _onChange,
        activeTrackColor: UIColorsToken.pri500,
        inactiveTrackColor: UIColorsToken.neu300,
        thumbColor: UIColorsToken.white,
      ),
    );
  }
}
