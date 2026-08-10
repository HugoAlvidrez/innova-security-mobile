import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/chat_provider.dart';
import 'theme/app_theme.dart';
import 'screens/home/home_screen.dart';
import 'screens/evidence/evidence_list_screen.dart';
import 'screens/chat/chat_screen.dart';
import 'screens/notes/notes_screen.dart';
import 'screens/profile/profile_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  static const List<Widget> _screens = [
    HomeScreen(),
    EvidenceListScreen(),
    ChatScreen(),
    NotesScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      // FAB de emergencia solo visible en Inicio
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton.extended(
              heroTag: 'emergency_fab',
              onPressed: () => Navigator.pushNamed(context, '/emergency'),
              backgroundColor: AppColors.emergency,
              foregroundColor: Colors.white,
              elevation: 6,
              icon: const Icon(Icons.warning_rounded),
              label: const Text(
                'EMERGENCIA',
                style: TextStyle(fontWeight: FontWeight.w700, letterSpacing: 0.8),
              ),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: Consumer<ChatProvider>(
        builder: (_, chat, __) => BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (i) {
            if (i == 2) chat.markAllAsRead();
            setState(() => _currentIndex = i);
          },
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Inicio',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.shield_outlined),
              activeIcon: Icon(Icons.shield),
              label: 'Eventos',
            ),
            BottomNavigationBarItem(
              icon: Badge(
                isLabelVisible: chat.unreadCount > 0,
                label: Text('${chat.unreadCount}'),
                child: const Icon(Icons.chat_bubble_outline),
              ),
              activeIcon: Badge(
                isLabelVisible: chat.unreadCount > 0,
                label: Text('${chat.unreadCount}'),
                child: const Icon(Icons.chat_bubble),
              ),
              label: 'Chat',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.event_note_outlined),
              activeIcon: Icon(Icons.event_note),
              label: 'Notas',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Perfil',
            ),
          ],
        ),
      ),
    );
  }
}
