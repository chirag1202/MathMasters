import 'package:flutter/material.dart';

class TimerCircle extends StatelessWidget {
  final Duration remaining;
  final Duration total;
  const TimerCircle({super.key, required this.remaining, required this.total});

  @override
  Widget build(BuildContext context) {
    final fraction = remaining.inMilliseconds / total.inMilliseconds;
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 64,
          height: 64,
          child: CircularProgressIndicator(
            value: fraction.clamp(0.0, 1.0),
            strokeWidth: 8,
          ),
        ),
        Text('${remaining.inSeconds}s'),
      ],
    );
  }
}
