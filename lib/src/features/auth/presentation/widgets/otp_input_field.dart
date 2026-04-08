import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/rayyan_colors.dart';

class OtpInputField extends StatefulWidget {
  final int length;
  final ValueChanged<String> onChanged;
  final ValueChanged<String>? onCompleted;

  const OtpInputField({
    super.key,
    this.length = 6,
    required this.onChanged,
    this.onCompleted,
  });

  @override
  State<OtpInputField> createState() => _OtpInputFieldState();
}

class _OtpInputFieldState extends State<OtpInputField> {
  late List<TextEditingController> _controllers;
  late List<FocusNode> _focusNodes;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(widget.length, (index) => TextEditingController());
    _focusNodes = List.generate(widget.length, (index) => FocusNode());
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  void _onChanged(String value, int index) {
    // Collect the whole string
    final otpStr = _controllers.map((c) => c.text).join();
    widget.onChanged(otpStr);

    if (value.isNotEmpty) {
      if (index < widget.length - 1) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
        if (widget.onCompleted != null && otpStr.length == widget.length) {
          widget.onCompleted!(otpStr);
        }
      }
    } else {
      if (index > 0) {
        _focusNodes[index - 1].requestFocus();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(widget.length, (index) {
        return Container(
          width: 50,
          height: 60,
          decoration: BoxDecoration(
            color: isDark ? RayyanColors.backgroundDark : RayyanColors.slate100,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _focusNodes[index].hasFocus
                  ? RayyanColors.primary
                  : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Center(
            child: TextField(
              controller: _controllers[index],
              focusNode: _focusNodes[index],
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              inputFormatters: [
                LengthLimitingTextInputFormatter(1),
                FilteringTextInputFormatter.digitsOnly,
              ],
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : RayyanColors.slate900,
              ),
              cursorColor: RayyanColors.primary,
              decoration: const InputDecoration(
                border: InputBorder.none,
                counterText: '',
                hintText: '·',
                hintStyle: TextStyle(
                  color: Colors.grey,
                  fontSize: 24,
                ),
              ),
              onChanged: (val) => _onChanged(val, index),
            ),
          ),
        );
      }),
    );
  }
}
