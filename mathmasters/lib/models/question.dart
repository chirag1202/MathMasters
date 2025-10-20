class Question {
  final String question;
  final List<String> options;
  final int answerIndex;

  const Question({
    required this.question,
    required this.options,
    required this.answerIndex,
  });

  factory Question.fromMap(Map<String, dynamic> map) {
    return Question(
      question: map['question'] as String,
      options: List<String>.from(map['options'] as List),
      answerIndex: map['answerIndex'] as int,
    );
  }

  Map<String, dynamic> toMap() => {
    'question': question,
    'options': options,
    'answerIndex': answerIndex,
  };
}

enum Topic {
  addition,
  subtraction,
  multiplication,
  division,
  fractions,
  decimals,
}

extension TopicX on Topic {
  String get key => switch (this) {
    Topic.addition => 'addition',
    Topic.subtraction => 'subtraction',
    Topic.multiplication => 'multiplication',
    Topic.division => 'division',
    Topic.fractions => 'fractions',
    Topic.decimals => 'decimals',
  };

  String get label => switch (this) {
    Topic.addition => 'Addition',
    Topic.subtraction => 'Subtraction',
    Topic.multiplication => 'Multiplication',
    Topic.division => 'Division',
    Topic.fractions => 'Fractions',
    Topic.decimals => 'Decimals',
  };
}
