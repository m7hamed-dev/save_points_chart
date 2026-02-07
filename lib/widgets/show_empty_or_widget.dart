import 'package:flutter/material.dart';

class ShowEmptyOrWidget extends StatelessWidget {
  const ShowEmptyOrWidget({
    super.key,
    required this.showWidget,
    required this.widget,
  });
  final bool showWidget;
  final Widget widget;

  @override
  Widget build(BuildContext context) {
    return showWidget ? widget : const SizedBox.shrink();
  }
}
