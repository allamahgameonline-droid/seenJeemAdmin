import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../widgets/stat_card.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final FirestoreService _firestoreService = FirestoreService();
  Map<String, dynamic>? stats;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final data = await _firestoreService.getDashboardStats();
    setState(() {
      stats = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Dashboard',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 24),
            if (stats == null)
              const Center(child: CircularProgressIndicator())
            else
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 4,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 2,
                children: [
                  StatCard(
                    title: 'Total Users',
                    value: stats!['totalUsers'].toString(),
                    icon: Icons.people,
                    color: Colors.blue,
                  ),
                  StatCard(
                    title: 'Total Games',
                    value: stats!['totalGames'].toString(),
                    icon: Icons.gamepad,
                    color: Colors.green,
                  ),
                  StatCard(
                    title: 'Total Questions',
                    value: stats!['totalQuestions'].toString(),
                    icon: Icons.question_answer,
                    color: Colors.orange,
                  ),
                  StatCard(
                    title: 'Total Revenue',
                    value: '\$${stats!['totalRevenue'].toStringAsFixed(2)}',
                    icon: Icons.attach_money,
                    color: Colors.red,
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
