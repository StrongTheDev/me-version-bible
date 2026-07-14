import 'package:flutter/cupertino.dart';

SizedBox emptyPage(String message, {Widget? icon}) {
  return SizedBox.expand(
    child: Center(
      child: Column(
        mainAxisAlignment: .center,
        crossAxisAlignment: .center,
        children: [icon ?? SizedBox(), Text(message)],
      ),
    ),
  );
}
