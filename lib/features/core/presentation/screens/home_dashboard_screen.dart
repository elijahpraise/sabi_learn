
import 'package:flutter/material.dart';

class HomeDashboardScreen extends StatelessWidget {
  const HomeDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const CircleAvatar(
              backgroundImage: NetworkImage(
                  'https://lh3.googleusercontent.com/aida-public/AB6AXuCYQK1QHgr9RpicyjW3qwkAMX0LU5gXx0OLyUG-AmPUmvKworL3A7nBMKkVPxssh1KmFSvwzU-ZMZCT7EtDekPmje4JIdZuMb_bUs3ghnkAQW_ruSJooylYN5hDSiTMjCR1VsyLDX5b-5gPSMwwxl52qEX15jlvatfdQPoI4xY0p-pnNhSxE1yBnThMgH98uukNN482ysk6XDtkZlyqXx3HGU1J6A0vDP0ropHsSAuoWMI3ccirH1RWOW8KTYLjgtvl8gsZivitJNcA'),
            ),
            const SizedBox(width: 12),
            Text(
              'SabiLearn',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.cloud_off),
            onPressed: () {},
          ),
        ],
        backgroundColor: Theme.of(context).colorScheme.surface.withOpacity(0.8),
      ),
      body: Row(
        children: [
          const _DesktopNavigation(),
          const Expanded(child: _MainContent()),
        ],
      ),
      bottomNavigationBar: const _MobileBottomNav(),
    );
  }
}

class _DesktopNavigation extends StatelessWidget {
  const _DesktopNavigation();

  @override
  Widget build(BuildContext context) {
    // This is hidden on mobile, so we check the screen width
    if (MediaQuery.of(context).size.width < 768) {
      return const SizedBox.shrink();
    }

    return Container(
      width: 256,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        border: Border(right: BorderSide(color: Theme.of(context).dividerColor.withOpacity(0.2))),
      ),
      child: Column(
        children: const [
          _NavItem(icon: Icons.home, label: 'Home', isActive: true),
          _NavItem(icon: Icons.school, label: 'Learn'),
          _NavItem(icon: Icons.auto_stories, label: 'Exams'),
          _NavItem(icon: Icons.person, label: 'Profile'),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    this.isActive = false,
  });

  final IconData icon;
  final String label;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
        color: isActive ? theme.colorScheme.primaryContainer.withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(28),
        child: InkWell(
      onTap: (){},
      borderRadius: BorderRadius.circular(28),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: isActive ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant, fill: isActive ? 1.0 : 0.0),
            const SizedBox(width: 16),
            Text(
              label,
              style: TextStyle(
                color: isActive ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    ),);
  }
}

class _MainContent extends StatelessWidget {
  const _MainContent();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24.0),
      children: const [
        _WelcomeSection(),
        SizedBox(height: 32),
        _QuickActions(),
        SizedBox(height: 32),
        _ProgressOverview(),
        SizedBox(height: 32),
        _RecentlyStudied(),
      ],
    );
  }
}

