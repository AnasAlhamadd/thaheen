import 'package:flutter/material.dart';

/// Supported language codes for the application.
enum AppLanguage {
  /// Arabic (Saudi Arabia)
  arabic('ar', 'SA', 'العربية', 'Cairo'),

  /// English (United States)
  english('en', 'US', 'English', 'Inter');

  /// Language code (e.g. 'ar', 'en')
  final String languageCode;

  /// Optional country code (e.g. 'SA', 'US')
  final String countryCode;

  /// Display name of the language
  final String displayName;

  /// Associated font family
  final String fontFamily;

  const AppLanguage(
    this.languageCode,
    this.countryCode,
    this.displayName,
    this.fontFamily,
  );

  /// Convert to Flutter [Locale]
  Locale get locale => Locale(languageCode, countryCode);

  /// Resolves [AppLanguage] from languageCode string or defaults to Arabic.
  static AppLanguage fromCode(String? code) {
    if (code == null) return AppLanguage.arabic;
    if (code.toLowerCase().startsWith('en')) {
      return AppLanguage.english;
    }
    return AppLanguage.arabic;
  }

  /// Returns true if the current language is English
  bool get isEnglish => this == AppLanguage.english;

  /// Returns true if the current language is Arabic
  bool get isArabic => this == AppLanguage.arabic;
}

/// Helper translations dictionary for simple UI strings across the app.
class AppStrings {
  /// Returns localized string by key and current locale code.
  static String tr(String key, String languageCode) {
    final isEn = languageCode.startsWith('en');
    return isEn ? (_en[key] ?? key) : (_ar[key] ?? key);
  }

  /// Returns localized string with named placeholder replacements.
  ///
  /// Example:
  /// ```dart
  /// AppStrings.trArgs('available_courses_count', 'ar', {'count': '5'});
  /// // → '5 مقررات متاحة'
  /// ```
  static String trArgs(
    String key,
    String languageCode,
    Map<String, String> args,
  ) {
    var result = tr(key, languageCode);
    for (final entry in args.entries) {
      result = result.replaceAll('{${entry.key}}', entry.value);
    }
    return result;
  }

  /// Returns the appropriate text based on language
  /// 
  /// Example:
  /// ```dart
  /// AppStrings.getLocalizedText('ar', 'عنوان عربي', 'English Title');
  /// // → 'عنوان عربي'
  /// 
  /// AppStrings.getLocalizedText('en', 'عنوان عربي', 'English Title');
  /// // → 'English Title'
  /// ```
  static String getLocalizedText(
    String languageCode,
    String arabicText,
    String? englishText,
  ) {
    final isEn = languageCode.startsWith('en');
    return isEn ? (englishText ?? arabicText) : arabicText;
  }

  /// Extension helper for easy access to bilingual text
  /// 
  /// Example:
  /// ```dart
  /// final title = course['title'].localized('ar', course['titleEn']);
  /// ```
  static String localized(
    dynamic value,
    String languageCode, [
    dynamic alternateValue,
  ]) {
    if (value == null) return '';
    final isEn = languageCode.startsWith('en');
    if (isEn && alternateValue != null) {
      return alternateValue.toString();
    }
    return value.toString();
  }

