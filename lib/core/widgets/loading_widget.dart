import 'package:flutter/material.dart';
import 'package:flutter_assignment/core/utils/extension.dart';

class LoadingWidget extends StatelessWidget {
  final String? message;

  const LoadingWidget({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          if (message != null) ...[
            const SizedBox(height: 16),
            message!.textMedium(textAlign: TextAlign.center),
          ],
        ],
      ),
    );
  }
}
