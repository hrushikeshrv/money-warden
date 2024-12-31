import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:markdown_widget/markdown_widget.dart';


class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
          child: FutureBuilder(
            future: rootBundle.loadString('docs/privacy-policy.md'),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return MarkdownWidget(data: snapshot.data!);
              }
              return const Center(child: CircularProgressIndicator(),);
            },
          ),
        ),
      )
    );
  }
}
