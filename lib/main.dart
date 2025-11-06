import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:job_connect/config/providers/text_size_provider.dart';
import 'package:job_connect/config/providers/theme_provider.dart';
import 'package:job_connect/config/services/shared_prefs_service.dart';
import 'package:job_connect/features/auth/viewmodel/auth_view_model.dart';
import 'package:job_connect/features/company/viewmodel/company_view_model.dart';
import 'package:job_connect/features/home/view_model/job_saved_view_model.dart';
import 'package:job_connect/features/home/view_model/podcast_view_model.dart';
import 'package:job_connect/features/job/view_model/job_application_view_model.dart';
import 'package:job_connect/features/mini_social/view_model/social_comment_view_model.dart';
import 'package:job_connect/features/mini_social/view_model/social_post_view_model.dart';
import 'package:job_connect/features/mini_social/view_model/social_save_post_view_model.dart';
import 'package:job_connect/features/notifications/viewmodel/notification_view_model.dart';
import 'package:job_connect/features/profile/view_model/candidate_info_view_model.dart';
import 'package:job_connect/features/profile/view_model/user_view_model.dart';
import 'package:job_connect/features/resume/view_model/resum_view_model.dart';
import 'package:job_connect/my_app.dart';
import 'package:job_connect/supabase/supabase_config.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await SupabaseConfig.init();
  SharedPreferences prefs = await SharedPreferences.getInstance();

  runApp(
    MultiProvider(
      providers: [
        // TODO: MANAGER SYSTEM
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => TextSizeProvider()),

        // TODO: MANAGER LOGIC
        ChangeNotifierProvider(create: (_) => AuthViewModel(prefs: SharedPrefsService(prefs: prefs))),
        ChangeNotifierProvider(create: (_) => CompanyViewModel()),  
        ChangeNotifierProvider(create: (_) => PodcastViewModel()),
        ChangeNotifierProvider(create: (_) => NotificationViewModel()),
        ChangeNotifierProvider(create: (_) => UserViewModel()),
        ChangeNotifierProvider(create: (_) => CandidateInfoViewModel()),
        ChangeNotifierProvider(create: (_) => ResumeViewModel()),
        ChangeNotifierProvider(create: (_) => JobSavedViewModel()),
        ChangeNotifierProvider(create: (_) => JobApplicationViewModel()),
        
        // TODO: SOCIAL
        ChangeNotifierProvider(create: (_) => SocialPostViewModel(prefs: SharedPrefsService(prefs: prefs))),
        ChangeNotifierProvider(create: (_) => SocialCommentViewModel()),
        ChangeNotifierProvider(create: (_) => SocialSavePostViewModel(prefs: SharedPrefsService(prefs: prefs))),

      ],
      child: MyApp(),
    ),
  );
}