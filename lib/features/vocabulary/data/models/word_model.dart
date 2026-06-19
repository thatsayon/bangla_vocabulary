import 'package:isar/isar.dart';
import '../../domain/entities/word_entity.dart';

part 'word_model.g.dart';

@collection
class WordModel {
  Id get isarId => fastHash(id);

  late String id;
  late String english;
  late String bangla;
  late String pronunciation;
  late String exampleEnglish;
  late String exampleBangla;
  late String difficulty;
  late bool isLearned;
  late bool isSaved;
  late String? learnedDate; // ISO date string "YYYY-MM-DD"

  WordEntity toEntity() {
    return WordEntity(
      id: id,
      english: english,
      bangla: bangla,
      pronunciation: pronunciation,
      exampleEnglish: exampleEnglish,
      exampleBangla: exampleBangla,
      difficulty: difficulty,
      isLearned: isLearned,
      isSaved: isSaved,
    );
  }

  static WordModel fromJson(Map<String, dynamic> json) {
    final m = WordModel();
    m.id = json['id'] as String;
    m.english = json['english'] as String;
    m.bangla = json['bangla'] as String;
    m.pronunciation = json['pronunciation'] as String;
    m.exampleEnglish = json['example_english'] as String;
    m.exampleBangla = json['example_bangla'] as String;
    m.difficulty = json['difficulty'] as String;
    m.isLearned = false;
    m.isSaved = false;
    m.learnedDate = null;
    return m;
  }

  static WordModel fromEntity(WordEntity e) {
    final m = WordModel();
    m.id = e.id;
    m.english = e.english;
    m.bangla = e.bangla;
    m.pronunciation = e.pronunciation;
    m.exampleEnglish = e.exampleEnglish;
    m.exampleBangla = e.exampleBangla;
    m.difficulty = e.difficulty;
    m.isLearned = e.isLearned;
    m.isSaved = e.isSaved;
    return m;
  }
}

// Deterministic hash for string IDs
int fastHash(String string) {
  var hash = 0xcbf29ce484222325;
  var i = 0;
  while (i < string.length) {
    final codeUnit = string.codeUnitAt(i++);
    hash ^= codeUnit >> 8;
    hash *= 0x100000001b3;
    hash ^= codeUnit & 0xFF;
    hash *= 0x100000001b3;
  }
  return hash;
}
