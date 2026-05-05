import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weather_forecast_app/main.dart';
import 'package:weather_forecast_app/widgets/shimmer_loading.dart';

void main() {
  testWidgets('App shows loading indicator on start', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    // On home screen, initially shows shimmer while loading
    expect(find.byType(ShimmerLoading), findsOneWidget);
  });
}