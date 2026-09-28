import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/localization/app_language.dart';
import '../../../../domain/entities/course.dart';
import '../../../../features/profile/presentation/cubit/settings_cubit.dart';
import '../../../../features/profile/presentation/cubit/settings_state.dart';

// ── Gradient palettes (light / dark) — each card gets a unique palette ──────
// Light: vivid, saturated, brand-consistent
const List<_GradPalette> _lightPalettes = [
  _GradPalette(
    start: Color(0xFF0056A6),
    end: Color(0xFF00B4D8),
    accent: Color(0xFF90E0EF),
    shadow: Color(0xFF0077B6),
  ),
  _GradPalette(
    start: Color(0xFF6A0572),
    end: Color(0xFFD63AF9),
    accent: Color(0xFFF5B8FF),
    shadow: Color(0xFF9B1FAD),
  ),
  _GradPalette(
    start: Color(0xFF004D40),
    end: Color(0xFF00BFA5),
    accent: Color(0xFF64FFDA),
    shadow: Color(0xFF00796B),
  ),
  _GradPalette(
    start: Color(0xFF7B1E00),
    end: Color(0xFFFF6B35),
    accent: Color(0xFFFFD166),
    shadow: Color(0xFFBF360C),
  ),
  _GradPalette(
    start: Color(0xFF1A237E),
    end: Color(0xFF5C6BC0),
    accent: Color(0xFF9FA8DA),
    shadow: Color(0xFF283593),
  ),
  _GradPalette(
    start: Color(0xFF1B5E20),
    end: Color(0xFF43A047),
    accent: Color(0xFFA5D6A7),
    shadow: Color(0xFF2E7D32),
  ),
];

const List<_GradPalette> _darkPalettes = [
  _GradPalette(
    start: Color(0xFF003566),
    end: Color(0xFF0096C7),
    accent: Color(0xFF48CAE4),
    shadow: Color(0xFF0077B6),
  ),
  _GradPalette(
    start: Color(0xFF3D0152),
    end: Color(0xFFAB47BC),
    accent: Color(0xFFCE93D8),
    shadow: Color(0xFF6A1B9A),
  ),
  _GradPalette(
    start: Color(0xFF00251A),
    end: Color(0xFF00897B),
    accent: Color(0xFF4DB6AC),
    shadow: Color(0xFF00695C),
  ),
  _GradPalette(
    start: Color(0xFF4A1000),
    end: Color(0xFFE64A19),
    accent: Color(0xFFFF8A65),
    shadow: Color(0xFF8D3200),
  ),
  _GradPalette(
    start: Color(0xFF0D1257),
    end: Color(0xFF3949AB),
    accent: Color(0xFF7986CB),
    shadow: Color(0xFF1A237E),
  ),
  _GradPalette(
    start: Color(0xFF0A2E0C),
    end: Color(0xFF388E3C),
    accent: Color(0xFF81C784),
    shadow: Color(0xFF1B5E20),
  ),
];

class _GradPalette {
  final Color start;
  final Color end;
  final Color accent;
  final Color shadow;
  const _GradPalette({
    required this.start,
    required this.end,
    required this.accent,
    required this.shadow,
  });
}

/// Compact course card — gradient RTL, large thumbnail in top-right corner only.
///
/// Layout (RTL):
/// ┌──────────────────────────────────[IMAGE]─┐  ← height ≈ 130 px
/// │  Title                                   │
/// │  Instructor                              │
/// │  ── chips ──  ══ progress ══   42%       │
/// └──────────────────────────────────────────┘
class CourseCardItem extends StatelessWidget {
  final Course course;
  final double progressRatio;
  final VoidCallback? onReturnFromCourse;

  const CourseCardItem({
    super.key,
    required this.course,
    required this.progressRatio,
    this.onReturnFromCourse,
  });

  int get _totalSections => course.sections.length;
  int get _totalLessons =>
      course.sections.fold(0, (sum, s) => sum + s.lessons.length);
  int get _totalDurationSec => course.sections.fold(
        0,
        (sum, s) => sum + s.lessons.fold(0, (ls, l) => ls + l.durationSec),
      );

  String _fmt(int sec) {
    final h = sec ~/ 3600;
    final m = (sec % 3600) ~/ 60;
    return h > 0 ? '$h:${m.toString().padLeft(2, '0')} س' : '$m د';
  }

