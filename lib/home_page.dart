import 'package:demo2/calculator_page.dart';
import 'package:demo2/money_share/money_share_page.dart';
import 'package:demo2/money_share/page/list_group_page.dart';
import 'package:demo2/sudoku/sudoku_page.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Trang chu")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Chon module",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Quan ly chia tien va dung may tinh nhanh.",
              style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.05,
                children: [
                  _ModuleCard(
                    title: "Sudoku",
                    subtitle: "Game Sudoku",
                    icon: Icons.gamepad,
                    iconColor: const Color(0xFF2FED28),
                    iconBackground: const Color(0xFFDBEAFE),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const SudokuPage()),
                      );
                    },
                  ),
                  _ModuleCard(
                    title: "Chia tien",
                    subtitle: "Nhap khoan chi/thu theo thanh vien",
                    icon: Icons.paid_rounded,
                    iconColor: const Color(0xFF2563EB),
                    iconBackground: const Color(0xFFDBEAFE),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const MoneySharePage(),
                        ),
                      );
                    },
                  ),
                  _ModuleCard(
                    title: "Danh sach nhom",
                    subtitle: "Xem cac nhom da luu trong Hive",
                    icon: Icons.groups_2_rounded,
                    iconColor: const Color(0xFF0F766E),
                    iconBackground: const Color(0xFFCCFBF1),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const ListGroupPage(),
                        ),
                      );
                    },
                  ),
                  _ModuleCard(
                    title: "May tinh",
                    subtitle: "Cong, tru, nhan, chia co ban",
                    icon: Icons.calculate_rounded,
                    iconColor: const Color(0xFF7C3AED),
                    iconBackground: const Color(0xFFEDE9FE),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const CalculatorPage(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModuleCard extends StatelessWidget {
  const _ModuleCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconBackground,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor),
              ),
              const Spacer(),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  color: Color(0xFF0F172A),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF64748B),
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
