/// Represents the current learning status of a lesson.
enum LessonStatus {
  /// The lesson has not been opened yet.
  notStarted,

  /// The lesson has been partially watched but not yet completed.
  inProgress,

  /// The lesson has reached 90% completion.
  completed,
}
