import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
            primarySwatch: Colors.blue,
            inputDecorationTheme: const InputDecorationTheme(
                border: OutlineInputBorder(),
                floatingLabelBehavior: FloatingLabelBehavior.always)),
        home: const QuestionForm());
  }
}

class QuestionForm extends StatefulWidget {
  const QuestionForm({Key? key}) : super(key: key);

  @override
  _QuestionFormState createState() => _QuestionFormState();
}

class _QuestionFormState extends State<QuestionForm> {
  final _questionCtrl = TextEditingController();
  var _correctOption = 'A';

  @override
  void dispose() {
    _questionCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: ListView(
          padding: const EdgeInsets.all(32),
          children: [
            TextFormField(
                controller: _questionCtrl,
                decoration: const InputDecoration(labelText: 'Question')),
            const SizedBox(height: 32),
            const Text('Correct Option'),
            Row(
                children: ['A', 'B', 'C', 'D']
                    .map((option) => [
                          Radio<String>(
                              value: option,
                              groupValue: _correctOption,
                              onChanged: (v) =>
                                  setState(() => _correctOption = v!)),
                          Text(option),
                          const SizedBox(width: 16)
                        ])
                    .expand((w) => w)
                    .toList())
          ],
        ),
      ),
    );
  }
}
