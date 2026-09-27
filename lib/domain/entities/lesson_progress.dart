import 'package:equatable/equatable.dart';

class LessonProgress extends Equatable {
  final String lessonId;
  final Duration position;
  final bool completed;

  const LessonProgress({
    required this.lessonId,
    required this.position,
    required this.completed,
  });

  LessonProgress copyWith({
    String? lessonId,
    Duration? position,
    bool? completed,
  }) {
    return LessonProgress(
      lessonId: lessonId ?? this.lessonId,
      position: position ?? this.position,
      completed: completed ?? this.completed,
    );
  }

  @override
  List<Object?> get props => [lessonId, position, completed];
}
