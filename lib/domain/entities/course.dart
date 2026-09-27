import 'package:equatable/equatable.dart';
import 'section.dart';

class Course extends Equatable {
  final String id;
  final String title;

  /// English title — falls back to [title] if empty.
  final String titleEn;

  /// Course description in Arabic.
  final String description;

  /// English description — falls back to [description] if empty.
  final String descriptionEn;

  final String instructor;

  /// English instructor name — falls back to [instructor] if empty.
  final String instructorEn;

  final String thumbnail;
  final List<Section> sections;

  const Course({
    required this.id,
    required this.title,
    this.titleEn = '',
    this.description = '',
    this.descriptionEn = '',
    required this.instructor,
    this.instructorEn = '',
    required this.thumbnail,
    required this.sections,
  });

  /// Returns [titleEn] when the language code starts with 'en' and a
  /// non-empty English title is available; otherwise returns [title].
  String localizedTitle(String languageCode) {
    if (languageCode.startsWith('en') && titleEn.isNotEmpty) return titleEn;
    return title;
  }

  /// Returns [instructorEn] when the language code starts with 'en' and a
  /// non-empty English name is available; otherwise returns [instructor].
  String localizedInstructor(String languageCode) {
    if (languageCode.startsWith('en') && instructorEn.isNotEmpty) {
      return instructorEn;
    }
    return instructor;
  }

  /// Returns [descriptionEn] when the language code starts with 'en' and a
  /// non-empty English description is available; otherwise returns [description].
  String localizedDescription(String languageCode) {
    if (languageCode.startsWith('en') && descriptionEn.isNotEmpty) {
      return descriptionEn;
    }
    return description;
  }

  @override
  List<Object?> get props => [
        id,
        title,
        titleEn,
        description,
        descriptionEn,
        instructor,
        instructorEn,
        thumbnail,
        sections,
      ];
}
