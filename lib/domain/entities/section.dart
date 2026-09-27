import 'package:equatable/equatable.dart';
import 'lesson.dart';

class Section extends Equatable {
  final String id;
  final String title;

  /// English title — falls back to [title] if empty.
  final String titleEn;

  final List<Lesson> lessons;

  const Section({
    required this.id,
    required this.title,
    this.titleEn = '',
    required this.lessons,
  });

  /// Returns [titleEn] when the language code starts with 'en' and a
  /// non-empty English title is available; otherwise returns [title].
  String localizedTitle(String languageCode) {
    if (languageCode.startsWith('en') && titleEn.isNotEmpty) return titleEn;
    return title;
  }

  @override
  List<Object?> get props => [id, title, titleEn, lessons];
}
