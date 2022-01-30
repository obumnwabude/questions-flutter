import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'models.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
        ),
      ),
      home: const QuestionForm(),
    );
  }
}

class QuestionForm extends StatefulWidget {
  const QuestionForm({Key? key}) : super(key: key);

  @override
  _QuestionFormState createState() => _QuestionFormState();
}

class _QuestionFormState extends State<QuestionForm> {
  final _formKey = GlobalKey<FormState>();
  final _questionCtrl = TextEditingController();
  final _optionCtrls =
      Question.OPTIONS.map((o) => TextEditingController()).toList();
  var _question = Question();
  final _questionsRef = FirebaseFirestore.instance
      .collection('questions')
      .withConverter<Question>(
        fromFirestore: (snap, _) => Question.fromJson(snap.data()!),
        toFirestore: (question, _) => question.toJson(),
      );

  void showSnackbar({required bool success, required String text}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).size.height - 96,
          right: 16,
          left: 16,
        ),
        behavior: SnackBarBehavior.floating,
        content: Row(children: [
          Icon(
            success ? Icons.gpp_good : Icons.error,
            color: success ? Colors.greenAccent : Colors.redAccent,
          ),
          const SizedBox(width: 8),
          Text(text),
        ]),
      ),
    );
  }

  @override
  void dispose() {
    _questionCtrl.dispose();
    for (var ctrl in _optionCtrls) {
      ctrl.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Questions'),
        ),
        body: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: StreamBuilder<DocumentSnapshot<Question>>(
              stream: _questionsRef.doc('question').snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<DocumentSnapshot<Question>> snap) {
                if (snap.data != null && snap.data!.exists) {
                  _question = snap.data!.data()!;
                  Future.delayed(Duration.zero, () async {
                    _questionCtrl.text = _question.value;
                    _question.options.asMap().entries.forEach(
                        (e) => _optionCtrls[e.key].text = e.value.value);
                  });
                }
                return ListView(padding: const EdgeInsets.all(32), children: [
                  TextFormField(
                    controller: _questionCtrl,
                    decoration: const InputDecoration(labelText: 'Question *'),
                    validator: (v) =>
                        v!.isEmpty ? 'Please fill in the Question' : null,
                  ),
                  const SizedBox(height: 32),
                  const Text('Correct Option'),
                  Row(
                      children: Question.OPTIONS
                          .map((option) => [
                                Radio<String>(
                                  value: option,
                                  groupValue: _question.correct,
                                  onChanged: (v) =>
                                      setState(() => _question.correct = v!),
                                ),
                                Text(option),
                                const SizedBox(width: 16)
                              ])
                          .expand((w) => w)
                          .toList()),
                  const SizedBox(height: 32),
                  ...Question.OPTIONS
                      .asMap()
                      .entries
                      .map((entry) => [
                            TextFormField(
                              controller: _optionCtrls[entry.key],
                              decoration: InputDecoration(
                                  labelText: 'Option ${entry.value}*'),
                              validator: (v) => v!.isEmpty
                                  ? 'Please fill in Option ${entry.value}'
                                  : null,
                            ),
                            const SizedBox(height: 32),
                          ])
                      .expand((w) => w),
                  Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                    ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          _question.value = _questionCtrl.text;
                          _question.options.asMap().entries.forEach((entry) =>
                              entry.value.value = _optionCtrls[entry.key].text);
                          _questionsRef
                              .doc('question')
                              .set(_question)
                              .then(
                                (_) => showSnackbar(
                                  success: true,
                                  text: 'Question updated successfully.',
                                ),
                              )
                              .catchError(
                                (error) => showSnackbar(
                                  success: false,
                                  text: error.toString(),
                                ),
                              );
                        } else {
                          showSnackbar(
                            success: false,
                            text: 'Please fill all the required fields.',
                          );
                        }
                      },
                      child: const Text('Update'),
                    )
                  ]),
                ]);
              },
            )),
      ),
    );
  }
}