class _WelcomeSection extends StatelessWidget {
  const _WelcomeSection();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Good morning, Elijah 👋',
              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('Ready to conquer your goals today?', style: TextStyle(fontSize: 18)),
          ],
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1B6D24).withOpacity(0.08),
                blurRadius: 32,
                offset: const Offset(0, 12),
              )
            ]
          ),
          child: Row(
            children: [
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondaryContainer,
                  shape: BoxShape.circle
                ),
                child: Icon(Icons.local_fire_department, color: theme.colorScheme.onSecondaryContainer, size: 28),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('14 Days', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  const Text('Current Streak', style: TextStyle(fontSize: 12)),
                ],
              )
            ],
          ),
        )
      ],
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions();

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 4,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1,
      children: const [
        _QuickActionButton(icon: Icons.psychology, label: 'Ask AI Tutor', color: Color(0xFF00569F)),
        _QuickActionButton(icon: Icons.play_arrow, label: 'Continue Learning', isPrimary: true),
        _QuickActionButton(icon: Icons.quiz, label: 'Take Quiz', color: Color(0xFF8B5000)),
        _QuickActionButton(icon: Icons.history_edu, label: 'Practice Exams', color: Color(0xFF0D631B)),
      ],
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  const _QuickActionButton({
    required this.icon,
    required this.label,
    this.color,
    this.isPrimary = false,
  });

  final IconData icon;
  final String label;
  final Color? color;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        backgroundColor: isPrimary ? theme.colorScheme.primary : theme.colorScheme.surface,
        foregroundColor: isPrimary ? theme.colorScheme.onPrimary : color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        shadowColor: isPrimary ? const Color(0xFF1B6D24).withOpacity(0.2) : null,
        elevation: isPrimary ? 8 : 1,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
           Container(
             width: 48, height: 48,
             decoration: BoxDecoration(
               shape: BoxShape.circle,
               color: isPrimary ? theme.colorScheme.onPrimary.withOpacity(0.2) : color?.withOpacity(0.1)
             ),
             child: Icon(icon, size: 28, fill: 1.0, color: isPrimary ? theme.colorScheme.onPrimary : color),
           ),
          const SizedBox(height: 12),
          Text(label, textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, color: isPrimary ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface)),
        ],
      ),
    );
  }
}

class _ProgressOverview extends StatelessWidget {
  const _ProgressOverview();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Weekly Goal', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
              Chip(
                label: const Text('65% Completed'),
                backgroundColor: theme.colorScheme.primaryContainer.withOpacity(0.1),
                labelStyle: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold),
              )
            ],
          ),
          const SizedBox(height: 24),
          const LinearProgressIndicator(value: 0.65, minHeight: 6, borderRadius: BorderRadius.all(Radius.circular(3))),
           const SizedBox(height: 24),
           GridView.count(
             shrinkWrap: true,
             crossAxisCount: 3,
             crossAxisSpacing: 16,
             mainAxisSpacing: 16,
             childAspectRatio: 2.5,
             children: const [
               _ProgressStat(icon: Icons.menu_book, label: 'Modules', value: '12', total: '20', color: Color(0xFF00569F)),
               _ProgressStat(icon: Icons.timer, label: 'Study Time', value: '4.5', total: 'hrs', color: Color(0xFF8B5000)),
                _ProgressStat(icon: Icons.task_alt, label: 'Quizzes', value: '8', total: 'passed', color: Color(0xFF0D631B)),
             ],
           )
        ],
      ),
    );
  }
}


class _ProgressStat extends StatelessWidget {
  const _ProgressStat({
    required this.icon,
    required this.label,
    required this.value,
    required this.total,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final String total;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
           BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color),
              const SizedBox(width: 8),
              Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
           const SizedBox(height: 8),
           RichText(
             text: TextSpan(
               style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
               children: [
                 TextSpan(text: value),
                 TextSpan(text: ' / $total', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant))
               ]
             ),
           )
        ],
      ),
    );
  }
}