  static const Map<String, String> _ar = {
    'app_title': 'ذَهِين - المنصة الأكاديمية الطبية',
    'app_name': 'ذَهِين',
    'subtitle': 'المنصة الأكاديمية الطبية',
    'courses': 'دوراتي',
    'home': 'الرئيسية',
    'profile': 'الملف الشخصي',
    'settings': 'الإعدادات والمظهر',
    'language': 'لغة التطبيق',
    'theme': 'المظهر',
    'theme_light': 'الوضع الفاتح',
    'theme_dark': 'الوضع الداكن',
    'theme_system': 'تلقائي (حسب النظام)',
    'arabic': 'العربية',
    'english': 'English',
    'student_greeting': 'مرحباً د. أحمد',
    'student_college': 'كلية الطب البشري · جامعة الملك سعود',
    'academic_level': 'سنة ثانية · ترم أول',
    'active_courses': 'المقررات النشطة',
    'target_gpa': 'المعدل المستهدف',
    'commitment_days': 'أيام الالتزام',
    'active_courses_section': 'المقررات الدراسية النشطة',
    'available_courses': 'مقررات متاحة',
    'available_courses_count': '{count} مقررات متاحة',
    'sections_count': '{count} أقسام',
    'lessons_count_label': '{count} دروس',
    'kickoff_title': 'ابدأ أول محاضرة اليوم 🎯',
    'kickoff_subtitle': 'انطلق في التشريح السريري وأسس حصيلتك الطبية بثقة واحترافية.',
    'kickoff_time_estimate': 'متبقي 45 دقيقة',
    'continue_watching_badge': 'متابعة المشاهدة',
    'start_now_badge': 'ابدأ الآن',
    'kickoff_semester_badge': 'انطلاقة الفصل الدراسي الجديد',
    'progress_percentage': 'تم مشاهدة {percentage}%',
    'time_less_than_minute': 'أقل من دقيقة',
    'time_one_minute': 'دقيقة واحدة',
    'time_two_minutes': 'دقيقتان',
    'time_n_minutes': '{count} دقائق',
    'time_remaining_one': 'متبقي دقيقة واحدة',
    'time_remaining_two': 'متبقي دقيقتان',
    'time_remaining_n': 'متبقي {count} دقيقة',
    'all_tracks': 'جميع المسارات التعليمية',
    'academic_record': 'السجل الأكاديمي',
    'saved_lessons': 'الدروس المحفوظة',
    'system_settings': 'إعدادات النظام والتفضيلات',
    'theme_mode_subtitle': 'التبديل بين الوضع الليلي والنهاري',
    'language_subtitle': 'اختر لغة واجهة التطبيق والخط',
    'retry': 'إعادة المحاولة',
    'no_notifications': 'لا توجد تنبيهات جديدة حالياً',
    'continue_lesson': 'متابعة الدرس',
    'start_anatomy': 'ابدأ بالتشريح السريري',
    'test_bank': 'بنك الأسئلة الطبي الشامل',
    'test_bank_soon': 'بنك الأسئلة الطبي الشامل متاح قريباً',
    'start_course': 'ابدأ المقرر',
    'continue_course': 'تابع المقرر',
    'lessons_count': 'دروس',
    'accredited_hours': 'ساعة تدريسية معتمدة',
    'academic_progress': 'نسبة الإنجاز الأكاديمي',
    'not_started': 'لم يبدأ',
    'in_progress': 'قيد التقدم',
    'completed': 'مكتمل',
    'course_details': 'تفاصيل الدورة',
    'lesson_player': 'مشغل الدرس',
    'next_lesson': 'الدرس التالي',
    'congratulations': 'تهانينا! 🎉',
    'course_finished_msg': 'لقد أنهيت جميع دروس هذه الدورة بنجاح.',
    'back_to_courses': 'العودة إلى الدورات',
    'lesson_completed_badge': 'تم إكمال هذا الدرس بنجاح!',
    'navigation_home': 'الرئيسية',
    'navigation_courses': 'دوراتي',
    'navigation_profile': 'الملف الشخصي',
    'welcome': 'مرحباً،',
    'continue_watching': 'متابعة المشاهدة',
    'start_now': 'ابدأ الآن',
    'resume_lesson': 'استكمال الدرس',
    'start_lesson': 'ابدأ الدرس',
    'time_remaining': 'متبقي',
    'academic_kickoff_title': 'انطلاقة الفصل الدراسي الجديد',
    'top_priority': 'أولوية قصوى',
    'academic_kickoff_action': 'انطلق في التشريح السريري',
    'dashboard': 'لوحة التحكم',
    'my_courses': 'دوراتي',
    'user_profile': 'الملف الشخصي',
    'search': 'بحث',
    'logout': 'تسجيل الخروج',
    'help': 'مساعدة',
    'about': 'عن التطبيق',
    'privacy': 'الخصوصية',
    'terms': 'الشروط والأحكام',
    'contact_us': 'اتصل بنا',
    'version': 'الإصدار',
    'feedback': 'إرسال ملاحظات',
    'loading': 'جاري التحميل...',
    'error_loading': 'حدث خطأ أثناء التحميل',
    'retry_button': 'إعادة المحاولة',
    'no_data': 'لا توجد بيانات متاحة',
    'no_internet': 'لا يوجد اتصال بالإنترنت',
    'connection_restored': 'تم استعادة الاتصال',
    'skip': 'تخطي',
    'next': 'التالي',
    'previous': 'السابق',
    'finish': 'إنهاء',
    'save': 'حفظ',
    'cancel': 'إلغاء',
    'confirm': 'تأكيد',
    'delete': 'حذف',
    'edit': 'تعديل',
    'add': 'إضافة',
    'view': 'عرض',
    'download': 'تحميل',
    'share': 'مشاركة',
    'rate': 'تقييم',
    'report': 'الإبلاغ عن مشكلة',
    'success': 'تم بنجاح',
    'error': 'خطأ',
    'warning': 'تحذير',
    'info': 'معلومة',
    'search_courses': 'ابحث في الدورات...',
    'no_search_results': 'لا توجد دورات مطابقة لبحثك',
    'search_by_title_or_instructor': 'ابحث بالعنوان أو اسم المدرس',
    'sequential_banner_title': 'مسار تعليمي متسلسل: ',
    'sequential_banner_description':
        'يُفتح كل درس تلقائياً بعد إتمام سابقه بنسبة 90% لضمان استيعاب المفاهيم الطبية والسريرية بترابط تام.',
    'completed_with_check': 'مكتمل ✓',
    'course_interactive': 'تفاعلي',
    'course_anatomy_description':
        'دراسة تطبيقية معمقة للجهازين الهيكلي والعضلي مع التركيز على الميكانيكا الحيوية والسيناريوهات السريرية لاختبارات SMLE.',
    'course_physiology_description':
        'دراسة متكاملة لوظائف أجهزة الجسم مع التركيز على التطبيقات السريرية وآليات الأمراض لاختبارات SMLE.',
    'rating_count': '({count} تقييم)',
    'enrolled_students': '+{count} طالب ملتحق',
    'semester_year_2_sem_1': 'السنة 2 · الترم 1',
    'semester_year_2_sem_2': 'السنة 2 · الترم 2',
    'plus_a_track': 'مسار +A',
    'course_preview': 'معاينة المقرر',
    'instructor_associate_professor':
        'أستاذ مشارك في العلوم الطبية السريرية',
    'academic_profile': 'الملف الأكاديمي',
    'tab_about_course': 'عن المقرر',
    'tab_lessons_content': 'الدروس والمحتوى',
    'tab_reviews_count': 'التقييمات ({count})',
    'progress_lessons': 'التقدم: {completed} من {total} دروس',
    'resume_lesson_title': 'متابعة: {title}',
    'continue_learning': 'متابعة التعلم',
    'course_not_found': 'لم يتم العثور على المقرر المطلوب.',
    'course_load_failed': 'فشل في تحميل تفاصيل المقرر. يرجى المحاولة مرة أخرى.',
    'lesson_plan': 'خطة الدروس',
    'syllabus_meta': '{lessons} دروس · {hours} ساعات',
    'expand_all': 'توسيع الكل',
    'collapse_all': 'طي الكل',
    'empty_lessons': 'لا توجد دروس مضافة لهذا المقرر حالياً.',
    'certificate_footer':
        'تمنحك منصة ذهين شهادة إتقان سريرية معتمدة عند إكمال 100% من المقرر',
    'about_overview_title': 'نظرة عامة على المقرر',
    'about_what_you_learn': 'ماذا ستتعلم في هذا المقرر:',
    'about_outcome_1':
        'استيعاب التشريح الوظيفي والميكانيكا الحيوية لأعضاء الجسم.',
    'about_outcome_2':
        'تحليل الحالات السريرية والسيناريوهات التشخيصية الواقعية.',
    'about_outcome_3':
        'التحضير الفعّال لأسئلة بنك الاختبارات والمفاهيم عالية الأهمية.',
    'reviews_verified_summary': '/ 5.0 ({count} تقييم معتمد)',
    'review_1_author': 'سارة أحمد · طالبة طب بشري',
    'review_1_body':
        'شرح رائع وواضح جداً، المقاطع مركزة ومفيدة للغاية للاختبارات السريرية.',
    'review_2_author': 'محمد خالد · امتياز طب',
    'review_2_body':
        'تسلسل المحتوى وطريقة فتح الدروس ساعدتني على الالتزام والاستيعاب بشكل ممتاز.',
    'bookmark_saved': 'تم حفظ المقرر في المفضلة',
    'bookmark_removed': 'تمت إزالة المقرر من المفضلة',
    'share_course_message': 'مشاركة المقرر ستتوفر قريباً',
    'stat_lessons': 'دروس',
    'stat_hours': 'ساعات',
    'stat_completed': 'مكتمل',
    'back': 'رجوع',
    'bookmark': 'حفظ في المفضلة',
  };

