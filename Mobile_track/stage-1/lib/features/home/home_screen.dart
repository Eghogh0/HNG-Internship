import 'package:flutter/material.dart';
import '../../core/widgets/tool_card.dart';
import '../unit_converter/converter_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Smart Utility Toolkit")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.count(
          crossAxisCount: 2,
          children: [
            ToolCard(
              title: "Unit Converter",
              icon: Icons.swap_horiz,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ConverterScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}