class ConverterLogic {
  static double convert(
    String type,
    double value,
    String from,
    String to,
  ) {
    if (type == "Length") {
      Map<String, double> units = {
        "Meter": 1,
        "Kilometer": 1000,
        "Centimeter": 0.01,
      };
      return value * units[from]! / units[to]!;
    }

    if (type == "Weight") {
      Map<String, double> units = {
        "Gram": 1,
        "Kilogram": 1000,
      };
      return value * units[from]! / units[to]!;
    }

    if (type == "Temperature") {
      if (from == "Celsius" && to == "Fahrenheit") {
        return (value * 9 / 5) + 32;
      }
      if (from == "Fahrenheit" && to == "Celsius") {
        return (value - 32) * 5 / 9;
      }
    }

    if (type == "Currency") {
      Map<String, double> rates = {
        "NGN": 1,
        "USD": 1500,
      };
      return value * rates[from]! / rates[to]!;
    }

    return value;
  }
}