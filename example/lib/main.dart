import 'package:flutter/material.dart';
import 'package:mentionable_text_field/controllers/mentionable_text_field_controller.dart';
import 'package:mentionable_text_field/widgets/mentionable_text_field.dart';

void main() {
  runApp(const App());
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  final data = [
    "Muhammad",
    "Arifin",
    "Ilham",
    "Muhammad Arifin",
    "Arifin Ilham",
    "Muhammad Arifin Ilham"
  ];
  late MentionableTextFieldController controller;
  String? findQuery;

  @override
  initState() {
    super.initState();

    controller = MentionableTextFieldController();
  }

  @override
  dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(useMaterial3: false),
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Mentionable Text Field"),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              MentionableTextField(
                controller: controller,
                maxLines: 3,
                onSearch: (val, prefix) {
                  setState(() {
                    findQuery = val;
                  });
                },
                decoration: const InputDecoration(),
              ),
              if (findQuery != null)
                ...data
                    .where(
                        (element) => element.toLowerCase().contains(findQuery!))
                    .map((e) => TextButton(
                        onPressed: () {
                          setState(() {
                            findQuery = null;
                          });

                          controller.appendMention(e);
                        },
                        child: Text(e)))
            ],
          ),
        ),
      ),
    );
  }
}
