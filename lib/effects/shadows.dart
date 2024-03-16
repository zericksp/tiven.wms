import 'package:flutter/material.dart';

class Textstyles extends StatelessWidget {
  final String data;
  final double size;
  final bool blColor;

  const Textstyles(
      {required this.data, required this.size, required this.blColor});

  @override
  Widget build(BuildContext context) {
    return Text(
      data,
      style: TextStyle(
          color: blColor ? Colors.white : Colors.black,
          fontSize: size == 0.0 ? 13.0 : size,
          shadows: <Shadow>[
            Shadow(
              offset: Offset(-1.0, -1.0),
              blurRadius: 3.0,
              color: Color.fromARGB(255, 226, 228, 228),
            ),
            Shadow(
              offset: Offset(1.0, 1.0),
              blurRadius: 4.0,
              color: Color.fromARGB(255, 105, 135, 135),
            ),
          ]),
    );
  }
}
