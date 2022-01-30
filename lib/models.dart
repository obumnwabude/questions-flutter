class Question {
  // ignore: constant_identifier_names
  static const OPTIONS = ['A', 'B', 'C', 'D'];

  String value = '';
  String correct = OPTIONS[0];
  List<Option> options = OPTIONS.map((o) => Option(index: o)).toList();

  Question();

  Question.fromJson(Map<String, Object?> json)
      : value = json['value']! as String,
        correct = json['correct']! as String,
        options = (json['options'] as List<dynamic>)
            .map((o) => Option.fromJson(o))
            .toList();

  Map<String, Object?> toJson() {
    return {
      'value': value,
      'correct': correct,
      'options': options.map((o) => o.toJson()).toList(),
    };
  }
}

class Option {
  String index;
  String value;

  Option({required this.index, this.value = ''});

  Option.fromJson(Map<String, Object?> json)
      : index = json['index']! as String,
        value = json['value']! as String;

  Map<String, Object?> toJson() => {'index': index, 'value': value};
}
