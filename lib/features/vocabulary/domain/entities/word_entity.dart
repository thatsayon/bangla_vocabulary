class WordEntity {
  final String id;
  final String english;
  final String bangla;
  final String pronunciation;
  final String exampleEnglish;
  final String exampleBangla;
  final String difficulty;
  bool isLearned;
  bool isSaved;

  WordEntity({
    required this.id,
    required this.english,
    required this.bangla,
    required this.pronunciation,
    required this.exampleEnglish,
    required this.exampleBangla,
    required this.difficulty,
    this.isLearned = false,
    this.isSaved = false,
  });

  WordEntity copyWith({
    bool? isLearned,
    bool? isSaved,
  }) {
    return WordEntity(
      id: id,
      english: english,
      bangla: bangla,
      pronunciation: pronunciation,
      exampleEnglish: exampleEnglish,
      exampleBangla: exampleBangla,
      difficulty: difficulty,
      isLearned: isLearned ?? this.isLearned,
      isSaved: isSaved ?? this.isSaved,
    );
  }
}
