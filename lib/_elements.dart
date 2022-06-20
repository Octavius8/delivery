import 'package:flutter/material.dart';
import '_config.dart';

class CPrimaryButton extends StatelessWidget {
  final String title;
  Function action;
  CPrimaryButton({required this.title, required this.action});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: () {
            action();
          },
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(Config.COLOR_ACCENTCOLOR),
          ),
          child: Text(title),
        ));
  }
}
