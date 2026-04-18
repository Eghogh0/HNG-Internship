import 'package:flutter/material.dart';
import 'converter_logic.dart';

class ConverterScreen extends StatefulWidget {
  const ConverterScreen({super.key});

  @override
  State<ConverterScreen> createState() => _ConverterScreenState();
}

class _ConverterScreenState extends State<ConverterScreen> {
  String type = "Length";
  String from = "Meter";
  String to = "Kilometer";
  double input = 0;
  double result = 0;

  List<String> getUnits() {
    switch (type) {
      case "Length":
        return ["Meter", "Kilometer", "Centimeter"];
      case "Weight":
        return ["Gram", "Kilogram"];
      case "Temperature":
        return ["Celsius", "Fahrenheit"];
      case "Currency":
        return ["NGN", "USD"];
      default:
        return [];
    }
  }

  void convert() {
    setState(() {
      result = ConverterLogic.convert(type, input, from, to);
    });
  }

  @override
  Widget build(BuildContext context) {
    final units = getUnits();

    return Scaffold(
      appBar: AppBar(title: const Text("Unit Converter")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButtonFormField(
              initialValue: type,
              items: ["Length", "Weight", "Temperature", "Currency"]
                  .map((e) => DropdownMenuItem(
                        value: e,
                        child: Text(e),
                      ))
                  .toList(),
              onChanged: (val) {
                setState(() {
                  type = val!;
                  from = getUnits().first;
                  to = getUnits().last;
                });
              },
            ),
            const SizedBox(height: 20),

            TextField(
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Enter value"),
              onChanged: (val) {
                input = double.tryParse(val) ?? 0;
              },
            ),

            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField(
                    initialValue: from,
                    items: units
                        .map((e) =>
                            DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (val) => setState(() => from = val!),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: DropdownButtonFormField(
                    initialValue: to,
                    items: units
                        .map((e) =>
                            DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (val) => setState(() => to = val!),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: convert,
              child: const Text("Convert"),
            ),

            const SizedBox(height: 20),

            Text(
              "Result: $result",
              style: const TextStyle(fontSize: 22),
            ),
          ],
        ),
      ),
    );
  }
}