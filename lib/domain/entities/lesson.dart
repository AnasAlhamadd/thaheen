import 'package:equatable/equatable.dart';

class Lesson extends Equatable {
  final String id;
  final String title;

  /// English title — falls back to [title] if empty.
  final String titleEn;

  final int durationSec;
  final String video;

  const Lesson({
    required this.id,
    required this.title,
    this.titleEn = '',
    required this.durationSec,
    required this.video,
  });

  /// Returns [titleEn] when the language code starts with 'en' and a
  /// non-empty English title is available; otherwise returns [title].
  String localizedTitle(String languageCode) {
    if (languageCode.startsWith('en') && titleEn.isNotEmpty) return titleEn;
    return title;
  }

  @override
  List<Object?> get props => [id, title, titleEn, durationSec, video];
}
