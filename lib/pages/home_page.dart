import 'package:flutter/material.dart';
import '../widgets/sidebar.dart';
import 'dashboard_page.dart';
import 'users_page.dart';
import 'games_page.dart';
import 'categories_page.dart';
import 'questions_page.dart';
import 'payments_page.dart';
import 'settings_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _currentPage = 'dashboard';

  Widget _getPage() {
    switch (_currentPage) {
      case 'dashboard':
        return const DashboardPage();
      case 'users':
        return const UsersPage();
      case 'games':
        return const GamesPage();
      case 'categories':
        return const CategoriesPage();
      case 'questions':
        return const QuestionsPage();
      case 'payments':
        return const PaymentsPage();
      case 'settings':
        return const SettingsPage();
      default:
        return const DashboardPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Sidebar(
            currentPage: _currentPage,
            onPageChange: (page) {
              setState(() {
                _currentPage = page;
              });
            },
          ),
          Expanded(
            child: _getPage(),
          ),
        ],
      ),
    );
  }
}
