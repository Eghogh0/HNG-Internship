import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerLoading extends StatelessWidget {
  const ShimmerLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(height: 20, width: 150, color: Colors.white),
            const SizedBox(height: 20),
            Container(height: 100, width: double.infinity, decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(12),
            )),
            const SizedBox(height: 20),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: List.generate(4, (_) => Container(height: 60, width: 70, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8))))),
          ],
        ),
      ),
    );
  }
}