  static const Map<String, String> _en = {
    'app_title': 'Thaheen - Medical Academic Platform',
    'app_name': 'Thaheen',
    'subtitle': 'Medical Academic Platform',
    'courses': 'My Courses',
    'home': 'Home',
    'profile': 'Profile',
    'settings': 'Settings & Appearance',
    'language': 'App Language',
    'theme': 'Appearance',
    'theme_light': 'Light Mode',
    'theme_dark': 'Dark Mode',
    'theme_system': 'System Default',
    'arabic': 'العربية',
    'english': 'English',
    'student_greeting': 'Welcome Dr. Ahmed',
    'student_college': 'College of Medicine · King Saud University',
    'academic_level': '2nd Year · 1st Semester',
    'active_courses': 'Active Courses',
    'target_gpa': 'Target GPA',
    'commitment_days': 'Streak Days',
    'active_courses_section': 'Active Academic Courses',
    'available_courses': 'Available Courses',
    'available_courses_count': '{count} courses available',
    'sections_count': '{count} sections',
    'lessons_count_label': '{count} lessons',
    'kickoff_title': 'Start Your First Lecture Today 🎯',
    'kickoff_subtitle': 'Dive into Clinical Anatomy and build your medical foundation with confidence.',
    'kickoff_time_estimate': '45 minutes remaining',
    'continue_watching_badge': 'Continue Watching',
    'start_now_badge': 'Start Now',
    'kickoff_semester_badge': 'Academic Semester Kickoff',
    'progress_percentage': 'Watched {percentage}%',
    'time_less_than_minute': 'Less than a minute',
    'time_one_minute': 'One minute',
    'time_two_minutes': 'Two minutes',
    'time_n_minutes': '{count} minutes',
    'time_remaining_one': '1 minute remaining',
    'time_remaining_two': '2 minutes remaining',
    'time_remaining_n': '{count} minutes remaining',
    'all_tracks': 'All Learning Tracks',
    'academic_record': 'Academic Record',
    'saved_lessons': 'Saved Lessons',
    'system_settings': 'System Settings & Preferences',
    'theme_mode_subtitle': 'Toggle between light and dark mode',
    'language_subtitle': 'Select application interface language & typography',
    'retry': 'Retry',
    'no_notifications': 'No new notifications currently',
    'continue_lesson': 'Continue Lesson',
    'start_anatomy': 'Start Clinical Anatomy',
    'test_bank': 'Comprehensive Medical Question Bank',
    'test_bank_soon': 'Medical Question Bank is coming soon',
    'start_course': 'Start Course',
    'continue_course': 'Continue Course',
    'lessons_count': 'lessons',
    'accredited_hours': 'Accredited Credit Hours',
    'academic_progress': 'Academic Progress',
    'not_started': 'Not Started',
    'in_progress': 'In Progress',
    'completed': 'Completed',
    'course_details': 'Course Details',
    'lesson_player': 'Lesson Player',
    'next_lesson': 'Next Lesson',
    'congratulations': 'Congratulations! 🎉',
    'course_finished_msg': 'You have successfully completed all lessons in this course.',
    'back_to_courses': 'Back to Courses',
    'lesson_completed_badge': 'Lesson completed successfully!',
    'navigation_home': 'Home',
    'navigation_courses': 'My Courses',
    'navigation_profile': 'Profile',
    'welcome': 'Welcome,',
    'continue_watching': 'Continue Watching',
    'start_now': 'Start Now',
    'resume_lesson': 'Resume Lesson',
    'start_lesson': 'Start Lesson',
    'time_remaining': 'Time Remaining',
    'academic_kickoff_title': 'Academic Semester Kickoff',
    'top_priority': 'Top Priority',
    'academic_kickoff_action': 'Start Clinical Anatomy',
    'dashboard': 'Dashboard',
    'my_courses': 'My Courses',
    'user_profile': 'Profile',
    'search': 'Search',
    'logout': 'Logout',
    'help': 'Help',
    'about': 'About',
    'privacy': 'Privacy',
    'terms': 'Terms & Conditions',
    'contact_us': 'Contact Us',
    'version': 'Version',
    'feedback': 'Send Feedback',
    'loading': 'Loading...',
    'error_loading': 'Error loading data',
    'retry_button': 'Retry',
    'no_data': 'No data available',
    'no_internet': 'No internet connection',
    'connection_restored': 'Connection restored',
    'skip': 'Skip',
    'next': 'Next',
    'previous': 'Previous',
    'finish': 'Finish',
    'save': 'Save',
    'cancel': 'Cancel',
    'confirm': 'Confirm',
    'delete': 'Delete',
    'edit': 'Edit',
    'add': 'Add',
    'view': 'View',
    'download': 'Download',
    'share': 'Share',
    'rate': 'Rate',
    'report': 'Report Issue',
    'success': 'Success',
    'error': 'Error',
    'warning': 'Warning',
    'info': 'Information',
    'search_courses': 'Search courses...',
    'no_search_results': 'No courses match your search',
    'search_by_title_or_instructor': 'Search by title or instructor',
    'sequential_banner_title': 'Sequential Learning Path: ',
    'sequential_banner_description':
        'Each lesson unlocks automatically after completing the previous one with 90% to ensure complete understanding of medical and clinical concepts.',
    'completed_with_check': 'Completed ✓',
    'course_interactive': 'Interactive',
    'course_anatomy_description':
        'In-depth applied study of the skeletal and muscular systems with focus on biomechanics and clinical scenarios for SMLE exams.',
    'course_physiology_description':
        'Integrated study of body system functions with focus on clinical applications and disease mechanisms for SMLE exams.',
    'rating_count': '({count} reviews)',
    'enrolled_students': '+{count} enrolled',
    'semester_year_2_sem_1': 'Year 2 · Sem 1',
    'semester_year_2_sem_2': 'Year 2 · Sem 2',
    'plus_a_track': '+A Track',
    'course_preview': 'Course Preview',
    'instructor_associate_professor':
        'Associate Professor of Clinical Medical Sciences',
    'academic_profile': 'Academic Profile',
    'tab_about_course': 'About Course',
    'tab_lessons_content': 'Lessons & Content',
    'tab_reviews_count': 'Reviews ({count})',
    'progress_lessons': 'Progress: {completed} of {total} lessons',
    'resume_lesson_title': 'Continue: {title}',
    'continue_learning': 'Continue Learning',
    'course_not_found': 'The requested course was not found.',
    'course_load_failed': 'Failed to load course details. Please try again.',
    'lesson_plan': 'Lesson plan',
    'syllabus_meta': '{lessons} lessons · {hours} hours',
    'expand_all': 'Expand all',
    'collapse_all': 'Collapse all',
    'empty_lessons': 'No lessons have been added to this course yet.',
    'certificate_footer':
        'Thaheen awards an accredited clinical mastery certificate when you complete 100% of the course',
    'about_overview_title': 'Course overview',
    'about_what_you_learn': 'What you will learn in this course:',
    'about_outcome_1':
        'Understand functional anatomy and biomechanics of body systems.',
    'about_outcome_2':
        'Analyze clinical cases and realistic diagnostic scenarios.',
    'about_outcome_3':
        'Prepare effectively for question-bank items and high-yield concepts.',
    'reviews_verified_summary': '/ 5.0 ({count} verified reviews)',
    'review_1_author': 'Sara Ahmed · Medical student',
    'review_1_body':
        'Excellent and clear teaching. The clips are focused and very useful for clinical exams.',
    'review_2_author': 'Mohammed Khaled · Medical intern',
    'review_2_body':
        'The content sequence and sequential unlocks helped me stay consistent and absorb the material.',
    'bookmark_saved': 'Course saved to bookmarks',
    'bookmark_removed': 'Course removed from bookmarks',
    'share_course_message': 'Course sharing will be available soon',
    'stat_lessons': 'Lessons',
    'stat_hours': 'Hours',
    'stat_completed': 'Completed',
    'back': 'Back',
    'bookmark': 'Save to bookmarks',
  };
}