  _GradPalette _palette(bool isDark) {
    final idx = course.id.codeUnits.fold(0, (a, b) => a + b) %
        (isDark ? _darkPalettes.length : _lightPalettes.length);
    return isDark ? _darkPalettes[idx] : _lightPalettes[idx];
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final pal = _palette(isDark);
    final pct = (progressRatio * 100).toInt();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
          await context.push('/courses/${course.id}');
          if (context.mounted) onReturnFromCourse?.call();
        },
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              // RTL: right → left
              begin: AlignmentDirectional.centerEnd,
              end: AlignmentDirectional.centerStart,
              colors: [pal.start, pal.end],
            ),
            boxShadow: [
              BoxShadow(
                color: pal.shadow.withValues(alpha: 0.40),
                blurRadius: 18,
                spreadRadius: -3,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: SizedBox(
              height: 130,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // ── gloss overlay ────────────────────────
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white.withValues(alpha: 0.10),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),

                  // ── text content (left side) ─────────────
                  PositionedDirectional(
                    start: 0,
                    top: 0,
                    bottom: 0,
                    // leave room for the 115 px image + a little gap
                    end: 122,
                    child: Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                          14, 12, 8, 12),
                      child: _TextContent(
                        course: course,
                        totalSections: _totalSections,
                        totalLessons: _totalLessons,
                        durationText: _fmt(_totalDurationSec),
                        progressRatio: progressRatio,
                        percentage: pct,
                        accent: pal.accent,
                      ),
                    ),
                  ),

                  // ── large thumbnail — top-right corner ───
                  PositionedDirectional(
                    top: 0,
                    end: 0,
                    bottom: 0,
                    child: _CornerImage(
                      thumbnailPath: course.thumbnail,
                      palette: pal,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ────────────────────────────────────────────────────────
// Large thumbnail — fills the card height, right corner
// ────────────────────────────────────────────────────────

class _CornerImage extends StatelessWidget {
  final String thumbnailPath;
  final _GradPalette palette;

  const _CornerImage({required this.thumbnailPath, required this.palette});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 130,
      child: ClipRRect(
        child: Image.asset(
          thumbnailPath,
          width: 115,
          fit: BoxFit.cover,
          alignment: AlignmentDirectional.centerEnd,
          errorBuilder: (_, _e, _s) => Center(
            child: Icon(
              Icons.menu_book_rounded,
              color: Colors.white.withValues(alpha: 0.60),
              size: 36,
            ),
          ),
        ),
      ),
    );
  }
}

// ────────────────────────────────────────────────────────
// Text content — title · instructor · chips · progress
// ────────────────────────────────────────────────────────

class _TextContent extends StatelessWidget {
  final Course course;
  final int totalSections;
  final int totalLessons;
  final String durationText;
  final double progressRatio;
  final int percentage;
  final Color accent;

  const _TextContent({
    required this.course,
    required this.totalSections,
    required this.totalLessons,
    required this.durationText,
    required this.progressRatio,
    required this.percentage,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final langCode = context.read<SettingsCubit>().state.language.languageCode;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // ── title ──────────────────────────────────────
        Text(
          course.localizedTitle(langCode),
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            height: 1.3,
            color: Colors.white,
            shadows: [Shadow(color: Colors.black38, blurRadius: 4)],
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),

        // ── instructor ─────────────────────────────────
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.person_rounded,
                size: 12, color: Colors.white.withValues(alpha: 0.70)),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                course.localizedInstructor(langCode),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withValues(alpha: 0.80),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),

        // ── meta chips ─────────────────────────────────
        BlocBuilder<SettingsCubit, SettingsState>(
          buildWhen: (p, c) => p.language != c.language,
          builder: (context, state) {
            final lc = state.language.languageCode;
            return Row(
              children: [
                _Chip(
                  icon: Icons.layers_rounded,
                  label: AppStrings.trArgs(
                      'sections_count', lc, {'count': '$totalSections'}),
                ),
                _dot(),
                _Chip(
                  icon: Icons.play_lesson_rounded,
                  label: AppStrings.trArgs(
                      'lessons_count_label', lc, {'count': '$totalLessons'}),
                ),
                _dot(),
                _Chip(
                  icon: Icons.schedule_rounded,
                  label: durationText,
                ),
              ],
            );
          },
        ),

        // ── progress ───────────────────────────────────
        _ProgressBar(
          progressRatio: progressRatio,
          percentage: percentage,
          accent: accent,
        ),
      ],
    );
  }

  Widget _dot() => Container(
        width: 3,
        height: 3,
        margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.40),
          shape: BoxShape.circle,
        ),
      );
}

class _Chip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _Chip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 11, color: Colors.white.withValues(alpha: 0.65)),
        const SizedBox(width: 3),
        Text(
          label,
          style: TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w500,
            color: Colors.white.withValues(alpha: 0.85),
          ),
        ),
      ],
    );
  }
}

// ────────────────────────────────────────────────────────
// Compact progress bar
// ────────────────────────────────────────────────────────

class _ProgressBar extends StatelessWidget {
  final double progressRatio;
  final int percentage;
  final Color accent;

  const _ProgressBar({
    required this.progressRatio,
    required this.percentage,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final fillColor =
        percentage == 100 ? AppColors.successEmerald : Colors.white;

    return Row(
      children: [
        Expanded(
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: progressRatio.clamp(0.0, 1.0)),
            duration: const Duration(milliseconds: 1000),
            curve: Curves.easeOutCubic,
            builder: (context, value, _) {
              return LayoutBuilder(
                builder: (context, constraints) {
                  return Stack(
                    children: [
                      // track
                      Container(
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.22),
                          borderRadius: BorderRadius.circular(99),
                        ),
                      ),
                      // fill
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 1000),
                        curve: Curves.easeOutCubic,
                        width: constraints.maxWidth * value,
                        height: 5,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(99),
                          gradient: LinearGradient(
                            colors: [
                              fillColor,
                              fillColor.withValues(alpha: 0.70),
                            ],
                          ),
                          boxShadow: value > 0
                              ? [
                                  BoxShadow(
                                    color: fillColor.withValues(alpha: 0.40),
                                    blurRadius: 5,
                                  )
                                ]
                              : null,
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ),
        const SizedBox(width: 7),
        // percentage label
        Text(
          '$percentage%',
          style: TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w800,
            color: percentage == 100 ? AppColors.successEmerald : Colors.white,
          ),
        ),
      ],
    );
  }
}
