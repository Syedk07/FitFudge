import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/workout_provider.dart';
import '../../ui/theme/app_theme.dart';
import 'dashboard_screen.dart';
import 'exercise_library_screen.dart';
import 'workout_templates_screen.dart';
import 'workout_history_screen.dart';
import 'profile_screen.dart';
import 'active_workout_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  static const List<Widget> _screens = [
    DashboardScreen(),
    ExerciseLibraryScreen(),
    WorkoutTemplatesScreen(),
    WorkoutHistoryScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final workoutProvider = context.watch<WorkoutProvider>();
    // Bottom nav height varies by platform and device (home indicator on iPhone).
    final bottomNavHeight = kBottomNavigationBarHeight +
        MediaQuery.of(context).padding.bottom;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      // Keep status-bar icons light on the dark brand background.
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light, // Android
        statusBarBrightness: Brightness.dark,       // iOS
        systemNavigationBarColor: AppColors.surface,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        body: Stack(
          children: [
            // Main content occupies full Scaffold body.
            _screens[_currentIndex],

            // Active-workout banner floats just above the bottom nav bar.
            // Accounts for the variable bottom-nav height (inc. iPhone home bar).
            if (workoutProvider.isWorkoutActive)
              Positioned(
                bottom: bottomNavHeight + 8,
                left: 12,
                right: 12,
                child: _ActiveWorkoutBanner(
                  templateName:
                      workoutProvider.activeTemplate?.name ?? 'Active Workout',
                  elapsed: workoutProvider.elapsedSeconds,
                ),
              ),
          ],
        ),
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(
            border: Border(
                top: BorderSide(color: AppColors.border, width: 0.5)),
          ),
          // SafeArea wraps the nav bar so content clears the home indicator
          // on iPhone X+ and equivalent Android gesture-nav devices.
          child: SafeArea(
            top: false,
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (index) => setState(() => _currentIndex = index),
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.dashboard_outlined),
                  activeIcon: Icon(Icons.dashboard),
                  label: 'Dashboard',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.search_outlined),
                  activeIcon: Icon(Icons.search),
                  label: 'Exercises',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.list_alt_outlined),
                  activeIcon: Icon(Icons.list_alt),
                  label: 'Workouts',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.history_outlined),
                  activeIcon: Icon(Icons.history),
                  label: 'History',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person_outline),
                  activeIcon: Icon(Icons.person),
                  label: 'Profile',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Active Workout Banner ────────────────────────────────────────────────────

class _ActiveWorkoutBanner extends StatelessWidget {
  final String templateName;
  final int elapsed;

  const _ActiveWorkoutBanner({
    required this.templateName,
    required this.elapsed,
  });

  String _formatTime(int s) {
    final m = s ~/ 60;
    final sec = s % 60;
    return '${m.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const ActiveWorkoutScreen()),
      ),
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          // Use the brand primary (deep brown) as the banner background
          // so it reads as a native in-app action surface.
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: AppColors.secondary.withValues(alpha: 0.5),
              width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.play_circle_filled,
                color: AppColors.secondary, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    templateName,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'Tap to return to workout',
                    style: TextStyle(
                      color: AppColors.textSecondary
                          .withValues(alpha: 0.8),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              _formatTime(elapsed),
              style: const TextStyle(
                color: AppColors.secondary,
                fontWeight: FontWeight.w800,
                fontSize: 18,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
