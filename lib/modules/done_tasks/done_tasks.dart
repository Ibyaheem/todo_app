import 'package:flutter/material.dart';

class DoneTasks extends StatelessWidget {
  const DoneTasks({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Done Tasks',
        style: TextStyle(
          fontSize: 25.0,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