class _RecentlyStudied extends StatelessWidget {
  const _RecentlyStudied();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Recently Studied', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
            TextButton(onPressed: (){}, child: const Text('View All')),
          ],
        ),
         const SizedBox(height: 16),
         GridView.count(
           shrinkWrap: true,
           crossAxisCount: 3,
           crossAxisSpacing: 16,
           mainAxisSpacing: 16,
           childAspectRatio: 0.8,
           children: const [
              _StudyCard(
               imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuBNoio1HT2W809EUKByPDbpAAaEO7lX7U6wFEsHRtF76uYLtP7H4Q-0o_NZdjFpgob_DvsKPU-KdvYv2psjCKTdGq_FfxFlZRYmO6WTpQaJnCiQlkAdFVfRc-sLB9k0vUX_zc1cwQ-GmsOJ7EAi1D0yofcByqFHCQWD5scC59WGMo6aEmn5SHyKW__ixgeLW8ZVw6crUYimOz_3_zxiWRZ3wTUB177NXLjRovYE1G7jRVPPk5VYAEd2yV8kZ5bSKLIT3bzEkgIISJpS',
               title: 'Quantum Mechanics Fundamentals',
               course: 'Physics 101',
               timeLeft: '15m left',
               progress: 0.8, 
               color: Color(0xFF00569F),
             ),
             _StudyCard(
               imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuAdozf9gwqy9M6htZ22I4HvbSt-4mgtUwoeAxigDgoFqMrjeJMbHi-vMO1kvY-2y1urx57WczTsrnIe53z8_OlERFoElp4NQTedw9G_Y1ZPO2aoPpr3vOHmii3e7PxyGImaus4OWWpqiDOE-Pz3ccsZYwVOhXeRRKZxPB2ZciJKcyPImg8EklBOBddwhNbzFC3J3mlpfTgQ-MQwcjx-y7vPsH7iBXDuu-Jnn4ZVQqZDtsY-4c5owUJAmqHmbP7g0bh_-JiY2YVLqz2z',
               title: 'Data Structures: Binary Trees',
               course: 'CS 204',
               timeLeft: '45m left',
               progress: 0.3, 
               color: Color(0xFF0D631B),
             ),
             _StudyCard(
               imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuC4ifGOAP-Y1BtHeKvC7OmdB7XW0V25qFUfbmQi9UbcT-NSNv-jaFEU-hQgcX2WGSCNO0w7P8kuTSsFWtLHWheFP2VPTMPmsf6Q55_gKw0JvHj6JkqPWo2ERHR4zB0TuxNx0wvRU_jBZ8iSIGmwkC00H0sLpM_kDyo1qQn-2_u5BNVjW15yMNfsuJ4JR-_sqC2R5NdHO6ys2JlnxARxXb4oofjgGqLVRu0s3RsRV-dccWSZqFCgrrJNviv1FRVcd_sQGRalINWhPV6-',
               title: 'Macroeconomic Policy',
               course: 'ECON 301',
               timeLeft: '5m left',
               progress: 0.95, 
               color: Color(0xFF8B5000),
             ),
           ],
         )
      ],
    );
  }
}

class _StudyCard extends StatelessWidget {
  const _StudyCard({
    required this.imageUrl,
    required this.title,
    required this.course,
    required this.timeLeft,
    required this.progress,
    required this.color,
  });

  final String imageUrl;
  final String title;
  final String course;
  final String timeLeft;
  final double progress;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 1,
      shadowColor: const Color(0xFF1B6D24).withOpacity(0.02),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 128,
            width: double.infinity,
            child: Image.network(imageUrl, fit: BoxFit.cover),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Chip(
                  label: Text(course),
                  backgroundColor: color.withOpacity(0.1),
                  labelStyle: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 10),
                ),
                const SizedBox(height: 8),
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 16),
                 Row(
                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                   children: [
                     Text(timeLeft, style: const TextStyle(fontSize: 12)),
                     SizedBox(
                       width: 64,
                       child: LinearProgressIndicator(value: progress, minHeight: 6, borderRadius: const BorderRadius.all(Radius.circular(3)))
                     )
                   ],
                 )
              ],
            ),
          ),
        ],
      ),
    );
  }
}


class _MobileBottomNav extends StatelessWidget {
  const _MobileBottomNav();

  @override
  Widget build(BuildContext context) {
    // This is hidden on desktop, so we check the screen width
    if (MediaQuery.of(context).size.width >= 768) {
      return const SizedBox.shrink();
    }
    return BottomNavigationBar(
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.school),
          label: 'Learn',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.auto_stories),
          label: 'Exams',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
      currentIndex: 0, // Set the current index
      onTap: (index) {},
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Theme.of(context).colorScheme.primary,
    );
  }
}
