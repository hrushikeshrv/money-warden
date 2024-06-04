import 'package:flutter/material.dart';

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 10, top: 10, bottom: 20),
          child: Text('Summary', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        ),
        Column(
          children: [
            Center(
                child: Text("Analytics Page")
            ),
          ],
        ),
      ],
    );
  }
}
